import 'catalog_data.dart';
import 'outfit_reference_data.dart';

/// A bilingual visual phrase that belongs inside a single class-outfit block.
/// They are deliberately editable description helpers, not claims that every
/// phrase is an exact model trigger tag.
class _ElswordStyleDetail {
  const _ElswordStyleDetail(this.zh, this.en);

  final String zh;
  final String en;
}

/// A visual starting point for one Elsword job path. Hair traits use existing
/// selectable feature tags, while [details] stay grouped with the outfit.
class _ElswordJobLook {
  const _ElswordJobLook({
    required this.palette,
    this.hairTags = const <String>[],
    this.details = const <_ElswordStyleDetail>[],
  });

  final String palette;
  final List<String> hairTags;
  final List<_ElswordStyleDetail> details;
}

class _ElswordJobOutfit {
  const _ElswordJobOutfit(
      this.characterZh, this.characterEn, this.jobZh, this.jobEn);

  final String characterZh;
  final String characterEn;
  final String jobZh;
  final String jobEn;

  String get id =>
      'taxonomy_costume_elsword_${characterEn.toLowerCase()}_${jobEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '')}';
  String get zh => '$characterZh・$jobZh轉職服裝';
  String get en => 'Elsword $characterEn $jobEn official class outfit';

  String get ownerCharacterTag => switch (characterEn) {
        'Aisha' => 'aisha landar',
        'Rena' => 'rena erindel',
        'Eve' => 'eve (elsword)',
        'Ara' => 'ara haan',
        'Elesis' => 'elesis (elsword)',
        _ => '',
      };

  _ElswordJobLook get look {
    final looks = switch (characterEn) {
      'Aisha' => _aishaLooks,
      'Rena' => _renaLooks,
      'Eve' => _eveLooks,
      'Ara' => _araLooks,
      'Elesis' => _elesisLooks,
      _ => const <String, _ElswordJobLook>{},
    };
    return looks[jobEn] ?? _fallbackLook;
  }

  List<String> get featureTags {
    final base = switch (characterEn) {
      'Aisha' => const ['purple hair', 'long hair', 'purple eyes'],
      'Rena' => const ['green hair', 'long hair'],
      'Eve' => const ['blonde hair', 'long hair'],
      'Ara' => const ['black hair', 'long hair'],
      'Elesis' => const ['red hair', 'long hair'],
      _ => const <String>[],
    };
    return {...base, ...look.hairTags}.toList(growable: false);
  }

  List<_ElswordStyleDetail> get visualDetails => [
        _ElswordStyleDetail('$jobZh職業套裝', '${jobEn.toLowerCase()} outfit'),
        ...look.details,
      ];
}

String _elswordVisualDetailId(String english) =>
    'elsword_detail_${english.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'^_|_$'), '')}';

const _fallbackLook = _ElswordJobLook(
  palette: '依原作職業設計',
  details: [
    _ElswordStyleDetail('原作職業剪裁', 'original class outfit design'),
  ],
);

const _aishaLooks = <String, _ElswordJobLook>{
  'High Magician': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色',
    hairTags: ['low twintails', 'ahoge', 'x-shaped hairclip'],
    details: [
      _ElswordStyleDetail('白紫法師長外套', 'white and purple mage coat'),
      _ElswordStyleDetail('粉紅胸前蝴蝶結', 'large pink chest bow'),
      _ElswordStyleDetail('寶石胸針', 'gemstone brooch'),
      _ElswordStyleDetail('寬大袖口', 'wide sleeves'),
    ],
  ),
  'Elemental Master': _ElswordJobLook(
    palette: '白色 × 紫色 × 粉紅色',
    hairTags: ['low twintails', 'ahoge', 'x-shaped hairclip'],
    details: [
      _ElswordStyleDetail('白色連帽長外套', 'white hooded coat'),
      _ElswordStyleDetail('放下的帽兜', 'hood down'),
      _ElswordStyleDetail('白色短斗篷', 'white capelet'),
      _ElswordStyleDetail('紫色滾邊', 'purple trim'),
      _ElswordStyleDetail('粉紅色滾邊', 'pink trim'),
      _ElswordStyleDetail('大型粉紅胸前蝴蝶結', 'large pink chest bow'),
      _ElswordStyleDetail('粉紅領結', 'pink bowtie'),
      _ElswordStyleDetail('胸前緞帶', 'chest ribbon'),
      _ElswordStyleDetail('大型寶石胸針', 'large gemstone brooch'),
      _ElswordStyleDetail('深紫高領毛衣', 'dark purple turtleneck sweater'),
      _ElswordStyleDetail('黑紫色貼身馬甲', 'black and purple fitted bodice'),
      _ElswordStyleDetail('黑色背心層', 'black vest'),
      _ElswordStyleDetail('白色寬大袖子', 'white oversized sleeves'),
      _ElswordStyleDetail('紫色百褶迷你裙', 'purple pleated miniskirt'),
      _ElswordStyleDetail('粉紅色裙裝點綴', 'pink skirt accents'),
      _ElswordStyleDetail('黑色大腿襪', 'black thighhighs'),
      _ElswordStyleDetail('粉紅大腿襪圖樣', 'pink markings on thighhighs'),
      _ElswordStyleDetail('白色大腿環帶', 'white thigh strap'),
      _ElswordStyleDetail('白粉寶石踝靴', 'white and pink jeweled ankle boots'),
      _ElswordStyleDetail(
          '水晶流蘇飾件', 'hanging crystal ornaments and crystal tassels'),
    ],
  ),
  'Aether Sage': _ElswordJobLook(
    palette: '白色 × 天藍色 × 金色',
    hairTags: ['twintails', 'ahoge'],
    details: [
      _ElswordStyleDetail('白藍以太法師外套', 'white and light blue aether mage coat'),
      _ElswordStyleDetail('金色幾何飾邊', 'gold geometric trim'),
      _ElswordStyleDetail('浮游水晶飾品', 'floating crystal ornaments'),
      _ElswordStyleDetail('分層短斗篷', 'layered capelet'),
    ],
  ),
  'Dark Magician': _ElswordJobLook(
    palette: '黑色 × 深紫色 × 酒紅色',
    hairTags: ['long straight hair', 'hair over one eye'],
    details: [
      _ElswordStyleDetail('黑紫暗黑法師洋裝', 'black and dark purple mage dress'),
      _ElswordStyleDetail('酒紅色蝴蝶結', 'burgundy bow'),
      _ElswordStyleDetail('黑色短斗篷', 'black capelet'),
      _ElswordStyleDetail('暗色寶石飾品', 'dark gemstone ornaments'),
    ],
  ),
  'Void Princess': _ElswordJobLook(
    palette: '黑色 × 紫色 × 洋紅色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('黑紫虛空公主禮服', 'black and purple void princess dress'),
      _ElswordStyleDetail('洋紅蝙蝠結飾', 'magenta bat-shaped ribbons'),
      _ElswordStyleDetail('高領束腰馬甲', 'high-neck corset bodice'),
      _ElswordStyleDetail('分層深色裙襬', 'layered dark skirt'),
    ],
  ),
  'Oz Sorcerer': _ElswordJobLook(
    palette: '黑色 × 紫色 × 粉紅色',
    hairTags: ['very long hair', 'twintails'],
    details: [
      _ElswordStyleDetail('黑紫奧茲魔女套裝', 'black and purple sorcerer outfit'),
      _ElswordStyleDetail('粉紅魔法緞帶', 'pink magic ribbons'),
      _ElswordStyleDetail('尖帽與短斗篷', 'witch hat and capelet'),
      _ElswordStyleDetail('發光寶石飾品', 'glowing gemstone ornaments'),
    ],
  ),
  'Battle Magician': _ElswordJobLook(
    palette: '黑色 × 紫色 × 金色',
    hairTags: ['high ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('黑紫戰鬥法師上衣', 'black and purple battle mage top'),
      _ElswordStyleDetail('金色護腕與護甲飾邊', 'gold bracers and armor trim'),
      _ElswordStyleDetail('貼身馬甲', 'fitted bodice'),
      _ElswordStyleDetail('披肩斗篷', 'shoulder capelet'),
    ],
  ),
  'Dimension Witch': _ElswordJobLook(
    palette: '靛藍色 × 紫色 × 銀色',
    hairTags: ['long hair', 'double bun'],
    details: [
      _ElswordStyleDetail('靛藍次元魔女外套', 'indigo dimension witch coat'),
      _ElswordStyleDetail('銀色月相飾邊', 'silver lunar trim'),
      _ElswordStyleDetail('星空內襯', 'starry inner lining'),
      _ElswordStyleDetail('環狀魔法飾品', 'orbital magic ornaments'),
    ],
  ),
  'Metamorphy': _ElswordJobLook(
    palette: '黑色 × 洋紅色 × 紫色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑洋紅變形法師裝', 'black and magenta metamorphy outfit'),
      _ElswordStyleDetail('發光心形寶石', 'glowing heart-shaped gemstone'),
      _ElswordStyleDetail('短版魔法外套', 'cropped magic jacket'),
      _ElswordStyleDetail('分層百褶短裙', 'layered pleated miniskirt'),
    ],
  ),
  'Wiz Magician': _ElswordJobLook(
    palette: '紫色 × 金色 × 白色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('紫金鍊金術師外套', 'purple and gold alchemist coat'),
      _ElswordStyleDetail('魔法瓶腰飾', 'alchemy flask belt ornaments'),
      _ElswordStyleDetail('白色袖口', 'white sleeve cuffs'),
      _ElswordStyleDetail('鍊金術徽章', 'alchemist emblem'),
    ],
  ),
  'Mystic Alchemist': _ElswordJobLook(
    palette: '青綠色 × 白色 × 棕色',
    hairTags: ['low ponytail', 'ahoge'],
    details: [
      _ElswordStyleDetail('青綠神秘鍊金外套', 'teal mystic alchemist coat'),
      _ElswordStyleDetail('白色實驗短斗篷', 'white laboratory capelet'),
      _ElswordStyleDetail('皮革瓶罐腰帶', 'leather vial belt'),
      _ElswordStyleDetail('鍊金結晶飾件', 'alchemical crystal ornaments'),
    ],
  ),
  'Lord Azoth': _ElswordJobLook(
    palette: '白色 × 金色 × 青綠色',
    hairTags: ['very long hair', 'long straight hair'],
    details: [
      _ElswordStyleDetail('白金亞佐特領主長袍', 'white and gold lord azoth robe'),
      _ElswordStyleDetail('青綠賢者石飾品', 'teal philosopher stone ornaments'),
      _ElswordStyleDetail('長版鍊金披肩', 'long alchemist mantle'),
      _ElswordStyleDetail('精緻金屬飾邊', 'ornate metallic trim'),
    ],
  ),
};

const _renaLooks = <String, _ElswordJobLook>{
  'Combat Ranger': _ElswordJobLook(
    palette: '綠色 × 棕色 × 白色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('綠棕戰鬥遊俠服', 'green and brown combat ranger outfit'),
      _ElswordStyleDetail('皮革護腕', 'leather arm guards'),
      _ElswordStyleDetail('遊俠斗篷', 'ranger capelet'),
    ],
  ),
  'Wind Sneaker': _ElswordJobLook(
    palette: '白色 × 綠色 × 天藍色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('白綠疾風武鬥服', 'white and green wind fighter outfit'),
      _ElswordStyleDetail('飄帶腰封', 'flowing sash belt'),
      _ElswordStyleDetail('腿部綁帶', 'leg wraps'),
    ],
  ),
  'Anemos': _ElswordJobLook(
    palette: '白色 × 青綠色 × 金色',
    hairTags: ['wavy hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail(
          '白青風靈舞者套裝', 'white and teal wind spirit dancer outfit'),
      _ElswordStyleDetail('羽毛披肩', 'feathered shoulder cape'),
      _ElswordStyleDetail('金色風紋飾邊', 'gold wind-pattern trim'),
    ],
  ),
  'Sniping Ranger': _ElswordJobLook(
    palette: '森林綠 × 棕色 × 黑色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('森林綠狙擊遊俠外套', 'forest green sniping ranger coat'),
      _ElswordStyleDetail('箭袋腰帶', 'quiver belt'),
      _ElswordStyleDetail('皮革護手', 'leather gloves'),
    ],
  ),
  'Grand Archer': _ElswordJobLook(
    palette: '白色 × 金色 × 綠色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('白金大弓手斗篷', 'white and gold grand archer cape'),
      _ElswordStyleDetail('綠色精靈飾邊', 'green elven trim'),
      _ElswordStyleDetail('裝飾箭袋', 'ornate quiver'),
    ],
  ),
  'Daybreaker': _ElswordJobLook(
    palette: '白色 × 金色 × 淺藍色',
    hairTags: ['long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金破曉弓手禮服', 'white and gold daybreaker archer dress'),
      _ElswordStyleDetail('淺藍靈石飾品', 'light blue spirit stone ornaments'),
      _ElswordStyleDetail('飄逸肩披', 'flowing shoulder mantle'),
    ],
  ),
  'Trapping Ranger': _ElswordJobLook(
    palette: '黑色 × 深綠色 × 棕色',
    hairTags: ['low ponytail'],
    details: [
      _ElswordStyleDetail(
          '黑綠陷阱遊俠服', 'black and dark green trapping ranger outfit'),
      _ElswordStyleDetail('工具腰帶', 'utility belt'),
      _ElswordStyleDetail('皮革短斗篷', 'leather capelet'),
    ],
  ),
  'Night Watcher': _ElswordJobLook(
    palette: '黑色 × 深藍色 × 銀色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('黑藍夜巡者鎧裝', 'black and navy night watcher armor'),
      _ElswordStyleDetail('銀色月紋飾邊', 'silver moon-pattern trim'),
      _ElswordStyleDetail('偵察披風', 'scout cloak'),
    ],
  ),
  'Twilight': _ElswordJobLook(
    palette: '黑色 × 紫色 × 深綠色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('暮光精靈披風', 'twilight elven cloak'),
      _ElswordStyleDetail('紫黑輕甲', 'purple and black light armor'),
      _ElswordStyleDetail('森林徽章', 'forest emblem'),
    ],
  ),
  'Poetic Ranger': _ElswordJobLook(
    palette: '象牙白 × 天藍色 × 金色',
    hairTags: ['long hair', 'twin braids'],
    details: [
      _ElswordStyleDetail('象牙白詩歌遊俠服', 'ivory poetic ranger outfit'),
      _ElswordStyleDetail('藍色吟遊飄帶', 'blue bard ribbons'),
      _ElswordStyleDetail('金色羽飾', 'gold feather ornaments'),
    ],
  ),
  'Tale Spinner': _ElswordJobLook(
    palette: '藍色 × 金色 × 白色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('藍金說書人套裝', 'blue and gold tale spinner outfit'),
      _ElswordStyleDetail('長版吟遊披肩', 'long bard mantle'),
      _ElswordStyleDetail('樂譜飾品', 'musical score ornaments'),
    ],
  ),
  'Prophetess': _ElswordJobLook(
    palette: '白色 × 青綠色 × 金色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白青預言者長袍', 'white and teal prophetess robe'),
      _ElswordStyleDetail('金色預言飾鏈', 'gold prophecy chains'),
      _ElswordStyleDetail('水晶頭飾', 'crystal head ornament'),
    ],
  ),
};

const _eveLooks = <String, _ElswordJobLook>{
  'Code: Exotic': _ElswordJobLook(
    palette: '黑色 × 紅色 × 銀色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('黑紅納斯德戰鬥裝甲', 'black and red nasod battle armor'),
      _ElswordStyleDetail('機械手臂飾件', 'mechanical arm ornaments'),
      _ElswordStyleDetail('銀色金屬護甲', 'silver metallic armor'),
    ],
  ),
  'Code: Nemesis': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白藍納斯德女王裝甲', 'white and blue nasod queen armor'),
      _ElswordStyleDetail('金色機械冠飾', 'gold mechanical crown ornament'),
      _ElswordStyleDetail('裝甲裙襬', 'armored skirt panels'),
    ],
  ),
  'Code: Ultimate': _ElswordJobLook(
    palette: '黑色 × 紅色 × 紫色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑紅終極戰鬥裝甲', 'black and red ultimate battle armor'),
      _ElswordStyleDetail('紫色能量核心', 'purple energy core'),
      _ElswordStyleDetail('機械護腿', 'mechanical leg guards'),
    ],
  ),
  'Code: Architecture': _ElswordJobLook(
    palette: '白色 × 天藍色 × 金色',
    hairTags: ['long straight hair'],
    details: [
      _ElswordStyleDetail('白藍建築師洋裝', 'white and light blue architecture dress'),
      _ElswordStyleDetail('金色機械緞帶', 'gold mechanical ribbons'),
      _ElswordStyleDetail('人偶風裙襬', 'doll-like skirt panels'),
    ],
  ),
  'Code: Empress': _ElswordJobLook(
    palette: '黑色 × 白色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑白皇后禮服', 'black and white empress dress'),
      _ElswordStyleDetail('金色機械冠飾', 'gold mechanical crown'),
      _ElswordStyleDetail('分層機械裙片', 'layered mechanical skirt panels'),
    ],
  ),
  'Code: Esencia': _ElswordJobLook(
    palette: '白色 × 藍色 × 淡金色',
    hairTags: ['long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白藍艾森希雅禮服', 'white and blue esencia dress'),
      _ElswordStyleDetail('淡金機械飾件', 'pale gold mechanical ornaments'),
      _ElswordStyleDetail('優雅分層裙襬', 'elegant layered skirt panels'),
    ],
  ),
  'Code: Electra': _ElswordJobLook(
    palette: '黑色 × 電光藍 × 白色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑藍電能戰衣', 'black and electric blue combat suit'),
      _ElswordStyleDetail('發光電路飾邊', 'glowing circuit trim'),
      _ElswordStyleDetail('機械護臂', 'mechanical arm guards'),
    ],
  ),
  'Code: Battle Seraph': _ElswordJobLook(
    palette: '白色 × 金色 × 淺藍色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('白金戰鬥熾天使裝甲', 'white and gold battle seraph armor'),
      _ElswordStyleDetail('淺藍發光核心', 'light blue glowing core'),
      _ElswordStyleDetail('翼狀機械飾件', 'wing-shaped mechanical ornaments'),
    ],
  ),
  'Code: Sariel': _ElswordJobLook(
    palette: '白色 × 金色 × 天藍色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金沙利葉禮服', 'white and gold sariel dress'),
      _ElswordStyleDetail('天藍能量線條', 'sky blue energy lines'),
      _ElswordStyleDetail('浮游機械光環', 'floating mechanical halo'),
    ],
  ),
  'Code: Unknown': _ElswordJobLook(
    palette: '黑色 × 紫色 × 青色',
    hairTags: ['long hair', 'hair over one eye'],
    details: [
      _ElswordStyleDetail('黑紫未知代碼戰衣', 'black and purple unknown code outfit'),
      _ElswordStyleDetail('青色故障光效飾件', 'cyan glitch-light ornaments'),
      _ElswordStyleDetail('不對稱護甲', 'asymmetrical armor'),
    ],
  ),
  'Code: Failess': _ElswordJobLook(
    palette: '白色 × 黑色 × 洋紅色',
    hairTags: ['long hair', 'messy hair'],
    details: [
      _ElswordStyleDetail('黑白無瑕代碼禮服', 'black and white failess dress'),
      _ElswordStyleDetail('洋紅錯誤光紋', 'magenta error-light patterns'),
      _ElswordStyleDetail('破碎機械飾片', 'fractured mechanical ornaments'),
    ],
  ),
  'Code: Antithese': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 銀色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail(
          '黑紅反命題裝甲禮服', 'black and dark red antithese armor dress'),
      _ElswordStyleDetail('銀色尖銳飾邊', 'silver sharp trim'),
      _ElswordStyleDetail('機械王冠飾件', 'mechanical crown ornaments'),
    ],
  ),
};

const _araLooks = <String, _ElswordJobLook>{
  'Little Hsien': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('白藍仙術韓服', 'white and blue martial hanfu'),
      _ElswordStyleDetail('金色雲紋飾邊', 'gold cloud-pattern trim'),
      _ElswordStyleDetail('飄帶腰封', 'flowing sash belt'),
    ],
  ),
  'Sakra Devanam': _ElswordJobLook(
    palette: '藍色 × 金色 × 白色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('藍金護法武術服', 'blue and gold guardian martial outfit'),
      _ElswordStyleDetail('裝甲護肩', 'armored shoulder guards'),
      _ElswordStyleDetail('神聖符文飾品', 'sacred rune ornaments'),
    ],
  ),
  'Apsara': _ElswordJobLook(
    palette: '白色 × 青色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白青天女戰袍', 'white and cyan apsara battle robe'),
      _ElswordStyleDetail('金色飄帶', 'gold flowing ribbons'),
      _ElswordStyleDetail('長袖武術上衣', 'long-sleeved martial top'),
    ],
  ),
  'Little Devil': _ElswordJobLook(
    palette: '黑色 × 紅色 × 紫色',
    hairTags: ['long hair', 'double bun'],
    details: [
      _ElswordStyleDetail(
          '黑紅小魔武術服', 'black and red little devil martial outfit'),
      _ElswordStyleDetail('紫色惡魔飾品', 'purple demon ornaments'),
      _ElswordStyleDetail('短版外套', 'cropped jacket'),
    ],
  ),
  'Yama Raja': _ElswordJobLook(
    palette: '黑色 × 深紫色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail(
          '黑紫冥王戰袍', 'black and dark purple yama raja battle robe'),
      _ElswordStyleDetail('金色鬼面飾件', 'gold oni-mask ornaments'),
      _ElswordStyleDetail('重疊腰封', 'layered waist sash'),
    ],
  ),
  'Devi': _ElswordJobLook(
    palette: '深紅色 × 黑色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('深紅帝魔長袍', 'dark red devi robe'),
      _ElswordStyleDetail('黑金戰甲飾邊', 'black and gold armor trim'),
      _ElswordStyleDetail('惡魔花紋', 'demon-pattern ornaments'),
    ],
  ),
  'Little Specter': _ElswordJobLook(
    palette: '白色 × 藍色 × 粉紅色',
    hairTags: ['high ponytail', 'hair ribbon'],
    details: [
      _ElswordStyleDetail('白藍靈狐術士服', 'white and blue fox spirit outfit'),
      _ElswordStyleDetail('粉紅符紙飾品', 'pink talisman ornaments'),
      _ElswordStyleDetail('短斗篷', 'capelet'),
    ],
  ),
  'Asura': _ElswordJobLook(
    palette: '黑色 × 藍色 × 銀色',
    hairTags: ['long hair', 'side braid'],
    details: [
      _ElswordStyleDetail('黑藍修羅戰鬥服', 'black and blue asura battle outfit'),
      _ElswordStyleDetail('銀色狐火飾邊', 'silver foxfire trim'),
      _ElswordStyleDetail('不對稱護甲', 'asymmetrical armor'),
    ],
  ),
  'Shakti': _ElswordJobLook(
    palette: '白色 × 金色 × 粉紅色',
    hairTags: ['very long hair', 'wavy hair'],
    details: [
      _ElswordStyleDetail('白金夏克提長袍', 'white and gold shakti robe'),
      _ElswordStyleDetail('粉紅靈狐飄帶', 'pink fox spirit ribbons'),
      _ElswordStyleDetail('寶石腰飾', 'gemstone waist ornaments'),
    ],
  ),
  'Little Helper': _ElswordJobLook(
    palette: '白色 × 綠色 × 金色',
    hairTags: ['long hair', 'twin braids'],
    details: [
      _ElswordStyleDetail('白綠靈獸使服', 'white and green spirit keeper outfit'),
      _ElswordStyleDetail('金色護符飾件', 'gold talisman ornaments'),
      _ElswordStyleDetail('分層短袍', 'layered cropped robe'),
    ],
  ),
  'Marici': _ElswordJobLook(
    palette: '珊瑚色 × 白色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('珊瑚白摩利西亞套裝', 'coral and white marici outfit'),
      _ElswordStyleDetail('金色靈獸紋飾', 'gold sacred beast ornaments'),
      _ElswordStyleDetail('長版袖飾', 'long sleeve ornaments'),
    ],
  ),
  'Surya': _ElswordJobLook(
    palette: '白色 × 金色 × 橘色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('白金蘇利耶禮服', 'white and gold surya robe'),
      _ElswordStyleDetail('橘金日輪飾品', 'orange and gold sun-disc ornaments'),
      _ElswordStyleDetail('長披肩', 'long shoulder mantle'),
    ],
  ),
};

const _elesisLooks = <String, _ElswordJobLook>{
  'Saber Knight': _ElswordJobLook(
    palette: '紅色 × 銀色 × 黑色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('紅銀軍刀騎士裝甲', 'red and silver saber knight armor'),
      _ElswordStyleDetail('黑色短披風', 'black capelet'),
      _ElswordStyleDetail('金屬護腕', 'metal bracers'),
    ],
  ),
  'Grand Master': _ElswordJobLook(
    palette: '白色 × 金色 × 紅色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('白金大師騎士裝甲', 'white and gold grand master armor'),
      _ElswordStyleDetail('紅色披風', 'red knight cape'),
      _ElswordStyleDetail('皇家徽章', 'royal emblem'),
    ],
  ),
  'Empire Sword': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('黑紅帝國之劍裝甲', 'black and dark red empire sword armor'),
      _ElswordStyleDetail('金色軍裝飾邊', 'gold military trim'),
      _ElswordStyleDetail('長披風', 'long cape'),
    ],
  ),
  'Pyro Knight': _ElswordJobLook(
    palette: '黑色 × 橘色 × 紅色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('黑橘烈焰騎士裝甲', 'black and orange pyro knight armor'),
      _ElswordStyleDetail('火焰紋飾邊', 'flame-pattern trim'),
      _ElswordStyleDetail('護肩鎧甲', 'armored pauldrons'),
    ],
  ),
  'Blazing Heart': _ElswordJobLook(
    palette: '紅色 × 黑色 × 金色',
    hairTags: ['long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail(
          '紅黑熾炎之心戰衣', 'red and black blazing heart battle outfit'),
      _ElswordStyleDetail('金色火焰飾件', 'gold flame ornaments'),
      _ElswordStyleDetail('貼身護甲馬甲', 'fitted armor bodice'),
    ],
  ),
  'Flame Lord': _ElswordJobLook(
    palette: '深紅色 × 黑色 × 橘色',
    hairTags: ['very long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('深紅炎之領主裝甲', 'dark red flame lord armor'),
      _ElswordStyleDetail('黑色熔岩披風', 'black lava-pattern cape'),
      _ElswordStyleDetail('橘色火焰飾邊', 'orange flame trim'),
    ],
  ),
  'Dark Knight': _ElswordJobLook(
    palette: '黑色 × 紫色 × 銀色',
    hairTags: ['long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑紫暗黑騎士裝甲', 'black and purple dark knight armor'),
      _ElswordStyleDetail('銀色尖刺飾件', 'silver spiked ornaments'),
      _ElswordStyleDetail('暗色長披風', 'dark long cape'),
    ],
  ),
  'Crimson Avenger': _ElswordJobLook(
    palette: '黑色 × 深紅色 × 銀色',
    hairTags: ['long hair', 'messy hair'],
    details: [
      _ElswordStyleDetail(
          '黑紅緋紅復仇者戰衣', 'black and dark red crimson avenger outfit'),
      _ElswordStyleDetail('銀色束帶護甲', 'silver strapped armor'),
      _ElswordStyleDetail('破損披風', 'tattered cape'),
    ],
  ),
  'Bloody Queen': _ElswordJobLook(
    palette: '黑色 × 血紅色 × 金色',
    hairTags: ['very long hair', 'straight hair'],
    details: [
      _ElswordStyleDetail('黑紅血腥女王禮服', 'black and blood-red bloody queen dress'),
      _ElswordStyleDetail('金色王冠飾件', 'gold crown ornaments'),
      _ElswordStyleDetail('裝甲裙襬', 'armored skirt panels'),
    ],
  ),
  'Soar Knight': _ElswordJobLook(
    palette: '海軍藍 × 銀色 × 白色',
    hairTags: ['high ponytail'],
    details: [
      _ElswordStyleDetail('藍銀飛空騎士裝甲', 'navy and silver soar knight armor'),
      _ElswordStyleDetail('白色長披風', 'white long cape'),
      _ElswordStyleDetail('藍色寶石護甲', 'blue gemstone armor'),
    ],
  ),
  'Patrona': _ElswordJobLook(
    palette: '白色 × 藍色 × 金色',
    hairTags: ['long hair', 'side ponytail'],
    details: [
      _ElswordStyleDetail('白藍帕特羅娜騎士裝', 'white and blue patrona knight outfit'),
      _ElswordStyleDetail('金色記憶徽章', 'gold memory emblem'),
      _ElswordStyleDetail('精緻肩甲', 'ornate shoulder armor'),
    ],
  ),
  'Adrestia': _ElswordJobLook(
    palette: '白色 × 藍色 × 銀色',
    hairTags: ['very long hair', 'high ponytail'],
    details: [
      _ElswordStyleDetail('白藍阿德雷斯緹亞裝甲', 'white and blue adrestia armor'),
      _ElswordStyleDetail('發光藍色左臂護甲', 'glowing blue left-arm armor'),
      _ElswordStyleDetail('銀色聖劍飾件', 'silver holy-sword ornaments'),
      _ElswordStyleDetail('長版王族披風', 'long royal cape'),
    ],
  ),
};

const _elswordJobs = <_ElswordJobOutfit>[
  _ElswordJobOutfit('愛莎', 'Aisha', '高階魔術師', 'High Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '元素大師', 'Elemental Master'),
  _ElswordJobOutfit('愛莎', 'Aisha', '以太賢者', 'Aether Sage'),
  _ElswordJobOutfit('愛莎', 'Aisha', '闇黑魔術師', 'Dark Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '虛無公主', 'Void Princess'),
  _ElswordJobOutfit('愛莎', 'Aisha', '奧茲魔術師', 'Oz Sorcerer'),
  _ElswordJobOutfit('愛莎', 'Aisha', '戰鬥魔術師', 'Battle Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '次元魔女', 'Dimension Witch'),
  _ElswordJobOutfit('愛莎', 'Aisha', '鍊金變形者', 'Metamorphy'),
  _ElswordJobOutfit('愛莎', 'Aisha', '巫師魔術師', 'Wiz Magician'),
  _ElswordJobOutfit('愛莎', 'Aisha', '神秘鍊金術師', 'Mystic Alchemist'),
  _ElswordJobOutfit('愛莎', 'Aisha', '亞佐特領主', 'Lord Azoth'),
  _ElswordJobOutfit('蕾娜', 'Rena', '戰鬥遊俠', 'Combat Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '疾風之靴', 'Wind Sneaker'),
  _ElswordJobOutfit('蕾娜', 'Rena', '安涅莫斯', 'Anemos'),
  _ElswordJobOutfit('蕾娜', 'Rena', '狙擊遊俠', 'Sniping Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '大弓手', 'Grand Archer'),
  _ElswordJobOutfit('蕾娜', 'Rena', '破曉者', 'Daybreaker'),
  _ElswordJobOutfit('蕾娜', 'Rena', '陷阱遊俠', 'Trapping Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '夜行者', 'Night Watcher'),
  _ElswordJobOutfit('蕾娜', 'Rena', '暮光', 'Twilight'),
  _ElswordJobOutfit('蕾娜', 'Rena', '詩意遊俠', 'Poetic Ranger'),
  _ElswordJobOutfit('蕾娜', 'Rena', '說書人', 'Tale Spinner'),
  _ElswordJobOutfit('蕾娜', 'Rena', '預言者', 'Prophetess'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Exotic', 'Code: Exotic'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Nemesis', 'Code: Nemesis'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Ultimate', 'Code: Ultimate'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Architecture', 'Code: Architecture'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Empress', 'Code: Empress'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Esencia', 'Code: Esencia'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Electra', 'Code: Electra'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Battle Seraph', 'Code: Battle Seraph'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Sariel', 'Code: Sariel'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Unknown', 'Code: Unknown'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Failess', 'Code: Failess'),
  _ElswordJobOutfit('伊芙', 'Eve', 'Code: Antithese', 'Code: Antithese'),
  _ElswordJobOutfit('亞拉', 'Ara', '小仙', 'Little Hsien'),
  _ElswordJobOutfit('亞拉', 'Ara', '帝天', 'Sakra Devanam'),
  _ElswordJobOutfit('亞拉', 'Ara', '阿修羅', 'Apsara'),
  _ElswordJobOutfit('亞拉', 'Ara', '小魔', 'Little Devil'),
  _ElswordJobOutfit('亞拉', 'Ara', '冥王', 'Yama Raja'),
  _ElswordJobOutfit('亞拉', 'Ara', '帝魔', 'Devi'),
  _ElswordJobOutfit('亞拉', 'Ara', '小靈', 'Little Specter'),
  _ElswordJobOutfit('亞拉', 'Ara', '修羅', 'Asura'),
  _ElswordJobOutfit('亞拉', 'Ara', '修緹', 'Shakti'),
  _ElswordJobOutfit('亞拉', 'Ara', '小輔', 'Little Helper'),
  _ElswordJobOutfit('亞拉', 'Ara', '摩利西亞', 'Marici'),
  _ElswordJobOutfit('亞拉', 'Ara', '蘇利耶', 'Surya'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '劍騎士', 'Saber Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '大師劍士', 'Grand Master'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '帝國之劍', 'Empire Sword'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '烈焰騎士', 'Pyro Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '熾炎之心', 'Blazing Heart'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '火焰領主', 'Flame Lord'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '闇黑騎士', 'Dark Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '緋紅復仇者', 'Crimson Avenger'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '血腥女王', 'Bloody Queen'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '飛空騎士', 'Soar Knight'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '帕特羅娜', 'Patrona'),
  _ElswordJobOutfit('艾麗希斯', 'Elesis', '阿德雷斯緹亞', 'Adrestia'),
];

/// Main selectable garment for each job. These IDs use the regular costume
/// taxonomy so colour, wear state, and other clothing controls stay editable.
final List<CatalogTagData> elswordJobOutfitTags =
    List<CatalogTagData>.unmodifiable(
  _elswordJobs.map((job) => CatalogTagData(
        id: job.id,
        group: '特殊服裝',
        zh: job.zh,
        en: job.en,
        order: 4,
        support: 'description',
      )),
);

/// Job-specific visible details. They are placed in the same costume prompt
/// parentheses as their selected job outfit, while remaining removable tags.
final List<CatalogTagData> elswordJobVisualDetailTags =
    List<CatalogTagData>.unmodifiable(
  <String, _ElswordStyleDetail>{
    for (final job in _elswordJobs)
      for (final detail in job.visualDetails) detail.en: detail,
  }.values.toList().asMap().entries.map((entry) => CatalogTagData(
        id: _elswordVisualDetailId(entry.value.en),
        group: '轉職服裝細節',
        zh: entry.value.zh,
        en: entry.value.en,
        order: entry.key + 1,
        support: 'description',
      )),
);

/// Complete built-in references. Aisha's Elemental Master uses the detailed
/// user-provided silhouette; the other paths are editable visual references
/// aligned with their official class names and themes.
final List<OutfitReferencePresetData> elswordJobOutfitReferencePresets =
    List<OutfitReferencePresetData>.unmodifiable(
  _elswordJobs
      .map((job) => OutfitReferencePresetData(
            id: job.id,
            category: '艾爾之光・轉職服裝',
            name: job.zh,
            palette: job.look.palette,
            description:
                '套用 ${job.characterZh}・${job.jobZh} 的職業服裝與髮型參考；服裝部位、顏色、穿脫與髮型皆可於套用後自行調整。',
            pieces: [
              OutfitPiecePresetData(scope: 'costume', garment: job.en),
            ],
            featureTags: job.featureTags,
            detailTagIds: job.visualDetails
                .map((detail) => _elswordVisualDetailId(detail.en))
                .toList(),
            ownerCharacterTags: job.ownerCharacterTag.isEmpty
                ? const <String>[]
                : <String>[job.ownerCharacterTag],
            ownerCharacterLabel: job.characterZh,
          ))
      .toList(),
);
