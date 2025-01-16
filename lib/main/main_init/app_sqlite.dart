import 'package:yunji/global.dart';


// 查询主页记忆库
Future<List<Map<String, dynamic>>?> queryHomePageMemoryBank() async {

  try {
    return await db.query('memory_bank', orderBy: 'NULL');
  } catch (e) {
    print('查询主页记忆库失败: $e');
    return null;
  }
}

Future<Map<String, dynamic>?> queryPersonalData() async {

  try {
    final List<Map<String, dynamic>> personalMaps =
        await db.query('personal_data');

    return personalMaps.isNotEmpty ? personalMaps[0] : null;
  } catch (e) {
    print('查询个人数据失败: $e');
    return null;
  }
}
