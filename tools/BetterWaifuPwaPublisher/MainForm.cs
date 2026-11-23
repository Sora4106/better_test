using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BetterWaifuPwaPublisher
{
    internal sealed class MainForm : Form
    {
        private readonly Color _background = Color.FromArgb(20, 17, 34);
        private readonly Color _surface = Color.FromArgb(39, 32, 61);
        private readonly Color _surface2 = Color.FromArgb(49, 40, 74);
        private readonly Color _accent = Color.FromArgb(236, 72, 153);
        private readonly Color _text = Color.FromArgb(248, 245, 255);
        private readonly Color _muted = Color.FromArgb(196, 181, 253);

        private TextBox _repositoryText;
        private TextBox _pwaText;
        private ListBox _selectedPathsList;
        private TextBox _remoteText;
        private TextBox _branchText;
        private TextBox _noteText;
        private CheckBox _analyzeCheck;
        private CheckBox _buildCheck;
        private CheckBox _cacheCheck;
        private Button _publishButton;
        private ProgressBar _progressBar;
        private Label _statusLabel;
        private RichTextBox _logBox;
        private PublisherSettings _settings;
        private bool _publishing;

        public MainForm()
        {
            InitializeWindow();
            BuildInterface();
            LoadSettings();
        }

        private void InitializeWindow()
        {
            Text = "BetterWaifu PWA Publisher（系統管理員）";
            StartPosition = FormStartPosition.CenterScreen;
            ClientSize = new Size(1040, 800);
            MinimumSize = new Size(860, 680);
            BackColor = _background;
            ForeColor = _text;
            Font = new Font("Microsoft JhengHei UI", 9.5F, FontStyle.Regular, GraphicsUnit.Point);
            AutoScaleMode = AutoScaleMode.Dpi;
            FormClosing += OnFormClosing;
        }

        private void BuildInterface()
        {
            Panel header = new Panel
            {
                Dock = DockStyle.Top,
                Height = 96,
                BackColor = Color.FromArgb(30, 24, 48),
                Padding = new Padding(22, 16, 22, 10)
            };
            Controls.Add(header);

            Label title = new Label
            {
                AutoSize = true,
                Text = "BetterWaifu PWA Publisher",
                ForeColor = _text,
                Font = new Font(Font.FontFamily, 19F, FontStyle.Bold),
                Location = new Point(20, 14)
            };
            header.Controls.Add(title);

            Label subtitle = new Label
            {
                AutoSize = true,
                Text = "管理員單鍵升版、驗證、建置、提交並推送至 GitHub",
                ForeColor = _muted,
                Font = new Font(Font.FontFamily, 10F),
                Location = new Point(23, 54)
            };
            header.Controls.Add(subtitle);

            Label adminBadge = new Label
            {
                AutoSize = true,
                Anchor = AnchorStyles.Top | AnchorStyles.Right,
                Text = "● 系統管理員模式",
                ForeColor = Color.FromArgb(134, 239, 172),
                Font = new Font(Font.FontFamily, 9.5F, FontStyle.Bold),
                Location = new Point(ClientSize.Width - 190, 22)
            };
            header.Controls.Add(adminBadge);
            header.Resize += delegate
            {
                adminBadge.Left = header.ClientSize.Width - adminBadge.Width - 24;
            };

            SplitContainer split = new SplitContainer
            {
                Dock = DockStyle.Fill,
                Orientation = Orientation.Horizontal,
                SplitterDistance = 485,
                SplitterWidth = 6,
                BackColor = _background,
                Panel1MinSize = 420,
                Panel2MinSize = 140
            };
            Controls.Add(split);
            split.BringToFront();

            Panel settingsPanel = new Panel
            {
                Dock = DockStyle.Fill,
                AutoScroll = true,
                BackColor = _background,
                Padding = new Padding(18, 14, 18, 10)
            };
            split.Panel1.Controls.Add(settingsPanel);

            TableLayoutPanel contentStack = new TableLayoutPanel
            {
                Dock = DockStyle.Top,
                AutoSize = true,
                ColumnCount = 1,
                RowCount = 2,
                BackColor = _background,
                Margin = new Padding(0)
            };
            contentStack.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            contentStack.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            contentStack.RowStyles.Add(new RowStyle(SizeType.Absolute, 108F));
            settingsPanel.Controls.Add(contentStack);

            TableLayoutPanel table = new TableLayoutPanel
            {
                Dock = DockStyle.Top,
                AutoSize = true,
                BackColor = _surface,
                Padding = new Padding(16, 14, 16, 14),
                ColumnCount = 3,
                RowCount = 8,
                GrowStyle = TableLayoutPanelGrowStyle.AddRows
            };
            table.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 145F));
            table.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            table.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 100F));
            contentStack.Controls.Add(table, 0, 0);

            _repositoryText = CreateTextBox();
            AddPathRow(table, 0, "Git 專案目錄", _repositoryText, BrowseRepository);

            _pwaText = CreateTextBox();
            AddPathRow(table, 1, "PWA 專案目錄", _pwaText, BrowsePwaDirectory);

            Label pathsLabel = CreateFieldLabel("要上傳的 PWA 路徑");
            pathsLabel.Padding = new Padding(0, 7, 0, 0);
            table.Controls.Add(pathsLabel, 0, 2);

            _selectedPathsList = new ListBox
            {
                Dock = DockStyle.Fill,
                Height = 92,
                BackColor = _surface2,
                ForeColor = _text,
                BorderStyle = BorderStyle.FixedSingle,
                HorizontalScrollbar = true,
                SelectionMode = SelectionMode.MultiExtended
            };
            table.Controls.Add(_selectedPathsList, 1, 2);
            table.SetColumnSpan(_selectedPathsList, 2);

            FlowLayoutPanel pathButtons = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                AutoSize = true,
                FlowDirection = FlowDirection.LeftToRight,
                WrapContents = true,
                Margin = new Padding(0, 5, 0, 7)
            };
            pathButtons.Controls.Add(CreateSmallButton("加入檔案", AddFiles));
            pathButtons.Controls.Add(CreateSmallButton("加入資料夾", AddFolder));
            pathButtons.Controls.Add(CreateSmallButton("移除選取", RemoveSelectedPaths));
            pathButtons.Controls.Add(CreateSmallButton("清空＝整個 PWA", ClearSelectedPaths));
            table.Controls.Add(pathButtons, 1, 3);
            table.SetColumnSpan(pathButtons, 2);

            Label pathHint = new Label
            {
                AutoSize = true,
                Text = "留空時會暫存整個 PWA 專案；所有路徑都必須位於 Git 專案與 PWA 目錄內。",
                ForeColor = _muted,
                Margin = new Padding(3, 0, 3, 9)
            };
            table.Controls.Add(pathHint, 1, 4);
            table.SetColumnSpan(pathHint, 2);

            TableLayoutPanel gitFields = new TableLayoutPanel
            {
                Dock = DockStyle.Fill,
                AutoSize = true,
                ColumnCount = 4,
                Margin = new Padding(0)
            };
            gitFields.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 62F));
            gitFields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            gitFields.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 58F));
            gitFields.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50F));
            gitFields.Controls.Add(CreateInlineLabel("Remote"), 0, 0);
            _remoteText = CreateTextBox();
            gitFields.Controls.Add(_remoteText, 1, 0);
            gitFields.Controls.Add(CreateInlineLabel("分支"), 2, 0);
            _branchText = CreateTextBox();
            gitFields.Controls.Add(_branchText, 3, 0);
            table.Controls.Add(CreateFieldLabel("GitHub 目標"), 0, 5);
            table.Controls.Add(gitFields, 1, 5);
            table.SetColumnSpan(gitFields, 2);

            _noteText = CreateTextBox();
            _noteText.Multiline = true;
            _noteText.Height = 56;
            _noteText.ScrollBars = ScrollBars.Vertical;
            table.Controls.Add(CreateFieldLabel("版本更新說明"), 0, 6);
            table.Controls.Add(_noteText, 1, 6);
            table.SetColumnSpan(_noteText, 2);

            FlowLayoutPanel optionsPanel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                AutoSize = true,
                FlowDirection = FlowDirection.LeftToRight,
                WrapContents = true,
                Margin = new Padding(0, 8, 0, 0)
            };
            _analyzeCheck = CreateCheckBox("先執行 Flutter analyze");
            _buildCheck = CreateCheckBox("建置 Flutter Web");
            _cacheCheck = CreateCheckBox("更新 PWA 快取版本");
            _buildCheck.CheckedChanged += delegate
            {
                if (!_buildCheck.Checked && !Directory.Exists(Path.Combine(_pwaText.Text, "build", "web")))
                    _cacheCheck.Checked = false;
            };
            optionsPanel.Controls.Add(_analyzeCheck);
            optionsPanel.Controls.Add(_buildCheck);
            optionsPanel.Controls.Add(_cacheCheck);
            table.Controls.Add(CreateFieldLabel("發布流程"), 0, 7);
            table.Controls.Add(optionsPanel, 1, 7);
            table.SetColumnSpan(optionsPanel, 2);

            Panel actionPanel = new Panel
            {
                Dock = DockStyle.Fill,
                Height = 108,
                BackColor = _background,
                Padding = new Padding(0, 12, 0, 0)
            };
            contentStack.Controls.Add(actionPanel, 0, 1);

            _publishButton = new Button
            {
                Dock = DockStyle.Top,
                Height = 50,
                Text = "自動升版並上傳 GitHub",
                BackColor = _accent,
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Font = new Font(Font.FontFamily, 12F, FontStyle.Bold),
                Cursor = Cursors.Hand
            };
            _publishButton.FlatAppearance.BorderSize = 0;
            _publishButton.Click += PublishClicked;
            actionPanel.Controls.Add(_publishButton);

            _progressBar = new ProgressBar
            {
                Dock = DockStyle.Top,
                Height = 7,
                Minimum = 0,
                Maximum = 100,
                Margin = new Padding(0, 7, 0, 0)
            };
            actionPanel.Controls.Add(_progressBar);
            _progressBar.BringToFront();

            _statusLabel = new Label
            {
                Dock = DockStyle.Top,
                Height = 28,
                Text = "就緒。設定會保存在此 Windows 使用者的 LocalAppData。",
                ForeColor = _muted,
                TextAlign = ContentAlignment.MiddleLeft
            };
            actionPanel.Controls.Add(_statusLabel);
            _statusLabel.BringToFront();

            Panel logPanel = new Panel
            {
                Dock = DockStyle.Fill,
                BackColor = _background,
                Padding = new Padding(18, 8, 18, 16)
            };
            split.Panel2.Controls.Add(logPanel);

            Label logTitle = new Label
            {
                Dock = DockStyle.Top,
                Height = 26,
                Text = "執行紀錄",
                ForeColor = _text,
                Font = new Font(Font.FontFamily, 10F, FontStyle.Bold)
            };
            logPanel.Controls.Add(logTitle);

            _logBox = new RichTextBox
            {
                Dock = DockStyle.Fill,
                BackColor = Color.FromArgb(13, 11, 24),
                ForeColor = Color.FromArgb(226, 232, 240),
                BorderStyle = BorderStyle.FixedSingle,
                ReadOnly = true,
                DetectUrls = true,
                Font = new Font("Consolas", 9F),
                WordWrap = false
            };
            logPanel.Controls.Add(_logBox);
            _logBox.BringToFront();
        }

        private void AddPathRow(TableLayoutPanel table, int row, string label, TextBox textBox, EventHandler browse)
        {
            table.Controls.Add(CreateFieldLabel(label), 0, row);
            table.Controls.Add(textBox, 1, row);
            Button button = CreateSmallButton("選擇…", browse);
            button.Dock = DockStyle.Fill;
            table.Controls.Add(button, 2, row);
        }

        private Label CreateFieldLabel(string text)
        {
            return new Label
            {
                Dock = DockStyle.Fill,
                AutoSize = true,
                Text = text,
                ForeColor = _text,
                TextAlign = ContentAlignment.MiddleLeft,
                Margin = new Padding(0, 5, 8, 7),
                Font = new Font(Font.FontFamily, 9.5F, FontStyle.Bold)
            };
        }

        private Label CreateInlineLabel(string text)
        {
            return new Label
            {
                Dock = DockStyle.Fill,
                Text = text,
                ForeColor = _muted,
                TextAlign = ContentAlignment.MiddleLeft
            };
        }

        private TextBox CreateTextBox()
        {
            return new TextBox
            {
                Dock = DockStyle.Fill,
                BackColor = _surface2,
                ForeColor = _text,
                BorderStyle = BorderStyle.FixedSingle,
                Margin = new Padding(0, 3, 7, 7)
            };
        }

        private Button CreateSmallButton(string text, EventHandler click)
        {
            Button button = new Button
            {
                AutoSize = true,
                MinimumSize = new Size(88, 31),
                Text = text,
                BackColor = _surface2,
                ForeColor = _text,
                FlatStyle = FlatStyle.Flat,
                Cursor = Cursors.Hand,
                Margin = new Padding(0, 0, 7, 0)
            };
            button.FlatAppearance.BorderColor = Color.FromArgb(124, 96, 181);
            button.Click += click;
            return button;
        }

        private CheckBox CreateCheckBox(string text)
        {
            return new CheckBox
            {
                AutoSize = true,
                Text = text,
                ForeColor = _text,
                Margin = new Padding(0, 3, 18, 4)
            };
        }

        private void LoadSettings()
        {
            _settings = SettingsStore.Load();
            if (string.IsNullOrWhiteSpace(_settings.RepositoryDirectory))
                _settings.RepositoryDirectory = DiscoverRepositoryDirectory();
            if (string.IsNullOrWhiteSpace(_settings.PwaDirectory) && !string.IsNullOrWhiteSpace(_settings.RepositoryDirectory))
                _settings.PwaDirectory = Path.Combine(_settings.RepositoryDirectory, "flutter_pwa");

            _repositoryText.Text = _settings.RepositoryDirectory;
            _pwaText.Text = _settings.PwaDirectory;
            _remoteText.Text = string.IsNullOrWhiteSpace(_settings.RemoteName) ? "origin" : _settings.RemoteName;
            _branchText.Text = string.IsNullOrWhiteSpace(_settings.BranchName) ? "main" : _settings.BranchName;
            _noteText.Text = _settings.ReleaseNote;
            _analyzeCheck.Checked = _settings.RunAnalyze;
            _buildCheck.Checked = _settings.BuildWeb;
            _cacheCheck.Checked = _settings.UpdatePwaCache;
            _selectedPathsList.Items.Clear();
            foreach (string selected in _settings.SelectedPaths ?? new List<string>())
            {
                if (!_selectedPathsList.Items.Contains(selected))
                    _selectedPathsList.Items.Add(selected);
            }
        }

        private string DiscoverRepositoryDirectory()
        {
            DirectoryInfo current = new DirectoryInfo(AppDomain.CurrentDomain.BaseDirectory);
            while (current != null)
            {
                if (Directory.Exists(Path.Combine(current.FullName, ".git")) &&
                    File.Exists(Path.Combine(current.FullName, "version.json")))
                    return current.FullName;
                current = current.Parent;
            }
            return string.Empty;
        }

        private PublisherSettings ReadSettingsFromForm()
        {
            return new PublisherSettings
            {
                RepositoryDirectory = _repositoryText.Text.Trim(),
                PwaDirectory = _pwaText.Text.Trim(),
                SelectedPaths = _selectedPathsList.Items.Cast<object>().Select(item => item.ToString()).ToList(),
                RemoteName = _remoteText.Text.Trim(),
                BranchName = _branchText.Text.Trim(),
                ReleaseNote = _noteText.Text.Trim(),
                RunAnalyze = _analyzeCheck.Checked,
                BuildWeb = _buildCheck.Checked,
                UpdatePwaCache = _cacheCheck.Checked
            };
        }

        private void BrowseRepository(object sender, EventArgs e)
        {
            string selected = BrowseDirectory("選擇 Git 專案根目錄", _repositoryText.Text);
            if (selected == null) return;
            _repositoryText.Text = selected;
            string expectedPwa = Path.Combine(selected, "flutter_pwa");
            if (Directory.Exists(expectedPwa)) _pwaText.Text = expectedPwa;
        }

        private void BrowsePwaDirectory(object sender, EventArgs e)
        {
            string selected = BrowseDirectory("選擇 Flutter PWA 專案目錄", _pwaText.Text);
            if (selected != null) _pwaText.Text = selected;
        }

        private string BrowseDirectory(string description, string initial)
        {
            using (FolderBrowserDialog dialog = new FolderBrowserDialog())
            {
                dialog.Description = description;
                dialog.ShowNewFolderButton = false;
                if (Directory.Exists(initial)) dialog.SelectedPath = initial;
                return dialog.ShowDialog(this) == DialogResult.OK ? dialog.SelectedPath : null;
            }
        }

        private void AddFiles(object sender, EventArgs e)
        {
            using (OpenFileDialog dialog = new OpenFileDialog())
            {
                dialog.Title = "選擇要上傳的 PWA 檔案";
                dialog.Multiselect = true;
                dialog.Filter = "所有檔案 (*.*)|*.*";
                if (Directory.Exists(_pwaText.Text)) dialog.InitialDirectory = _pwaText.Text;
                if (dialog.ShowDialog(this) != DialogResult.OK) return;
                foreach (string file in dialog.FileNames) AddSelectedPath(file);
            }
        }

        private void AddFolder(object sender, EventArgs e)
        {
            string selected = BrowseDirectory("選擇要遞迴上傳的 PWA 資料夾", _pwaText.Text);
            if (selected != null) AddSelectedPath(selected);
        }

        private void AddSelectedPath(string path)
        {
            string full = Path.GetFullPath(path);
            if (!_selectedPathsList.Items.Contains(full)) _selectedPathsList.Items.Add(full);
        }

        private void RemoveSelectedPaths(object sender, EventArgs e)
        {
            object[] selected = _selectedPathsList.SelectedItems.Cast<object>().ToArray();
            foreach (object item in selected) _selectedPathsList.Items.Remove(item);
        }

        private void ClearSelectedPaths(object sender, EventArgs e)
        {
            _selectedPathsList.Items.Clear();
        }

        private async void PublishClicked(object sender, EventArgs e)
        {
            if (_publishing) return;
            PublisherSettings settings = ReadSettingsFromForm();
            SettingsStore.Save(settings);

            DialogResult confirm = MessageBox.Show(
                "將依畫面設定自動升版、驗證、建置、commit 並 push 到 GitHub。\r\n\r\n" +
                "本工具不會 reset、checkout 或清除未選取的修改。是否繼續？",
                "確認發布",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            if (confirm != DialogResult.Yes) return;

            SetPublishingState(true);
            _logBox.Clear();
            AppendLog("=== BetterWaifu PWA 發布開始 " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " ===");
            try
            {
                PublisherOptions options = new PublisherOptions
                {
                    RepositoryDirectory = settings.RepositoryDirectory,
                    PwaDirectory = settings.PwaDirectory,
                    SelectedPaths = settings.SelectedPaths,
                    RemoteName = settings.RemoteName,
                    BranchName = settings.BranchName,
                    ReleaseNote = settings.ReleaseNote,
                    RunAnalyze = settings.RunAnalyze,
                    BuildWeb = settings.BuildWeb,
                    UpdatePwaCache = settings.UpdatePwaCache
                };

                PublisherEngine engine = new PublisherEngine();
                PublishResult result = await Task.Run(delegate
                {
                    return engine.Publish(options, AppendLog, UpdateProgress);
                });

                string shortCommit = result.CommitHash.Length > 10
                    ? result.CommitHash.Substring(0, 10)
                    : result.CommitHash;
                UpdateProgress(100, "發布完成：" + result.VersionLabel);
                AppendLog("=== 完成：" + result.VersionLabel + " / " + shortCommit + " ===");
                MessageBox.Show(
                    (result.PushedExistingCommitOnly ? "既有本地提交已重新推送成功。" : "PWA 已自動升版並推送成功。") +
                    "\r\n\r\n版本：" + result.VersionLabel +
                    "\r\nCommit：" + shortCommit,
                    "發布成功",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (Exception exception)
            {
                UpdateProgress(_progressBar.Value, "發布失敗");
                AppendLog("ERROR: " + exception.Message);
                MessageBox.Show(
                    exception.Message,
                    "發布失敗",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                SetPublishingState(false);
            }
        }

        private void AppendLog(string message)
        {
            if (IsDisposed) return;
            if (InvokeRequired)
            {
                BeginInvoke(new Action<string>(AppendLog), message);
                return;
            }
            _logBox.AppendText("[" + DateTime.Now.ToString("HH:mm:ss") + "] " + message + Environment.NewLine);
            _logBox.SelectionStart = _logBox.TextLength;
            _logBox.ScrollToCaret();
        }

        private void UpdateProgress(int value, string status)
        {
            if (IsDisposed) return;
            if (InvokeRequired)
            {
                BeginInvoke(new Action<int, string>(UpdateProgress), value, status);
                return;
            }
            _progressBar.Value = Math.Max(_progressBar.Minimum, Math.Min(_progressBar.Maximum, value));
            _statusLabel.Text = status;
        }

        private void SetPublishingState(bool publishing)
        {
            _publishing = publishing;
            _publishButton.Enabled = !publishing;
            _repositoryText.Enabled = !publishing;
            _pwaText.Enabled = !publishing;
            _selectedPathsList.Enabled = !publishing;
            _remoteText.Enabled = !publishing;
            _branchText.Enabled = !publishing;
            _noteText.Enabled = !publishing;
            _analyzeCheck.Enabled = !publishing;
            _buildCheck.Enabled = !publishing;
            _cacheCheck.Enabled = !publishing;
            UseWaitCursor = publishing;
            if (publishing) UpdateProgress(1, "準備發布…");
        }

        private void OnFormClosing(object sender, FormClosingEventArgs e)
        {
            if (_publishing)
            {
                DialogResult close = MessageBox.Show(
                    "發布仍在執行。直接關閉視窗可能讓外部 Git／Flutter 行程繼續運作。確定要關閉嗎？",
                    "發布尚未完成",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Warning);
                if (close != DialogResult.Yes)
                {
                    e.Cancel = true;
                    return;
                }
            }

            try { SettingsStore.Save(ReadSettingsFromForm()); }
            catch { }
        }
    }
}
