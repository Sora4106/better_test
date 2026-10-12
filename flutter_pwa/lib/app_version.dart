const appVersion = '1.1.238';
const appBuildNumber = 240;
const appVersionLabel = '1.1.238+240';
const appVersionHistory = <Map<String, String>>[
  {'version': '1.1.238', 'build': '240', 'label': '1.1.238+240', 'date': '2026-10-12', 'notes': '自動偵測：chore: normalize pubspec whitespace'},
  {'version': '1.1.237', 'build': '239', 'label': '1.1.237+239', 'date': '2026-10-12', 'notes': '反推標籤改為保留括號階層：先解析人物數量與人物區塊，再以完整標籤優先處理角色、特徵、服裝、主次色與動作；多人內容分別回填，未對應詞保留到對應人物或共用額外欄位。'},
  {'version': '1.1.236', 'build': '238', 'label': '1.1.236+238', 'date': '2026-10-11', 'notes': '髮飾與頭飾維持原配件選單，但提示詞改併入人物特徵區塊，連同配色一起輸出'},
  {'version': '1.1.235', 'build': '237', 'label': '1.1.235+237', 'date': '2026-10-11', 'notes': '原創與動漫角色改為真正互斥；原創角色可在角色區或第4項儲存，並立即列入原創角色清單'},
  {'version': '1.1.234', 'build': '236', 'label': '1.1.234+236', 'date': '2026-10-11', 'notes': '新增原創角色特徵預設：可用第4項既有特徵與手動特徵命名儲存、套用時不輸出名稱'},
];
