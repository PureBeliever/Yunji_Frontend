import 'dart:convert';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:sqflite/sqflite.dart';
// 插入其他人的个人记忆库
Future<void> insertOtherPeoplePersonalMemoryBank(List<Map<String, dynamic>> memoryBankData) async {
  final db = databaseManager.database;

  // 清空数据库中的数据
  await db?.delete('other_personal_memory_bank');

  for (var memoryBank in memoryBankData) {
    memoryBank['question'] = jsonEncode(memoryBank['question']);
    memoryBank['answer'] = jsonEncode(memoryBank['answer']);

    await db?.insert(
      'other_personal_memory_bank',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

// 查询其他人的个人记忆库
Future<List<Map<String, dynamic>>> queryOtherPeoplePersonalMemoryBank(List<int> ids) async {
  final db = databaseManager.database;
  final placeholders = List.filled(ids.length, '?').join(',');
  final mysqlQueryStatement = 'id IN ($placeholders)';

  final List<Map<String, dynamic>> memoryBank = await db!.query(
    'other_personal_memory_bank',
    where: mysqlQueryStatement,
    whereArgs: ids,
  );

  return ids.reversed
      .map((id) => memoryBank.firstWhere((row) => row['id'] == id))
      .toList();
}
