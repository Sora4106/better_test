using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace BetterWaifuPwaPublisher
{
    internal sealed class CommandResult
    {
        public int ExitCode { get; set; }
        public string Output { get; set; }
    }

    internal static class ProcessRunner
    {
        public static CommandResult Run(
            string executable,
            IEnumerable<string> arguments,
            string workingDirectory,
            Action<string> log)
        {
            string argumentText = JoinArguments(arguments);
            return RunRaw(executable, argumentText, workingDirectory, log);
        }

        public static CommandResult RunBatch(
            string batchPath,
            IEnumerable<string> arguments,
            string workingDirectory,
            Action<string> log)
        {
            StringBuilder command = new StringBuilder();
            command.Append(QuoteForCmd(batchPath));
            foreach (string argument in arguments)
            {
                command.Append(' ');
                command.Append(QuoteForCmd(argument));
            }

            string raw = "/d /s /c \"" + command + "\"";
            return RunRaw("cmd.exe", raw, workingDirectory, log);
        }

        private static CommandResult RunRaw(
            string executable,
            string argumentText,
            string workingDirectory,
            Action<string> log)
        {
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = executable;
            startInfo.Arguments = argumentText;
            startInfo.WorkingDirectory = workingDirectory;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            startInfo.StandardOutputEncoding = Encoding.UTF8;
            startInfo.StandardErrorEncoding = Encoding.UTF8;
            startInfo.EnvironmentVariables["GIT_TERMINAL_PROMPT"] = "0";
            startInfo.EnvironmentVariables["LANG"] = "C.UTF-8";

            StringBuilder captured = new StringBuilder();
            object sync = new object();
            using (Process process = new Process())
            {
                process.StartInfo = startInfo;
                process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs eventArgs)
                {
                    if (eventArgs.Data == null) return;
                    lock (sync) captured.AppendLine(eventArgs.Data);
                    if (log != null) log(eventArgs.Data);
                };
                process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs eventArgs)
                {
                    if (eventArgs.Data == null) return;
                    lock (sync) captured.AppendLine(eventArgs.Data);
                    if (log != null) log(eventArgs.Data);
                };

                try
                {
                    process.Start();
                }
                catch (Exception exception)
                {
                    throw new InvalidOperationException(
                        "無法啟動工具：" + executable + "。" + exception.Message,
                        exception);
                }

                process.BeginOutputReadLine();
                process.BeginErrorReadLine();
                process.WaitForExit();
                process.WaitForExit();

                return new CommandResult
                {
                    ExitCode = process.ExitCode,
                    Output = captured.ToString().Trim()
                };
            }
        }

        private static string JoinArguments(IEnumerable<string> arguments)
        {
            StringBuilder builder = new StringBuilder();
            foreach (string argument in arguments)
            {
                if (builder.Length > 0) builder.Append(' ');
                builder.Append(QuoteArgument(argument));
            }
            return builder.ToString();
        }

        private static string QuoteArgument(string value)
        {
            if (value == null) return "\"\"";
            if (value.Length > 0 && value.IndexOfAny(new[] { ' ', '\t', '\n', '\v', '\"' }) < 0)
            {
                return value;
            }

            StringBuilder quoted = new StringBuilder();
            quoted.Append('\"');
            int backslashes = 0;
            foreach (char character in value)
            {
                if (character == '\\')
                {
                    backslashes++;
                    continue;
                }

                if (character == '\"')
                {
                    quoted.Append('\\', backslashes * 2 + 1);
                    quoted.Append('\"');
                    backslashes = 0;
                    continue;
                }

                quoted.Append('\\', backslashes);
                backslashes = 0;
                quoted.Append(character);
            }
            quoted.Append('\\', backslashes * 2);
            quoted.Append('\"');
            return quoted.ToString();
        }

        private static string QuoteForCmd(string value)
        {
            if (value == null) return "\"\"";
            return "\"" + value.Replace("\"", "\"\"") + "\"";
        }
    }
}
