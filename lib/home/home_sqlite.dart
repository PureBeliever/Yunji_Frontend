import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:yunji/main/global.dart';

Future<Map<String, dynamic>> queryIdAndLength() async {
  final personalMaps = await db.query('intdatabase');
  return personalMaps.isNotEmpty ? personalMaps.first : {};
}

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

// 更新intdatabase
Future<void> updateint(String idList, int length) async {
  try {
    await db.update(
      'intdatabase',
      {'number': idList, 'length': length},
      where: 'id = ?',
      whereArgs: [0],
    );
  } catch (e) {
    print('更新intdatabase失败: $e');
  }
}
