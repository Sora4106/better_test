using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace BetterWaifuPwaPublisher
{
    internal sealed class PublisherEngine
    {
        private static readonly string[] VersionFiles =
        {
            "version.json",
            "CHANGELOG.md",
            "flutter_pwa/lib/app_version.dart",
            "flutter_pwa/pubspec.yaml"
        };

        public PublishResult Publish(
            PublisherOptions options,
            Action<string> log,
            Action<int, string> progress)
        {
            if (log == null) log = delegate { };
            if (progress == null) progress = delegate { };

            progress(3, "檢查設定與 Git 工作樹");
            string repository = NormalizeExistingDirectory(options.RepositoryDirectory, "Git 專案目錄");
            string pwaDirectory = NormalizeExistingDirectory(options.PwaDirectory, "PWA 專案目錄");
            EnsureInside(repository, pwaDirectory, "PWA 專案目錄必須位於 Git 專案內。");
            RequireFile(Path.Combine(pwaDirectory, "pubspec.yaml"), "PWA 目錄缺少 pubspec.yaml。");
            RequireFile(Path.Combine(repository, ".git", "HEAD"), "選擇的目錄不是 Git 工作樹根目錄。");
            RequireFile(Path.Combine(repository, "tools", "update-version.ps1"), "專案缺少 tools/update-version.ps1。");
            RequireFile(Path.Combine(repository, "tools", "update-pwa-cache.ps1"), "專案缺少 tools/update-pwa-cache.ps1。");

            string remote = (options.RemoteName ?? string.Empty).Trim();
            string branch = (options.BranchName ?? string.Empty).Trim();
            if (remote.Length == 0) throw new InvalidOperationException("Git remote 不可空白。");
            if (branch.Length == 0) throw new InvalidOperationException("Git 分支不可空白。");

            string git = FindTool("git.exe");
            string powershell = FindTool("powershell.exe");
            string flutter = FindTool("flutter.bat");
            log("Git：" + git);
            log("Flutter：" + flutter);

            string rootFromGit = RunRequired(
                git,
                new[] { "rev-parse", "--show-toplevel" },
                repository,
                log,
                "無法確認 Git 工作樹根目錄。").Output.Trim();
            if (!PathsEqual(repository, rootFromGit))
            {
                throw new InvalidOperationException(
                    "Git 根目錄實際是「" + rootFromGit + "」，請直接選擇該目錄。");
            }

            CommandResult staged = RunRequired(
                git,
                new[] { "diff", "--cached", "--name-only" },
                repository,
                log,
                "無法檢查 staged 內容。");
            if (!string.IsNullOrWhiteSpace(staged.Output))
            {
                throw new InvalidOperationException(
                    "Git index 已有 staged 檔案。為避免混入其他修改，請先提交或取消暫存後再使用本工具。\r\n" +
                    staged.Output);
            }

            string currentBranch = RunRequired(
                git,
                new[] { "branch", "--show-current" },
                repository,
                log,
                "無法讀取目前分支。").Output.Trim();
            if (!string.Equals(currentBranch, branch, StringComparison.Ordinal))
            {
                throw new InvalidOperationException(
                    "目前分支是「" + currentBranch + "」，設定要上傳的是「" + branch + "」。本工具不會自動切換分支。");
            }

            RunRequired(
                git,
                new[] { "remote", "get-url", remote },
                repository,
                log,
                "找不到 Git remote「" + remote + "」。");

            string userName = RunRequired(
                git,
                new[] { "config", "user.name" },
                repository,
                log,
                "Git user.name 尚未設定。").Output.Trim();
            string userEmail = RunRequired(
                git,
                new[] { "config", "user.email" },
                repository,
                log,
                "Git user.email 尚未設定。").Output.Trim();
            if (userName.Length == 0 || userEmail.Length == 0)
            {
                throw new InvalidOperationException("請先設定 Git user.name 與 user.email。");
            }

            progress(9, "同步遠端狀態");
            RunRequired(
                git,
                new[] { "fetch", remote, branch },
                repository,
                log,
                "無法抓取遠端狀態，請檢查網路與 GitHub 權限。");
            string divergence = RunRequired(
                git,
                new[] { "rev-list", "--left-right", "--count", "HEAD..." + remote + "/" + branch },
                repository,
                log,
                "無法比較本地與遠端分支。").Output.Trim();
            int localAhead;
            int remoteAhead;
            ParseDivergence(divergence, out localAhead, out remoteAhead);
            if (remoteAhead > 0)
            {
                throw new InvalidOperationException(
                    "遠端分支比本地多 " + remoteAhead + " 個提交。為避免覆蓋他人修改，請先人工整合遠端內容。");
            }

            List<string> selected = BuildSelectedPathspecs(repository, pwaDirectory, options.SelectedPaths);
            bool hasSelectedChanges = HasSelectedChanges(git, repository, selected, log);
            if (!hasSelectedChanges)
            {
                if (localAhead > 0)
                {
                    progress(70, "重試推送既有本地提交");
                    log("選取的 PWA 路徑沒有新修改；偵測到本地尚有 " + localAhead + " 個未推送提交，直接重試 push。");
                    RunRequired(
                        git,
                        new[] { "push", remote, branch },
                        repository,
                        log,
                        "Git push 失敗。提交仍安全保留在本地，可修正登入或網路後重試。");
                    return new PublishResult
                    {
                        VersionLabel = ReadVersionLabel(repository),
                        CommitHash = RunRequired(git, new[] { "rev-parse", "HEAD" }, repository, log, "無法讀取 HEAD。").Output.Trim(),
                        PushedExistingCommitOnly = true
                    };
                }

                log("選取的 PWA 路徑目前沒有 Git 差異；仍會追加版本編號並重新建置、發布。");
            }

            Dictionary<string, byte[]> versionBackup = BackupVersionFiles(repository);
            bool versionUpdated = false;
            bool stagedByApplication = false;
            bool committed = false;
            try
            {
                progress(16, "自動追加版本編號");
                string note = (options.ReleaseNote ?? string.Empty).Trim();
                if (note.Length == 0) note = "管理員桌面工具單鍵發布 PWA";
                RunRequired(
                    powershell,
                    new[]
                    {
                        "-NoProfile",
                        "-ExecutionPolicy", "Bypass",
                        "-File", Path.Combine(repository, "tools", "update-version.ps1"),
                        "-Notes", note
                    },
                    repository,
                    log,
                    "自動升版失敗。");
                versionUpdated = true;
                string versionLabel = ReadVersionLabel(repository);
                log("新版本：" + versionLabel);

                if (options.RunAnalyze)
                {
                    progress(28, "執行 Flutter analyze");
                    RunBatchRequired(
                        flutter,
                        new[] { "analyze" },
                        pwaDirectory,
                        log,
                        "Flutter analyze 失敗，已停止上傳。");
                }

                if (options.BuildWeb)
                {
                    progress(43, "建置 Flutter Web PWA");
                    RunBatchRequired(
                        flutter,
                        new[] { "build", "web", "--release" },
                        pwaDirectory,
                        log,
                        "Flutter Web 建置失敗，已停止上傳。");
                }

                if (options.UpdatePwaCache)
                {
                    if (!options.BuildWeb && !Directory.Exists(Path.Combine(pwaDirectory, "build", "web")))
                    {
                        throw new InvalidOperationException("尚未建置 build/web，無法更新 PWA 快取。");
                    }
                    progress(60, "更新 PWA 快取版本");
                    string buildRelative = ToRepositoryPath(repository, Path.Combine(pwaDirectory, "build", "web"));
                    RunRequired(
                        powershell,
                        new[]
                        {
                            "-NoProfile",
                            "-ExecutionPolicy", "Bypass",
                            "-File", Path.Combine(repository, "tools", "update-pwa-cache.ps1"),
                            "-BuildDirectory", buildRelative
                        },
                        repository,
                        log,
                        "PWA 快取版號更新失敗，已停止上傳。");
                }

                progress(68, "檢查並暫存指定檔案");
                List<string> stagePaths = new List<string>(selected);
                foreach (string versionFile in VersionFiles)
                {
                    if (!stagePaths.Contains(versionFile, StringComparer.OrdinalIgnoreCase))
                        stagePaths.Add(versionFile);
                }

                List<string> diffCheckArgs = new List<string> { "diff", "--check", "--" };
                diffCheckArgs.AddRange(stagePaths);
                RunRequired(git, diffCheckArgs, repository, log, "檔案含有 Git 空白錯誤，已停止上傳。");

                List<string> addArgs = new List<string> { "add", "--" };
                addArgs.AddRange(stagePaths);
                RunRequired(git, addArgs, repository, log, "Git add 失敗。");
                stagedByApplication = true;
                RunRequired(git, new[] { "diff", "--cached", "--check" }, repository, log, "staged 差異檢查失敗。");

                CommandResult cachedNames = RunRequired(
                    git,
                    new[] { "diff", "--cached", "--name-only" },
                    repository,
                    log,
                    "無法讀取 staged 檔案。");
                if (string.IsNullOrWhiteSpace(cachedNames.Output))
                    throw new InvalidOperationException("沒有可提交的檔案。");
                log("即將提交：\r\n" + cachedNames.Output);

                progress(78, "建立 Git 提交");
                string commitMessage = "release: publish BetterWaifu PWA " + versionLabel;
                RunRequired(
                    git,
                    new[] { "commit", "-m", commitMessage },
                    repository,
                    log,
                    "Git commit 失敗；檔案仍保留且可能已 staged，請查看紀錄後處理。");
                committed = true;

                string commitHash = RunRequired(
                    git,
                    new[] { "rev-parse", "HEAD" },
                    repository,
                    log,
                    "無法讀取新提交雜湊。").Output.Trim();

                progress(88, "推送至 GitHub");
                RunRequired(
                    git,
                    new[] { "push", remote, branch },
                    repository,
                    log,
                    "Git push 失敗。新提交已安全保留在本地；修正登入或網路後再次按按鈕即可重試推送。");

                progress(100, "完成");
                return new PublishResult
                {
                    VersionLabel = versionLabel,
                    CommitHash = commitHash,
                    PushedExistingCommitOnly = false
                };
            }
            catch
            {
                if (versionUpdated && !stagedByApplication && !committed)
                {
                    RestoreVersionFiles(repository, versionBackup);
                    log("發布在暫存前失敗；已還原本工具修改的版本檔案，原 PWA 修改保持不變。");
                }
                throw;
            }
        }

        private static bool HasSelectedChanges(
            string git,
            string repository,
            List<string> selected,
            Action<string> log)
        {
            List<string> arguments = new List<string>
            {
                "status",
                "--porcelain=v1",
                "--untracked-files=all",
                "--"
            };
            arguments.AddRange(selected);
            CommandResult result = RunRequired(git, arguments, repository, log, "無法檢查選取檔案的狀態。");
            return !string.IsNullOrWhiteSpace(result.Output);
        }

        private static List<string> BuildSelectedPathspecs(
            string repository,
            string pwaDirectory,
            IList<string> selectedPaths)
        {
            List<string> result = new List<string>();
            if (selectedPaths == null || selectedPaths.Count == 0)
            {
                result.Add(ToRepositoryPath(repository, pwaDirectory));
                return result;
            }

            foreach (string selected in selectedPaths)
            {
                if (string.IsNullOrWhiteSpace(selected)) continue;
                string full = Path.GetFullPath(selected.Trim());
                if (!File.Exists(full) && !Directory.Exists(full))
                    throw new InvalidOperationException("選取的路徑不存在：" + full);
                EnsureInside(repository, full, "選取路徑必須位於 Git 專案內：" + full);
                EnsureInside(pwaDirectory, full, "選取路徑必須位於 PWA 專案內：" + full);
                string relative = ToRepositoryPath(repository, full);
                if (!result.Contains(relative, StringComparer.OrdinalIgnoreCase)) result.Add(relative);
            }

            if (result.Count == 0)
                throw new InvalidOperationException("沒有有效的 PWA 路徑。");
            return result;
        }

        private static Dictionary<string, byte[]> BackupVersionFiles(string repository)
        {
            Dictionary<string, byte[]> backup = new Dictionary<string, byte[]>(StringComparer.OrdinalIgnoreCase);
            foreach (string relative in VersionFiles)
            {
                string path = Path.Combine(repository, relative.Replace('/', Path.DirectorySeparatorChar));
                RequireFile(path, "缺少版本檔案：" + relative);
                backup[relative] = File.ReadAllBytes(path);
            }
            return backup;
        }

        private static void RestoreVersionFiles(string repository, Dictionary<string, byte[]> backup)
        {
            foreach (KeyValuePair<string, byte[]> entry in backup)
            {
                string path = Path.Combine(repository, entry.Key.Replace('/', Path.DirectorySeparatorChar));
                File.WriteAllBytes(path, entry.Value);
            }
        }

        private static string ReadVersionLabel(string repository)
        {
            string json = File.ReadAllText(Path.Combine(repository, "version.json"));
            Match match = Regex.Match(json, "\\\"label\\\"\\s*:\\s*\\\"([^\\\"]+)\\\"");
            if (!match.Success) throw new InvalidOperationException("version.json 缺少 label。");
            return match.Groups[1].Value;
        }

        private static void ParseDivergence(string value, out int localAhead, out int remoteAhead)
        {
            string[] parts = Regex.Split(value.Trim(), "\\s+");
            if (parts.Length < 2 || !int.TryParse(parts[0], out localAhead) || !int.TryParse(parts[1], out remoteAhead))
                throw new InvalidOperationException("無法解析 Git 分支差異：" + value);
        }

        private static CommandResult RunRequired(
            string executable,
            IEnumerable<string> arguments,
            string workingDirectory,
            Action<string> log,
            string errorMessage)
        {
            CommandResult result = ProcessRunner.Run(executable, arguments, workingDirectory, log);
            if (result.ExitCode != 0)
                throw new InvalidOperationException(errorMessage + "\r\n" + result.Output);
            return result;
        }

        private static CommandResult RunBatchRequired(
            string batchPath,
            IEnumerable<string> arguments,
            string workingDirectory,
            Action<string> log,
            string errorMessage)
        {
            CommandResult result = ProcessRunner.RunBatch(batchPath, arguments, workingDirectory, log);
            if (result.ExitCode != 0)
                throw new InvalidOperationException(errorMessage + "\r\n" + result.Output);
            return result;
        }

        private static string FindTool(string name)
        {
            if (Path.IsPathRooted(name) && File.Exists(name)) return name;
            string path = Environment.GetEnvironmentVariable("PATH") ?? string.Empty;
            foreach (string directory in path.Split(Path.PathSeparator))
            {
                if (string.IsNullOrWhiteSpace(directory)) continue;
                try
                {
                    string candidate = Path.Combine(directory.Trim(), name);
                    if (File.Exists(candidate)) return candidate;
                }
                catch { }
            }

            if (string.Equals(name, "powershell.exe", StringComparison.OrdinalIgnoreCase))
            {
                string systemPowerShell = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.System),
                    "WindowsPowerShell",
                    "v1.0",
                    "powershell.exe");
                if (File.Exists(systemPowerShell)) return systemPowerShell;
            }
            throw new InvalidOperationException("找不到必要工具：" + name + "。請先安裝並加入 PATH。");
        }

        private static string NormalizeExistingDirectory(string value, string label)
        {
            if (string.IsNullOrWhiteSpace(value))
                throw new InvalidOperationException(label + "不可空白。");
            string full = Path.GetFullPath(value.Trim()).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            if (!Directory.Exists(full))
                throw new InvalidOperationException(label + "不存在：" + full);
            return full;
        }

        private static void EnsureInside(string parent, string child, string message)
        {
            string normalizedParent = Path.GetFullPath(parent).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            string normalizedChild = Path.GetFullPath(child).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            if (PathsEqual(normalizedParent, normalizedChild)) return;
            string prefix = normalizedParent + Path.DirectorySeparatorChar;
            if (!normalizedChild.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                throw new InvalidOperationException(message);
        }

        private static bool PathsEqual(string left, string right)
        {
            return string.Equals(
                Path.GetFullPath(left).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar),
                Path.GetFullPath(right).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar),
                StringComparison.OrdinalIgnoreCase);
        }

        private static string ToRepositoryPath(string repository, string fullPath)
        {
            Uri root = new Uri(AppendDirectorySeparator(Path.GetFullPath(repository)));
            Uri target = new Uri(Path.GetFullPath(fullPath));
            string relative = Uri.UnescapeDataString(root.MakeRelativeUri(target).ToString());
            return relative.Replace('\\', '/');
        }

        private static string AppendDirectorySeparator(string path)
        {
            return path.EndsWith(Path.DirectorySeparatorChar.ToString(), StringComparison.Ordinal)
                ? path
                : path + Path.DirectorySeparatorChar;
        }

        private static void RequireFile(string path, string message)
        {
            if (!File.Exists(path)) throw new InvalidOperationException(message);
        }
    }
}
