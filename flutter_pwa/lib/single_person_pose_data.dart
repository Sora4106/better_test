import 'catalog_data.dart';

String _soloPoseSlug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

List<CatalogTagData> _soloPoseGroup(
  String prefix,
  String group,
  List<(String, String)> rows,
) =>
    rows
        .map(
          (row) => CatalogTagData(
            id: 'solo_${prefix}_${_soloPoseSlug(row.$2)}',
            group: group,
            zh: row.$1,
            en: row.$2,
            order: 4,
            support: 'description',
          ),
        )
        .toList();

const singlePersonPoseGroups = <String>{
  '單人・站姿',
  '單人・靠牆姿勢',
  '單人・椅子坐姿',
  '單人・桌邊姿勢',
  '單人・地板坐姿',
  '單人・床上坐姿',
  '單人・仰躺姿勢',
  '單人・側躺姿勢',
  '單人・俯臥姿勢',
  '單人・跪蹲姿勢',
};

/// One hundred non-adult, single-person pose descriptions. These phrases are
/// deliberately contextual (chair, table, wall, floor, or bed) so they can be
/// combined with hand, head, gaze, and camera tags without implying an act.
final List<CatalogTagData> singlePersonPoseTags = <CatalogTagData>[
  ..._soloPoseGroup('standing', '單人・站姿', const [
    ('放鬆站姿', 'relaxed standing pose'),
    ('立正式站姿', 'standing at attention'),
    ('雙手叉腰站立', 'standing with both hands on hips'),
    ('單手叉腰站立', 'standing with one hand on hip'),
    ('雙手背後站立', 'standing with hands behind back'),
    ('抱臂站立', 'standing with arms folded'),
    ('雙手插口袋站立', 'standing with hands in pockets'),
    ('雙腳併攏站立', 'standing with feet together'),
    ('寬步站姿', 'wide stance pose'),
    ('腳踝交叉站立', 'standing with ankles crossed'),
    ('腳跟併攏站立', 'standing with heels together'),
    ('重心放在單腿站立', 'standing with weight shifted to one leg'),
  ]),
  ..._soloPoseGroup('wall', '單人・靠牆姿勢', const [
    ('背貼牆站立', 'standing with back against wall'),
    ('放鬆靠牆', 'relaxed lean against wall'),
    ('單肩靠牆站立', 'standing with one shoulder against wall'),
    ('側身靠牆站立', 'standing sideways against wall'),
    ('單手扶牆', 'one hand resting on wall'),
    ('雙掌貼牆', 'both palms against wall'),
    ('站在牆角旁', 'standing near wall corner'),
    ('背靠牆坐著', 'seated with back against wall'),
    ('坐在地板並靠牆', 'sitting on floor against wall'),
    ('靠牆低蹲', 'crouching against wall'),
  ]),
  ..._soloPoseGroup('chair', '單人・椅子坐姿', const [
    ('端正坐在椅子上', 'upright seated on chair'),
    ('放鬆坐在椅子上', 'relaxed seated on chair'),
    ('側坐在椅子上', 'sitting sideways on chair'),
    ('反向坐椅子', 'sitting backward on chair'),
    ('坐在椅子前緣', 'perched on front edge of chair'),
    ('坐椅子向後靠', 'leaning back in chair'),
    ('坐椅子向前傾', 'leaning forward while seated on chair'),
    ('坐椅子翹腿', 'seated on chair with legs crossed'),
    ('坐椅子交叉腳踝', 'seated on chair with ankles crossed'),
    ('坐椅子雙腳併攏', 'seated on chair with feet together'),
  ]),
  ..._soloPoseGroup('table', '單人・桌邊姿勢', const [
    ('坐在桌面上', 'sitting on tabletop'),
    ('坐在桌緣', 'sitting on edge of table'),
    ('坐在桌角', 'perched on table corner'),
    ('向後倚著桌子', 'leaning back against table'),
    ('向前伏在桌面', 'leaning forward over table'),
    ('站在桌旁並單手扶桌', 'standing beside table with one hand on tabletop'),
    ('坐在桌旁', 'seated beside table'),
    ('雙肘放在桌上', 'elbows resting on table'),
    ('坐桌旁托腮', 'chin resting on hand at table'),
    ('斜倚在桌面上', 'reclining across tabletop'),
  ]),
  ..._soloPoseGroup('floor_sitting', '單人・地板坐姿', const [
    ('盤腿坐在地板', 'cross-legged sitting on floor'),
    ('坐地板並抬起雙膝', 'sitting on floor with knees raised'),
    ('坐地板並向前伸腿', 'sitting on floor with legs extended forward'),
    ('側身坐在地板', 'side-sitting on floor'),
    ('跪坐在地板', 'kneeling sit on floor'),
    ('坐地板並抬起單膝', 'sitting on floor with one knee raised'),
    ('坐地板並雙手向後支撐', 'sitting on floor with hands behind body'),
    ('坐地板並單臂後撐', 'sitting on floor leaning back on one arm'),
    ('坐地板抱膝', 'sitting on floor hugging knees'),
    ('坐地板並交叉腳踝', 'seated on floor with ankles crossed'),
  ]),
  ..._soloPoseGroup('bed_sitting', '單人・床上坐姿', const [
    ('端正坐在床上', 'upright sitting on bed'),
    ('坐在床緣', 'sitting at edge of bed'),
    ('盤腿坐在床上', 'cross-legged sitting on bed'),
    ('坐床上並抬起雙膝', 'sitting on bed with knees raised'),
    ('側身坐在床上', 'side-sitting on bed'),
    ('坐床上向後倚', 'sitting on bed while leaning back'),
    ('坐床上並讓雙腿垂下', 'sitting on bed with legs dangling'),
    ('靠著床頭板坐', 'sitting against headboard'),
  ]),
  ..._soloPoseGroup('supine', '單人・仰躺姿勢', const [
    ('平躺在地板', 'lying flat on floor'),
    ('臉朝上躺在地板', 'lying face up on floor'),
    ('地板仰臥姿勢', 'supine pose on floor'),
    ('仰躺並將雙臂放身側', 'lying on back with arms at sides'),
    ('仰躺並將雙臂伸過頭', 'lying on back with arms above head'),
    ('仰躺並抬起單膝', 'lying on back with one knee raised'),
    ('仰躺並彎曲雙膝', 'lying on back with both knees bent'),
    ('仰躺並交叉腳踝', 'lying on back with ankles crossed'),
    ('仰躺並以單臂遮額', 'lying on back with one arm over forehead'),
    ('在地板放鬆伸展四肢', 'spread-out resting pose on floor'),
  ]),
  ..._soloPoseGroup('side_lying', '單人・側躺姿勢', const [
    ('在地板側躺', 'side-lying pose on floor'),
    ('側身蜷曲休息', 'curled resting pose on one side'),
    ('側躺並彎曲雙膝', 'lying on side with knees bent'),
    ('側躺並以手肘支撐', 'lying on side propped on elbow'),
    ('側躺並以手托頭', 'lying on side with head resting on hand'),
    ('側躺並伸直雙腿', 'lying on side with legs extended'),
    ('側躺並抬起上側膝蓋', 'lying on side with upper knee raised'),
    ('向左側斜躺', 'reclining on left side'),
    ('向右側斜躺', 'reclining on right side'),
    ('側躺並伸出單臂', 'lying on side with one arm extended'),
  ]),
  ..._soloPoseGroup('prone', '單人・俯臥姿勢', const [
    ('俯臥在地板', 'prone pose on floor'),
    ('臉朝下並伸直雙腿', 'lying face down with legs extended'),
    ('臉朝下並彎曲雙膝', 'lying face down with knees bent'),
    ('臉朝下並抬起雙腳', 'lying face down with feet raised'),
    ('臉朝下並以雙肘支撐', 'lying face down propped on elbows'),
    ('臉朝下並雙手托下巴', 'lying face down with chin in hands'),
    ('臉朝下並向前伸臂', 'lying face down with arms extended forward'),
    ('臉朝下並將雙臂放身側', 'lying face down with arms at sides'),
    ('臉朝下並將頭轉向側面', 'lying face down with head turned sideways'),
    ('臉頰貼地休息', 'resting cheek on floor'),
  ]),
  ..._soloPoseGroup('kneeling_crouching', '單人・跪蹲姿勢', const [
    ('直身跪姿', 'upright kneeling pose'),
    ('雙膝併攏跪姿', 'kneeling with knees together'),
    ('自然分膝跪姿', 'kneeling with knees comfortably apart'),
    ('跪姿並雙手放大腿', 'kneeling with hands on thighs'),
    ('跪在椅子旁', 'kneeling beside chair'),
    ('跪在床旁', 'kneeling beside bed'),
    ('低身蹲伏', 'low crouching pose'),
    ('蹲伏並讓單膝接近地面', 'crouching with one knee near floor'),
    ('全腳掌著地深蹲', 'flat-footed squat'),
    ('放鬆蹲坐姿勢', 'resting squat pose'),
  ]),
];
