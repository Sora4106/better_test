import 'outfit_reference_data.dart';

// The source wardrobe's numbering is kept in the IDs for saved selections.
// Each fragment follows the source order. Repeated part keys share a toggle.
enum _OutfitPart {
  silhouette('整體風格／配色'),
  upper('上身'),
  outerwear('外套／罩衫／披風'),
  lower('下身'),
  onepiece('連身服裝'),
  headwear('帽子／髮飾'),
  legwear('襪子／腿部配件'),
  footwear('鞋子'),
  accessory('配件');

  const _OutfitPart(this.label);

  final String label;

  OutfitUnifiedPhraseSectionData phrase(String en) =>
      OutfitUnifiedPhraseSectionData(id: name, zh: label, en: en);
}

const _generalOutfits = '一般服裝 · General Outfits';
const _catMotifOutfits = '貓咪主題服裝 · Cat-Motif Outfits';

OutfitReferencePresetData _outfit(
  int sourceId, {
  required String category,
  required String nameZh,
  required String nameEn,
  required String palette,
  required String description,
  required List<OutfitUnifiedPhraseSectionData> sections,
}) =>
    OutfitReferencePresetData(
      id: 'aeris_outfit_${sourceId.toString().padLeft(2, '0')}',
      category: category,
      name: '$nameZh · $nameEn',
      palette: palette,
      description: description,
      pieces: const [],
      unifiedPhraseZh: nameZh,
      unifiedPhraseEn: sections.map((section) => section.en).join(', '),
      unifiedPhraseSections: List.unmodifiable(sections),
    );

/// Wardrobe presets that can be applied to any person slot.
final aerisOutfitReferencePresets =
    List<OutfitReferencePresetData>.unmodifiable([
  _outfit(
    2,
    category: _generalOutfits,
    nameZh: '皇家騎士裝',
    nameEn: 'Royal Knight',
    palette: '皇家藍 × 銀白 × 金色',
    description: '軍裝外套、銀甲、刺繡短披風與藍白百褶戰裙，搭配護膝和鎧甲靴。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'elegant royal knight uniform, '
        'royal blue and silver white color palette',
      ),
      _OutfitPart.outerwear.phrase(
        'tailored navy blue military jacket',
      ),
      _OutfitPart.upper.phrase(
        'fitted white high collar blouse, '
        'standing collar',
      ),
      _OutfitPart.outerwear.phrase(
        'gold embroidered jacket lapels, '
        'polished golden buttons',
      ),
      _OutfitPart.upper.phrase(
        'royal crest chest brooch',
      ),
      _OutfitPart.outerwear.phrase(
        'structured shoulder seams',
      ),
      _OutfitPart.upper.phrase(
        'silver shoulder pauldrons, '
        'decorative silver chest plate, '
        'ivory sleeve inserts, '
        'fitted long sleeves, '
        'royal blue cuffs with gold trim',
      ),
      _OutfitPart.lower.phrase(
        'narrow dark brown leather waist belt, '
        'antique gold buckle, '
        'decorative belt straps',
      ),
      _OutfitPart.outerwear.phrase(
        'short royal blue cape with gold embroidered hem',
      ),
      _OutfitPart.lower.phrase(
        'layered royal blue and white above-knee pleated combat skirt, '
        'silver waist armor accents, '
        'white ruffled underskirt, '
        'golden skirt border embroidery',
      ),
      _OutfitPart.legwear.phrase(
        'dark navy fitted leggings, '
        'silver knee guards',
      ),
      _OutfitPart.footwear.phrase(
        'polished royal blue armored boots, '
        'silver plated boot details, '
        'gold buckle accents',
      ),
      _OutfitPart.silhouette.phrase(
        'elegant fantasy knight costume',
      ),
    ],
  ),
  _outfit(
    3,
    category: _generalOutfits,
    nameZh: '朱紅巫女服',
    nameEn: 'Shrine Maiden',
    palette: '朱紅 × 純白 × 金色',
    description: '白色和服式上衣搭配朱紅袴裙、櫻花髮飾、足袋與紅帶木屐。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'traditional japanese shrine maiden outfit, '
        'bright vermilion red and pure white colors',
      ),
      _OutfitPart.upper.phrase(
        'crisp white kimono style blouse, '
        'layered white kimono collar with crimson inner collar, '
        'flowing wide kimono sleeves, '
        'red inner sleeve lining, '
        'delicate golden sakura embroidery',
      ),
      _OutfitPart.lower.phrase(
        'red waist ties, '
        'decorative white braided cord, '
        'small golden bell charms, '
        'fitted red obi-style waist belt, '
        'deep crimson hakama-inspired pleated skirt, '
        'structured above-knee skirt, '
        'crisp symmetrical pleats, '
        'white ruffled underskirt edge, '
        'thin gold floral hem embroidery, '
        'crimson bow at back waist',
      ),
      _OutfitPart.headwear.phrase(
        'red satin hair ribbon, '
        'white cherry blossom hair ornaments',
      ),
      _OutfitPart.legwear.phrase(
        'white tabi socks',
      ),
      _OutfitPart.footwear.phrase(
        'traditional wooden geta sandals, '
        'red sandal straps',
      ),
      _OutfitPart.silhouette.phrase(
        'elegant ceremonial shrine attire',
      ),
    ],
  ),
  _outfit(
    4,
    category: _generalOutfits,
    nameZh: '粉紅偶像舞台服',
    nameEn: 'Pink Idol Stage',
    palette: '櫻花粉 × 白色 × 香檳金',
    description: '櫻花粉表演外套、白色荷葉襯衫與多層百褶裙，搭配厚底舞台鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'cute pink idol stage uniform, '
        'bright sakura pink and snow white color scheme',
      ),
      _OutfitPart.outerwear.phrase(
        'short tailored pink performance jacket, '
        'structured pink lapels, '
        'champagne gold piping',
      ),
      _OutfitPart.upper.phrase(
        'white frilled blouse, '
        'decorative pearl buttons, '
        'large pink satin chest bow, '
        'golden heart gemstone brooch, '
        'short puff sleeves, '
        'scalloped white lace sleeve cuffs',
      ),
      _OutfitPart.accessory.phrase(
        'pink ribbon wristlets',
      ),
      _OutfitPart.upper.phrase(
        'fitted corset style waist panel',
      ),
      _OutfitPart.lower.phrase(
        'golden waist buckle, '
        'short flared layered idol skirt, '
        'alternating vivid pink and pale pink pleated panels, '
        'three white lace underskirt layers, '
        'scalloped skirt hem, '
        'golden star embroidery, '
        'pink satin side bows, '
        'long waist ribbon tails',
      ),
      _OutfitPart.headwear.phrase(
        'pink hair ribbon accessories',
      ),
      _OutfitPart.legwear.phrase(
        'white thighhigh socks, '
        'fluffy lace sock tops, '
        'pink satin bows',
      ),
      _OutfitPart.footwear.phrase(
        'pink and white platform stage shoes, '
        'gold heart buckles',
      ),
      _OutfitPart.silhouette.phrase(
        'coordinated cheerful idol costume',
      ),
    ],
  ),
  _outfit(
    5,
    category: _generalOutfits,
    nameZh: '經典維多利亞女僕裝',
    nameEn: 'Classic Victorian Maid',
    palette: '黑色 × 白色 × 淡粉',
    description: '黑色束身上衣、白蕾絲圍裙與蓬裙，搭配女僕頭飾及瑪莉珍鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'classic victorian maid costume, '
        'rich black and pure white palette',
      ),
      _OutfitPart.upper.phrase(
        'fitted black bodice, '
        'white ruffled high collar, '
        'white lace chest bib, '
        'small black satin neck bow, '
        'narrow pearl-like button row, '
        'gathered black puff sleeves, '
        'scalloped white lace sleeve cuffs',
      ),
      _OutfitPart.lower.phrase(
        'white apron shoulder straps, '
        'wide white frilled apron, '
        'two embroidered apron pockets, '
        'large white waist bow tied at back, '
        'black short flared skirt, '
        'layered ruffled white petticoat, '
        'white scalloped skirt edge',
      ),
      _OutfitPart.headwear.phrase(
        'white lace maid headdress, '
        'black satin hair bows',
      ),
      _OutfitPart.accessory.phrase(
        'decorative white wrist cuffs',
      ),
      _OutfitPart.legwear.phrase(
        'opaque black thighhigh socks, '
        'white lace sock top bands',
      ),
      _OutfitPart.footwear.phrase(
        'black polished mary jane shoes, '
        'small gold buckles',
      ),
      _OutfitPart.silhouette.phrase(
        'refined black white contrast',
      ),
    ],
  ),
  _outfit(
    6,
    category: _generalOutfits,
    nameZh: '薄荷綠休閒街頭風',
    nameEn: 'Mint Casual Streetwear',
    palette: '薄荷綠 × 白色 × 深藍',
    description: '薄荷綠防風外套、白 T 恤和深藍丹寧短褲，搭配棒球帽、斜背包與厚底球鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'cute modern streetwear, '
        'mint green and white color blocking',
      ),
      _OutfitPart.outerwear.phrase(
        'oversized mint green windbreaker jacket, '
        'lightweight sporty fabric, '
        'white front panels, '
        'dark navy sleeve stripe accents, '
        'open zipper front, '
        'metallic zipper pull, '
        'ribbed mint sleeve cuffs, '
        'practical side pockets',
      ),
      _OutfitPart.upper.phrase(
        'simple fitted white crew neck t-shirt, '
        'subtle mint logo embroidery',
      ),
      _OutfitPart.lower.phrase(
        'high-waisted dark navy denim shorts, '
        'folded short hems, '
        'white contrast stitching, '
        'soft cotton waistband, '
        'decorative fabric belt',
      ),
      _OutfitPart.headwear.phrase(
        'mint green baseball cap with small white embroidery',
      ),
      _OutfitPart.accessory.phrase(
        'sporty headphones resting around neck, '
        'compact mint crossbody pouch, '
        'silver zipper charm',
      ),
      _OutfitPart.legwear.phrase(
        'white ankle socks',
      ),
      _OutfitPart.footwear.phrase(
        'mint and white chunky sneakers, '
        'navy outsole accents, '
        'pale green shoelaces',
      ),
      _OutfitPart.silhouette.phrase(
        'lively sporty casual fashion',
      ),
    ],
  ),
  _outfit(
    7,
    category: _generalOutfits,
    nameZh: '翠綠花卉夏日泳裝',
    nameEn: 'Botanical Summer Beachwear',
    palette: '翠綠 × 純白 × 褐色',
    description: '翠綠花卉繞頸兩件式泳裝搭配白色罩衫、編織草帽與皮革涼鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'botanical summer beach outfit, '
        'vivid emerald green and pure white color palette',
      ),
      _OutfitPart.upper.phrase(
        'fitted green floral halter swim top, '
        'delicate white flower embroidery, '
        'secure shoulder straps, '
        'white binding along edges',
      ),
      _OutfitPart.lower.phrase(
        'matching high-waisted green swim bottoms, '
        'scalloped white trim, '
        'subtle leaf patterns',
      ),
      _OutfitPart.outerwear.phrase(
        'airy white open-front beach shirt, '
        'translucent loose cotton fabric, '
        'three-quarter rolled sleeves, '
        'pale green vine embroidery at cuffs',
      ),
      _OutfitPart.lower.phrase(
        'emerald waist ribbon',
      ),
      _OutfitPart.headwear.phrase(
        'broad-brim natural woven straw sunhat, '
        'dark green hat band, '
        'white daisy ornaments',
      ),
      _OutfitPart.accessory.phrase(
        'delicate flower bracelet, '
        'compact woven beach tote',
      ),
      _OutfitPart.footwear.phrase(
        'tan brown flat leather beach sandals, '
        'ankle straps, '
        'white floral sandal clips',
      ),
      _OutfitPart.silhouette.phrase(
        'refreshing coordinated botanical beachwear',
      ),
    ],
  ),
  _outfit(
    8,
    category: _generalOutfits,
    nameZh: '淡紫櫻花浴衣',
    nameEn: 'Lavender Floral Yukata',
    palette: '淡紫 × 櫻花粉 × 金黃',
    description: '淡紫櫻花浴衣、金黃色腰帶與垂墜流蘇，搭配花簪、足袋和木屐。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'elegant japanese floral summer yukata, '
        'soft lavender purple and sakura pink palette',
      ),
      _OutfitPart.onepiece.phrase(
        'traditional overlap kimono front, '
        'white inner collar, '
        'pale pink collar trim, '
        'wide flowing kimono sleeves, '
        'pink lining, '
        'intricate cherry blossom prints across lavender fabric, '
        'delicate white flower details, '
        'subtle gold floral highlights',
      ),
      _OutfitPart.accessory.phrase(
        'wide golden yellow obi sash, '
        'structured decorative obi knot on back, '
        'long blush pink ribbon ties, '
        'dangling floral tassels',
      ),
      _OutfitPart.onepiece.phrase(
        'long straight wrap style yukata skirt, '
        'ankle-length floral hem border',
      ),
      _OutfitPart.headwear.phrase(
        'delicate flower hairpins, '
        'pink silk ribbon hair accessories',
      ),
      _OutfitPart.legwear.phrase(
        'white tabi socks',
      ),
      _OutfitPart.footwear.phrase(
        'wooden geta sandals with pink straps',
      ),
      _OutfitPart.onepiece.phrase(
        'lightweight summer cloth',
      ),
      _OutfitPart.silhouette.phrase(
        'graceful japanese festival fashion',
      ),
    ],
  ),
  _outfit(
    9,
    category: _generalOutfits,
    nameZh: '卡其旅行探險裝',
    nameEn: 'Adventure Traveler',
    palette: '卡其 × 橄欖綠 × 深咖啡',
    description: '亞麻襯衫、橄欖綠背心與披肩，搭配卡其短褲、皮革配件和綁帶長靴。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'practical fantasy explorer outfit, '
        'warm khaki olive green and dark chocolate brown palette',
      ),
      _OutfitPart.upper.phrase(
        'ivory collared linen shirt, '
        'rolled sleeves, '
        'gathered shoulders',
      ),
      _OutfitPart.outerwear.phrase(
        'short fitted olive green vest, '
        'brown leather vest borders, '
        'antique brass buttons',
      ),
      _OutfitPart.accessory.phrase(
        'crossed brown shoulder harness straps',
      ),
      _OutfitPart.lower.phrase(
        'wide dark leather waist belt, '
        'rectangular brass buckle, '
        'two utility pouches on belt, '
        'leaf-embroidered pouch flap, '
        'high-waisted khaki travel shorts, '
        'reinforced side pockets, '
        'tidy rolled short hems, '
        'dark brown topstitching',
      ),
      _OutfitPart.outerwear.phrase(
        'short olive green shoulder cape, '
        'brass leaf clasp',
      ),
      _OutfitPart.accessory.phrase(
        'dark brown fingerless leather gloves',
      ),
      _OutfitPart.headwear.phrase(
        'wide brim tan explorer hat, '
        'dark brown hat band, '
        'narrow green feather decoration',
      ),
      _OutfitPart.accessory.phrase(
        'compact brown leather shoulder satchel',
      ),
      _OutfitPart.footwear.phrase(
        'sturdy lace-up knee boots, '
        'leather strap and buckle details',
      ),
      _OutfitPart.silhouette.phrase(
        'rustic travel costume',
      ),
    ],
  ),
  _outfit(
    10,
    category: _generalOutfits,
    nameZh: '藍白公主禮服',
    nameEn: 'Royal Blue Princess Gown',
    palette: '皇家藍 × 珍珠白 × 銀色',
    description: '象牙白緞面上身、皇家藍裙襬與銀色刺繡，搭配水晶冠及繫帶鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'elegant fairytale royal blue princess gown, '
        'pearl white and silver accents',
      ),
      _OutfitPart.headwear.phrase(
        'jeweled silver tiara with pale blue crystals, '
        'white floral hair ornaments',
      ),
      _OutfitPart.upper.phrase(
        'fitted ivory satin bodice, '
        'sweetheart neckline, '
        'off-shoulder translucent white chiffon sleeves, '
        'soft sleeve ruffles, '
        'detailed silver vine embroidery, '
        'blue crystal chest brooch, '
        'structured waist seams',
      ),
      _OutfitPart.lower.phrase(
        'royal blue satin ribbon belt, '
        'ornate silver waist ornament, '
        'flared knee-length royal blue skirt, '
        'white layered petticoat, '
        'pale blue chiffon overlay, '
        'silver floral hem embroidery, '
        'scalloped white lace borders, '
        'decorative blue bows on skirt panels',
      ),
      _OutfitPart.accessory.phrase(
        'short white lace gloves, '
        'pearl bracelet',
      ),
      _OutfitPart.legwear.phrase(
        'cream knee socks',
      ),
      _OutfitPart.footwear.phrase(
        'royal blue low heel strap shoes, '
        'silver crystal shoe decorations',
      ),
      _OutfitPart.silhouette.phrase(
        'polished regal dress design',
      ),
    ],
  ),
  _outfit(
    11,
    category: _catMotifOutfits,
    nameZh: '貓掌刺繡女僕裝',
    nameEn: 'Cat-Motif Maid',
    palette: '黑色 × 白色 × 粉紅',
    description: '黑白女僕裝搭配粉色貓掌刺繡、愛心胸針、蕾絲髮箍和瑪莉珍鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'cute cat motif maid costume, '
        'black and white palette with pastel pink accents',
      ),
      _OutfitPart.upper.phrase(
        'fitted black maid bodice, '
        'crisp white ruffled collar, '
        'white lace chest bib, '
        'pink satin bow at neck, '
        'pearl-style front buttons, '
        'short black puff sleeves, '
        'scalloped white lace cuffs',
      ),
      _OutfitPart.lower.phrase(
        'white apron straps, '
        'white frilled apron, '
        'embroidered pink paw print apron pockets, '
        'wide apron waistband, '
        'large pink satin back bow, '
        'short layered black skirt, '
        'white ruffled petticoat, '
        'pink ribbon skirt border',
      ),
      _OutfitPart.upper.phrase(
        'small cat-face heart brooch',
      ),
      _OutfitPart.headwear.phrase(
        'white lace maid headband',
      ),
      _OutfitPart.accessory.phrase(
        'black wrist cuffs, '
        'pink paw print decorative stitching',
      ),
      _OutfitPart.legwear.phrase(
        'white opaque thighhigh socks, '
        'black lace sock tops, '
        'pale pink bows',
      ),
      _OutfitPart.footwear.phrase(
        'polished black mary jane shoes, '
        'pink heart-shaped shoe buckles',
      ),
    ],
  ),
  _outfit(
    12,
    category: _catMotifOutfits,
    nameZh: '黑貓刺繡魔女裝',
    nameEn: 'Black Cat Witch',
    palette: '黑色 × 深紫 × 金色',
    description: '深紫尖帽、綁帶束身上衣與不對稱裙襬，點綴星月和黑貓刺繡。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'dark black cat motif witch outfit, '
        'black violet and antique gold color palette',
      ),
      _OutfitPart.headwear.phrase(
        'wide brim pointed violet witch hat, '
        'black satin hat band, '
        'embroidered gold stars and crescent moon, '
        'dangling star charms',
      ),
      _OutfitPart.upper.phrase(
        'black high-neck inner blouse, '
        'sheer deep purple sleeves, '
        'layered black lace cuffs, '
        'fitted violet corset bodice, '
        'black lace-up front, '
        'golden crescent brooch, '
        'narrow gold seam piping, '
        'purple satin neck bow',
      ),
      _OutfitPart.lower.phrase(
        'short layered asymmetrical purple witch skirt, '
        'black pleated underskirt, '
        'gold constellation embroidery, '
        'black cat silhouette embroidery near hem, '
        'narrow belt with star charms',
      ),
      _OutfitPart.legwear.phrase(
        'black opaque knee socks',
      ),
      _OutfitPart.footwear.phrase(
        'dark violet lace-up ankle boots, '
        'antique brass buckles',
      ),
      _OutfitPart.silhouette.phrase(
        'intricate magical fabric textures',
      ),
    ],
  ),
  _outfit(
    13,
    category: _catMotifOutfits,
    nameZh: '貓紋中華風套裝',
    nameEn: 'Chinese-Inspired Cat-Motif Outfit',
    palette: '朱紅 × 黑色 × 金色',
    description: '朱紅立領盤扣上衣與百褶裙，搭配金色雲紋、貓形刺繡及花簪。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'elegant red chinese-inspired cat motif fashion, '
        'rich crimson black and gold palette',
      ),
      _OutfitPart.upper.phrase(
        'fitted red mandarin collar blouse, '
        'black satin collar trim, '
        'golden frog button closures along diagonal front, '
        'short decorative cap sleeves, '
        'gold cloud embroidery on shoulder panels, '
        'fitted black waist insert, '
        'golden seam piping',
      ),
      _OutfitPart.lower.phrase(
        'small embroidered cat silhouette near hem',
      ),
      _OutfitPart.upper.phrase(
        'ornate floral brocade',
      ),
      _OutfitPart.lower.phrase(
        'wide crimson satin waist sash, '
        'dangling golden tassel charms, '
        'above-knee layered red pleated skirt, '
        'translucent black underskirt, '
        'gold floral skirt hem border, '
        'red silk side bow',
      ),
      _OutfitPart.headwear.phrase(
        'crimson ribbon hair ornaments, '
        'golden flower hairpin',
      ),
      _OutfitPart.accessory.phrase(
        'delicate red cuffs',
      ),
      _OutfitPart.legwear.phrase(
        'black knee socks',
      ),
      _OutfitPart.footwear.phrase(
        'polished black strap shoes, '
        'gold metal buckles',
      ),
    ],
  ),
  _outfit(
    14,
    category: _catMotifOutfits,
    nameZh: '貓兔刺繡套裝',
    nameEn: 'Cat and Bunny Theme',
    palette: '黑色 × 白色 × 粉紅',
    description: '黑背心繡有兔臉與貓掌，搭配粉白層疊裙、毛球腰飾和愛心鞋扣。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'playful cat and bunny themed fashion outfit, '
        'glossy black snowy white and blush pink colors',
      ),
      _OutfitPart.outerwear.phrase(
        'fitted black waistcoat',
      ),
      _OutfitPart.upper.phrase(
        'white rounded-collar blouse, '
        'black ribbon-trimmed shirt front, '
        'large pale pink satin neck bow, '
        'polished gold heart buttons, '
        'short white puff sleeves, '
        'black bow sleeve cuffs',
      ),
      _OutfitPart.outerwear.phrase(
        'embroidered bunny face and cat paw motifs on vest',
      ),
      _OutfitPart.lower.phrase(
        'short high-waisted layered black skirt, '
        'pastel pink pleated overskirt panels, '
        'white scalloped lace underskirt, '
        'pale pink waist sash, '
        'fluffy round white pompom accessory on waist bow',
      ),
      _OutfitPart.upper.phrase(
        'bunny charm brooch',
      ),
      _OutfitPart.accessory.phrase(
        'slim black wrist cuffs',
      ),
      _OutfitPart.legwear.phrase(
        'white knee socks, '
        'pink bows near tops',
      ),
      _OutfitPart.footwear.phrase(
        'black mary jane shoes, '
        'pale pink heart-shaped shoe ornaments',
      ),
    ],
  ),
  _outfit(
    15,
    category: _catMotifOutfits,
    nameZh: '貓掌運動服',
    nameEn: 'Cat-Motif Sportswear',
    palette: '白色 × 深藍 × 粉紅',
    description: '白色運動 T 恤、深藍跑步短褲與腰繫外套，搭配貓咪棒球帽及跑鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'sporty casual cat motif outfit, '
        'pure white navy and pastel pink colors',
      ),
      _OutfitPart.upper.phrase(
        'comfortable white athletic t-shirt, '
        'short raglan sleeves, '
        'dark navy side panels, '
        'thin pink piping along sleeve ends, '
        'centered pink paw-print chest emblem, '
        'lightweight breathable jersey fabric',
      ),
      _OutfitPart.lower.phrase(
        'fitted high-waisted navy running shorts, '
        'white curved side stripes, '
        'pink elastic drawstring waist, '
        'reinforced navy hems',
      ),
      _OutfitPart.outerwear.phrase(
        'white sporty jacket tied around waist',
      ),
      _OutfitPart.accessory.phrase(
        'pink and white soft wristbands, '
        'subtle stitched paw motifs',
      ),
      _OutfitPart.headwear.phrase(
        'white baseball cap with navy visor, '
        'pink embroidered cat icon',
      ),
      _OutfitPart.accessory.phrase(
        'compact white sports pouch',
      ),
      _OutfitPart.legwear.phrase(
        'short white ankle socks, '
        'pale pink stripes',
      ),
      _OutfitPart.footwear.phrase(
        'navy and white running sneakers, '
        'bright pink shoelace accents, '
        'rubber athletic soles',
      ),
    ],
  ),
  _outfit(
    16,
    category: _catMotifOutfits,
    nameZh: '貓掌深藍泳裝',
    nameEn: 'Cat-Motif Ocean Blue Swimwear',
    palette: '深海藍 × 白色 × 淡藍',
    description: '深海藍貓掌連身泳裝疊穿泳褲，搭配白色罩衫、貝殼項鍊和涼鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'sporty deep ocean blue cat motif swimwear, '
        'pure white and pale blue accents',
      ),
      _OutfitPart.onepiece.phrase(
        'navy athletic one-piece swimsuit, '
        'smoothly curved white side panels, '
        'secure broad shoulder straps, '
        'pale blue neckline edging, '
        'embroidered white paw-print chest emblem',
      ),
      _OutfitPart.lower.phrase(
        'matching navy fitted swim shorts worn over swimsuit, '
        'thin white side trim',
      ),
      _OutfitPart.outerwear.phrase(
        'lightweight white open-front beach shirt, '
        'short loose sleeves, '
        'translucent cotton beach layer, '
        'blue wave embroidery on cuffs',
      ),
      _OutfitPart.lower.phrase(
        'narrow navy waist ribbon tie',
      ),
      _OutfitPart.accessory.phrase(
        'small shell pendant necklace',
      ),
      _OutfitPart.headwear.phrase(
        'pale blue flower hairpin',
      ),
      _OutfitPart.accessory.phrase(
        'blue waterproof bracelet, '
        'striped navy and white beach tote',
      ),
      _OutfitPart.footwear.phrase(
        'flat navy beach sandals with white straps',
      ),
      _OutfitPart.silhouette.phrase(
        'practical coordinated summer outfit',
      ),
    ],
  ),
  _outfit(
    17,
    category: _catMotifOutfits,
    nameZh: '貓飾櫻花祭典浴衣',
    nameEn: 'Cat-Motif Festival Yukata',
    palette: '櫻花粉 × 淡紫 × 白色',
    description: '櫻花粉浴衣、淡紫腰帶與貓臉吊飾，搭配花簪、足袋和粉帶木屐。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'traditional sakura festival yukata with subtle cat ornaments, '
        'soft pink pale lavender and pure white palette',
      ),
      _OutfitPart.onepiece.phrase(
        'cherry blossom floral fabric pattern, '
        'elegant wrap-over kimono front, '
        'layered white inner collar, '
        'graceful wide sleeves, '
        'pale purple sleeve lining, '
        'delicate gold floral piping',
      ),
      _OutfitPart.accessory.phrase(
        'wide lavender obi belt, '
        'oversized golden yellow back obi bow, '
        'dangling pale pink silk tassels, '
        'decorative cat-face obi charm',
      ),
      _OutfitPart.onepiece.phrase(
        'narrow silk sleeve ties, '
        'long straight pink yukata skirt, '
        'lavender sakura border around hem',
      ),
      _OutfitPart.headwear.phrase(
        'floral hairpins with hanging beads, '
        'blush pink satin hair ribbon',
      ),
      _OutfitPart.legwear.phrase(
        'white tabi socks',
      ),
      _OutfitPart.footwear.phrase(
        'brown wooden geta sandals with soft pink straps',
      ),
      _OutfitPart.silhouette.phrase(
        'lightweight japanese summer festival costume',
      ),
    ],
  ),
  _outfit(
    18,
    category: _catMotifOutfits,
    nameZh: '貓掌毛絨睡衣',
    nameEn: 'Cozy Cat Pajamas',
    palette: '奶白 × 淡粉 × 雪白',
    description: '奶白刷毛連帽上衣與蕾絲背心搭配淡粉睡褲、長襪和貓臉室內拖鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'cozy cat-patterned winter loungewear, '
        'warm cream white and blush pink color palette',
      ),
      _OutfitPart.outerwear.phrase(
        'oversized cream fleece hoodie, '
        'thick sherpa-lined hood, '
        'wide plush sleeve cuffs, '
        'pastel pink satin neck bow, '
        'fluffy white pompom drawstrings, '
        'two large front pockets with embroidered sleeping cat faces, '
        'pink paw-print embroidered sleeve patches',
      ),
      _OutfitPart.upper.phrase(
        'cream lace camisole under open hoodie, '
        'scalloped white lace camisole neckline, '
        'pale pink chest ribbon',
      ),
      _OutfitPart.lower.phrase(
        'loose blush pink pajama shorts, '
        'white double ruffled short hems, '
        'decorative pink waist tie',
      ),
      _OutfitPart.legwear.phrase(
        'cream white ribbed thighhigh socks, '
        'thick plush sock cuffs, '
        'pink satin bows, '
        'fluffy matching leg warmers',
      ),
      _OutfitPart.footwear.phrase(
        'snow white cat-face plush indoor slippers with decorative pink paw pads',
      ),
    ],
  ),
  _outfit(
    19,
    category: _catMotifOutfits,
    nameZh: '黑粉貓掌偶像服',
    nameEn: 'Cat-Motif Idol Stage',
    palette: '黑色 × 亮粉 × 白色',
    description: '黑色短外套、亮粉蝴蝶結與貓掌刺繡舞台裙，搭配厚底瑪莉珍鞋。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'bright pink and black cat-themed idol stage costume, '
        'snow white and gold accents',
      ),
      _OutfitPart.outerwear.phrase(
        'cropped fitted black stage jacket, '
        'structured lapels with vivid fuchsia piping, '
        'black puff sleeves, '
        'white lace sleeve ends',
      ),
      _OutfitPart.upper.phrase(
        'crisp white blouse with frilled front, '
        'large hot pink satin chest bow, '
        'golden heart gemstone brooch, '
        'decorative double row gold buttons, '
        'black fitted corset waist',
      ),
      _OutfitPart.lower.phrase(
        'oversized pink satin waist bow with long ribbon tails, '
        'short layered idol skirt, '
        'black pleated panels combined with fuchsia plaid inserts, '
        'thick white ruffled underskirt, '
        'scalloped white hem, '
        'delicate embroidered cat paw motifs',
      ),
      _OutfitPart.accessory.phrase(
        'black and pink wrist lace cuffs',
      ),
      _OutfitPart.headwear.phrase(
        'vivid pink star hair bow',
      ),
      _OutfitPart.legwear.phrase(
        'opaque white thighhigh socks, '
        'pink bows',
      ),
      _OutfitPart.footwear.phrase(
        'black platform mary jane shoes, '
        'gold heart buckles',
      ),
    ],
  ),
  _outfit(
    20,
    category: _catMotifOutfits,
    nameZh: '星心貓掌魔法風套裝',
    nameEn: 'Cat-Motif Magical Stage Costume',
    palette: '粉紅 × 白色 × 金色',
    description: '玫粉束身上衣與星心刺繡百褶裙，搭配緞帶髮飾、長襪與星扣短靴。',
    sections: [
      _OutfitPart.silhouette.phrase(
        'sparkling pink magical stage costume with embroidered cat motifs, '
        'bright pink snow white and warm gold colors',
      ),
      _OutfitPart.upper.phrase(
        'elaborate white frilled collar, '
        'oversized rose pink satin neck bow, '
        'central gold heart jewel brooch, '
        'fitted white blouse bodice, '
        'rounded puff sleeves, '
        'pink ribbon sleeve ties, '
        'scalloped white lace sleeve cuffs, '
        'rose pink corset-style waist panel, '
        'golden star and heart embroidery, '
        'decorative gold front buttons',
      ),
      _OutfitPart.lower.phrase(
        'large pink satin waist bow with long tails, '
        'short layered magical skirt, '
        'rose pink pleated outer skirt panels, '
        'white scalloped petticoat, '
        'pale pink translucent chiffon trim, '
        'delicate gold star charms on skirt, '
        'small stitched paw motifs',
      ),
      _OutfitPart.headwear.phrase(
        'pink and gold satin hair ribbons',
      ),
      _OutfitPart.accessory.phrase(
        'white lace wrist cuffs',
      ),
      _OutfitPart.legwear.phrase(
        'white thighhigh socks, '
        'pastel pink ribbon bows',
      ),
      _OutfitPart.footwear.phrase(
        'white pink ankle boots with gold star buckles',
      ),
    ],
  ),
]);
