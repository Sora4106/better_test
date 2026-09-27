import 'catalog_data.dart';

String _expressionSlug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

String _expressionIdToken(String category, String value) {
  if (category != 'symbols') return _expressionSlug(value);
  return value.codeUnits
      .map((codeUnit) => codeUnit.toRadixString(16))
      .join('_');
}

List<CatalogTagData> _expressionTags({
  required String category,
  required List<(String, String)> rows,
  bool adult = false,
  String? conflictGroup,
}) =>
    rows
        .map(
          (row) => CatalogTagData(
            id: 'expression_catalog_${category}_${_expressionIdToken(category, row.$2)}',
            group: '表情',
            zh: row.$1,
            en: row.$2,
            order: 3,
            adult: adult,
            conflictGroup: conflictGroup,
            support: 'official',
          ),
        )
        .toList();

/// Broad, bilingual expression catalogue based on the Danbooru face and eyes
/// tag groups used by Illustrious-derived models. Static anatomy (eye colour,
/// eye shape, fangs, and so on) remains in the character feature catalogue.
/// Previously registered English tags are de-duplicated by the app's central
/// tag index, so saved selections keep their original IDs.
final List<CatalogTagData> expressionCatalogTags = <CatalogTagData>[
  ..._expressionTags(
    category: 'eyes',
    conflictGroup: 'expression_eyes',
    rows: const [
      ('眨眼瞬間', 'blinking'),
      ('用力閉眼／畏縮瞇眼', 'wince'),
      ('睜大眼睛', 'wide-eyed'),
      ('鬥雞眼', 'cross-eyed'),
      ('懇求眼神', 'pleading eyes'),
      ('翻白眼', 'rolling eyes'),
      ('怒視', 'glaring'),
      ('眼球突出', 'bulging eyes'),
      ('驚訝瞪眼', 'eye pop'),
      ('眼神閃動', 'flashing eyes'),
      ('純白空白眼', 'blank eyes'),
      ('愛心形眼睛', 'heart-shaped eyes'),
      ('收縮瞳孔', 'constricted pupils'),
      ('放大瞳孔', 'dilated pupils'),
      ('看向遠方', 'looking afar'),
      ('環顧四周', 'looking around'),
      ('看著另一人', 'looking at another'),
      ('看著手', 'looking at hand'),
      ('看著雙手', 'looking at hands'),
      ('看著鏡子', 'looking at mirror'),
      ('看著物件', 'looking at object'),
      ('看著手機', 'looking at phone'),
      ('看著自己', 'looking at self'),
      ('回頭看', 'looking back'),
      ('看向外面', 'looking outside'),
      ('從眼鏡上方看', 'looking over eyewear'),
      ('看向側邊', 'looking to the side'),
      ('刻意避開視線', 'averting eyes'),
    ],
  ),
  ..._expressionTags(
    category: 'mouth',
    conflictGroup: 'expression_mouth',
    rows: const [
      ('皺嘴／不悅嘴型', 'frown'),
      ('鼓起臉頰', 'puffy cheeks'),
      ('痛苦扭曲嘴型', 'grimace'),
      ('放聲大笑', 'laughing'),
      ('忍住笑意', 'stifled laugh'),
      ('勉強微笑', 'forced smile'),
      ('緊張微笑', 'nervous smile'),
      ('悲傷微笑', 'sad smile'),
      ('假笑', 'false smile'),
      ('咬緊牙齒', 'gritted teeth'),
      ('上排牙齒可見', 'upper teeth'),
      ('下排牙齒可見', 'lower teeth'),
      ('嘴角流口水', 'mouth drool'),
      ('發光嘴巴', 'glowing mouth'),
      ('裂開嘴型', 'split mouth'),
      ('縫合嘴型', 'stitched mouth'),
      ('嘴內文字', 'text in mouth'),
      ('百合惠式嘴型', 'Yurie mouth'),
      ('嘆氣', 'sigh'),
      ('尖叫', 'screaming'),
      ('啜泣', 'sobbing'),
    ],
  ),
  ..._expressionTags(
    category: 'teasing',
    rows: const [
      ('自鳴得意臉', 'doyagao'),
      ('邪惡露齒笑', 'evil grin'),
    ],
  ),
  ..._expressionTags(
    category: 'teasing_adult',
    adult: true,
    rows: const [
      ('性興奮表情（成年角色）', 'aroused'),
      ('失神情慾表情（成年角色）', 'fucked silly'),
      ('陶醉情慾表情（成年角色）', 'torogao'),
      ('強烈高潮顏（成年角色）', 'ohogao'),
      ('張口陶醉顏（成年角色）', 'ohhoai'),
      ('口部邀請表情（成年角色）', 'oral invitation'),
    ],
  ),
  ..._expressionTags(
    category: 'symbols',
    rows: const [
      ('緊閉雙眼符號', '> <'),
      ('大小眼驚訝符號', 'O o'),
      ('圓形雙眼符號', '0 0'),
      ('彎曲雙眼符號', '3 3'),
      ('不對稱旋轉眼符號', '6 9'),
      ('旋轉暈眩眼符號', '@ @'),
      ('彎眼開心符號', '^ ^'),
      ('直線雙眼符號', '| |'),
      ('平淡雙眼符號', '= ='),
      ('十字雙眼符號', '+ +'),
      ('誇張圓眼符號', '<o> <o>'),
      ('誇張直瞳符號', '<|> <|>'),
      ('X 形雙眼符號', 'X X'),
      ('圓眼無言符號', '0_0'),
      ('方框眼符號', '|_|'),
      ('暈眩發亮眼符號', '+_+'),
      ('半暈眩眼符號', '+_-'),
      ('無奈平眼符號', '=_='),
      ('大哭符號', 'T_T'),
      ('單側暈眩符號', '>_@'),
      ('大笑閉眼符號', 'XD'),
      ('貓咪開心眼符號', 'x3'),
      ('開心彎眼符號', '^v^'),
      ('吐舌彎眼符號', '^q^'),
      ('圓眼貓嘴符號', '0w0'),
      ('柔和貓嘴符號', 'uwu'),
      ('圓眼噘嘴符號', 'o3o'),
      ('用力噘嘴符號', '>3<'),
    ],
  ),
  ..._expressionTags(
    category: 'emotion',
    rows: const [
      ('惱怒', 'annoyed'),
      ('無聊', 'bored'),
      ('困惑', 'confused'),
      ('瘋狂狀態', 'crazy'),
      ('絕望', 'despair'),
      ('堅定', 'determined'),
      ('失望', 'disappointed'),
      ('鄙視', 'disdain'),
      ('厭惡', 'disgust'),
      ('苦惱', 'distress'),
      ('醉意表情', 'drunk'),
      ('狂喜', 'ecstasy'),
      ('嫉妒', 'envy'),
      ('興奮', 'excited'),
      ('筋疲力盡', 'exhausted'),
      ('挫折', 'frustrated'),
      ('內疚', 'guilt'),
      ('開心', 'happy'),
      ('庫柏力克凝視', 'kubrick stare'),
      ('孤單', 'lonely'),
      ('疼痛表情', 'pain'),
      ('沮喪', 'depressed'),
      ('陰鬱表情', 'gloom (expression)'),
      ('懷疑', 'skeptical'),
      ('睏倦', 'sleepy'),
      ('鬧彆扭', 'sulking'),
      ('思考中', 'thinking'),
      ('沉思', 'pensive'),
      ('掙扎表情', 'struggling'),
      ('怒容', 'scowl'),
      ('全臉泛紅', 'full-face blush'),
      ('貼紙式腮紅', 'blush stickers'),
      ('雙眉上揚', 'raised eyebrows'),
      ('眉頭內側上揚', 'raised inner eyebrows'),
      ('V 形眉毛', 'v-shaped eyebrows'),
      ('臉部陰影', 'shaded face'),
      ('多重表情', 'multiple expressions'),
    ],
  ),
];
