import 'dart:convert';
import 'package:yunji/main/app_global_variable.dart';
import 'package:sqflite/sqflite.dart';
 // 插入其他人的个人记忆库
  Future<void> insertOtherPeoplePersonalMemoryBank(var memoryBankData) async {
    final db = databaseManager.database;

    memoryBankData.forEach((memoryBank) {
      memoryBank['question'] = jsonEncode(memoryBank['question']);
      memoryBank['reply'] = jsonEncode(memoryBank['reply']);
    

      db?.insert('other_personal_memory_bank', memoryBank,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  // 查询其他人的个人记忆库
  Future<List<Map<String, dynamic>>> queryOtherPeoplePersonalMemoryBank(
      List<int> ids) async {
    final db = databaseManager.database;
    //mysql查询语句
    String mysqlQueryStatement = 'memory_bank_id IN (${ids.map((id) => '?').join(',')})';

    List<dynamic> idList = ids.reversed.toList();
    final List<Map<String, dynamic>> memoryBank = await db!.query(
      'other_personal_memory_bank',
      where: mysqlQueryStatement,
      whereArgs: idList,
    );
    //根据id排序
    final List<Map<String, dynamic>> sortedResults = idList
        .map((id) => memoryBank.firstWhere((row) => row['memory_bank_id'] == id))
        .toList();

    return sortedResults;
  }

