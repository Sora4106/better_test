import 'catalog_data.dart';

String _fingerGestureSlug(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

List<CatalogTagData> _fingerGestureTags(
  String prefix,
  String group,
  List<(String, String, String)> rows,
) =>
    rows
        .map(
          (row) => CatalogTagData(
            id: '${prefix}_${_fingerGestureSlug(row.$2)}',
            group: group,
            zh: row.$1,
            en: row.$2,
            order: 4,
            support: row.$3,
          ),
        )
        .toList();

const fingerGestureGroups = <String>{
  '手指・指向方向',
  '手指・手勢形狀',
  '手指・嘴臉互動',
  '手指・細節動作',
};

/// Finger and hand actions are intentionally stackable. A user may assign
/// different gestures to each hand or combine a gesture with a mouth action.
final List<CatalogTagData> fingerGestureTags = <CatalogTagData>[
  ..._fingerGestureTags(
    'finger_point',
    '手指・指向方向',
    const [
      ('指向觀看者', 'pointing at viewer', 'official'),
      ('指向另一人', 'pointing at another', 'official'),
      ('指向物件', 'pointing at object', 'official'),
      ('指向自己', 'pointing at self', 'official'),
      ('指向後方', 'pointing backward', 'official'),
      ('指向下方', 'pointing down', 'official'),
      ('明確指向前方', 'pointing forward', 'official'),
      ('指向側邊', 'pointing to the side', 'official'),
      ('指向上方', 'pointing up', 'official'),
      ('用拇指指向', 'pointing with thumb', 'official'),
      ('用食指指向左方', 'pointing left with index finger', 'description'),
      ('用食指指向右方', 'pointing right with index finger', 'description'),
    ],
  ),
  ..._fingerGestureTags(
    'finger_sign',
    '手指・手勢形狀',
    const [
      ('舉起食指', 'index finger raised', 'official'),
      ('比出中指', 'middle finger', 'official'),
      ('伸出小指', 'pinky out', 'official'),
      ('手指交叉祈求好運', 'crossed fingers', 'official'),
      ('單手手槍手勢', 'finger gun', 'official'),
      ('雙手手槍手勢', 'double finger gun', 'official'),
      ('單手指愛心', 'finger heart', 'official'),
      ('夏威夷沙卡手勢', 'shaka sign', 'official'),
      ('雙指敬禮', 'two-finger salute', 'official'),
      ('辣妹V字手勢', 'gyaru v', 'official'),
      ('掌心朝內V字手勢', 'inward v', 'official'),
      ('V字手勢放在眼睛旁', 'v over eye', 'official'),
      ('V字手勢放在嘴旁', 'v over mouth', 'official'),
      ('搓指金錢手勢', 'money gesture', 'official'),
      ('OK手勢', 'ok sign', 'official'),
      ('捏取手勢', 'pinching gesture', 'official'),
      ('張開手掌', 'open hand', 'official'),
      ('張開五指', 'spread fingers', 'official'),
      ('手指彎曲', 'curled fingers', 'official'),
      ('握拳振奮', 'fist pump', 'official'),
      ('舉起拳頭', 'raised fist', 'official'),
      ('瓦肯舉手禮', 'vulcan salute', 'official'),
      ('勾手指招呼靠近', 'beckoning', 'official'),
      ('豎起拇指', 'thumbs up', 'official'),
      ('拇指向下', 'thumbs down', 'official'),
      ('食指抵唇噤聲', 'shushing', 'official'),
    ],
  ),
  ..._fingerGestureTags(
    'finger_face',
    '手指・嘴臉互動',
    const [
      ('手指放在嘴邊', 'finger to mouth', 'official'),
      ('手指貼著臉頰', 'finger to cheek', 'official'),
      ('舔自己的手指', 'licking own finger', 'official'),
      ('舔另一人的手指', "licking another's finger", 'official'),
      ('自己的手指放入口中', 'finger in own mouth', 'official'),
      ('吸吮手指', 'finger sucking', 'official'),
      ('輕咬自己的手指', 'biting own finger', 'official'),
      ('吸吮拇指', 'thumb sucking', 'official'),
      ('指尖輕觸嘴唇', 'fingertip touching lips', 'description'),
      ('舌尖碰觸指尖', 'tongue touching fingertip', 'description'),
    ],
  ),
  ..._fingerGestureTags(
    'finger_action',
    '手指・細節動作',
    const [
      ('彈響手指', 'snapping fingers', 'description'),
      ('用手指繞頭髮', 'twirling hair', 'official'),
      ('勾小指約定', 'pinky swear', 'official'),
      ('手指取景框', 'finger frame', 'official'),
      ('雙手愛心', 'heart hands', 'official'),
      ('指尖相抵沉思', 'steepled fingers', 'official'),
      ('用手指計數', 'counting on fingers', 'description'),
      ('手指輕敲', 'tapping fingers', 'description'),
      ('食指左右搖動', 'wagging index finger', 'description'),
      ('用手指描繪輪廓', 'tracing with finger', 'description'),
      ('雙手指尖互相碰觸', 'touching fingertips together', 'description'),
      ('用兩指夾住小物件', 'holding small object between fingers', 'description'),
    ],
  ),
];
