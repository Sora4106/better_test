import 'attached_outfit_reference_data.dart';
import 'catalog_data.dart';

String _attachedStandaloneKey(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll(RegExp(r'\s*,\s*$'), '');

String _attachedStandaloneSlug(String value) => _attachedStandaloneKey(value)
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

List<String> _attachedPhraseSegments(Iterable<String> phrases) {
  final unique = <String>{};
  for (final phrase in phrases) {
    for (final raw in phrase.split(',')) {
      final value = _attachedStandaloneKey(raw);
      if (value.isNotEmpty) unique.add(value);
    }
  }
  return unique.toList(growable: false)..sort();
}

Map<String, int> _attachedPhraseSegmentCounts(Iterable<String> phrases) {
  final result = <String, int>{};
  for (final phrase in phrases) {
    for (final raw in phrase.split(',')) {
      final value = _attachedStandaloneKey(raw);
      if (value.isEmpty) continue;
      result.update(value, (count) => count + 1, ifAbsent: () => 1);
    }
  }
  return result;
}

bool _isIndependentPoseSegment(String value, int count) {
  if (count < 2) return false;
  if (RegExp(r'^(?:other|upper|lower)\b').hasMatch(value)) return false;
  if (RegExp(r'\b(?:it|its|them|one another)\b').hasMatch(value)) return false;
  return true;
}

/// Every comma-delimited A/B/C outfit component remains selectable without
/// replacing the original full-outfit cards. Existing English tags win during
/// the app's normal de-duplication pass, so this list only fills true gaps.
final List<CatalogTagData> attachedOutfitStandaloneTags =
    List<CatalogTagData>.unmodifiable(
  _attachedPhraseSegments(
    attachedOutfitReferencePresets.map(
      (preset) => preset.unifiedPhraseEn ?? '',
    ),
  ).map(
    (english) => CatalogTagData(
      id: 'attached_outfit_part_${_attachedStandaloneSlug(english)}',
      group: _attachedOutfitGroup(english),
      zh: _keywordSummary(
        english,
        _outfitZhKeywords,
        fallback: '套裝服裝片段',
      ),
      en: english,
      order: 5,
      support: 'description',
    ),
  ),
);

/// Reusable pose atoms found at least twice in the supplied 1,000 kits. A
/// fragment that depends on a previous clause (`other hand`, `around it`, and
/// similar wording) stays exclusively in its complete package prompt because
/// it would be ambiguous and grammatically incomplete as a standalone chip.
final List<CatalogTagData> attachedPoseStandaloneTags =
    List<CatalogTagData>.unmodifiable(() {
  final phrases = attachedPosePackages
      .map((package) => package.naturalPrompt)
      .toList(growable: false);
  final counts = _attachedPhraseSegmentCounts(phrases);
  final values = counts.entries
      .where((entry) => _isIndependentPoseSegment(entry.key, entry.value))
      .map((entry) => entry.key)
      .toList(growable: false)
    ..sort();
  return values.map(
    (english) => CatalogTagData(
      id: 'attached_pose_part_${_attachedStandaloneSlug(english)}',
      group: _attachedPoseGroup(english),
      zh: _keywordSummary(
        english,
        _poseZhKeywords,
        fallback: '可獨立選擇的姿勢細節',
      ),
      en: english,
      order: 4,
      support: 'description',
    ),
  );
}());

final List<CatalogTagData> attachedStandaloneTags =
    List<CatalogTagData>.unmodifiable(<CatalogTagData>[
  ...attachedOutfitStandaloneTags,
  ...attachedPoseStandaloneTags,
]);

String _attachedOutfitGroup(String value) {
  if (_containsAny(value, const [
    'boots',
    'shoes',
    'sandals',
    'slippers',
    'sneakers',
    'heels',
    'loafers',
    'mary janes',
    'ballet shoes',
  ])) {
    return '鞋子';
  }
  if (_containsAny(value, const [
    'socks',
    'stockings',
    'thighhigh',
    'tights',
    'legwear',
    'tabi',
  ])) {
    return '襪子';
  }
  if (_containsAny(value, const ['skirt', 'overskirt', 'hakama'])) {
    return '裙子';
  }
  if (_containsAny(value, const ['pants', 'bottoms', 'leggings'])) {
    return '褲子';
  }
  if (_containsAny(value, const [
    'jacket',
    'coat',
    'cape',
    'overcoat',
    'shawl',
    'blazer',
  ])) {
    return '外套';
  }
  if (_containsAny(value, const [
    'blouse',
    'shirt',
    'sweater',
    'cardigan',
    'hoodie',
    'top',
    'bodice',
    'corset',
    'vest',
    'camisole',
  ])) {
    return '上衣';
  }
  if (_containsAny(value, const [
    'dress',
    'gown',
    'qipao',
    'kimono',
    'yukata',
    'jumpsuit',
    'bodysuit',
    'nightdress',
    'bathrobe',
    'swimsuit',
    'bikini',
    'outfit',
    'loungewear',
    'sleepwear',
    'homewear',
    'costume',
    'pajama set',
  ])) {
    return '服裝';
  }
  if (_containsAny(value, const [
    'hat',
    'cap',
    'bonnet',
    'headband',
    'headpiece',
    'glasses',
    'brooch',
    'bracelet',
    'ornament',
    'accessories',
    'ribbon',
    'bow',
    'scarf',
    'belt',
    'strap',
    'harness',
    'apron',
    'satchel',
    'bag',
    'veil',
    'choker',
    'gloves',
    'crown',
    'goggles',
    'tiara',
    'arm guards',
    'mittens',
    'wristbands',
    'pouches',
    'obi',
  ])) {
    return '配件';
  }
  if (_containsAny(value, const [
    'leather',
    'lace',
    'knit',
    'fur',
    'fluffy',
    'fishnet',
    'sheer',
    'transparent fabric',
    'metallic',
    'woven',
  ])) {
    return '服裝材質';
  }
  return '服裝細節';
}

String _attachedPoseGroup(String value) {
  if (_containsAny(value, const ['view', 'angle', 'overhead', 'top-down'])) {
    return '畫面';
  }
  if (_isPoseLocation(value)) return '場景';
  if (_containsAny(value, const [
    'sitting',
    'seated',
    'kneeling',
    'cross-legged',
    'on heels',
  ])) {
    return '坐姿與跪姿';
  }
  if (_containsAny(value, const [
    'lying',
    'reclining',
    'curled',
    'cocoon pose',
  ])) {
    return '躺臥姿勢';
  }
  if (_containsAny(value, const [
    'standing',
    'walking',
    'stance',
    'weight on',
  ])) {
    return '站立與蹲姿';
  }
  if (_containsAny(value, const [
    'expression',
    'smile',
    'cheerful',
    'sleepy',
    'dreamy',
  ])) {
    return '表情';
  }
  if (_containsAny(value, const [
    'head',
    'chin',
    'cheek',
    'face',
    'lips',
  ])) {
    return '頭部姿勢';
  }
  if (_containsAny(value, const ['hand', 'palm', 'finger'])) {
    return '手部姿勢';
  }
  if (_containsAny(value, const ['arm', 'elbow', 'shoulder'])) {
    return '手臂姿勢';
  }
  if (_containsAny(value, const [
    'leg',
    'knee',
    'foot',
    'feet',
    'ankle',
    'heel',
    'toe',
    'thigh',
    'hips',
  ])) {
    return '腿部姿勢';
  }
  if (_containsAny(value, const [
    'torso',
    'back',
    'chest',
    'waist',
    'body',
    'posture',
  ])) {
    return '軀幹姿勢';
  }
  return '全身姿勢';
}

String _keywordSummary(
  String value,
  Map<String, String> dictionary, {
  required String fallback,
}) {
  final parts = <String>[];
  for (final entry in dictionary.entries) {
    if (_hasTerm(value, entry.key) && !parts.contains(entry.value)) {
      parts.add(entry.value);
    }
  }
  return parts.isEmpty ? fallback : parts.take(7).join('・');
}

bool _hasTerm(String value, String term) => RegExp(
      '(^|[^a-z0-9])${RegExp.escape(term)}([^a-z0-9]|\$)',
    ).hasMatch(value);

bool _isPoseLocation(String value) => _containsAny(value, const [
      'floor',
      'wall',
      'window',
      'doorway',
      'doorframe',
      'stair',
      'counter',
      'bench',
      'beanbag',
      'chaise',
      'hammock chair',
      'platform',
      'path',
      'field',
      'alleyway',
      'railing',
      'pier',
      'fence',
      'open space',
      'beach',
      'bed',
      'chair',
      'desk',
      'garden',
      'rooftop',
      'rug',
      'sofa',
      'stool',
      'table',
      'tatami room',
      'city street',
    ]);

bool _containsAny(String value, List<String> needles) =>
    needles.any(value.contains);

const _outfitZhKeywords = <String, String>{
  'deep red': '深紅色',
  'dark purple': '深紫色',
  'dark green': '深綠色',
  'royal blue': '皇家藍',
  'sage green': '鼠尾草綠',
  'peach pink': '蜜桃粉',
  'black': '黑色',
  'white': '白色',
  'cream': '米白色',
  'brown': '棕色',
  'red': '紅色',
  'pink': '粉紅色',
  'orange': '橘色',
  'yellow': '黃色',
  'green': '綠色',
  'blue': '藍色',
  'navy': '深藍色',
  'purple': '紫色',
  'cyan': '青色',
  'gold': '金色',
  'silver': '銀色',
  'beige': '米色',
  'dark': '深色',
  'light': '淺色',
  'dark academia': '暗黑學院風',
  'astronaut-inspired': '太空人風',
  'ninja-inspired': '忍者風',
  'chinese-inspired': '中式風',
  'gothic': '哥德式',
  'maid': '女僕風',
  'sailor': '水手風',
  'military': '軍裝風',
  'academic': '學院風',
  'streetwear': '街頭風',
  'techwear': '機能風',
  'sporty': '運動休閒風',
  'athletic': '運動風',
  'bohemian': '波希米亞風',
  'cottagecore': '田園風',
  'victorian': '維多利亞風',
  'retro': '復古風',
  'punk': '龐克風',
  'royal': '皇家風',
  'bridal': '新娘風',
  'formal': '正式',
  'traditional': '傳統',
  'futuristic': '未來風',
  'cyber': '賽博風',
  'comfortable': '舒適',
  'cozy': '溫暖舒適',
  'soft': '柔軟',
  'oversized': '寬鬆大尺寸',
  'fitted': '合身',
  'asymmetrical': '不對稱',
  'layered': '層次',
  'ruffled': '荷葉邊',
  'frilled': '褶邊',
  'floral': '花卉',
  'plaid': '格紋',
  'off-shoulder': '露肩',
  'sleeveless': '無袖',
  'puff-sleeve': '泡泡袖',
  'puff sleeves': '泡泡袖',
  'cropped': '短版',
  'mary janes': '瑪莉珍鞋',
  'lace-up boots': '綁帶靴',
  'ankle boots': '短靴',
  'heeled boots': '高跟靴',
  'boots': '靴子',
  'sneakers': '運動鞋',
  'sandals': '涼鞋',
  'slippers': '拖鞋',
  'loafers': '樂福鞋',
  'heels': '高跟鞋',
  'shoes': '鞋子',
  'thighhigh socks': '大腿襪',
  'thighhighs': '大腿襪',
  'knee socks': '膝下襪',
  'ankle socks': '短襪',
  'stockings': '長襪',
  'tights': '連褲襪',
  'socks': '襪子',
  'dress': '洋裝',
  'gown': '禮服',
  'qipao': '旗袍',
  'kimono': '和服',
  'yukata': '浴衣',
  'jumpsuit': '連身衣',
  'bodysuit': '緊身連身衣',
  'nightdress': '睡裙',
  'bathrobe': '浴袍',
  'swimsuit': '泳裝',
  'bikini': '比基尼',
  'loungewear': '居家服',
  'sleepwear': '睡衣',
  'homewear': '居家服',
  'outfit': '套裝',
  'costume': '服裝',
  'overskirt': '外層裙',
  'skirt': '裙子',
  'hakama': '袴裙',
  'pants': '長褲',
  'bottoms': '下身',
  'leggings': '緊身褲',
  'blouse': '女式襯衫',
  'shirt': '上衣',
  'sweater': '毛衣',
  'cardigan': '開襟衫',
  'hoodie': '連帽上衣',
  'camisole': '細肩帶上衣',
  'top': '上衣',
  'bodice': '緊身胸衣',
  'corset': '馬甲',
  'vest': '背心',
  'jacket': '外套',
  'overcoat': '大衣',
  'coat': '大衣',
  'cape': '斗篷',
  'shawl': '披肩',
  'blazer': '西裝外套',
  'hat': '帽子',
  'cap': '帽子',
  'bonnet': '軟帽',
  'headband': '髮帶',
  'headpiece': '頭飾',
  'glasses': '眼鏡',
  'brooch': '胸針',
  'bracelet': '手鍊',
  'ornaments': '飾品',
  'accessories': '配件',
  'ribbon': '緞帶',
  'bow': '蝴蝶結',
  'scarf': '圍巾',
  'belts': '腰帶',
  'belt': '腰帶',
  'straps': '綁帶',
  'strap': '綁帶',
  'harness': '束帶',
  'apron': '圍裙',
  'satchel': '側背書包',
  'bag': '包包',
  'veil': '頭紗',
  'choker': '頸鍊',
  'gloves': '手套',
  'crown': '王冠',
  'leather': '皮革',
  'lace': '蕾絲',
  'knit': '針織',
  'fur': '毛絨',
  'fluffy': '蓬鬆',
  'fishnet': '網襪材質',
  'sheer': '透膚',
  'transparent': '透明',
  'metallic': '金屬質感',
  'woven': '編織',
  'trim': '滾邊',
  'embroidery': '刺繡',
  'piping': '滾條',
  'panels': '拼接片',
  'lining': '內裡',
  'details': '細節',
  'neckline': '領口',
  'collar': '衣領',
  'sleeves': '袖子',
  'cuffs': '袖口',
  'waist': '腰部',
  'hem': '下擺',
  'animal-ear hood': '動物耳連帽',
  'cat-ear hood': '貓耳連帽',
  'arm guards': '護臂',
  'decorative frog closures': '裝飾盤扣',
  'decorative tassels': '裝飾流蘇',
  'goggles': '護目鏡',
  'maple leaf pattern': '楓葉圖案',
  'metal chains': '金屬鏈條',
  'pajama set': '成套睡衣',
  'paw cushion accessory': '肉球坐墊配件',
  'paw mittens': '肉球連指手套',
  'rose decorations': '玫瑰裝飾',
  'side slit': '側開衩',
  'sport wristbands': '運動護腕',
  'tiara': '冠冕',
  'utility pouches': '機能收納袋',
  'wide obi': '寬版腰帶',
};

const _poseZhKeywords = <String, String>{
  'three-quarter overhead view': '四分之三俯視',
  'three-quarter back view': '四分之三背面視角',
  'slightly high-angle view': '稍高角度視角',
  'slightly low-angle view': '稍低角度視角',
  'eye-level view': '平視視角',
  'top-down view': '正上方俯視',
  'overhead view': '俯視視角',
  'front high-angle view': '正面高角度視角',
  'back view': '背面視角',
  'overhead': '俯視',
  'windowsill': '窗台',
  'window seat': '窗邊座位',
  'window': '窗邊',
  'floor cushion': '地板坐墊',
  'floor': '地板',
  'wall': '牆邊',
  'doorway': '門口',
  'doorframe': '門框',
  'staircase': '樓梯',
  'stairs': '階梯',
  'bar counter': '吧台',
  'counter': '櫃台',
  'park bench': '公園長椅',
  'bench': '長椅',
  'beanbag': '懶骨頭沙發',
  'chaise lounge': '貴妃椅',
  'hammock chair': '吊椅',
  'station platform': '車站月台',
  'outdoor path': '戶外小徑',
  'forest path': '森林小徑',
  'grass field': '草地',
  'garden wall': '花園牆邊',
  'shrine steps': '神社階梯',
  'alleyway': '巷弄',
  'bridge railing': '橋上欄杆',
  'railing': '欄杆',
  'pier': '碼頭',
  'fence': '圍欄',
  'open space': '開放空間',
  'armchair': '扶手椅',
  'beach': '沙灘',
  'bed': '床上',
  'chair': '椅子',
  'city street': '城市街道',
  'desk': '書桌',
  'garden': '花園',
  'rooftop': '屋頂',
  'rug': '地毯',
  'sofa': '沙發',
  'stool': '凳子',
  'table': '桌邊',
  'tatami room': '榻榻米房間',
  'sitting cross-legged': '盤腿坐姿',
  'cross-legged': '盤腿',
  'sitting sideways': '側坐',
  'sitting upright': '挺直坐姿',
  'sitting tall': '高挺坐姿',
  'sitting on heels': '跪坐於腳跟',
  'sitting on edge': '坐在邊緣',
  'sitting near edge': '坐在邊緣附近',
  'seated': '坐姿',
  'sitting': '坐姿',
  'kneeling upright': '直立跪姿',
  'kneeling': '跪姿',
  'reclining': '斜躺',
  'lying diagonally': '斜向躺姿',
  'curled on side': '側身蜷縮',
  'standing pose': '站姿',
  'standing confidently': '自信站立',
  'walking pose': '行走姿勢',
  'weight on one leg': '重心放在單腿',
  'blanket cocoon pose': '毛毯包裹姿勢',
  'standing': '站立',
  'lying on side with pillow hugged to chest': '側躺並將枕頭抱在胸前',
  'lying on side': '側躺',
  'lying on stomach': '俯臥',
  'both hands': '雙手',
  'one hand': '單手',
  'hands': '手部',
  'one arm': '單臂',
  'both arms': '雙臂',
  'arms': '手臂',
  'elbows': '手肘',
  'elbow': '單肘',
  'palms': '手掌',
  'fingers': '手指',
  'behind back': '置於背後',
  'behind head': '置於腦後',
  'behind body': '身體後方',
  'in pockets': '插入口袋',
  'on hips': '雙手叉腰',
  'on hip': '單手叉腰',
  'on lap': '放在腿上',
  'on thighs': '放在大腿上',
  'on thigh': '放在大腿',
  'on knees': '放在膝上',
  'on knee': '放在膝蓋',
  'near face': '靠近臉部',
  'at cheek': '靠近臉頰',
  'on cheek': '托住臉頰',
  'under chin': '托住下巴',
  'clasped': '交握',
  'folded': '收攏',
  'crossed': '交叉',
  'holding': '拿著',
  'waving': '揮手',
  'saluting': '敬禮',
  'peace signs': 'V字手勢',
  'touching': '輕觸',
  'brushing hair': '撥弄頭髮',
  'lifting hair': '撩起頭髮',
  'reaching': '伸手',
  'supporting': '支撐',
  'resting': '自然放置',
  'relaxed': '放鬆',
  'open': '張開',
  'outward': '向外',
  'around knees': '環抱膝蓋',
  'knees together': '雙膝併攏',
  'knees close': '雙膝靠近',
  'knees hugged': '抱膝',
  'one knee raised': '單膝抬起',
  'one knee up': '單膝抬高',
  'knees bent': '屈膝',
  'legs crossed at ankles': '腳踝交叉',
  'legs crossed': '雙腿交叉',
  'legs apart': '雙腿分開',
  'legs straight': '雙腿伸直',
  'legs extended': '雙腿伸展',
  'legs close': '雙腿靠攏',
  'ankles crossed': '腳踝交叉',
  'ankles together': '腳踝併攏',
  'feet together': '雙腳併攏',
  'feet apart': '雙腳分開',
  'feet flat': '腳掌平放',
  'feet dangling': '雙腳懸空',
  'feet offset': '雙腳錯開',
  'feet staggered': '雙腳前後錯開',
  'feet tucked behind': '雙腳收於身後',
  'front toe pointed': '前腳腳尖繃直',
  'one ankle over the other': '單側腳踝疊在另一側',
  'one foot on rung': '單腳踩在橫檔',
  'one foot on tiptoe': '單腳踮起',
  'one foot pivoted': '單腳轉向',
  'one foot planted': '單腳穩定著地',
  'one heel lifted': '單側腳跟抬起',
  'heel raised': '腳跟抬起',
  'toes inward': '腳尖內收',
  'toes pointed': '腳尖繃直',
  'toe touching floor': '腳尖點地',
  'one leg': '單腿',
  'legs': '腿部',
  'hips shifted': '髖部偏移',
  'hips angled': '髖部轉向',
  'torso leaning forward': '軀幹前傾',
  'torso leaning back': '軀幹後傾',
  'torso leaning sideways': '軀幹側傾',
  'torso twisted toward viewer': '軀幹扭向鏡頭',
  'torso turned toward viewer': '軀幹轉向鏡頭',
  'torso twisted': '軀幹扭轉',
  'torso straight': '軀幹挺直',
  'torso upright': '軀幹直立',
  'torso elongated': '軀幹延展',
  'torso relaxed': '軀幹放鬆',
  'torso stretched upward': '軀幹向上伸展',
  'torso angled': '軀幹轉角',
  'gentle torso twist': '軀幹輕柔扭轉',
  'torso twisting': '軀幹扭轉中',
  'back straight': '背部挺直',
  'straight posture': '挺直姿勢',
  'shoulders relaxed': '肩膀放鬆',
  'shoulders back': '肩膀向後',
  'shoulders open': '肩膀展開',
  'shoulders squared': '雙肩端正',
  'chest open': '胸口展開',
  'chest lifted': '挺胸',
  'head turned toward viewer': '頭部轉向鏡頭',
  'head tilted': '歪頭',
  'chin slightly raised': '下巴微抬',
  'chin slightly lowered': '下巴微收',
  'chin in hands': '雙手托下巴',
  'chin in hand': '單手托下巴',
  'cheek resting on hand': '手托臉頰',
  'looking over shoulder': '回頭越肩看',
  'looking back over shoulder': '回頭越肩看',
  'confident expression': '自信表情',
  'confident pose': '自信姿勢',
  'playful expression': '俏皮表情',
  'cheerful pose': '開朗姿勢',
  'relaxed expression': '放鬆表情',
  'relaxed smile': '放鬆微笑',
  'gentle smile': '溫柔微笑',
  'soft smile': '柔和微笑',
  'dreamy pose': '夢幻姿勢',
  'sleepy pose': '睏倦姿勢',
  'cute pose': '可愛姿勢',
  'cozy pose': '舒適姿勢',
  'modest pose': '端莊姿勢',
  'elegant stance': '優雅站姿',
  'calm expression': '平靜表情',
  'looking at viewer': '看向鏡頭',
  'looking outside': '看向窗外',
  'shoulders angled': '肩膀轉向',
  'shoulders down': '肩膀下沉',
  'front high-angle': '正面高角度',
  'front view': '正面視角',
  'high-angle view': '高角度視角',
  'low-angle view': '低角度視角',
  'side view': '側面視角',
  'three-quarter view': '四分之三視角',
  'slightly': '輕微',
  'gently': '輕柔',
  'softly': '柔和',
  'forward': '向前',
  'back': '向後',
  'sideways': '向側面',
  'upright': '直立',
  'straight': '伸直',
  'bent': '彎曲',
  'raised': '抬起',
  'lifted': '抬高',
  'together': '併攏',
  'apart': '分開',
  'close': '靠近',
};
