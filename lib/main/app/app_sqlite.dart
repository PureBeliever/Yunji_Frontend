import 'package:yunji/main/app/app_global_variable.dart';


// 查询主页记忆库
Future<List<Map<String, dynamic>>?> queryHomePageMemoryBank() async {
  final db = databaseManager.database;
  if (db == null) {
    throw Exception('Database is not initialized');
  }

  return await db.query('memory_bank', orderBy: 'NULL');
}

Future<Map<String, dynamic>?> queryPersonalData() async {
  final db = databaseManager.database;

  final List<Map<String, dynamic>> personalMaps =
      await db!.query('personal_data');

  return personalMaps.isNotEmpty ? personalMaps[0] : null;
}

Future<List<Map<String, dynamic>>> queryPersonalMemoryBank(String memoryBankIdList) async {
  final db = databaseManager.database;
  if (db == null) {
    throw Exception('Database is not initialized');
  }
  memoryBankIdList = memoryBankIdList.replaceAll('[', '').replaceAll(']', '');
  return await db.query('personal_memory_bank', where: 'id IN ($memoryBankIdList)', orderBy: 'NULL');
}
