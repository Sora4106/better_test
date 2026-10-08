const appVersion = '1.1.212';
const appBuildNumber = 214;
const appVersionLabel = '1.1.212+214';
const appVersionHistory = <Map<String, String>>[
  {'version': '1.1.212', 'build': '214', 'label': '1.1.212+214', 'date': '2026-10-09', 'notes': '依 Danbooru 現有標籤補入濕上衣、濕褲子、濕短褲、濕裙子、濕洋裝、濕胸罩、濕內褲、濕襪子與濕連褲襪。; 體液分類新增尿液（pee）、排尿（peeing）與尿濕自己（peeing self）；未採用無法確認的 urine、urination、urine stain。'},
  {'version': '1.1.211', 'build': '213', 'label': '1.1.211+213', 'date': '2026-10-08', 'notes': '新增手指掰開陰道、陰唇與陰道口擴張相關標籤。; 新增整套配色表，可將主色與可選次色套用至目前已選服裝與配件。'},
  {'version': '1.1.210', 'build': '212', 'label': '1.1.210+212', 'date': '2026-10-07', 'notes': '擴充「體液」成人標籤：新增陰道體液射出（female ejaculation）、陰道體液噴射（squirting）、陰道精液流出（cum from pussy）與陰道精液滴落（cumdrip）；保留既有體內射精與陰道內精液。'},
  {'version': '1.1.209', 'build': '211', 'label': '1.1.209+211', 'date': '2026-10-07', 'notes': '在輸出結果區新增可見的「匯出目前選擇 JSON／匯入目前選擇 JSON」按鈕；JSON 會保存目前各人物、標籤分區、權重與額外正向詞，匯入時覆蓋並依原欄位回填。'},
  {'version': '1.1.208', 'build': '210', 'label': '1.1.208+210', 'date': '2026-10-07', 'notes': '完整狀態備份改為分區 JSON：直接保存已勾選標籤、人物欄位、服裝／姿勢額外正向詞、權重、套裝與負面詞，匯入會覆蓋回填，並保留舊備份相容。; 標籤反推改為先自動分析預覽：列出可對應的中英文標籤與未對應詞；確認後才套用，未對應詞可自行決定是否加入額外正向標籤。'},
];
