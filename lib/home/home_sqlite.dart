import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:yunji/main/global.dart';



// 插入记忆库
Future<void> insertHomePageMemoryBank(
    List<Map<String, dynamic>> memoryBankData) async {
  for (var memoryBank in memoryBankData) {
    try {
      memoryBank['question'] = jsonEncode(memoryBank['question']);
      memoryBank['answer'] = jsonEncode(memoryBank['answer']);
      await db.insert(
        'memory_bank',
        memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('插入记忆库失败: $e');
    }
  }
}

