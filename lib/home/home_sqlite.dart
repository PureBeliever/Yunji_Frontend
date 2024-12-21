
import 'dart:convert';
import 'package:sqflite/sqflite.dart';  
import 'package:yunji/main/app_global_variable.dart';
Future<Map<String, dynamic>> queryIdAndLength() async {
    final db = databaseManager.database;

    if (db == null) {
      throw Exception('Database is not initialized');
    }

    final List<Map<String, dynamic>> personalMaps = await db.query('intdatabase');

    if (personalMaps.isEmpty) {
      throw Exception('No data found in intdatabase');
    }

    return personalMaps[0];
  }


  // 插入记忆库
  Future<void> insertHomePageMemoryBank(var memoryBankData) async {
    final db = databaseManager.database;

    memoryBankData.forEach((memoryBank) {
      memoryBank['question'] = jsonEncode(memoryBank['question']);
      memoryBank['reply'] = jsonEncode(memoryBank['reply']);
   

      db?.insert(
        'memory_bank',
        memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
// 查询主页记忆库
    Future<List<Map<String, dynamic>>> queryHomePageMemoryBank() async {
    final db = databaseManager.database;

    final List<Map<String, dynamic>> memoryBank = await db!.query(
      'memory_bank',
      orderBy: 'NULL',
    );
    return memoryBank;
  }

  // 更新intdatabase
  Future<void> updateint(String idList, int length) async {
    final db = databaseManager.database;

    await db?.update(
      'intdatabase',
        {'number': idList, 'length': length},
      where: 'id = ?',
      whereArgs: [0],
    );
  }