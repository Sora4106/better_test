# BetterWaifu PWA Publisher

Windows 管理員桌面工具，用一個主要按鈕完成 BetterWaifu Flutter PWA 的升版與 GitHub 發布。

## 功能

- EXE 透過 manifest 要求系統管理員權限。
- 選擇 Git 專案、PWA 專案，以及要暫存的 PWA 檔案或資料夾。
- 留空檔案清單時，暫存整個 PWA 專案目錄。
- 自動執行 `tools/update-version.ps1` 追加版本與 CHANGELOG。
- 可選擇執行 `flutter analyze`、`flutter build web --release` 與 PWA 快取更新。
- 只暫存指定的 PWA 路徑與四個版本檔案，再自動 commit、push。
- 選取的 PWA 路徑沒有 Git 差異時，仍可追加版本並重新建置、發布。
- 使用既有 Git for Windows Credential Manager，不儲存 GitHub Token。
- 不執行 `git reset`、`git checkout`，且偵測到既有 staged 檔案或遠端領先時會停止。
- push 失敗時保留本地 commit；再次按發布按鈕可直接重試 push，不會重複升版。

## 建置 EXE

在專案根目錄執行：

```powershell
powershell -ExecutionPolicy Bypass -File tools/BetterWaifuPwaPublisher/build.ps1
```

產物：

```text
tools/BetterWaifuPwaPublisher/release/BetterWaifuPwaPublisher.exe
```

這是使用 Windows 內建 .NET Framework 編譯的單一 x64 EXE，不需要攜帶 DLL。

## 煙霧測試

測試會建立隔離的暫存 Git repository 與 bare remote，不會碰觸真正的專案或 GitHub：

```powershell
powershell -ExecutionPolicy Bypass -File tools/BetterWaifuPwaPublisher/test.ps1
```
