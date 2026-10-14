import 'blue_outfit_reference_data.dart' as blue;
import 'elsword_job_outfit_data.dart' as elsword;
import 'outfit_reference_data.dart' as base;
import 'pink_outfit_reference_data.dart' as pink;

export 'outfit_reference_data.dart'
    show OutfitPiecePresetData, OutfitReferencePresetData;

/// Complete built-in outfit catalog shown by the outfit inspiration picker.
final outfitReferencePresets = <base.OutfitReferencePresetData>[
  ...base.outfitReferencePresets,
  ...blue.blueOutfitReferencePresets,
  ...pink.pinkOutfitReferencePresets,
  ...elsword.elswordJobOutfitReferencePresets,
];
