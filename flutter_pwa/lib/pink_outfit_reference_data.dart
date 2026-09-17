import 'outfit_reference_data.dart';

/// Pink-and-white outfit references kept separately so their palette can grow
/// without mixing them into the blue-only inspiration catalog.
const pinkOutfitReferencePresets = <OutfitReferencePresetData>[
  OutfitReferencePresetData(
    id: 'pink_white_equestrian_layered',
    category: '甜美／浪漫',
    name: '粉白馬術風分層裙裝',
    palette: '粉紅色 × 白色 × 淺粉紅',
    description: '白色長袖鈕扣襯衫配粉紅領結與腰帶，下身為粉白分層蕾絲裙和馬術靴；保留騎馬服的俐落腰線，同時維持甜美層次。',
    pieces: [
      OutfitPiecePresetData(
        scope: 'accessory',
        garment: 'large hair bow',
        mainColor: 'pink',
        secondaryColor: 'white',
      ),
      OutfitPiecePresetData(
        scope: 'accessory',
        garment: 'neck ribbon',
        mainColor: 'hot pink',
        secondaryColor: 'white',
      ),
      OutfitPiecePresetData(
        scope: 'top',
        garment: 'button-up shirt',
        mainColor: 'white',
        secondaryColor: 'light pink',
        detailColor: 'light pink',
        cut: 'long sleeves',
        fit: 'fitted',
        length: 'waist length',
        materials: ['cotton'],
        details: ['buttons', 'lace trim', 'ruffles'],
        patterns: ['solid color'],
      ),
      OutfitPiecePresetData(
        scope: 'accessory',
        garment: 'belt',
        mainColor: 'hot pink',
        secondaryColor: 'white',
      ),
      OutfitPiecePresetData(
        scope: 'skirt',
        garment: 'tiered skirt',
        mainColor: 'pink',
        secondaryColor: 'white',
        detailColor: 'white',
        cut: 'high-waisted',
        fit: 'regular fit',
        length: 'midi',
        materials: ['chiffon'],
        details: ['layered', 'lace trim', 'ruffles', 'ribbon'],
        patterns: ['solid color'],
      ),
      OutfitPiecePresetData(
        scope: 'shoes',
        garment: 'riding boots',
        mainColor: 'white',
        secondaryColor: 'pink',
        materials: ['leather'],
        details: ['lace-up'],
      ),
    ],
    mainStyle: 'feminine',
    subStyle: 'romantic feminine style',
    mood: 'sweet mood',
    occasion: 'outdoor outfit',
  ),
];
