const appVersion = '1.1.240';
const appBuildNumber = 242;
const appVersionLabel = '1.1.240+242';
const appVersionHistory = <Map<String, String>>[
  {'version': '1.1.240', 'build': '242', 'label': '1.1.240+242', 'date': '2026-10-15', 'notes': '修正艾爾之光轉職服裝目錄驗證，確保 PWA 部署可正常完成。'},
  {'version': '1.1.239', 'build': '241', 'label': '1.1.239+241', 'date': '2026-10-14', 'notes': '新增上半身動作與物件配色、可局部套用的整套配色表、原作設定服裝調整、服裝組合整併，以及艾爾之光轉職服裝。'},
  {'version': '1.1.238', 'build': '240', 'label': '1.1.238+240', 'date': '2026-10-12', 'notes': '自動偵測：chore: normalize pubspec whitespace'},
  {'version': '1.1.237', 'build': '239', 'label': '1.1.237+239', 'date': '2026-10-12', 'notes': '反推標籤改為保留括號階層：先解析人物數量與人物區塊，再以完整標籤優先處理角色、特徵、服裝、主次色與動作；多人內容分別回填，未對應詞保留到對應人物或共用額外欄位。'},
  {'version': '1.1.236', 'build': '238', 'label': '1.1.236+238', 'date': '2026-10-11', 'notes': '髮飾與頭飾維持原配件選單，但提示詞改併入人物特徵區塊，連同配色一起輸出'},
];
