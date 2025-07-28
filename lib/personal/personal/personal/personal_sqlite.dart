import 'package:sqflite/sqflite.dart';
import 'package:yunji/main/global.dart';
import 'dart:convert';
import 'package:yunji/personal/personal/personal/personal_api.dart';

// 插入用户个人记忆库
Future<void> insertUserPersonalMemoryBank(var memoryBankData) async {
  try {
    for (var memoryBank in memoryBankData) {
      memoryBank['question'] = jsonEncode(memoryBank['question']);
      memoryBank['answer'] = jsonEncode(memoryBank['answer']);
      memoryBank['review_record'] = jsonEncode(memoryBank['review_record']);
      memoryBank['memory_time'] = jsonEncode(memoryBank['memory_time']);

      await db.insert('personal_memory_bank', memoryBank,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  } catch (e) {
    print('插入用户个人记忆库时出错: $e');
  }
}

Future<void> insertPersonalData(PersonalData personal) async {
  try {
    await db.insert(
      'personal_data',
      personal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    print('插入个人数据时出错: $e');
  }
}

Future<List<Map<String, dynamic>>> queryUserPersonalMemoryBank(
    List<int> ids) async {
  try {
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> memoryBank = await db.query(
      'personal_memory_bank',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );

    return ids.reversed
        .map((id) =>
            memoryBank.firstWhere((row) => row['id'] == id, orElse: () => {}))
        .where((element) => element.isNotEmpty)
        .toList();
  } catch (e) {
    print('查询用户个人记忆库时出错: $e');
    return [];
  }
}
