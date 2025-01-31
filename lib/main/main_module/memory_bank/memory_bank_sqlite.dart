import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/main/global.dart';
import 'dart:convert';

import 'package:yunji/main/main_init/app_sqlite.dart';

Future<void> updateMemoryBankData(String userName, List<int> idList,
    String typeList, int id, int quantity, String type) async {
  try {
    final query = 'UPDATE personal_data SET $typeList = ? WHERE user_name = ?';
    await db.rawUpdate(query, [jsonEncode(idList), userName]);

    final updateQuery = 'UPDATE memory_bank SET $type = $type + ? WHERE id = ?';
    await db.rawUpdate(updateQuery, [quantity, id]);

    final updateQuery1 =
        'UPDATE personal_memory_bank SET $type = $type + ? WHERE id = ?';
    await db.rawUpdate(updateQuery1, [quantity, id]);

    final updateQuery2 =
        'UPDATE other_personal_memory_bank SET $type = $type + ? WHERE id = ?';
    await db.rawUpdate(updateQuery2, [quantity, id]);

    await _synchronizeApp();
  } catch (e) {
    print('更新记忆库数据时发生错误: $e');
    throw Exception('更新记忆库数据失败');
  }
}

Future<void> _synchronizeApp() async {
  try {
    final personalData = await queryPersonalData();
    final homePageMemoryDatabaseData = await queryHomePageMemoryBank();
    if (personalData != null && homePageMemoryDatabaseData != null) {
      userPersonalInformationManagement
          .requestUserPersonalInformationDataOnTheBackEnd(personalData);
      refreshofHomepageMemoryBankextends
          .updateMemoryRefreshValue(homePageMemoryDatabaseData);
    } else {
     smsLogin(contexts!);
    }
  } catch (e) {
    print('同步应用时发生错误: $e');
    throw Exception('同步应用失败');
  }
}

Future<void> addPersonalMemoryBankData(dynamic data) async {
  try {
    // 检查 ID 是否已存在
    final existingData = await db.query(
      'personal_memory_bank',
      where: 'id = ?',
      whereArgs: [data['id']],
    );

    if (existingData.isEmpty) {
      // 如果不存在，则插入数据
      await db.insert('personal_memory_bank', data);
    }
  } catch (e) {
    print('添加个人记忆库数据时发生错误: $e');
    throw Exception('添加个人记忆库数据失败');
  }
}

Future<void> deletePersonalMemoryBankData(int id) async {
  try {
    // 直接删除数据，无需检查 ID 是否存在
    await db.delete('personal_memory_bank', where: 'id = ?', whereArgs: [id]);
  } catch (e) {
    print('删除个人记忆库数据时发生错误: $e');
    throw Exception('删除个人记忆库数据失败');
  }
}
