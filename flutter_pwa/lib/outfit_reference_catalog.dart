import 'blue_outfit_reference_data.dart' as blue;
import 'outfit_reference_data.dart' as base;

export 'outfit_reference_data.dart'
    show OutfitPiecePresetData, OutfitReferencePresetData;

/// Complete built-in outfit catalog shown by the outfit inspiration picker.
const outfitReferencePresets = <base.OutfitReferencePresetData>[
  ...base.outfitReferencePresets,
  ...blue.blueOutfitReferencePresets,
];
