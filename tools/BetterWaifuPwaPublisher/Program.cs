using System;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Principal;
using System.Windows.Forms;

[assembly: AssemblyTitle("BetterWaifu PWA Publisher")]
[assembly: AssemblyDescription("BetterWaifu PWA 管理員單鍵 GitHub 發布工具")]
[assembly: AssemblyCompany("BetterWaifu")]
[assembly: AssemblyProduct("BetterWaifu PWA Publisher")]
[assembly: AssemblyCopyright("Copyright © BetterWaifu 2026")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]
[assembly: ComVisible(false)]

namespace BetterWaifuPwaPublisher
{
    internal static class Program
    {
        [STAThread]
        private static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (!IsAdministrator())
            {
                MessageBox.Show(
                    "此工具需要系統管理員權限。請確認 Windows 的 UAC 提示後重新啟動。",
                    "BetterWaifu PWA Publisher",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            Application.Run(new MainForm());
        }

        private static bool IsAdministrator()
        {
            try
            {
                WindowsIdentity identity = WindowsIdentity.GetCurrent();
                WindowsPrincipal principal = new WindowsPrincipal(identity);
                return principal.IsInRole(WindowsBuiltInRole.Administrator);
            }
            catch
            {
                return false;
            }
        }
    }
}
