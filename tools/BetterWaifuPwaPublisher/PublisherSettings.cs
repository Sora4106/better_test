using System;
using System.Collections.Generic;
using System.IO;
using System.Web.Script.Serialization;

namespace BetterWaifuPwaPublisher
{
    internal sealed class PublisherSettings
    {
        public string RepositoryDirectory { get; set; }
        public string PwaDirectory { get; set; }
        public List<string> SelectedPaths { get; set; }
        public string RemoteName { get; set; }
        public string BranchName { get; set; }
        public string ReleaseNote { get; set; }
        public bool RunAnalyze { get; set; }
        public bool BuildWeb { get; set; }
        public bool UpdatePwaCache { get; set; }

        public PublisherSettings()
        {
            RepositoryDirectory = string.Empty;
            PwaDirectory = string.Empty;
            SelectedPaths = new List<string>();
            RemoteName = "origin";
            BranchName = "main";
            ReleaseNote = "管理員桌面工具單鍵發布 PWA";
            RunAnalyze = true;
            BuildWeb = true;
            UpdatePwaCache = true;
        }
    }

    internal static class SettingsStore
    {
        private static readonly string SettingsDirectory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "BetterWaifu",
            "PwaPublisher");

        private static readonly string SettingsPath = Path.Combine(
            SettingsDirectory,
            "settings.json");

        public static PublisherSettings Load()
        {
            try
            {
                if (!File.Exists(SettingsPath))
                {
                    return new PublisherSettings();
                }

                JavaScriptSerializer serializer = new JavaScriptSerializer();
                PublisherSettings settings = serializer.Deserialize<PublisherSettings>(
                    File.ReadAllText(SettingsPath));
                return settings ?? new PublisherSettings();
            }
            catch
            {
                return new PublisherSettings();
            }
        }

        public static void Save(PublisherSettings settings)
        {
            Directory.CreateDirectory(SettingsDirectory);
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            File.WriteAllText(SettingsPath, serializer.Serialize(settings));
        }
    }

    internal sealed class PublisherOptions
    {
        public string RepositoryDirectory { get; set; }
        public string PwaDirectory { get; set; }
        public List<string> SelectedPaths { get; set; }
        public string RemoteName { get; set; }
        public string BranchName { get; set; }
        public string ReleaseNote { get; set; }
        public bool RunAnalyze { get; set; }
        public bool BuildWeb { get; set; }
        public bool UpdatePwaCache { get; set; }
    }

    internal sealed class PublishResult
    {
        public string VersionLabel { get; set; }
        public string CommitHash { get; set; }
        public bool PushedExistingCommitOnly { get; set; }
    }
}
