import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'dart:convert';

import 'package:yunji/main/app/app_sqlite.dart';

Future<void> updateMemoryBankData(String userName, List<int> idList,
    String typeList, int id, int quantity, String type) async {
  final db = databaseManager.database;;

  final query = 'UPDATE personal_data SET $typeList = ? WHERE user_name = ?';
  await db!.rawUpdate(query, [jsonEncode(idList), userName]);

  final updateQuery = 'UPDATE memory_bank SET $type = $type + ? WHERE id = ?';
  await db!.rawUpdate(updateQuery, [quantity, id]);

  final updateQuery1 =
      'UPDATE personal_memory_bank SET $type = $type + ? WHERE id = ?';
  await db!.rawUpdate(updateQuery1, [quantity, id]);

  final updateQuery2 =
      'UPDATE other_personal_memory_bank SET $type = $type + ? WHERE id = ?';
  await db!.rawUpdate(updateQuery2, [quantity, id]);

  await _synchronizeApp();
}

Future<void> _synchronizeApp() async {
  final personalData = await queryPersonalData();
  final homePageMemoryDatabaseData = await queryHomePageMemoryBank();
  if (personalData != null) {
    userPersonalInformationManagement
        .requestUserPersonalInformationDataOnTheBackEnd(personalData);
    refreshofHomepageMemoryBankextends
        .updateMemoryRefreshValue(homePageMemoryDatabaseData);
  } else {
    soginDependencySettings(contexts!);
  }
}

Future<void> addPersonalMemoryBankData(dynamic data) async {
  final db = databaseManager.database;

  // 检查 ID 是否已存在
  final existingData = await db!.query(
    'personal_memory_bank',
    where: 'id = ?',
    whereArgs: [data['id']],
  );


  if (existingData.isEmpty ) {
    // 如果不存在，则插入数据
    await db.insert('personal_memory_bank', data);

  }

}

Future<void> deletePersonalMemoryBankData(int id) async {
  final db = databaseManager.database;

  // 直接删除数据，无需检查 ID 是否存在
  await db!.delete('personal_memory_bank', where: 'id = ?', whereArgs: [id]);
}
