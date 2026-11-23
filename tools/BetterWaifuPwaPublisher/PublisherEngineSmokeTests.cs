using System;
using System.Collections.Generic;
using System.IO;

namespace BetterWaifuPwaPublisher
{
    internal static class PublisherEngineSmokeTests
    {
        private static int Main()
        {
            string tempRoot = Path.Combine(
                Path.GetTempPath(),
                "BetterWaifuPwaPublisherTests-" + Guid.NewGuid().ToString("N"));
            try
            {
                Directory.CreateDirectory(tempRoot);
                TestBatchArgumentQuoting(tempRoot);
                TestPublishToIsolatedBareRemote(tempRoot);
                Console.WriteLine("PASS: Publisher engine smoke tests completed.");
                return 0;
            }
            catch (Exception exception)
            {
                Console.Error.WriteLine("FAIL: " + exception);
                return 1;
            }
            finally
            {
                try
                {
                    string safeTemp = Path.GetFullPath(Path.GetTempPath());
                    string safeTarget = Path.GetFullPath(tempRoot);
                    if (safeTarget.StartsWith(safeTemp, StringComparison.OrdinalIgnoreCase) && Directory.Exists(safeTarget))
                        Directory.Delete(safeTarget, true);
                }
                catch { }
            }
        }

        private static void TestBatchArgumentQuoting(string tempRoot)
        {
            string batch = Path.Combine(tempRoot, "echo args.bat");
            File.WriteAllText(batch, "@echo off\r\necho FIRST=[%~1]\r\necho SECOND=[%~2]\r\n");
            CommandResult result = ProcessRunner.RunBatch(
                batch,
                new[] { "plain", "value with spaces" },
                tempRoot,
                null);
            Assert(result.ExitCode == 0, "Batch runner returned " + result.ExitCode);
            Assert(result.Output.Contains("FIRST=[plain]"), "First batch argument was corrupted: " + result.Output);
            Assert(result.Output.Contains("SECOND=[value with spaces]"), "Spaced batch argument was corrupted: " + result.Output);
        }

        private static void TestPublishToIsolatedBareRemote(string tempRoot)
        {
            string repository = Path.Combine(tempRoot, "repo");
            string remote = Path.Combine(tempRoot, "remote.git");
            Directory.CreateDirectory(repository);
            RunGit(repository, "init", "-b", "main");
            RunGit(repository, "config", "user.name", "Publisher Smoke Test");
            RunGit(repository, "config", "user.email", "publisher-smoke@example.invalid");

            Directory.CreateDirectory(Path.Combine(repository, "flutter_pwa", "lib"));
            Directory.CreateDirectory(Path.Combine(repository, "tools"));
            File.WriteAllText(Path.Combine(repository, "version.json"), "{\"version\":\"1.0.0\",\"build\":1,\"label\":\"1.0.0+1\"}");
            File.WriteAllText(Path.Combine(repository, "CHANGELOG.md"), "# Test changelog\r\n");
            File.WriteAllText(Path.Combine(repository, "flutter_pwa", "pubspec.yaml"), "name: smoke_test\r\nversion: 1.0.0+1\r\n");
            File.WriteAllText(Path.Combine(repository, "flutter_pwa", "lib", "app_version.dart"), "const appVersionLabel = '1.0.0+1';\r\n");
            File.WriteAllText(Path.Combine(repository, "flutter_pwa", "lib", "main.dart"), "void main() {}\r\n");
            File.WriteAllText(
                Path.Combine(repository, "tools", "update-version.ps1"),
                "$ErrorActionPreference='Stop'\r\n" +
                "$root=Split-Path -Parent $PSScriptRoot\r\n" +
                "Set-Content -LiteralPath (Join-Path $root 'version.json') -Encoding UTF8 -Value '{\"version\":\"1.0.1\",\"build\":2,\"label\":\"1.0.1+2\"}'\r\n" +
                "Add-Content -LiteralPath (Join-Path $root 'CHANGELOG.md') -Encoding UTF8 -Value 'release 1.0.1+2'\r\n" +
                "Set-Content -LiteralPath (Join-Path $root 'flutter_pwa/lib/app_version.dart') -Encoding UTF8 -Value \"const appVersionLabel = '1.0.1+2';\"\r\n" +
                "$pubspec=(Get-Content -Raw -LiteralPath (Join-Path $root 'flutter_pwa/pubspec.yaml')) -replace 'version: .*','version: 1.0.1+2'\r\n" +
                "$pubspec=$pubspec.TrimEnd(\"`r\",\"`n\")+\"`n\"\r\n" +
                "[IO.File]::WriteAllText((Join-Path $root 'flutter_pwa/pubspec.yaml'),$pubspec,(New-Object Text.UTF8Encoding($false)))\r\n");
            File.WriteAllText(
                Path.Combine(repository, "tools", "update-pwa-cache.ps1"),
                "param([string]$BuildDirectory)\r\nWrite-Host 'cache ok'\r\n");

            RunGit(repository, "add", ".");
            RunGit(repository, "commit", "-m", "initial");
            RunGit(tempRoot, "init", "--bare", remote);
            RunGit(repository, "remote", "add", "origin", remote);
            RunGit(repository, "push", "-u", "origin", "main");

            File.AppendAllText(
                Path.Combine(repository, "flutter_pwa", "lib", "main.dart"),
                "// selected PWA change\r\n");

            PublisherOptions options = new PublisherOptions
            {
                RepositoryDirectory = repository,
                PwaDirectory = Path.Combine(repository, "flutter_pwa"),
                SelectedPaths = new List<string>(),
                RemoteName = "origin",
                BranchName = "main",
                ReleaseNote = "smoke release",
                RunAnalyze = false,
                BuildWeb = false,
                UpdatePwaCache = false
            };
            PublishResult result = new PublisherEngine().Publish(options, null, null);
            Assert(result.VersionLabel == "1.0.1+2", "Unexpected version: " + result.VersionLabel);
            Assert(!result.PushedExistingCommitOnly, "A new release should have been created.");

            string status = RunGit(repository, "status", "--porcelain").Output;
            Assert(string.IsNullOrWhiteSpace(status), "Repository is not clean after publish: " + status);
            string localHead = RunGit(repository, "rev-parse", "HEAD").Output.Trim();
            string remoteHead = RunGit(repository, "rev-parse", "origin/main").Output.Trim();
            Assert(localHead == remoteHead, "Push did not update the isolated remote.");

            PublishResult cleanRepublish = new PublisherEngine().Publish(options, null, null);
            Assert(!cleanRepublish.PushedExistingCommitOnly, "A clean repository should create a new release instead of being rejected.");
            string republishedHead = RunGit(repository, "rev-parse", "HEAD").Output.Trim();
            Assert(republishedHead != localHead, "Publishing without selected PWA changes did not create a release commit.");
            string republishedRemoteHead = RunGit(repository, "rev-parse", "origin/main").Output.Trim();
            Assert(republishedHead == republishedRemoteHead, "Clean republish did not update the isolated remote.");
            status = RunGit(repository, "status", "--porcelain").Output;
            Assert(string.IsNullOrWhiteSpace(status), "Repository is not clean after clean republish: " + status);

            File.AppendAllText(
                Path.Combine(repository, "flutter_pwa", "lib", "main.dart"),
                "// staged safety check\r\n");
            RunGit(repository, "add", "flutter_pwa/lib/main.dart");
            bool rejectedStaged = false;
            try
            {
                new PublisherEngine().Publish(options, null, null);
            }
            catch (InvalidOperationException exception)
            {
                rejectedStaged = exception.Message.IndexOf("staged", StringComparison.OrdinalIgnoreCase) >= 0;
            }
            Assert(rejectedStaged, "Publisher did not reject pre-existing staged changes.");
        }

        private static CommandResult RunGit(string workingDirectory, params string[] arguments)
        {
            CommandResult result = ProcessRunner.Run("git.exe", arguments, workingDirectory, null);
            if (result.ExitCode != 0)
                throw new InvalidOperationException("git " + string.Join(" ", arguments) + " failed: " + result.Output);
            return result;
        }

        private static void Assert(bool condition, string message)
        {
            if (!condition) throw new InvalidOperationException(message);
        }
    }
}
