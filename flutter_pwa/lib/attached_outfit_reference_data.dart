import 'outfit_reference_data.dart';
import 'prompt_package_data.dart';

class _AttachedOutfitSeed {
  const _AttachedOutfitSeed(
    this.number,
    this.category,
    this.name,
    this.tags,
  );

  final int number;
  final String category;
  final String name;
  final String tags;
}

class _AttachedPoseSeed {
  const _AttachedPoseSeed(this.number, this.category, this.prompt);

  final int number;
  final String category;
  final String prompt;
}

/// Complete clothing sets transcribed from the supplied reference list.
/// Every source line is retained in one unified phrase so selections preserve
/// the original garments, palette, shoes, legwear and accessories.
final attachedOutfitReferencePresets =
    List<OutfitReferencePresetData>.unmodifiable(
  _parseAttachedOutfitSeeds()
      .map(
        (seed) => OutfitReferencePresetData(
          id: 'attached_outfit_' + seed.number.toString().padLeft(2, '0'),
          category: seed.category,
          name: seed.number.toString().padLeft(2, '0') + '・' + seed.name,
          palette: _attachedOutfitPalette(seed.tags),
          description: seed.category + '的完整服裝、鞋襪與配件片語；套用後會維持原始搭配。',
          pieces: const <OutfitPiecePresetData>[],
          unifiedPhraseZh: seed.name,
          unifiedPhraseEn: seed.tags,
          unifiedPhraseSections: <OutfitUnifiedPhraseSectionData>[
            OutfitUnifiedPhraseSectionData(
              id: 'complete',
              zh: '整套服裝',
              en: seed.tags,
            ),
          ],
        ),
      )
      .toList(growable: false),
);

/// All 1,000 supplied single-person pose kits. The original English remains a
/// complete natural prompt, while category and generated Chinese summaries
/// keep the catalogue navigable without losing the pose relationships.
final attachedPosePackages = List<PromptPackageData>.unmodifiable(
  _parseAttachedPoseSeeds()
      .map(
        (seed) => PromptPackageData(
          id: 'attached_pose_' + seed.number.toString(),
          name: _attachedPoseName(seed),
          description: _attachedPoseDescription(seed),
          category: seed.category,
          naturalPrompt: seed.prompt,
          naturalPromptZh: _attachedPoseDescription(seed),
        ),
      )
      .toList(growable: false),
);

/// Category buckets are prepared once, so the package picker only builds the
/// currently selected group instead of repeatedly filtering all 1,000 items.
final attachedPosePackagesByCategory = _groupAttachedPosePackages(
  attachedPosePackages,
);

Map<String, List<PromptPackageData>> _groupAttachedPosePackages(
  List<PromptPackageData> packages,
) {
  final grouped = <String, List<PromptPackageData>>{};
  for (final package in packages) {
    (grouped[package.category] ??= <PromptPackageData>[]).add(package);
  }
  return Map<String, List<PromptPackageData>>.unmodifiable(
    <String, List<PromptPackageData>>{
      for (final entry in grouped.entries)
        entry.key: List<PromptPackageData>.unmodifiable(entry.value),
    },
  );
}

List<_AttachedOutfitSeed> _parseAttachedOutfitSeeds() {
  final result = <_AttachedOutfitSeed>[];
  var category = '';
  int? number;
  var name = '';
  var tags = <String>[];

  void flush() {
    if (number == null) return;
    final phrase = tags
        .map((tag) => tag.trim().replaceFirst(RegExp(r',$'), ''))
        .where((tag) => tag.isNotEmpty)
        .join(', ')
        .replaceAll(RegExp(r'\blolita\b', caseSensitive: false), 'gothic');
    result.add(_AttachedOutfitSeed(number, category, name, phrase));
  }

  for (final sourceLine in _attachedOutfitSource.split('\n')) {
    final line = sourceLine.trim();
    if (line.startsWith('## A組')) {
      flush();
      number = null;
      tags = <String>[];
      category = '附件套裝・A 時尚／角色';
      continue;
    }
    if (line.startsWith('## B組')) {
      flush();
      number = null;
      tags = <String>[];
      category = '附件套裝・B 主題／幻想';
      continue;
    }
    if (line.startsWith('## C組')) {
      flush();
      number = null;
      tags = <String>[];
      category = '附件套裝・C 居家／睡衣';
      continue;
    }
    final heading = RegExp(r'^###\s+(\d+)\s+(.+)$').firstMatch(line);
    if (heading != null) {
      flush();
      number = int.parse(heading.group(1)!);
      name = heading.group(2)!.trim();
      tags = <String>[];
      continue;
    }
    if (line.isNotEmpty && number != null) tags.add(line);
  }
  flush();
  return List<_AttachedOutfitSeed>.unmodifiable(result);
}

List<_AttachedPoseSeed> _parseAttachedPoseSeeds() {
  final result = <_AttachedPoseSeed>[];
  var category = '';
  final heading = RegExp(
    r'^(?:##\s+)?[A-Z]\.\s*(.+?)(?=\s*\d{3,4}[–-]\d{2,4}$)',
  );
  final item = RegExp(r'^(\d{3,4})\.\s*(.+)$');
  for (final sourceLine in _attachedPoseSource.split('\n')) {
    final line = sourceLine.trim();
    final categoryMatch = heading.firstMatch(line);
    if (categoryMatch != null) {
      category = categoryMatch.group(1)!.trim();
      continue;
    }
    final itemMatch = item.firstMatch(line);
    if (itemMatch == null || category.isEmpty) continue;
    result.add(
      _AttachedPoseSeed(
        int.parse(itemMatch.group(1)!),
        category,
        itemMatch.group(2)!.trim(),
      ),
    );
  }
  return List<_AttachedPoseSeed>.unmodifiable(result);
}

String _attachedOutfitPalette(String tags) {
  const colors = <String, String>{
    'black': '黑色',
    'white': '白色',
    'red': '紅色',
    'pink': '粉紅色',
    'purple': '紫色',
    'blue': '藍色',
    'navy': '深藍色',
    'cyan': '青色',
    'green': '綠色',
    'sage': '鼠尾草綠',
    'yellow': '黃色',
    'orange': '橘色',
    'brown': '棕色',
    'cream': '米白色',
    'beige': '米色',
    'gold': '金色',
    'silver': '銀色',
    'peach': '蜜桃色',
  };
  final lower = tags.toLowerCase();
  final selected = <String>[];
  for (final entry in colors.entries) {
    if (lower.contains(entry.key) && !selected.contains(entry.value)) {
      selected.add(entry.value);
    }
    if (selected.length == 3) break;
  }
  return selected.isEmpty ? '依套裝設定' : selected.join(' × ');
}

String _attachedPoseName(_AttachedPoseSeed seed) {
  return seed.number.toString().padLeft(3, '0') +
      '・' +
      _attachedPoseBaseZh(seed.prompt) +
      '・' +
      _attachedPoseDetailZh(seed.prompt);
}

String _attachedPoseDescription(_AttachedPoseSeed seed) {
  return seed.category +
      '・' +
      _attachedPoseBaseZh(seed.prompt) +
      '，' +
      _attachedPoseDetailZh(seed.prompt) +
      '。';
}

String _attachedPoseBaseZh(String prompt) {
  final value = prompt.toLowerCase();
  if (value.contains('pillow') ||
      value.contains('cushion') ||
      value.contains('plush') ||
      value.contains('stuffed')) {
    return '抱枕玩偶互動';
  }
  if (value.contains('cat') ||
      value.contains('kitten') ||
      value.contains('dog') ||
      value.contains('puppy')) {
    return '小動物互動';
  }
  if (value.contains('bird') ||
      value.contains('penguin') ||
      value.contains('owl') ||
      value.contains('chick')) {
    return '鳥類互動';
  }
  if (value.contains('book') ||
      value.contains('flower') ||
      value.contains('bouquet') ||
      value.contains('bag') ||
      value.contains('camera') ||
      value.contains('cup') ||
      value.contains('gift')) {
    return '物件互動';
  }
  if (value.contains('walking') ||
      value.contains('walk') ||
      value.contains('running') ||
      value.contains('run pose') ||
      value.contains('skipping') ||
      value.contains('step')) {
    return '行走動態';
  }
  if (value.contains('standing')) return '站姿';
  if (value.contains('kneeling')) return '跪姿';
  if (value.contains('lying') ||
      value.contains('reclining') ||
      value.contains('half-lying')) {
    return '躺姿';
  }
  if (value.contains('sitting') ||
      value.contains('seated') ||
      value.contains('sit,')) {
    return '坐姿';
  }
  return '動作組合';
}

String _attachedPoseDetailZh(String prompt) {
  final value = prompt.toLowerCase();
  final parts = <String>[];
  void add(bool condition, String label) {
    if (condition && !parts.contains(label) && parts.length < 3) {
      parts.add(label);
    }
  }

  add(value.contains('front view'), '正面');
  add(value.contains('side view'), '側面');
  add(value.contains('three-quarter'), '斜側面');
  add(value.contains('top-down') || value.contains('high-angle'), '俯視');
  add(value.contains('low-angle'), '仰視');
  add(value.contains('both hands') || value.contains('arms wrapped'), '雙手動作');
  add(value.contains('one hand') || value.contains('one arm'), '單手動作');
  add(
      value.contains('hugging') ||
          value.contains('holding') ||
          value.contains('clutching'),
      '抱持');
  add(value.contains('knees hugged') || value.contains('arms around knees'),
      '抱膝');
  add(value.contains('cross-legged'), '盤腿');
  add(value.contains('hands behind back'), '雙手背後');
  add(value.contains('hands behind head'), '雙手抱頭');
  add(value.contains('head tilted') || value.contains('head tilt'), '歪頭');
  add(value.contains('looking back'), '回頭');
  add(value.contains('waving'), '揮手');
  add(value.contains('peace sign'), '比V');
  add(value.contains('heart sign') || value.contains('heart shape'), '愛心手勢');
  add(value.contains('cat paw'), '貓爪手勢');
  add(value.contains('legs crossed'), '交叉腿');
  add(value.contains('one knee raised'), '單膝抬起');
  add(value.contains('legs extended'), '雙腿伸展');
  add(value.contains('window'), '窗邊');
  add(value.contains('wall'), '靠牆');
  add(value.contains('bed'), '床上');
  add(value.contains('sofa'), '沙發');
  add(value.contains('chair'), '椅子');
  add(value.contains('floor'), '地板');
  return parts.isEmpty ? '自然姿態' : parts.join('／');
}

const String _attachedOutfitSource = r'''## A組｜20種不同風格

### 01 黑紅哥德洛麗塔
black and deep red gothic dress,
frilled blouse,
black corset bodice,
lace-up waist,
layered ruffle skirt,
deep red skirt panels,
black lace trim,
detached sleeves,
black thighhighs,
lace stockings,
platform mary janes,
red ribbon accessories

### 02 黑黃街頭機能風
streetwear outfit,
black cropped jacket,
white oversized jacket,
yellow trim,
black fitted top,
black pleated skirt,
utility straps,
waist belt,
thigh straps,
black knee socks,
high-top sneakers,
yellow accent details

### 03 紅白華麗和服風
formal kimono,
red and white kimono,
floral kimono pattern,
gold embroidery,
wide obi,
decorative obi bow,
layered kimono sleeves,
red sash,
white inner layer,
traditional sandals,
flower ornaments

### 04 藍白魔導風
fantasy mage outfit,
navy and white mage coat,
white blouse,
navy fitted bodice,
gold trim,
detached sleeves,
layered skirt,
asymmetrical coat tails,
white thighhighs,
navy lace-up boots,
gold gemstone accessories

### 05 棕色蒸氣龐克風
steampunk outfit,
brown leather corset,
cream puff-sleeve blouse,
leather harness,
utility belts,
brown layered skirt,
gear ornaments,
leather thigh straps,
brown stockings,
lace-up boots,
goggles,
brass accessories

### 06 海軍水手風
navy sailor outfit,
white sailor blouse,
navy sailor collar,
yellow neck ribbon,
navy pleated skirt,
white stripe trim,
navy knee socks,
brown loafers,
sailor cap

### 07 橘白運動休閒風
sporty casual outfit,
white athletic jacket,
orange trim,
orange athletic bottoms,
white fitted top,
sport wristbands,
crew socks,
white sneakers,
orange sneaker accents

### 08 米白冬季大衣風
winter outfit,
cream long coat,
fur collar,
fur cuffs,
cream knit sweater,
brown beret,
dark tights,
brown lace-up boots,
plaid scarf,
winter gloves

### 09 白橘度假洋裝風
summer resort dress,
white sundress,
orange ribbon details,
ruffled neckline,
layered flowing skirt,
wide-brim straw hat,
orange waist ribbon,
ankle strap sandals,
woven handbag

### 10 黑紅龐克搖滾風
punk outfit,
black leather jacket,
black fitted top,
red plaid skirt,
asymmetrical layered skirt,
waist belts,
metal chains,
fishnet stockings,
black lace-up boots,
silver buckle details

### 11 黑白女僕風
classic maid outfit,
black maid dress,
white frilled blouse,
white apron,
frilled apron,
puff sleeves,
black ribbon bow,
layered skirt,
white stockings,
black mary janes,
maid headband

### 12 紅白巫女風
miko outfit,
white shrine maiden top,
wide white sleeves,
red hakama skirt,
red waist ties,
white tabi socks,
red sandals,
traditional ribbon details

### 13 深綠古典維多利亞風
victorian dress,
deep green dress,
cream ruffled blouse,
high collar,
corset waist,
layered long skirt,
lace trim,
puff sleeves,
decorative bonnet,
dark boots,
antique brooch

### 14 紫黑未來機能風
futuristic streetwear,
black cropped jacket,
purple neon trim,
cyan trim,
black fitted bodice,
black pleated skirt,
utility straps,
thigh straps,
asymmetrical stockings,
platform boots,
techwear belts

### 15 森林田園風
cottagecore dress,
cream floral dress,
sage green details,
puff sleeves,
lace neckline,
high-waist skirt,
floral embroidery,
ruffled hem,
straw hat,
brown mary janes,
woven basket bag

### 16 藍白軍裝風
military-inspired outfit,
navy officer coat,
white fitted jacket,
gold piping,
gold epaulettes,
high collar,
navy pleated skirt,
waist belt,
black thighhighs,
navy heeled boots,
military cap

### 17 紅金旗袍風
red qipao,
high collar,
gold floral embroidery,
fitted waist,
side slit,
gold piping,
red heels,
gold hair ornaments,
decorative tassels

### 18 桃白公主禮服風
princess gown,
peach pink ball gown,
white ruffled bodice,
off-shoulder neckline,
layered full skirt,
rose decorations,
lace trim,
waist bow,
white gloves,
peach heels,
tiara

### 19 學院文藝風
academic outfit,
beige blazer,
white collared blouse,
red ribbon tie,
brown plaid skirt,
knee socks,
brown loafers,
school satchel,
classic cardigan

### 20 紫黑魔女風
witch outfit,
dark purple witch dress,
black corset bodice,
layered purple skirt,
detached sleeves,
gold trim,
black thighhighs,
lace-up boots,
wide-brim witch hat,
ribbon ornaments


## B組｜另外20種不同風格

### 21 黑白賽博禮裝風
cyber couture outfit,
black and white asymmetrical dress,
white fitted bodice,
black harness straps,
silver trim,
layered high-low skirt,
transparent fabric panels,
black gloves,
black heels,
metallic accessories

### 22 深色學院復古風
dark academia outfit,
brown plaid blazer,
white collared blouse,
dark ribbon tie,
brown plaid skirt,
black knee socks,
brown loafers,
long academic coat,
leather satchel

### 23 粉白甜系洛麗塔
sweet lolita dress,
pink and white dress,
frilled neckline,
puff sleeves,
layered ruffle skirt,
large pink bows,
white lace trim,
white thighhighs,
pink mary janes,
frilled headpiece

### 24 波西米亞旅行風
bohemian outfit,
cream peasant blouse,
earth-tone layered skirt,
embroidered vest,
wide waist belt,
patterned shawl,
leather sandals,
wide-brim hat,
woven accessories

### 25 白橘太空裝
astronaut-inspired outfit,
white technical jumpsuit,
orange trim,
black utility straps,
white padded jacket,
utility belt,
reinforced knee panels,
white boots,
orange hardware details

### 26 英倫偵探風
detective outfit,
brown plaid cape coat,
brown vest,
white collared blouse,
dark tie,
brown fitted skirt,
dark stockings,
brown lace-up boots,
deerstalker hat,
leather satchel

### 27 紅黑馬戲團領班風
ringmaster outfit,
red tailcoat,
black fitted bodice,
gold trim,
white frilled blouse,
black layered skirt,
red ribbon bow,
black thighhighs,
black heeled boots,
mini top hat

### 28 海盜船長風
pirate outfit,
black pirate coat,
deep red lining,
white off-shoulder blouse,
black corset,
red waist sash,
layered skirt,
thigh straps,
black lace-up boots,
tricorn hat,
gold buckle details

### 29 白金芭蕾舞裙風
ballet costume,
white tutu dress,
gold embroidery,
fitted corset bodice,
layered tulle skirt,
off-shoulder straps,
white stockings,
ribbon ballet shoes,
delicate floral ornaments

### 30 黑紅吸血鬼貴族風
vampire gothic dress,
black and deep red dress,
high collar,
black corset,
deep red layered skirt,
lace sleeves,
black cape,
black stockings,
black heels,
rose accessories,
gothic choker

### 31 森林遊俠風
forest ranger outfit,
dark green hooded cape,
cream blouse,
brown leather vest,
green layered skirt,
utility belt,
leather thigh straps,
brown lace-up boots,
arm guards,
leather pouches

### 32 棕白咖啡女僕風
brown maid dress,
cream frilled blouse,
white apron,
ruffled apron,
brown fitted bodice,
puff sleeves,
layered skirt,
white ankle socks,
brown mary janes,
maid headband

### 33 白金新娘禮服風
bridal gown,
white wedding dress,
gold embroidery,
lace bodice,
off-shoulder sleeves,
layered flowing skirt,
long veil,
white gloves,
white heels,
floral hair ornament

### 34 橘白海灘度假風
orange and white swimsuit,
ruffled bikini top,
orange ribbon bikini,
white sheer cover-up,
orange waist ribbon,
white sandals,
sun hat,
beach bracelet

### 35 紅白復古圓點風
retro dress,
red polka dot dress,
white collar,
fitted waist,
flared skirt,
white waist belt,
red heels,
white gloves,
red headband

### 36 紫黑忍者幻想風
ninja-inspired outfit,
black fitted bodysuit,
dark purple wrap top,
purple sash,
detached sleeves,
thigh straps,
black stockings,
black shin guards,
purple scarf,
black boots

### 37 藍白皇家禮服風
royal gown,
royal blue and white dress,
gold embroidery,
fitted corset bodice,
layered white skirt,
blue overskirt,
white gloves,
blue heels,
gold crown,
gemstone brooch

### 38 棕白鍊金術師風
alchemist outfit,
cream blouse,
brown corset vest,
brown layered skirt,
white overcoat,
leather belts,
utility pouches,
gold trim,
brown lace-up boots,
round glasses,
leather gloves

### 39 黑紅樂團風
rock band outfit,
black leather jacket,
black fitted top,
red plaid skirt,
black fishnet stockings,
waist belt,
metal chain accessories,
black lace-up boots,
red ribbon accents

### 40 奶油針織保暖風
cozy knit outfit,
cream cable-knit sweater,
oversized knit top,
cream thighhigh socks,
plaid scarf,
brown ankle boots,
soft knit cardigan,
warm layered clothing


## C組｜20種居家風

### 41 荷葉睡裙風
nightdress,
white sleep dress,
lace-trim neckline,
ruffled sleeves,
soft ribbon bow,
loose flowing skirt,
frilled hem,
light sleepwear

### 42 粉色睡衣套裝風
pajama set,
pink pajama top,
pink pajama pants,
buttoned pajama shirt,
soft collar,
contrast piping,
comfortable sleepwear,
house slippers

### 43 奶油針織居家風
home knit outfit,
cream cable-knit sweater,
oversized knit sweater,
cream thighhigh socks,
soft knit legwear,
house slippers

### 44 開襟外套居家風
home casual outfit,
cream cardigan,
oversized cardigan,
white camisole,
dark lounge bottoms,
soft knit socks,
indoor slippers,
relaxed layered outfit

### 45 貓帽連帽家居風
hooded loungewear,
cream zip hoodie,
cat-ear hood,
paw-print details,
white inner top,
lounge bottoms,
soft socks,
indoor slippers

### 46 和風居家浴衣
casual yukata,
cream floral yukata,
red obi,
maple leaf pattern,
wide sleeves,
soft waist sash,
traditional indoor sandals

### 47 中式居家風
chinese-inspired loungewear,
cream sleeveless top,
floral embroidery,
mandarin collar,
decorative frog closures,
fitted lounge bottoms,
soft slippers

### 48 女僕居家風
home maid outfit,
brown maid dress,
white frilled apron,
white puff-sleeve blouse,
brown fitted bodice,
frilled skirt,
white stockings,
brown mary janes,
maid headband

### 49 圍裙家事風
housework outfit,
cream floral apron dress,
white blouse,
rolled sleeves,
floral apron,
waist tie,
comfortable indoor shoes,
simple head ribbon

### 50 運動居家風
sporty loungewear,
white track jacket,
deep red trim,
athletic lounge bottoms,
white sport socks,
indoor sneakers,
zip-up jacket

### 51 寬鬆T恤居家風
oversized t-shirt,
white graphic t-shirt,
loose lounge shirt,
soft lounge bottoms,
bare-leg homewear,
house slippers

### 52 吊帶睡裙＋外套
camisole nightdress,
white lace-trim sleep dress,
thin shoulder straps,
pink ribbon bow,
soft pink cardigan,
frilled hem,
light sleep socks

### 53 連身針織毛衣風
knit sweater dress,
cream turtleneck sweater dress,
cable-knit texture,
sleeveless knit dress,
cream thighhigh socks,
ribbon side details,
soft house shoes

### 54 白色居家浴袍風
bathrobe,
white fluffy robe,
shawl collar,
waist tie,
fur-like trim,
soft slippers,
comfortable spa-style loungewear

### 55 露肩睡衣風
off-shoulder loungewear,
white ruffled sleep top,
red ribbon details,
white lounge bottoms,
frilled trim,
soft thighhigh socks,
paw cushion accessory

### 56 毛絨動物居家風
plush animal loungewear,
cream fluffy hoodie,
animal-ear hood,
oversized sleeves,
paw mittens,
soft lounge bottoms,
plush slippers,
furry trim

### 57 層次針織居家風
layered home outfit,
cream cable-knit cardigan,
light camisole,
plaid lounge skirt,
soft knit socks,
brown indoor shoes,
ribbon details

### 58 文藝書房居家風
bookish home outfit,
red plaid shawl,
cream blouse,
brown cardigan,
dark lounge skirt,
opaque tights,
soft loafers,
round glasses

### 59 早晨輕便風
morning loungewear,
white camisole top,
red ribbon bow,
white lounge bottoms,
soft frilled trim,
light indoor slippers

### 60 秋冬保暖居家風
autumn winter loungewear,
cream knit sweater,
red plaid blanket shawl,
dark leggings,
thick knit socks,
brown slippers,
warm scarf,
layered knit clothing''';

const String _attachedPoseSource = r'''## A. 站姿／日常／可愛／優雅 001–030

001. front view, eye-level view, standing, head slightly tilted, looking at viewer, one hand touching hair, other arm relaxed at side, shoulders relaxed, torso straight, weight shifted onto one leg, knees close together, one foot slightly forward

002. three-quarter view, eye-level view, standing, chin slightly lowered, gentle smile, hands clasped behind back, shoulders slightly pulled back, torso leaning forward slightly, legs close together, ankles close, toes turned slightly inward

003. front view, slightly high-angle view, standing, head tilted to one side, both hands clasped in front of chest, elbows tucked inward, torso straight, knees slightly bent, feet close together, toes slightly inward

004. three-quarter view, low-angle view, standing confidently, chin slightly raised, one hand on hip, other arm hanging naturally, shoulders open, torso straight, weight on back leg, front leg extended slightly forward, heel lightly raised

005. side view, eye-level view, standing, looking back over shoulder, one hand holding opposite elbow, torso slightly twisted, hips angled away, legs crossed at ankles, rear heel raised

006. back view, looking back, standing, head turned toward viewer, one hand lifting hair away from shoulder, other hand resting near waist, slight torso twist, one knee relaxed, feet staggered

007. front view, eye-level view, standing, both hands holding skirt sides lightly, shoulders relaxed, torso upright, knees together, one foot turned outward, soft cheerful pose

008. front view, high-angle view, standing, both hands behind head, elbows outward, relaxed smile, slight back stretch, hips shifted sideways, one knee bent, feet apart naturally

009. three-quarter view, eye-level view, standing, one hand touching cheek, other hand resting near waist, torso slightly curved, hips shifted opposite direction, legs crossed, front toe touching floor

010. front view, low-angle view, standing, arms crossed loosely under chest, shoulders relaxed, torso straight, one knee bent slightly, feet shoulder-width apart, confident expression

011. three-quarter view, eye-level view, standing, fingertip near lips, other hand behind back, slight forward lean, head tilted, knees close, ankles crossed, playful expression

012. front view, eye-level view, standing, both hands making small heart shape near chest, elbows bent, shoulders slightly raised, torso straight, legs together, one heel lifted, cheerful smile

013. front view, eye-level view, standing, one hand waving near face, other hand holding bag strap, torso upright, weight on one leg, opposite knee slightly bent, feet offset

014. three-quarter view, slightly high-angle view, standing, one hand holding hat brim, other hand on waist, shoulders angled, torso slightly twisted, legs crossed, front foot pointed outward

015. side view, eye-level view, standing, both hands clasped behind back, head turned toward viewer, chest slightly forward, back gently arched, one leg straight, other knee bent, toe touching ground

016. front view, eye-level view, standing, hands inside jacket pockets, shoulders relaxed, torso slightly slouched, legs apart naturally, one foot turned sideways, casual expression

017. three-quarter view, low-angle view, standing, one hand raised above head, other hand resting on hip, torso stretched upward, hip shifted sideways, one leg straight, other leg extended diagonally

018. front view, high-angle view, standing, both hands holding collar, elbows close, chin tucked slightly, shoulders raised, torso straight, knees together, toes inward, shy expression

019. side view, slightly low-angle view, standing, one hand brushing hair behind ear, other hand relaxed, torso slightly twisted toward viewer, hips back slightly, legs close, one heel raised

020. front view, eye-level view, standing, hands clasped at lower abdomen, shoulders down, straight posture, feet together, knees relaxed, calm formal pose

021. three-quarter view, eye-level view, standing, one hand holding opposite wrist behind back, chin slightly raised, torso angled, hips shifted sideways, legs crossed at calves, elegant expression

022. front view, eye-level view, standing, one arm raised in a cheerful salute, other hand on hip, torso upright, one knee bent outward, heel lifted, energetic pose

023. three-quarter view, high-angle view, standing, both hands lightly touching cheeks, elbows inward, shoulders raised, torso slightly leaning forward, knees close together, feet angled inward

024. front view, low-angle view, standing, one hand adjusting tie or ribbon, other hand in pocket, shoulders squared, torso straight, feet apart, one leg slightly forward

025. side view, eye-level view, standing, arms folded behind back, head tilted upward slightly, torso elongated, hips neutral, one knee softly bent, feet staggered

026. front view, eye-level view, standing, both hands stretching overhead, fingers interlaced, shoulders raised, torso extended upward, slight back arch, legs straight, feet close together

027. three-quarter view, eye-level view, standing, one arm crossing waist, other hand touching chin, head slightly tilted, hips shifted, legs crossed at ankles, thoughtful pose

028. front view, slightly low-angle view, standing, both hands on hips, elbows outward, chest lifted, torso straight, legs shoulder-width apart, feet firmly planted

029. three-quarter back view, eye-level view, standing, looking over shoulder, one hand holding hair, other hand near hip, torso twisted, one leg behind the other, heel raised

030. front view, slightly high-angle view, standing, hands clasped behind lower back, head tilted, shoulders forward slightly, torso leaning toward viewer, knees together, one foot lightly crossing in front


## B. 站姿／微性感但SFW 031–050

031. three-quarter view, eye-level view, standing, head tilted slightly back, one hand touching neck, other hand resting on hip, gentle back arch, hips shifted sideways, legs crossed, front toe pointed

032. front view, slightly low-angle view, standing, one hand behind head, other hand on waist, shoulders open, torso slightly curved, one knee bent inward, feet offset

033. side view, eye-level view, standing, looking at viewer, one arm raised above head against wall, other hand near waist, torso elongated, hips angled, legs crossed at ankles

034. three-quarter view, eye-level view, standing, fingertips touching collarbone, other hand resting along outer thigh, shoulders relaxed, torso slightly twisted, one leg forward, heel raised

035. front view, high-angle view, standing, hands behind head, elbows wide, torso gently arched, hip shifted, one knee bent, feet apart naturally

036. three-quarter view, slightly low-angle view, standing, one hand on hip, other hand touching lips, chin raised slightly, waist curved, front leg crossed over rear leg

037. side view, eye-level view, standing, one hand holding opposite upper arm, other hand resting near waist, chest angled toward viewer, hips slightly back, knees close, rear heel lifted

038. front view, eye-level view, standing, both hands lightly holding sides of jacket, shoulders back, torso straight, legs close together, one knee bent, playful confident smile

039. three-quarter back view, eye-level view, standing, looking back, one hand touching lower hair, other hand on waist, gentle torso twist, hips shifted, one leg crossed behind

040. front view, low-angle view, standing, one arm extended upward, other hand along waist, body stretched diagonally, hip shifted outward, one foot on tiptoe

041. three-quarter view, eye-level view, standing, both hands clasped behind head, elbows outward, head tilted, torso slightly leaning sideways, legs crossed, relaxed smile

042. front view, eye-level view, standing, one hand holding sleeve near shoulder, other hand resting on opposite hip, torso gently curved, knees slightly bent, feet staggered

043. side view, low-angle view, standing, head turned toward viewer, one hand at back of neck, other arm relaxed, torso slightly arched, one leg extended behind, toe touching floor

044. three-quarter view, high-angle view, standing, fingertip touching lower lip, other hand behind back, shoulders slightly forward, torso leaning in, knees together, ankles crossed

045. front view, eye-level view, standing, both arms crossed loosely, one shoulder slightly raised, hips tilted opposite direction, one knee bent inward, feet close

046. three-quarter view, eye-level view, standing, one hand touching waist, other hand lifting hair, torso slightly twisted, front leg straight, rear knee bent, rear heel lifted

047. side view, eye-level view, standing, arms behind back, shoulders pulled gently back, chin slightly lowered, back softly curved, legs together, one foot forward

048. front view, slightly high-angle view, standing, hands clasped above chest, head tilted, torso leaning forward slightly, knees close, one heel raised

049. three-quarter view, low-angle view, standing, one arm raised behind head, other hand near outer thigh, shoulders angled, torso elongated, hips shifted, front toe pointed

050. front view, eye-level view, standing, one hand touching cheek, other hand at waist, torso turned slightly, one knee bent inward, feet close, soft teasing smile


## C. 地板坐姿／跪姿 051–080

051. floor, front view, eye-level view, sitting on floor, knees bent to one side, hands resting on lap, torso upright, head slightly tilted, ankles together

052. floor, three-quarter view, slightly high-angle view, sitting cross-legged, one hand on knee, other hand touching cheek, torso relaxed, shoulders down, feet tucked under legs

053. floor, front view, high-angle view, sitting with knees hugged to chest, arms wrapped around knees, chin resting on knees, back slightly rounded, feet close together

054. floor, side view, eye-level view, sitting with legs extended forward, hands behind body supporting weight, torso leaning back, head turned toward viewer, ankles crossed

055. floor, three-quarter view, high-angle view, sitting with one knee raised, one leg folded beneath body, one arm resting on raised knee, other hand on floor, torso slightly twisted

056. floor, front view, eye-level view, kneeling, sitting on heels, hands resting neatly on thighs, torso straight, shoulders relaxed, feet tucked behind

057. floor, three-quarter view, eye-level view, kneeling, one knee raised, opposite knee on floor, one hand resting on raised knee, other hand touching hair, torso upright

058. floor, side view, low-angle view, kneeling upright, hands clasped behind back, shoulders pulled back, torso straight, knees together, feet extended behind

059. floor, front view, high-angle view, kneeling, hands clasped at chest, head tilted slightly, torso leaning forward, knees close, toes pointed behind

060. floor, three-quarter view, eye-level view, sitting sideways, both legs folded to one side, one hand on floor for support, other hand on lap, torso gently curved

061. floor, front view, high-angle view, sitting with legs in butterfly position, feet together, hands holding ankles, torso leaning slightly forward, cheerful expression

062. floor, side view, eye-level view, sitting with one leg extended, other knee bent, arm resting across bent knee, other hand supporting body behind, torso twisted toward viewer

063. floor, three-quarter view, high-angle view, sitting with both knees bent, feet flat on floor, hands behind body, torso leaning back, head tilted toward viewer

064. floor, front view, eye-level view, sitting with one leg folded under, other leg bent upward, both hands clasped around raised knee, torso upright

065. floor, three-quarter view, eye-level view, kneeling on one knee, opposite foot planted forward, one hand on waist, other hand resting on raised thigh, confident pose

066. floor, front view, slightly high-angle view, sitting with legs crossed at ankles in front, hands resting beside hips, torso straight, shoulders relaxed

067. floor, side view, eye-level view, sitting on heels, torso turned toward viewer, one hand on floor beside knee, other hand brushing hair back

068. floor, three-quarter view, high-angle view, sitting with knees folded beneath body, torso leaning to one side, one elbow on knee, cheek resting on hand

069. floor, front view, eye-level view, sitting with one knee raised and other leg extended diagonally, one hand on knee, other hand behind body, torso slightly leaning back

070. floor, three-quarter view, slightly low-angle view, kneeling upright, one arm raised overhead, other hand resting on thigh, torso stretched sideways, feet tucked behind

071. floor, front view, high-angle view, kneeling, both hands making peace signs beside face, torso upright, knees together, feet behind, playful expression

072. floor, side view, eye-level view, sitting with legs folded behind to one side, one hand supporting body, other hand at collarbone, head turned toward viewer

073. floor, three-quarter view, eye-level view, sitting cross-legged, elbows resting on knees, hands supporting cheeks, torso leaning forward, relaxed smile

074. floor, front view, high-angle view, sitting with knees together and feet to either side, hands clasped between knees, torso slightly forward, shy pose

075. floor, three-quarter view, eye-level view, one knee on floor, other leg extended sideways, one hand on hip, other arm stretched upward, torso leaning sideways

076. floor, front view, eye-level view, sitting with both legs extended diagonally to one side, one hand behind for support, other hand waving, ankles crossed

077. floor, side view, high-angle view, sitting with knees pulled close, one arm wrapped around legs, other hand touching hair, shoulders slightly rounded

078. floor, three-quarter view, low-angle view, kneeling with one knee raised, hands clasped behind head, torso upright, hips resting lightly on rear heel

079. floor, front view, eye-level view, kneeling with knees slightly apart, hands resting on thighs, straight posture, chin slightly raised, composed expression

080. floor, three-quarter view, high-angle view, sitting with one leg tucked under and one extended forward, fingertips touching floor beside body, torso angled gracefully


## D. 地板躺姿 081–100

081. floor, top-down view, lying on back, head turned toward viewer, one arm above head, other hand resting on abdomen, one leg straight, other knee bent

082. floor, top-down view, lying on back, both arms stretched overhead, torso elongated, legs together, toes pointed, relaxed expression

083. floor, three-quarter overhead view, lying on side, one hand supporting head, other arm resting along waist, lower leg straight, upper knee bent forward

084. floor, side view, eye-level view, lying on side, head resting on folded arm, other hand near face, legs slightly bent, ankles close

085. floor, top-down view, lying on back, hands behind head, elbows outward, one knee raised, other leg extended, feet relaxed

086. floor, three-quarter view, low-angle view, reclining on one elbow, other hand resting on raised knee, torso slightly twisted, one leg straight, other knee bent

087. floor, high-angle view, lying on stomach, elbows on floor, chin resting on hands, lower legs raised behind, ankles crossed

088. floor, side view, lying on stomach, one arm stretched forward, other hand near face, head turned toward viewer, one knee bent sideways slightly

089. floor, top-down view, lying diagonally, one arm extended outward, other hand touching hair, legs crossed at ankles, toes pointed

090. floor, three-quarter overhead view, lying on back, one hand near cheek, other arm extended sideways, knees bent together to one side

091. floor, side view, reclining with both elbows behind body, torso raised, legs extended forward, ankles crossed, chin slightly raised

092. floor, high-angle view, lying on side curled gently, hands near face, knees bent slightly, feet together, calm sleepy pose

093. floor, top-down view, lying on back, arms spread softly outward, one leg straight, other knee bent across body, head turned opposite direction

094. floor, three-quarter view, lying on stomach, propped on forearms, shoulders lifted, legs extended behind, one foot crossed over the other

095. floor, high-angle view, reclining on one hip, one palm on floor, other hand on thigh, torso angled upward, knees bent to one side

096. floor, top-down view, lying on back, both hands clasped over chest, one ankle crossed over the other, legs straight, serene expression

097. floor, three-quarter view, reclining on both hands, torso leaning back, knees bent, one foot flat and one leg extended, playful smile

098. floor, side view, lying on side, upper arm stretched overhead along floor, lower hand near chin, legs extended with knees slightly bent

099. floor, top-down view, lying on back, one arm covering forehead, other hand resting beside hip, one knee raised, other leg extended diagonally

100. floor, three-quarter overhead view, lying on back, both knees bent, legs tilted together to one side, hands above head, relaxed curved body line


## E. 椅子／沙發 101–130

101. chair, front view, eye-level view, sitting upright, hands on lap, shoulders relaxed, knees together, feet flat on floor

102. chair, three-quarter view, eye-level view, sitting with legs crossed at knees, one hand on armrest, other hand touching chin, torso straight

103. chair, side view, eye-level view, sitting sideways on chair, torso turned toward viewer, one hand on chair back, legs crossed at ankles

104. chair, slightly low-angle view, sitting backward on chair, arms folded over chair back, torso leaning forward, knees apart naturally, feet planted

105. chair, high-angle view, sitting near edge of seat, hands clasped between knees, torso leaning forward, knees together, toes inward

106. chair, three-quarter view, sitting relaxed, one elbow on armrest, cheek resting on hand, opposite hand on thigh, legs crossed

107. chair, front view, eye-level view, sitting with one leg crossed over the other, hands behind head, elbows wide, torso leaning back slightly

108. chair, side view, sitting with both feet on chair edge, knees hugged lightly, arms around knees, chin tilted downward

109. chair, three-quarter view, sitting sideways, one leg crossed over chair edge, other foot on floor, one arm draped over chair back

110. chair, front view, slightly low-angle view, sitting with feet apart naturally, forearms resting on thighs, torso leaning forward, confident gaze

111. chair, high-angle view, sitting with one knee raised onto seat, other foot on floor, one hand around raised knee, torso slightly twisted

112. chair, three-quarter view, sitting elegantly, ankles crossed, knees angled to one side, both hands clasped on lap, straight posture

113. sofa, front view, sitting centered, hands resting beside hips, torso relaxed, knees together, feet slightly forward

114. sofa, three-quarter view, reclining into cushions, one arm along backrest, other hand on lap, legs crossed at ankles

115. sofa, side view, sitting curled sideways, knees drawn up, one arm wrapped around legs, other hand holding cushion

116. sofa, high-angle view, lying sideways, head resting on armrest, one arm beneath head, legs bent slightly, ankles stacked

117. sofa, front view, sitting with one knee tucked under body, other foot on floor, elbow on sofa back, cheek resting on hand

118. sofa, three-quarter view, reclining with both arms along backrest, torso open, legs crossed at knees, relaxed confident expression

119. sofa, side view, sitting on edge, hands behind body on seat, torso leaning back, legs extended slightly forward

120. sofa, high-angle view, sitting with both knees hugged to chest, chin resting on knees, feet on cushion, cozy pose

121. armchair, front view, sitting upright, one arm on armrest, other hand holding cup near face, ankles crossed

122. armchair, three-quarter view, sitting diagonally, legs crossed, elbow on armrest, head supported by hand, calm expression

123. armchair, side view, reclining deeply, head resting against backrest, hands folded over abdomen, one leg crossed over the other

124. chair, front view, sitting with hands gripping seat edges lightly, shoulders back, knees together, feet pointed outward

125. chair, three-quarter view, sitting near edge, one hand behind head, other hand on thigh, torso gently arched, legs crossed

126. stool, front view, sitting tall, one hand on hip, other hand resting on thigh, one knee bent more than the other, feet staggered

127. stool, side view, sitting sideways, one hand holding seat edge, other hand brushing hair back, legs crossed at ankles

128. stool, three-quarter view, sitting with one foot on stool rung, other foot on floor, elbow resting on raised knee

129. bench, front view, sitting with hands behind on bench, torso leaning back, legs extended forward, ankles crossed

130. bench, three-quarter view, sitting with one knee raised onto bench, one arm around knee, other hand resting behind body


## F. 桌子／書桌／吧台 131–155

131. desk, front view, sitting behind desk, elbows on tabletop, hands clasped under chin, torso leaning forward, feet together beneath desk

132. desk, three-quarter view, sitting sideways, one elbow on desk, cheek resting on hand, legs crossed at knees

133. desk, side view, sitting on desk edge, hands beside hips, torso straight, legs hanging naturally, ankles crossed

134. desk, front view, sitting on desk edge, one hand behind body, other hand holding book near chest, knees together, feet pointed downward

135. desk, low-angle view, sitting on desk edge, arms crossed loosely, torso leaning slightly back, one leg crossed over the other

136. desk, three-quarter view, standing beside desk, one hand resting on tabletop, other hand touching hair, hips shifted, legs crossed

137. desk, side view, leaning against desk, both hands behind body on tabletop, torso slightly reclined, one knee bent

138. desk, front view, leaning forward with palms on desk, shoulders slightly forward, torso straight from hips, one leg behind the other

139. desk, three-quarter view, sitting at desk, one hand writing, other hand supporting cheek, torso slightly hunched, feet crossed beneath chair

140. desk, high-angle view, sitting with forearms on desk, head resting on folded arms, legs relaxed beneath seat

141. table, front view, sitting with hands around cup, elbows near body, torso upright, knees close, feet together

142. table, three-quarter view, sitting with one elbow on table, fingers near lips, other hand on lap, legs crossed

143. table, side view, sitting sideways, one hand holding drink, other arm over chair back, legs crossed at ankles

144. table, front view, standing behind table, hands resting lightly on tabletop, shoulders relaxed, torso leaning slightly forward

145. table, three-quarter view, sitting on table edge, one hand at collarbone, other hand supporting body, one leg extended, other knee bent

146. table, side view, sitting on table edge, torso turned toward viewer, legs crossed at calves, toes pointed down

147. bar counter, front view, standing, one elbow on counter, cheek resting on hand, other hand at waist, legs crossed

148. bar counter, three-quarter view, sitting on high stool, one elbow on counter, torso turned toward viewer, legs crossed, feet on stool rung

149. bar counter, side view, leaning back against counter, hands behind body, one leg bent forward, relaxed expression

150. table, high-angle view, sitting with chin resting on both hands, elbows on table, shoulders raised slightly, feet swinging beneath chair

151. desk, side view, standing and reaching toward high shelf, one hand on desk for support, torso stretched upward, one heel lifted

152. table, three-quarter view, standing while arranging objects, one hand extended forward, other hand holding object near waist, feet staggered

153. desk, front view, sitting with one knee pulled slightly toward chest on chair, arms resting around knee, torso relaxed

154. table, low-angle view, sitting on table edge, hands behind body, shoulders pulled back, one knee bent, other leg hanging straight

155. desk, three-quarter view, standing beside chair, one hand holding chair back, other hand at waist, torso angled, one foot crossing behind


## G. 床上／臥室 156–180

156. bed, top-down view, lying on back, head centered on pillow, one hand above head, other hand on abdomen, one knee bent, other leg straight

157. bed, high-angle view, lying on side, head on pillow, one hand under cheek, other hand resting near waist, knees gently bent

158. bed, side view, sitting on bed edge, hands beside hips, torso straight, knees together, feet touching floor

159. bed, front view, sitting cross-legged, hands resting on knees, torso relaxed, head slightly tilted

160. bed, high-angle view, sitting with knees hugged to chest, arms around knees, chin resting softly on top

161. bed, three-quarter view, kneeling on mattress, hands on thighs, torso upright, feet tucked behind, gentle smile

162. bed, side view, kneeling while leaning forward onto hands, back straight, head turned toward viewer, feet tucked behind

163. bed, top-down view, lying diagonally, arms stretched overhead, torso elongated, legs together, toes pointed

164. bed, three-quarter overhead view, lying on stomach, elbows on pillow, chin in hands, lower legs raised, ankles crossed

165. bed, side view, lying on stomach, head resting on folded arms, one knee bent slightly sideways, relaxed sleepy pose

166. bed, high-angle view, reclining against pillows, one arm behind head, other hand on lap, one knee raised, other leg extended

167. bed, front view, sitting against headboard, legs extended forward, hands resting beside hips, ankles crossed

168. bed, three-quarter view, sitting against pillows, one knee raised, arms wrapped around knee, other leg extended

169. bed, top-down view, lying on back, both hands holding pillow above chest, one leg crossed loosely over the other

170. bed, side view, lying curled gently under blanket, hands near face, knees bent, feet together

171. bed, high-angle view, sitting on heels, hands clasped behind back, torso leaning forward slightly, knees close

172. bed, three-quarter view, sitting sideways, one hand on mattress, other hand touching hair, legs folded to one side

173. bed, front view, sitting with one knee bent and one leg extended, both hands behind body, torso leaning back

174. bed, high-angle view, reclining on one elbow, other hand holding phone near face, one knee raised, other leg straight

175. bed, top-down view, lying on side with pillow hugged to chest, upper knee bent forward, lower leg extended

176. bed, three-quarter view, sitting near edge, one hand covering yawn, other hand on mattress, legs slightly apart naturally, sleepy pose

177. bed, side view, standing beside bed, one knee resting on mattress, one hand on headboard, other arm relaxed

178. bed, high-angle view, sitting with legs tucked beneath body, hands wrapped around mug, shoulders relaxed

179. bed, front view, kneeling while stretching both arms overhead, torso elongated, gentle back stretch, feet tucked under

180. bed, top-down view, lying on back, arms spread loosely, knees bent together to one side, relaxed morning pose


## H. 牆壁／窗戶／門框 181–195

181. wall, front view, leaning back against wall, arms crossed, one knee bent with foot against wall, confident expression

182. wall, three-quarter view, one hand against wall above shoulder, other hand on hip, torso angled, legs crossed at ankles

183. wall, side view, shoulder leaning against wall, hands behind back, head turned toward viewer, one knee softly bent

184. wall, low-angle view, back against wall, both hands in pockets, shoulders relaxed, legs apart naturally

185. wall, high-angle view, palms behind body against wall, torso leaning slightly forward, knees together, one heel lifted

186. window, side view, standing beside window, one hand touching glass, other hand near chest, head turned outward, legs close together

187. window, three-quarter view, leaning lightly against windowsill, one elbow resting on sill, other hand holding curtain, feet crossed

188. window, back view, looking outside, both hands on windowsill, torso slightly leaning forward, one knee relaxed

189. window, front view, sitting on windowsill, one hand beside hip, other hand touching hair, legs hanging, ankles crossed

190. window, three-quarter view, sitting sideways on sill, knees bent, one arm wrapped around legs, other hand on frame

191. doorway, front view, one hand holding doorframe above shoulder, other hand at waist, hips shifted, legs crossed

192. doorway, three-quarter view, both hands lightly holding opposite sides of doorframe, torso leaning forward slightly, one foot ahead

193. doorway, side view, shoulder resting on frame, arms loosely crossed, one knee bent, toe touching floor

194. railing, three-quarter view, forearms resting on railing, torso leaning forward slightly, one leg crossed behind the other

195. balcony, back three-quarter view, both hands on railing, looking over shoulder, torso twisted, one leg extended slightly behind


## I. 樓梯／戶外／動態／伸展 196–200

196. stairs, three-quarter view, sitting on step, one knee raised, elbow resting on knee, other hand beside hip, other leg extended down one step, relaxed casual pose

197. stairs, low-angle view, standing one step above camera, one hand on railing, other hand touching hair, torso upright, one leg forward, rear heel lifted

198. outdoor path, three-quarter view, walking, head turned toward viewer, one arm swinging forward, other arm back, torso naturally rotated, front knee bent, rear leg extended

199. open space, front view, full-body stretch, both arms raised overhead, torso leaning sideways, one leg straight, other knee bent, feet apart, cheerful relaxed expression

200. open space, three-quarter view, playful spin pose, head turned toward viewer, one arm extended outward, other arm bent near chest, torso twisting, skirt or coat moving with motion, one leg supporting body, other leg lifted slightly behind, pointed toe
追加 600 種姿勢標籤（201–800）
J. 站姿延伸 201–260
201. front view, eye-level view, standing, head slightly tilted, one hand touching collar, other hand relaxed at side, torso upright, knees together, one foot slightly forward
202. three-quarter view, eye-level view, standing, looking at viewer, one hand behind back, other hand waving, shoulders relaxed, hips shifted, ankles crossed
203. front view, slightly high-angle view, standing, both hands clasped in front, chin lowered, torso straight, knees close, toes inward
204. side view, eye-level view, standing, looking back over shoulder, one hand brushing hair, other hand near waist, one knee bent, rear heel raised
205. three-quarter view, slightly low-angle view, standing, one hand on hip, other hand near cheek, chest open, one leg extended diagonally
206. front view, eye-level view, standing, both hands behind back, shoulders slightly forward, head tilted, knees together, feet aligned
207. front view, low-angle view, standing confidently, arms loosely crossed, chin raised slightly, legs shoulder-width apart
208. three-quarter view, eye-level view, standing, one hand adjusting sleeve, other hand holding skirt hem lightly, knees close, front toe pointed
209. side view, eye-level view, standing, both hands in pockets, torso slightly leaning back, one leg straight, one knee relaxed
210. front view, high-angle view, standing, both hands near chest, elbows inward, shy posture, knees together, heels close
211. three-quarter view, eye-level view, standing, one hand holding bag strap, other hand at waist, torso turned slightly, legs crossed at calves
212. front view, eye-level view, standing, one arm lifted overhead, other hand on hip, torso stretched, one knee bent inward
213. side view, slightly low-angle view, standing, arms behind back, head turned toward viewer, hips gently back, one foot behind the other
214. three-quarter back view, eye-level view, standing, looking over shoulder, one hand lifting hair, other arm relaxed, one leg forward
215. front view, eye-level view, standing, both hands holding jacket lapels, shoulders back, torso straight, one foot angled outward
216. three-quarter view, high-angle view, standing, fingertips near lips, other hand behind waist, knees close, front heel raised
217. front view, eye-level view, standing, hands clasped behind head, elbows wide, relaxed back stretch, hips shifted
218. side view, eye-level view, standing, one hand at neck, other hand across stomach, gentle torso twist, knees soft
219. three-quarter view, low-angle view, standing, one hand extended outward, other hand at chest, body angled dynamically, one leg forward
220. front view, eye-level view, standing, one hand saluting, other arm hanging naturally, feet together, playful expression
221. three-quarter view, eye-level view, standing, one elbow bent with hand near shoulder, other hand near thigh, hips tilted, legs close
222. front view, slightly low-angle view, standing, both hands on hips, shoulders squared, feet apart, confident pose
223. side view, eye-level view, standing, one arm folded under chest, other hand touching chin, thoughtful posture
224. front view, eye-level view, standing, hands lightly clasped at lower abdomen, calm formal posture, knees relaxed
225. three-quarter view, eye-level view, standing, one hand raised in peace sign, other hand behind back, one knee bent
226. front view, high-angle view, standing, both hands lightly touching cheeks, shoulders raised slightly, toes inward
227. side view, eye-level view, standing, one hand on wall, other hand at waist, hips angled, one leg straight
228. three-quarter view, eye-level view, standing, one hand over chest, other hand extended slightly outward, soft elegant posture
229. front view, eye-level view, standing, arms at sides, torso straight, one foot slightly ahead, minimal neutral pose
230. three-quarter view, eye-level view, standing, one hand tucked behind head, other hand in pocket, relaxed casual pose
231. front view, slightly high-angle view, standing, hands folded neatly, head tilted, knees together, modest pose
232. side view, slightly low-angle view, standing, one hand touching ear, other hand resting behind back, one heel lifted
233. front view, eye-level view, standing, both hands lifting skirt edges lightly, knees together, cheerful pose
234. three-quarter view, eye-level view, standing, one hand making small heart sign, other hand at waist, legs crossed
235. front view, eye-level view, standing, both arms stretched sideways, shoulders relaxed, feet apart, open welcoming pose
236. side view, eye-level view, standing, hands clasped behind body, back straight, chest slightly forward
237. three-quarter view, high-angle view, standing, one hand touching ribbon, other hand by side, hips shifted, toes inward
238. front view, eye-level view, standing, one arm across stomach, other elbow resting on it, hand at cheek
239. three-quarter back view, eye-level view, standing, one hand over shoulder, other hand at thigh, elegant turn pose
240. front view, low-angle view, standing, arms spread softly, chin slightly raised, one knee bent
241. side view, eye-level view, standing, one hand holding scarf, other hand down, legs close together
242. front view, eye-level view, standing, fingers interlaced in front of chest, shoulders relaxed, one foot back
243. three-quarter view, eye-level view, standing, one hand on hip, other hand holding sleeve cuff, front toe pointed
244. front view, slightly high-angle view, standing, both hands near mouth, elbows tucked in, shy playful pose
245. side view, eye-level view, standing, one hand at shoulder, other hand resting on thigh, one knee bent softly
246. three-quarter view, low-angle view, standing, one arm raised high, other hand open near waist, dynamic cheerful pose
247. front view, eye-level view, standing, both hands holding backpack straps, torso slightly leaning forward
248. three-quarter view, eye-level view, standing, one hand extended behind, other near chest, body twisted elegantly
249. side view, eye-level view, standing, looking upward slightly, hands folded behind back, long straight posture
250. front view, eye-level view, standing, one hand waving above shoulder, other hand on hip, one leg angled outward
251. front view, eye-level view, standing, both hands in front pockets, weight on one leg, casual posture
252. three-quarter view, slightly low-angle view, standing, one hand on chest, other hand down, one ankle crossed over the other
253. side view, eye-level view, standing, one hand brushing bangs aside, other arm at side, rear heel raised
254. front view, eye-level view, standing, arms loosely folded, head tilted, knees lightly bent
255. three-quarter view, eye-level view, standing, one hand reaching outward, other behind back, body angled gently
256. front view, high-angle view, standing, both hands clasped under chin, one knee inward, cute pose
257. side view, slightly high-angle view, standing, one arm bent with hand near face, other hand on thigh, playful lean
258. three-quarter view, eye-level view, standing, one hand holding hair ends, other hand at hip, elegant stance
259. front view, eye-level view, standing, hands at sides, one knee slightly bent inward, calm neutral pose
260. three-quarter view, eye-level view, standing, one hand making V sign near eye, other hand hanging loosely, cheerful pose
K. 走路／動態站姿 261–320
261. front view, walking pose, one arm forward, other arm back, torso upright, one leg stepping forward
262. three-quarter view, walking pose, looking back, one hand lifting hair, one foot mid-step
263. side view, brisk walking pose, arms swinging naturally, torso slightly forward, rear heel lifted
264. front view, light skipping pose, both arms spread, one leg lifted, cheerful movement
265. three-quarter view, walking while waving, one hand up, other hand holding bag, front foot stepping
266. side view, slow graceful walk, one hand at chest, one hand trailing behind, skirt moving
267. front view, turning mid-step, arms softly out, torso twisting, one foot pivoting
268. three-quarter view, stepping onto toes, one hand at waist, other holding hat, elegant stroll
269. side view, half-running pose, elbows bent, chest forward, one knee raised
270. front view, walking with hands in pockets, shoulders relaxed, one foot crossing slightly in front
271. three-quarter view, looking upward while walking, one hand near face, other down, long stride
272. side view, cautious step, both hands clasped in front, one foot testing ground
273. front view, playful hop, one knee raised, both arms bent outward
274. three-quarter view, soft dance-like step, one arm overhead, one arm outward, front foot pointed
275. side view, stretching while walking, both hands linked behind head, one leg stepping
276. front view, runway-like walk, hands relaxed, shoulders back, one leg crossing centerline
277. three-quarter view, holding hem while stepping, other hand at waist, torso angled
278. side view, quick turn step, one arm extended behind, one in front, hair swaying
279. front view, walking with one arm folded and one hand at chin, thoughtful pace
280. three-quarter view, stepping over puddle pose, one knee high, balance arm out
281. front view, marching pose, one fist near chest, one leg lifted sharply
282. side view, elegant heel-first step, one hand behind back, torso tall
283. three-quarter view, reaching forward while stepping, other arm behind, dynamic balance
284. front view, walking with shopping bag, shoulders relaxed, one knee bent forward
285. side view, light run pose, ponytail flying, elbows bent, rear leg stretched
286. three-quarter view, stop-and-turn pose, one foot planted, one foot pivoted, one hand near cheek
287. front view, stepping backward playfully, hands slightly raised, torso leaning back
288. side view, strolling with one hand in coat pocket, other hand adjusting scarf
289. three-quarter view, skipping with both arms bent upward, one foot lifted behind
290. front view, confident stride, both shoulders level, hands down, knees aligned
291. side view, careful descending step, one hand extended for balance, one foot lower
292. three-quarter view, leaning into wind while walking, hands holding coat edges
293. front view, tiptoe step, both hands clasped behind back, knees together
294. side view, stepping over threshold, one hand on doorframe, other hand lifting skirt
295. three-quarter view, playful spin-step, one arm open, other near chest, skirt flaring
296. front view, walking while holding umbrella at side, head slightly lowered
297. side view, running lightly with one hand near hat, other arm pumping
298. three-quarter view, one foot on tiptoe behind, hands extended, dance-step pose
299. front view, stepping sideways, one hand up near shoulder, one hand down
300. side view, stride with both hands clasped before chest, modest dynamic movement
301. three-quarter view, stepping forward with one hand saluting, other at waist
302. front view, jogging pose, both elbows bent, torso forward, knees active
303. side view, long step with one arm reaching back, other forward
304. three-quarter view, playful bounce, one arm out, one hand at cheek, one knee raised
305. front view, stepping while looking to side, hands loose at sides
306. side view, tiptoe sneak step, shoulders slightly hunched, hands near chest
307. three-quarter view, energetic run-up pose, one leg back, both arms bent
308. front view, stepping with bouquet held forward, other hand behind back
309. side view, relaxed walk with one hand brushing hair, other in pocket
310. three-quarter view, gentle turn-step, one arm curved overhead, one foot pivoted
311. front view, walking with drink cup, other hand waving, easy casual motion
312. side view, stretched stride, arms softly extended, body elongated
313. three-quarter view, hopping sideways, one hand raised, one leg bent outward
314. front view, stepping while holding skirt, knees close, toes pointed
315. side view, lively walk with bag swinging, one heel lifted
316. three-quarter view, quick backward glance while walking, one hand near ear
317. front view, skipping with one arm overhead, one leg lifted behind
318. side view, balanced mid-step pose, hands held slightly out from body
319. three-quarter view, walking with slight forward lean, determined expression
320. front view, one foot planted, one heel raised, both hands open outward, transition step pose
L. 坐姿延伸（地面／低台）321–380
321. floor, front view, sitting with legs straight forward, hands beside hips, ankles together
322. floor, three-quarter view, sitting with one knee raised and one extended, hands around raised knee
323. floor, side view, sitting with both legs folded behind, one hand on floor, other near face
324. floor, front view, cross-legged, hands on knees, relaxed upright posture
325. floor, high-angle view, sitting with both knees hugged, chin on knees, cozy pose
326. floor, three-quarter view, sitting with legs to one side, torso turned toward viewer
327. floor, side view, reclining on straight arms behind, legs bent together
328. floor, front view, one leg tucked under, one knee up, hands on shin
329. floor, three-quarter view, sitting with ankles crossed, palms on floor behind body
330. floor, high-angle view, kneeling, hands on thighs, torso leaning slightly forward
331. floor, front view, kneeling with one hand waving, other resting on lap
332. floor, side view, seiza sitting pose, hands folded neatly, calm posture
333. floor, three-quarter view, seiza with torso twisted toward viewer, one hand on floor
334. floor, front view, butterfly sit, hands holding feet, back straight
335. floor, three-quarter view, sitting with one leg bent outward, other folded in
336. floor, side view, knees bent up, arms wrapped around shins, soft smile
337. floor, front view, legs apart slightly, hands planted between legs, casual stretch
338. floor, three-quarter view, one hand behind body, one hand at collar, one knee up
339. floor, side view, sitting with both legs extended diagonally, one ankle over the other
340. floor, front view, kneeling with hands clasped behind back, shoulders open
341. floor, three-quarter view, sitting sideways, elbow on knee, cheek in hand
342. floor, top-down view, sitting curled in a soft C-shape, knees near chest
343. floor, front view, legs crossed loosely, one hand holding shoe, playful casual pose
344. floor, side view, one knee folded, one leg stretched behind, one hand reaching forward
345. floor, three-quarter view, sitting on one heel, other knee raised, confident resting pose
346. floor, front view, both knees bent, feet flat, arms resting atop knees
347. floor, side view, both hands behind body, chest open, knees bent and together
348. floor, three-quarter view, one hand supporting body, other hand waving above shoulder
349. floor, front view, seiza pose with one hand over heart, other hand on lap
350. floor, high-angle view, knees together to one side, hands folded beside legs
351. floor, front view, cross-legged, arms stretched upward, relaxed stretch
352. floor, side view, seated with one knee tucked close, one hand around ankle
353. floor, three-quarter view, knees bent to left side, torso upright, hands on lap
354. floor, front view, sitting with soles together, elbows on knees, chin in hands
355. floor, side view, one leg forward, one tucked behind, both hands on floor
356. floor, three-quarter view, seated on cushion, hands holding knees, cozy posture
357. floor, front view, kneeling, one hand extended outward, one hand at chest
358. floor, side view, sitting with legs outstretched, hands on calves, leaning slightly forward
359. floor, three-quarter view, cross-legged, one elbow on knee, fingers near lips
360. floor, front view, one leg tucked, one leg extended to side, one hand on thigh
361. floor, side view, seiza, hands tucked into sleeves, modest pose
362. floor, three-quarter view, knees hugged, head resting sideways on knees
363. floor, front view, both hands pressing floor behind body, knees bent and open slightly
364. floor, side view, one arm across raised knee, other behind body, relaxed posture
365. floor, three-quarter view, sitting with ankles crossed under skirt, both hands folded
366. floor, front view, kneeling with one hand at cheek, other on thigh
367. floor, side view, seated with torso leaning backward onto elbows, legs straight
368. floor, three-quarter view, one leg folded under, other knee raised high, one arm atop knee
369. floor, front view, sitting with legs apart in a V shape, hands between knees
370. floor, high-angle view, seated with both hands spread on floor, leaning in playfully
371. floor, side view, kneeling and reaching forward, torso elongated
372. floor, three-quarter view, seated with one foot flat, one folded leg, hand on ankle
373. floor, front view, cross-legged, both hands making peace signs beside face
374. floor, side view, seated with torso twisted back, hair falling over shoulder
375. floor, three-quarter view, sitting on folded blanket, one hand holding mug
376. floor, front view, kneeling upright, one hand saluting, other hand on lap
377. floor, side view, seated with knees stacked, arms wrapped lightly around waist
378. floor, three-quarter view, one leg folded inward, other extended, one hand reaching out
379. floor, front view, sitting small and compact, knees tucked close, hands on shins
380. floor, side view, seated tall with one hand on floor and other lifting hair
M. 躺姿 / 半躺姿延伸 381–440
381. floor, top-down view, lying on back, arms loose at sides, one knee bent
382. floor, side view, lying on side, one hand under cheek, legs softly curled
383. floor, front overhead view, lying on stomach, chin in hands, feet raised
384. floor, three-quarter overhead view, reclining on one elbow, one knee lifted
385. floor, top-down view, lying diagonally, one arm above head, one hand on thigh
386. sofa, reclining, one arm along backrest, other hand on abdomen, legs crossed
387. bed, side view, lying on side, arms around pillow, knees bent
388. bed, top-down view, lying on back, both hands over chest, ankles crossed
389. bed, three-quarter overhead view, lying on stomach, one cheek on pillow, legs extended
390. sofa, side view, half-lying, one elbow supporting torso, one leg bent
391. floor, high-angle view, lying on back, one hand covering forehead, one leg straight
392. floor, side view, reclining with both hands behind body, knees bent
393. bed, top-down view, lying spread gently, one knee tilted outward
394. sofa, front view, reclining into cushion, one hand reaching toward viewer
395. floor, three-quarter view, lying on side, upper arm draped across waist
396. bed, overhead view, curled on side, hands near face, sleepy pose
397. floor, side view, lying on stomach, one leg bent upward, other leg straight
398. floor, top-down view, lying on back, arms above head, legs together
399. sofa, side view, lying along sofa length, ankles crossed, one arm under head
400. bed, three-quarter overhead view, reclining against pillows, one knee up
401. floor, reclining pose, one elbow down, one hand touching chin, legs bent to side
402. bed, lying on side, hugging blanket, knees close together
403. floor, top-down view, lying on back, both knees bent, feet flat, hands by head
404. sofa, high-angle view, lying curled with feet tucked under, calm expression
405. bed, side view, lying on stomach, elbows on mattress, feet lifted and crossed
406. floor, side view, reclining with one hand on chest, other arm extended
407. bed, top-down view, lying on back, one ankle over the other, head turned aside
408. floor, three-quarter overhead view, lying with knees to one side, arms relaxed
409. sofa, reclining upright with one arm behind head, one leg tucked up
410. bed, front high-angle, lying diagonally, one hand brushing hair away
411. floor, side view, half-curled pose, one arm around waist, knees bent
412. bed, overhead view, both arms hugging pillow over chest, legs extended
413. sofa, three-quarter view, reclining with one hand holding book near face
414. floor, lying on side, knees bent, lower hand under head, upper hand on thigh
415. bed, high-angle view, lying on stomach, hands folded under cheek
416. floor, reclining on elbows, torso lifted, legs folded to one side
417. bed, lying on back, one arm up, one arm out, relaxed sprawl
418. sofa, lying across seat, knees bent over armrest slightly
419. floor, top-down view, soft curled fetal-like pose, hands near chin
420. bed, half-reclining with blanket over legs, one knee raised
421. floor, side view, lying on side and propped on elbow, top leg bent
422. bed, overhead, one hand holding phone above face, legs relaxed
423. floor, reclining with torso twisted toward viewer, ankles crossed
424. sofa, laid sideways, one hand hanging over edge, dreamy pose
425. bed, front high-angle, lying on side with pillow hugged tightly
426. floor, top-down view, lying with one arm across eyes, one knee bent
427. bed, side view, lying on stomach, one hand under pillow, calm resting pose
428. sofa, reclining with knees hugged loosely, one cheek against cushion
429. floor, three-quarter overhead, one arm stretched out, legs long and aligned
430. bed, reclining with one hand behind head, one hand holding blanket
431. floor, side view, lying on back then turning head toward viewer, one knee up
432. sofa, front view, slouched reclining, one hand on armrest, one ankle crossed
433. bed, top-down, lying symmetrically, hands beside head, feet pointed
434. floor, side view, reclining and reading, one elbow down, book above chest
435. bed, side view, curled with blanket around shoulders
436. floor, high-angle view, lying with legs folded to one side and hands clasped
437. sofa, reclining with one leg draped over the other, elegant lounge pose
438. bed, overhead, lying on back with both arms open and relaxed
439. floor, side view, half-lying with one foot tucked under knee
440. sofa, reclining upright against armrest, one hand holding pillow, legs bent together
N. 椅子 / 沙發 / 躺椅 441–500
441. chair, front view, sitting upright, hands folded on lap, ankles together
442. chair, three-quarter view, one leg crossed, elbow on armrest, chin in hand
443. chair, side view, sitting sideways, both hands on seat edge, knees together
444. chair, front view, sitting near edge, one hand holding ribbon, one foot back
445. chair, three-quarter view, leaning back, both hands behind head, legs crossed
446. chair, side view, sitting with one knee up on seat, one arm draped around it
447. chair, front view, arms resting on armrests, legs apart naturally, composed posture
448. chair, high-angle view, knees hugged on seat, feet tucked up, cozy pose
449. chair, three-quarter view, both hands on thighs, back straight, feet flat
450. chair, side view, one hand on chair back, other at waist, legs crossed at ankle
451. stool, front view, sitting tall, hands beside hips, knees together
452. stool, three-quarter view, one foot on rung, elbow on raised knee
453. stool, side view, one hand behind body, one leg extended slightly forward
454. bench, front view, sitting centered, hands clasped between knees
455. bench, three-quarter view, one knee raised, one arm draped across it
456. bench, side view, leaning back on hands, legs extended along bench
457. bench, front view, ankles crossed, hands on lap, calm pose
458. sofa, front view, sitting upright, one arm over sofa back
459. sofa, three-quarter view, one knee tucked under body, other foot on floor
460. sofa, side view, reclining against cushions, one hand at cheek
461. sofa, front view, sitting cross-legged, hands around mug
462. sofa, three-quarter view, legs tucked to one side, one elbow on cushion
463. sofa, side view, sitting on edge, hands behind body, torso leaning back
464. armchair, front view, one hand on armrest, one hand holding book
465. armchair, three-quarter view, legs crossed, cheek resting on hand
466. armchair, side view, both feet drawn onto seat, arms around knees
467. chaise lounge, side view, reclining, one hand over stomach, legs elegantly bent
468. chaise lounge, three-quarter view, one elbow supporting torso, one hand extended
469. chair, front view, one hand saluting, other on thigh, feet together
470. chair, three-quarter view, one hand behind neck, other gripping seat edge
471. chair, side view, torso twisted toward viewer, knees together, ankles crossed
472. stool, front view, elbows on knees, chin resting in hands
473. stool, three-quarter view, one leg extended, toes touching floor lightly
474. bench, high-angle view, sitting with palms beside body, shoulders relaxed
475. sofa, front view, slouching comfortably, one leg folded up
476. sofa, side view, both feet on seat, chin on knees
477. armchair, front view, one arm hanging over side, relaxed elegant posture
478. chair, low-angle view, sitting with crossed legs and straight back
479. chair, front view, both hands clasped at chest, toes inward
480. bench, three-quarter view, leaning sideways on one arm, one leg stretched
481. sofa, three-quarter view, one hand fixing hair, other hand on cushion
482. chair, side view, one elbow on knee, other hand behind neck
483. stool, front view, both hands on lap, knees close, gentle posture
484. armchair, high-angle view, curled softly with blanket on lap
485. chaise lounge, front three-quarter view, reclining, legs extended and crossed
486. sofa, side view, lying partly across cushions, propped on elbow
487. chair, front view, one foot on toes, hands gripping seat edge lightly
488. bench, three-quarter view, sitting with one foot on bench, arm around knee
489. stool, side view, hands behind body, shoulders pulled back
490. armchair, front view, ankles crossed, one hand holding teacup
491. chair, three-quarter view, one hand waving, other hand on armrest
492. sofa, front view, sitting with both hands under chin, cute pose
493. bench, side view, hands in lap, torso angled slightly forward
494. armchair, three-quarter view, one elbow on armrest, fingers at temple
495. chair, front view, one knee crossed over the other, one hand at collarbone
496. sofa, side view, one leg tucked beneath body, one hand on sofa back
497. stool, three-quarter view, torso leaning forward, one hand reaching outward
498. chair, high-angle view, hands folded, calm symmetrical posture
499. bench, front view, legs together, one hand holding hat in lap
500. sofa, three-quarter view, seated sideways, both hands holding cushion
O. 桌上 / 邊緣 / 窗台 / 櫃台 501–560
501. desk, front view, sitting on edge, legs hanging, hands beside hips
502. desk, three-quarter view, sitting sideways, one hand behind body, one hand at cheek
503. desk, side view, both feet dangling, torso straight, ankles crossed
504. desk, front view, one knee drawn up on desk, arm resting over it
505. desk, low-angle view, hands behind on desk, chest open, one leg extended down
506. table, front view, leaning forward with palms on tabletop, feet apart naturally
507. table, three-quarter view, sitting on edge with one leg crossed over the other
508. table, side view, one hand on table, other hand lifting hair, one foot on chair rung
509. counter, front view, leaning with elbows on counter, hands under chin
510. counter, three-quarter view, one elbow on surface, other hand at waist
511. windowsill, front view, sitting with knees together, hands gripping sill
512. windowsill, side view, sitting sideways, one leg bent up, one leg hanging
513. windowsill, three-quarter view, one hand holding curtain, other hand on sill
514. desk, front view, one arm extended across tabletop, torso leaning over slightly
515. desk, side view, sitting backward with one hand on desk, one foot on chair
516. table, three-quarter view, perching on table corner, legs crossed at ankles
517. bar counter, side view, seated on stool, one foot on rung, one hand holding drink
518. bar counter, front view, standing, forearms on counter, hips leaning in
519. desk, high-angle view, resting chin on folded arms on desk
520. windowsill, side view, leaning against frame, one hand on glass
521. shelf ladder, three-quarter view, one foot on lower rung, one hand reaching upward
522. desk, three-quarter view, one hand holding book, other hand on tabletop
523. counter, front view, one hand saluting playfully, other hand flat on counter
524. table, side view, sitting on edge, torso turned toward viewer, feet pointed down
525. windowsill, front view, both hands in lap, shoulders relaxed, knees bent to one side
526. desk, three-quarter view, one hand tucked under chin, other hand holding pen
527. counter, side view, leaning with one hip against counter edge
528. windowsill, three-quarter view, one knee up, arms around it
529. desk, front view, torso forward, one hand extended as if offering something
530. table, side view, seated on corner, one hand behind, one hand on thigh
531. desk, low-angle view, crossed legs while seated on desk edge
532. bar stool, front view, sitting tall, one elbow resting on counter
533. windowsill, side view, seated with ankles crossed, gazing outside
534. counter, three-quarter view, one hand on cheek, other arm folded over waist
535. desk, front view, leaning against desk with crossed ankles
536. table, three-quarter view, sitting with one leg tucked under and one dangling
537. windowsill, front view, both hands lightly gripping frame, feet together
538. desk, side view, one knee resting on chair, torso leaning over desk
539. counter, front view, one hand holding cup at chest height, other on counter
540. windowsill, three-quarter view, shoulders turned back toward viewer
541. desk, front view, sitting on chair backward, arms folded atop chair back
542. table, side view, both palms on surface behind hips, legs stretched
543. counter, high-angle view, elbows on bar, chin resting on hands
544. windowsill, side view, head resting on one hand, thoughtful gaze outward
545. desk, three-quarter view, one hand fixing ribbon, other holding papers
546. table, front view, one hand on table edge, one hand in pocket
547. counter, three-quarter view, one foot crossed over the other, relaxed lean
548. windowsill, front view, sitting cross-legged, hands around knees
549. desk, side view, standing and bending slightly over it, both palms down
550. table, three-quarter view, one hand holding flower, one hand resting at hip
551. counter, side view, half-seated against counter, one knee bent
552. windowsill, three-quarter view, one hand trailing along the frame
553. desk, front view, leaning while one foot rests on chair rung
554. table, low-angle view, seated on tabletop, shoulders back, legs aligned
555. counter, front view, one finger near lips, playful posture
556. windowsill, high-angle view, compact tucked-in seated pose
557. desk, three-quarter view, one hand reaching toward camera from tabletop
558. table, side view, one leg stretched out, one knee bent, hand at collarbone
559. counter, three-quarter view, both hands around warm cup, soft smile
560. windowsill, side view, one leg hanging and one folded on sill, relaxed pose
P. 床上 / 居家 / 慵懶 561–620
561. bed, front high-angle view, sitting at edge, hands on mattress, feet together
562. bed, three-quarter view, sitting cross-legged, hands folded on lap
563. bed, side view, kneeling upright, hands on thighs, neat posture
564. bed, high-angle view, lying on stomach reading book, legs lifted
565. bed, top-down view, lying on back, one hand behind head, one on blanket
566. bed, three-quarter overhead view, curled on side, hands near pillow
567. bed, front view, sitting with knees hugged, chin resting on knees
568. bed, side view, reclining on elbows, knees bent together
569. bed, three-quarter view, one knee up, one leg extended, hand on shin
570. bed, top-down view, arms spread softly, blanket over lower legs
571. bed, front view, sitting on heels, one hand waving, other on lap
572. bed, side view, leaning back against headboard, one arm over raised knee
573. bed, high-angle view, lying diagonally, one arm over forehead
574. bed, front view, sitting with feet tucked to one side, hands clasped
575. bed, three-quarter view, kneeling and leaning slightly forward, hands on mattress
576. bed, side view, lying on side with pillow hugged to chest
577. bed, top-down view, lying on stomach, chin in hands, ankles crossed
578. bed, front view, sitting with one hand holding mug, one leg folded in
579. bed, three-quarter view, lounging against pillows, one hand holding phone
580. bed, side view, seated on edge tying shoelace, torso bent forward
581. bed, front view, sitting with knees apart naturally, palms behind body
582. bed, high-angle view, one hand over mouth mid-yawn, other on pillow
583. bed, side view, sitting with one knee up, resting cheek on knee
584. bed, top-down view, both hands under head, one foot over the other
585. bed, three-quarter view, curled in blanket with shoulders peeking out
586. bed, front view, kneeling with both arms stretched upward in morning stretch
587. bed, side view, lying partly on stomach, one leg bent
588. bed, high-angle view, lying on back, hands holding stuffed toy on chest
589. bed, front view, sitting sideways at edge, ankles crossed
590. bed, three-quarter view, leaning over pillow pile, elbows sunk into cushions
591. bed, side view, seated while brushing hair, one hand holding strands
592. bed, top-down view, lying with both knees bent, blanket bunched around waist
593. bed, front view, sitting compactly under blanket, hands wrapped around cup
594. bed, three-quarter view, kneeling while arranging blanket, one hand forward
595. bed, side view, reclining and looking over shoulder, one elbow down
596. bed, overhead, lying on side with one hand near lips, dreamy pose
597. bed, front view, sitting with one leg extended and one tucked in
598. bed, side view, kneeling near pillows, one hand on pillow, one at cheek
599. bed, three-quarter view, sitting on edge with hands gripping mattress lightly
600. bed, top-down view, blanket cocoon pose, only face and knees visible
601. tatami room, front view, seiza sitting with hands on lap
602. tatami room, three-quarter view, sitting cross-legged holding cushion
603. rug, front view, lying on stomach with legs kicking upward
604. rug, side view, sitting with both legs to one side, one hand on floor
605. rug, three-quarter view, lying on back, one knee bent, one arm stretched
606. rug, front high-angle, sitting with tea tray in lap
607. rug, side view, kneeling and reaching for low table
608. rug, three-quarter view, reclining on one elbow, legs folded to side
609. beanbag, front view, sinking into beanbag, knees up, arms around legs
610. beanbag, side view, sprawled with one arm over backrest
611. beanbag, three-quarter view, reclining with one leg hanging over edge
612. hammock chair, front view, sitting with knees tucked, hands on ropes
613. hammock chair, side view, one hand brushing hair, feet dangling
614. hammock chair, three-quarter view, one leg tucked up, other hanging down
615. floor cushion, front view, sitting with legs crossed and hands in sleeves
616. floor cushion, side view, kneeling on cushion, one hand at chin
617. rug, top-down view, starfish lying pose with relaxed limbs
618. tatami room, front view, kneeling bow-start pose, hands on floor
619. low sofa, three-quarter view, half-lounging with ankles crossed
620. rug, side view, sitting and leaning back on palms, legs extended
Q. 牆邊 / 窗邊 / 樓梯 / 戶外 621–680
621. wall, front view, leaning with one shoulder against wall, hands behind back
622. wall, three-quarter view, one foot against wall, arms crossed
623. wall, side view, one hand above head on wall, hips angled
624. wall, front view, palms behind body against wall, knees together
625. wall, three-quarter view, one hand tracing wall, other at waist
626. wall, side view, relaxed lean with one heel against wall
627. wall, low-angle view, both hands in pockets, chin lifted
628. wall, high-angle view, hands clasped in front, shy lean
629. window, front view, standing with both hands on windowsill
630. window, side view, one hand on curtain, looking outside
631. window, three-quarter view, leaning back onto frame, ankles crossed
632. window seat, front view, knees up and hands around shins
633. window seat, side view, legs extended along seat, one hand at cheek
634. window seat, three-quarter view, one elbow on knee, chin in hand
635. doorway, front view, one hand on doorframe, one hand on hip
636. doorway, three-quarter view, both hands on frame, slight lean forward
637. doorway, side view, shoulder against frame, one foot crossed forward
638. doorway, low-angle view, hand above head holding frame, confident pose
639. staircase, front view, standing mid-step, one hand on railing
640. staircase, three-quarter view, seated on step, one knee raised
641. staircase, side view, descending carefully, one hand lifting skirt
642. staircase, low-angle view, looking down from higher step, hands on railing
643. staircase, high-angle view, sitting with legs turned to one side
644. staircase, three-quarter view, leaning on railing, ankles crossed
645. outdoor path, front view, standing in breeze, one hand holding hat
646. outdoor path, side view, walking while looking upward
647. park bench, front view, sitting with hands in lap, ankles crossed
648. park bench, three-quarter view, one leg tucked under, holding scarf
649. park bench, side view, leaning back with one arm over backrest
650. bridge railing, front view, both hands resting on rail, torso leaning slightly
651. bridge railing, side view, looking over river, one hand on cheek
652. garden wall, three-quarter view, sitting on ledge, legs hanging
653. garden wall, side view, sitting sideways, one hand planted behind
654. fence, front view, hands lightly gripping top rail, feet together
655. fence, three-quarter view, one leg crossed behind, one hand waving
656. alleyway, front view, one hand in pocket, other hand adjusting collar
657. alleyway, three-quarter view, leaning against brick wall, one knee bent
658. rooftop, front view, standing near edge, arms open to breeze
659. rooftop, side view, sitting on low ledge, one hand behind body
660. rooftop, three-quarter view, one foot on ledge, elbow resting on knee
661. grass field, front view, standing with both arms outspread
662. grass field, side view, spinning pose with one leg lifted
663. flower field, three-quarter view, both hands near face, knees together
664. garden, front view, crouching lightly, one hand on knee
665. garden, side view, kneeling among flowers, hand reaching down
666. beach, front view, walking barefoot, shoes in one hand
667. beach, side view, standing with one hand shading eyes
668. pier, three-quarter view, seated at edge, one leg swinging down
669. pier, side view, leaning on railing with crossed ankles
670. forest path, front view, crouched slightly to inspect something
671. forest path, three-quarter view, one hand brushing branch aside
672. shrine steps, front view, sitting with hands on knees
673. shrine steps, side view, standing and turning back
674. city street, front view, stepping across crosswalk, one hand holding bag
675. city street, three-quarter view, waiting pose with hands in coat pockets
676. station platform, front view, both hands around strap of bag
677. station platform, side view, one foot on suitcase, relaxed lean
678. station platform, three-quarter view, waving while stepping forward
679. bookstore aisle, front view, tiptoe reaching for upper shelf
680. library window, side view, seated on sill holding closed book
R. 可愛 / 活潑 / 小動作 681–740
681. front view, standing, double peace signs beside face, knees together
682. three-quarter view, standing, puffed cheeks, both fists raised near shoulders
683. front view, standing, one eye closed, one hand saluting, one foot inward
684. side view, standing, hands clasped behind back, head tilted up
685. front view, standing, both hands making cat paw gesture, knees slightly bent
686. three-quarter view, standing, finger to lips, other hand behind back
687. front view, standing, both hands near cheeks, elbows in, toes inward
688. side view, standing, one hand waving high, one heel raised
689. front view, standing, both fists lightly clenched near chest, excited pose
690. three-quarter view, standing, one hand making peace sign near eye, other at waist
691. front view, sitting on floor, both hands supporting cheeks, knees hugged
692. three-quarter view, sitting, one hand making heart sign, one arm around legs
693. front view, sitting cross-legged, hands on knees, bright smile
694. side view, kneeling, one hand on lap, one hand waving gently
695. bed, front high-angle, lying on stomach, feet kicked up, hands under chin
696. chair, front view, sitting with feet together, hands folded under chin
697. sofa, three-quarter view, sitting compactly with cushion hugged close
698. front view, standing, one arm raised straight up in cheer pose
699. side view, standing, both hands behind head, one knee bent back
700. three-quarter view, standing, one hand at mouth as if giggling
701. front view, standing, both index fingers touching together at chest
702. side view, sitting on bench, one hand propping cheek, legs swinging
703. front view, kneeling, hands spread on thighs, attentive cute pose
704. three-quarter view, standing, one hand on hat, other hand open outward
705. front view, standing, one hand giving thumbs up, other on hip
706. side view, standing, both arms stretched behind in playful morning stretch
707. three-quarter view, standing, hands forming heart over chest
708. front view, sitting, feet tucked to one side, one hand on cheek
709. side view, kneeling on bed, both hands holding blanket edge
710. front view, standing, one hand extended as if inviting someone
711. three-quarter view, standing, hands tucked into oversized sleeves
712. front view, seated on stool, one foot tapping, hands on knees
713. side view, standing, one arm folded, one finger pointing upward
714. front view, standing, one hand holding ribbon ends, other at side
715. three-quarter view, leaning forward slightly, both hands behind back
716. front view, sitting on floor, feet together, hands around ankles
717. side view, standing, both hands cupping face, elbows forward
718. three-quarter view, sitting on chair, one hand waving near shoulder
719. front view, standing, hands clasped overhead, body stretched long
720. side view, sitting on sofa, one hand on cushion, one foot tucked under
721. front view, kneeling on floor, one hand making V sign, other on thigh
722. three-quarter view, standing, one hand holding strand of hair, one heel up
723. front view, sitting on bed, toes pointed inward, hands on lap
724. side view, standing, chin tucked, both hands holding sleeve cuffs
725. front view, standing, both arms open wide in welcoming pose
726. three-quarter view, standing, one hand at collarbone, one hand lifting hem lightly
727. front view, sitting on low wall, both hands by sides, feet dangling
728. side view, standing, one hand adjusting glasses, other in pocket
729. three-quarter view, standing, one hand near lips, playful teasing expression
730. front view, sitting cross-legged on sofa, both hands holding mug
731. side view, kneeling, one hand reaching forward, torso leaning slightly
732. three-quarter view, standing, finger-heart gesture with one hand, other at waist
733. front view, standing, one hand over mouth in surprised pose
734. side view, sitting on floor, hugging one knee, other leg extended
735. front view, standing, both hands raised with open palms beside shoulders
736. three-quarter view, standing, one elbow tucked, one hand under chin
737. front view, kneeling on bed, one hand on pillow, one hand waving
738. side view, standing, both hands holding backpack straps, slight bounce posture
739. three-quarter view, sitting on windowsill, knees together, smiling softly
740. front view, standing, one foot lifted slightly behind, hands clasped at chest
S. 優雅 / 帥氣 / 時裝感 741–800
741. front view, standing tall, one hand at waist, one hand hanging straight, runway posture
742. three-quarter view, one leg in front of the other, shoulders back, chin raised
743. side view, one hand behind back, one hand holding glove or accessory, elegant stance
744. front view, seated on chair with straight back, ankles crossed, hands folded neatly
745. three-quarter view, leaning against pillar, arms crossed, composed cool pose
746. side view, one hand fixing cuff, one foot slightly behind, poised stance
747. front view, both hands in coat pockets, one knee bent, cool casual fashion pose
748. three-quarter view, one arm draped across torso, other hand at jawline
749. side view, seated on stool with one foot on rung, one elbow on knee
750. front view, standing with cape or coat spread slightly by one hand
751. three-quarter view, chin slightly down, gaze up toward viewer, one hand in hair
752. side view, standing with one arm extended back, body turned elegantly
753. front view, sitting on sofa edge, hands resting apart on seat, knees together
754. three-quarter view, one hand on railing, other in pocket, long silhouette pose
755. side view, seated sideways on chair, upper torso twisted toward viewer
756. front view, standing with feet apart, hands on hips, commanding posture
757. three-quarter view, one hand holding necklace or tie, other relaxed at side
758. side view, leaning on wall with one shoulder, legs crossed at ankles
759. front view, seated in armchair, one arm on armrest, one leg crossed over knee
760. three-quarter view, standing with one hand at lower back, elegant torso curve
761. side view, one hand holding umbrella or cane-like prop position, formal stance
762. front view, standing with coat over shoulders, hands lightly gripping collar edges
763. three-quarter view, long stride stopped mid-step, one hand brushing hair
764. side view, seated on desk edge, back straight, legs together
765. front view, standing in spotlight pose, arms open slightly, chest lifted
766. three-quarter view, hand at temple, other hand tucked behind back
767. side view, reclining on chaise, one elbow supporting upper body
768. front view, standing with one arm folded across stomach and one hand at chin
769. three-quarter view, seated on bench, shoulders squared, calm noble pose
770. side view, one hand sliding into coat pocket, other holding bag strap
771. front view, standing, one foot on step above the other, hands at sides
772. three-quarter view, hands clasped behind lower back, chin turned aside
773. side view, one hand lightly touching wall, one leg crossing behind
774. front view, chair pose, seated backward on chair, arms over backrest, cool pose
775. three-quarter view, standing, one hand holding glasses near lips
776. side view, one arm lifted overhead, elongated editorial silhouette
777. front view, seated with one ankle on opposite knee, hands relaxed on armrests
778. three-quarter view, standing with one hand holding coat hem outward
779. side view, slight bow of head, both hands folded before waist
780. front view, standing with feet together, both hands behind back, aristocratic pose
781. three-quarter view, body turned away, face turned back, one hand at shoulder
782. side view, seated with one knee raised, forearm resting over it
783. front view, standing with one hand giving a formal greeting gesture
784. three-quarter view, leaning against bar counter, one foot hooked behind other
785. side view, standing under window light, hands folded softly in front
786. front view, sitting on staircase with one elbow on raised knee
787. three-quarter view, standing with scarf trailing, one hand securing it
788. side view, one hand on hip, other holding book at side
789. front view, standing with subtle contrapposto, shoulders and hips opposing
790. three-quarter view, relaxed model pose, one knee bent, one hand near chin
791. side view, seated on windowsill, posture tall, ankles crossed neatly
792. front view, standing with both hands lightly gripping coat lapels
793. three-quarter view, stepping down from platform, one hand balancing
794. side view, one hand in sleeve, other hand holding small case or book
795. front view, seated at desk with hands folded, composed intellectual pose
796. three-quarter view, standing with one arm around own waist, other hand extended
797. side view, standing, looking downward softly, one foot on tiptoe
798. front view, arms folded loosely, one knee angled inward, cool gentle stance
799. three-quarter view, seated elegantly with legs crossed and shoulders relaxed
800. side view, final neutral fashion pose, hands relaxed, spine long, chin level
拿著 / 抱著 / 互動物件姿勢 200 種（801–1000）
T. 抱枕 / 玩偶 / 布偶 / 寢具類 801–850
801. bed, high-angle view, sitting cross-legged, hugging large pillow to chest, chin resting on pillow
802. bed, side view, lying on side, arms wrapped around body pillow, knees bent
803. sofa, front view, sitting with square cushion hugged in lap, ankles together
804. floor, three-quarter view, kneeling while holding heart-shaped pillow in both arms
805. bed, top-down view, lying on back, plush toy resting on chest, both hands around it
806. chair, front view, sitting upright, holding teddy bear in lap with both hands
807. sofa, side view, curled pose, hugging round cushion against knees
808. floor, front view, sitting with legs to one side, holding rabbit plush against cheek
809. bed, three-quarter view, reclining against pillows, holding cat plush with one arm
810. floor, high-angle view, sitting with both knees hugged and small penguin plush tucked between arms
811. sofa, front view, both arms wrapped around long bolster pillow, feet tucked on seat
812. bed, side view, lying on stomach, chin on pillow, hugging small doll with one arm
813. floor, three-quarter view, cross-legged, holding oversized stuffed bear in lap
814. chair, side view, sitting sideways, cuddling fox plush against chest
815. bed, front view, sitting with one leg folded, clutching blanket to chest
816. sofa, high-angle view, lounging with one hand holding star-shaped cushion, one leg bent
817. floor, front view, sitting seiza, holding plush penguin in both hands at chest height
818. bed, top-down view, lying on back, both hands around pillow over stomach
819. sofa, three-quarter view, sitting with body pillow upright, cheek resting against it
820. chair, front view, hugging cat plush against shoulder, knees together
821. floor, side view, sitting with one knee up, one arm around pillow, cheek on knee
822. bed, three-quarter view, kneeling while holding blanket bundle in arms
823. sofa, front view, hugging two small plush toys side by side
824. floor, high-angle view, lying on stomach, plush rabbit under chin
825. bed, side view, sitting on edge, holding folded blanket in lap
826. chair, three-quarter view, sitting with stuffed bird on lap, one hand patting it
827. floor, front view, holding donut cushion around waist while sitting cross-legged
828. sofa, side view, cuddling crescent moon cushion while reclining
829. bed, top-down view, hugging pillow over face playfully
830. floor, three-quarter view, sitting with plush seal on knees, both hands around it
831. bed, front view, sitting under blanket, clutching stuffed bear close
832. sofa, front view, holding small cushion to cheek, one leg tucked up
833. floor, side view, sitting with plush cat in lap, gently stroking its head
834. chair, high-angle view, holding patchwork doll with both hands at chest
835. bed, three-quarter view, lying on side, hugging long stuffed animal
836. sofa, front view, cradling rabbit plush in arms like a baby
837. floor, front view, kneeling, holding wrapped blanket like a bundle
838. bed, side view, leaning against headboard, pillow hugged against one raised knee
839. chair, three-quarter view, holding star plush out in front with both hands
840. floor, high-angle view, sitting compactly with soft pillow tucked under chin
841. bed, front view, lying on stomach, plush penguin between elbows
842. sofa, side view, hugging U-shaped neck pillow while lounging
843. floor, three-quarter view, sitting with giant bear plush beside body, leaning on it
844. chair, front view, small cushion on lap, both hands resting over it
845. bed, top-down view, blanket cocoon pose, clutching tiny plush near face
846. sofa, three-quarter view, reclining with fox plush draped over shoulder
847. floor, side view, seiza pose, hugging cylindrical bolster vertically
848. chair, side view, holding folded quilt in arms, calm cozy pose
849. bed, front view, sitting with hands around pillow and feet tucked inward
850. sofa, front view, snuggling with plush cat and cushion together
U. 貓咪 / 狗狗 / 小動物抱持 851–900
851. floor, front view, sitting cross-legged, holding small cat in lap with both hands
852. chair, three-quarter view, sitting while cat rests on knees, one hand stroking back
853. sofa, side view, lying on side with kitten tucked against chest
854. floor, high-angle view, kneeling and lifting cat gently under front legs
855. bed, front view, sitting with cat in lap, cheek touching cat head
856. windowsill, side view, holding sleepy kitten in arms while seated
857. floor, three-quarter view, one knee up, puppy sitting beside thigh, hand on its head
858. park bench, front view, holding small dog on lap, one arm supporting its body
859. sofa, front view, cuddling puppy against shoulder
860. floor, side view, seated with dog lying across legs, one hand rubbing belly
861. bed, high-angle view, kitten curled on chest, both hands around it protectively
862. chair, front view, cradling tiny puppy in both arms
863. floor, three-quarter view, cat perched on shoulder, one hand supporting hindquarters
864. sofa, side view, reclining with cat sleeping on stomach
865. floor, front view, kneeling while offering open palm to curious kitten
866. garden, three-quarter view, crouching and lifting small dog with both arms
867. bench, side view, sitting with dog leaning against leg, hand on collar
868. bed, front view, sitting with one knee up, cat resting on knee
869. floor, high-angle view, hugging fluffy cat to chest while seated
870. chair, three-quarter view, cat in lap, one hand under chin scratching
871. sofa, front view, holding puppy up near face, smiling at it
872. floor, side view, kitten curled in crossed arms, gentle protective pose
873. rug, three-quarter view, lying on stomach, cat stretched beside one arm
874. armchair, front view, dog on one armrest, hand resting on its back
875. bed, side view, lying on back with kitten held above chest
876. floor, front view, sitting with both legs to one side, puppy nestled between thighs
877. bench, three-quarter view, cat on lap, one hand at cheek, relaxed pose
878. sofa, side view, small dog half in lap, one arm draped around it
879. floor, kneeling, both hands holding cat close to collarbone
880. chair, front view, holding sleepy puppy wrapped in blanket
881. bed, three-quarter view, sitting cross-legged, cat tucked inside arms
882. floor, side view, one hand extended with treat, bird-sized pet watching
883. park, crouching, hands under puppy chest as if about to lift
884. sofa, front view, cat on shoulder, one hand supporting paws
885. floor, three-quarter view, sitting and brushing cat with one hand
886. chair, side view, puppy standing on lap, both hands steadying it
887. bed, front high-angle view, kitten asleep on pillow beside torso, hand nearby
888. floor, front view, hugging medium plush-like dog close while kneeling
889. armchair, three-quarter view, cat asleep in lap, hands folded around it
890. sofa, side view, lounging with dog at feet and one hand reaching down
891. floor, high-angle view, sitting with cat in lap and puppy beside knee
892. bench, front view, dog beside seat, one hand holding leash gently
893. rug, side view, lying on side with cat curled against stomach
894. chair, three-quarter view, holding tiny kitten near face, elbows tucked in
895. bed, front view, sitting with dog’s front paws resting on raised knee
896. floor, front view, kneeling while cat rubs against shoulder, hand guiding it
897. sofa, high-angle view, curled with blanket and cat tucked under chin
898. park grass, seated pose, puppy between folded legs, arms wrapped around it
899. chair, side view, cat on armrest, chin supported by hand while watching it
900. floor, three-quarter view, seated, dog resting head on lap, both hands petting it
V. 鳥類 / 企鵝 / 小型生物互動 901–940
901. front view, standing, small bird perched on index finger, other hand supporting wrist
902. three-quarter view, standing, both hands cupped together holding tiny bird
903. side view, seated on bench, bird perched on shoulder, one hand near it
904. floor, kneeling, penguin plush hugged against chest with both arms
905. chair, front view, small penguin stuffed toy on lap, hands around it
906. standing pose, holding tiny owl on gloved hand, other arm at side
907. sitting pose, bird perched on raised knee, one hand extended gently
908. floor, front view, cross-legged, two small chicks in lap, hands protective around them
909. bench, side view, pigeon perched on hand, elbow resting on knee
910. three-quarter view, standing, bird perched on forearm, gaze directed at bird
911. chair, front view, holding swan plush to one side, legs together
912. floor, side view, sitting with penguin plush against cheek, knees hugged
913. standing pose, one hand holding seed, small bird pecking from palm
914. windowsill, seated, one hand near open window, bird landing on finger
915. floor, front view, kneeling, holding duck plush in lap
916. standing pose, bird perched on headband or shoulder, one hand lifted near it
917. armchair, three-quarter view, cradling penguin plush under one arm while reading
918. bed, front view, hugging round chick plush over blanket
919. floor, high-angle view, sitting with birdcage nearby, one hand resting on open door
920. bench, front view, small bird perched on both joined hands
921. three-quarter view, seated on floor, holding flamingo plush upright beside shoulder
922. standing pose, one hand extended outward with white dove perched on fingers
923. chair, side view, parrot-like bird perched on backrest near shoulder
924. floor, kneeling, both hands around baby penguin plush on tatami or rug
925. windowsill, front view, sitting and watching bird on palm
926. standing pose, sparrow perched on wrist, other hand lightly touching feathers
927. floor, cross-legged, large penguin plush between legs, arms draped over it
928. bench, side view, small bird perched on knee, one hand cupped nearby
929. chair, front view, owl plush in lap, one finger tapping its beak
930. standing pose, flock interaction gesture, one bird near shoulder and one at hand
931. floor, front view, kneeling, hugging penguin plush from behind playfully
932. side view, seated, bird perched on open book held in lap
933. standing pose, both palms open, one bird taking off from fingertips
934. sofa, three-quarter view, cuddling duck plush while reclining
935. bed, high-angle view, penguin plush beside pillow, one arm around it
936. chair, front view, holding chick plush under chin with both hands
937. floor, side view, sitting and feeding small bird from cup or dish in hand
938. standing pose, hummingbird-like tiny bird hovering near outstretched fingers
939. windowsill, three-quarter view, perched sitting, bird on one knee
940. floor, front view, both knees up, holding small round penguin plush against shins
W. 書本 / 花束 / 雜貨 / 小物抱持 941–1000
941. front view, standing, holding closed book to chest with both hands
942. three-quarter view, sitting on chair, open book in lap, one hand turning page
943. side view, standing, stack of books hugged against torso
944. floor, kneeling, diary held close to heart, head tilted
945. sofa, front view, reading book with legs tucked beside body
946. chair, side view, holding notebook in one hand and pen in the other
947. bed, high-angle view, lying on stomach, elbows down, book open before face
948. front view, standing, bouquet held in both hands before waist
949. three-quarter view, sitting on bench, flowers resting on lap, fingers touching petals
950. side view, standing, one hand holding parasol, other hand gathering skirt
951. floor, front view, cross-legged, holding photo frame in lap
952. chair, three-quarter view, clutching gift box with ribbon against chest
953. sofa, side view, mug in both hands, knees tucked up
954. front view, standing, one hand holding shopping bag, other hand waving
955. three-quarter view, seated on desk, holding tablet or sketchbook against knee
956. side view, standing, violin case or instrument case resting by leg, hand on handle
957. floor, front view, kneeling, basket held in lap with both hands
958. chair, front view, one hand holding teacup, other hand saucer beneath
959. sofa, three-quarter view, hugging a folded coat or scarf bundle
960. front view, standing, camera held with both hands at chest
961. side view, seated, umbrella laid across knees, one hand on handle
962. floor, three-quarter view, holding game controller in both hands while sitting cross-legged
963. bed, front high-angle view, holding phone with both hands above knees
964. bench, front view, one hand holding lunch box, other hand resting on knee
965. standing pose, one arm full of shopping bags, other hand adjusting hat
966. floor, kneeling, both hands around lantern or decorative light
967. chair, side view, clutching folded letter near lips
968. sofa, front view, tray balanced on lap, hands holding edges
969. standing pose, one hand holding bouquet behind back, other at side
970. bench, three-quarter view, guitar or ukulele across lap, one hand on neck
971. floor, front view, seated with plush backpack hugged like a cushion
972. chair, side view, both hands around hot cup, shoulders relaxed
973. standing pose, one hand holding paper bag of pastries, other hand near mouth
974. desk, front view, holding stack of notebooks against chest while seated
975. floor, three-quarter view, flower basket beside thigh, one hand resting on handle
976. sofa, side view, one hand holding remote, other around cushion
977. standing pose, one hand lifting camera strap, other holding camera body
978. bed, high-angle view, clutching folded sweater to chest
979. chair, front view, one hand holding mirror, other adjusting hair
980. floor, side view, seated with sketchbook propped on knees
981. standing pose, two-handed hold on wrapped present box at chest level
982. bench, side view, handbag resting on lap, both hands atop it
983. chair, three-quarter view, holding stack of mail or letters while seated
984. sofa, front view, one hand holding snacks bowl, other holding spoon
985. standing pose, one hand holding umbrella over shoulder, other in pocket
986. floor, front view, holding globe or decorative sphere in lap
987. bed, side view, notebook hugged close while lying on side
988. chair, front view, holding bouquet upright beside cheek
989. windowsill, seated, one hand around teacup, one hand on sill
990. standing pose, tote bag hanging from forearm, one hand holding handle
991. floor, three-quarter view, both hands supporting potted flower pot while kneeling
992. sofa, side view, holding magazine open with legs tucked
993. chair, front view, one hand holding small lantern or candle holder, other shielding it
994. standing pose, one hand holding headphones, other holding music player or phone
995. floor, kneeling, one hand holding plush diary, other hand over cover
996. desk, side view, one hand holding fountain pen, other holding notebook edge
997. bench, front view, holding picnic basket on lap with both hands
998. standing pose, folded jacket draped over arm, other hand holding drink cup
999. chair, three-quarter view, one hand holding flower stem near lips, other on lap
1000. floor, front view, cross-legged, both arms wrapped around a stack of books, chin resting on top''';
