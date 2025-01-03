
import 'dart:convert';
import 'package:sqflite/sqflite.dart';  
import 'package:yunji/main/app/app_global_variable.dart';
Future<Map<String, dynamic>> queryIdAndLength() async {
  final db = databaseManager.database;
  if (db == null) {
    throw Exception('Database is not initialized');
  }

  final personalMaps = await db.query('intdatabase');
  if (personalMaps.isEmpty) {
    throw Exception('No data found in intdatabase');
  }

  return personalMaps.first;
}

// 插入记忆库
Future<void> insertHomePageMemoryBank(List<Map<String, dynamic>> memoryBankData) async {
  final db = databaseManager.database;
  if (db == null) {
    throw Exception('Database is not initialized');
  }

  for (var memoryBank in memoryBankData) {
    memoryBank['question'] = jsonEncode(memoryBank['question']);
    memoryBank['answer'] = jsonEncode(memoryBank['answer']);
    await db.insert(
      'memory_bank',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

// 更新intdatabase
Future<void> updateint(String idList, int length) async {
  final db = databaseManager.database;
  if (db == null) {
    throw Exception('Database is not initialized');
  }

  await db.update(
    'intdatabase',
    {'number': idList, 'length': length},
    where: 'id = ?',
    whereArgs: [0],
  );
}