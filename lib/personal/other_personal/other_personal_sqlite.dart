import 'dart:convert';
import 'package:yunji/main/app_global_variable.dart';
import 'package:sqflite/sqflite.dart';
// 插入其他人的个人记忆库
Future<void> insertOtherPeoplePersonalMemoryBank(List<Map<String, dynamic>> memoryBankData) async {
  final db = databaseManager.database;

  for (var memoryBank in memoryBankData) {
    memoryBank['question'] = jsonEncode(memoryBank['question']);
    memoryBank['reply'] = jsonEncode(memoryBank['reply']);

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
  final mysqlQueryStatement = 'memory_bank_id IN ($placeholders)';

  final List<Map<String, dynamic>> memoryBank = await db!.query(
    'other_personal_memory_bank',
    where: mysqlQueryStatement,
    whereArgs: ids,
  );

  return ids.reversed
      .map((id) => memoryBank.firstWhere((row) => row['memory_bank_id'] == id))
      .toList();
}
