import 'package:sqflite/sqflite.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'dart:convert';
import 'package:yunji/personal/personal/personal/personal_api.dart';

// 插入用户个人记忆库
Future<void> insertUserPersonalMemoryBank(var memoryBankData) async {
  final db = databaseManager.database;
print('记忆库存入数据库');
  memoryBankData.forEach((memoryBank) {
    memoryBank['question'] = jsonEncode(memoryBank['question']);
    memoryBank['reply'] = jsonEncode(memoryBank['reply']);
    memoryBank['review_record'] = jsonEncode(memoryBank['review_record']);
    memoryBank['memory_time'] = jsonEncode(memoryBank['memory_time']);
    
    print(memoryBank);
    db?.insert('personal_memory_bank', memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace);
  });
}

Future<void> insertPersonalData(PersonalData personal) async {
  final db = databaseManager.database;
  await db?.insert(
    'personal_data',
    personal.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// 查询用户个人记忆库
Future<List<Map<String, dynamic>>> queryUserPersonalMemoryBank(
    List<int> ids) async {
  final db = databaseManager.database;

  String mysqlQueryStatement =
      ' memory_bank_id IN (${ids.map((id) => '?').join(',')})';

  List<dynamic> idList = ids.reversed.toList();
  final List<Map<String, dynamic>> memoryBank = await db!.query(
    'personal_memory_bank ',
    where: mysqlQueryStatement,
    whereArgs: idList,
  );
  //根据id排序
  final List<Map<String, dynamic>> sortedResults = idList
      .map((memory_bank_id) => memoryBank
          .firstWhere((row) => row['memory_bank_id'] == memory_bank_id))
      .toList();

  return sortedResults;
}
