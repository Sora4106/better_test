import 'catalog_data.dart';
import 'outfit_reference_data.dart';

/// Job-specific outfit descriptions for the Elsword cast. These are written as
/// editable natural-language helpers: the model may recognise the job name,
/// while the user can still add the normal colour, cut and decoration tags.
class _ElswordJobOutfit {
  const _ElswordJobOutfit(
      this.characterZh, this.characterEn, this.jobZh, this.jobEn);

  final String characterZh;
  final String characterEn;
  final String jobZh;
  final String jobEn;

  String get id =>
      'elsword_${characterEn.toLowerCase()}_${jobEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+$'), '')}';
  String get zh => '$characterZh・$jobZh轉職服裝';
  String get en => 'Elsword $characterEn $jobEn official class outfit';
}

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

final List<OutfitReferencePresetData> elswordJobOutfitReferencePresets =
    List<OutfitReferencePresetData>.unmodifiable(
  _elswordJobs
      .map((job) => OutfitReferencePresetData(
            id: job.id,
            category: '艾爾之光・轉職服裝',
            name: job.zh,
            palette: '依原作職業設計',
            description:
                '套用艾爾之光 ${job.characterZh}・${job.jobZh} 的職業服裝描述；仍可再調整現有服裝部位、顏色與裝飾。',
            pieces: [
              OutfitPiecePresetData(scope: 'costume', garment: job.en),
            ],
          ))
      .toList(),
);
