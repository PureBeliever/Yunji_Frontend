import 'package:sqflite/sqflite.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'dart:convert';
import 'package:yunji/personal/personal/personal/personal_api.dart';

// 插入用户个人记忆库
Future<void> insertUserPersonalMemoryBank(var memoryBankData) async {
  final db = databaseManager.database;

  memoryBankData.forEach((memoryBank) {
    memoryBank['question'] = jsonEncode(memoryBank['question']);
    memoryBank['reply'] = jsonEncode(memoryBank['reply']);
    memoryBank['review_record'] = jsonEncode(memoryBank['review_record']);
    memoryBank['memory_time'] = jsonEncode(memoryBank['memory_time']);
    
    db?.insert('personal_memory_bank', memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace);
  });
}

Future<void> insertPersonalData(PersonalData personal) async {
  final db = databaseManager.database;
  if (db != null) {
    await db.insert(
      'personal_data',
      personal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

Future<List<Map<String, dynamic>>> queryUserPersonalMemoryBank(List<int> ids) async {
  final db = databaseManager.database;
  if (db == null || ids.isEmpty) return [];

  final placeholders = List.filled(ids.length, '?').join(',');
  final List<Map<String, dynamic>> memoryBank = await db.query(
    'personal_memory_bank',
    where: 'memory_bank_id IN ($placeholders)',
    whereArgs: ids,
  );

  return ids.reversed
      .map((id) => memoryBank.firstWhere((row) => row['memory_bank_id'] == id, orElse: () => {}))
      .where((element) => element.isNotEmpty)
      .toList();
}
