import 'dart:convert';
import 'package:yunji/global.dart';
import 'package:sqflite/sqflite.dart';

Future<void> insertOtherPeoplePersonalMemoryBank(
    List<Map<String, dynamic>> memoryBankData) async {
  await db.delete('other_personal_memory_bank');

  for (var memoryBank in memoryBankData) {
    try {
      memoryBank['question'] = jsonEncode(memoryBank['question']);
      memoryBank['answer'] = jsonEncode(memoryBank['answer']);

      await db.insert(
        'other_personal_memory_bank',
        memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error inserting data: $e');
    }
  }
}

Future<List<Map<String, dynamic>>> queryOtherPeoplePersonalMemoryBank(
    List<int> ids) async {
  final placeholders = List.filled(ids.length, '?').join(',');
  final mysqlQueryStatement = 'id IN ($placeholders)';

  try {
    final List<Map<String, dynamic>> memoryBank = await db.query(
      'other_personal_memory_bank',
      where: mysqlQueryStatement,
      whereArgs: ids,
    );

    return ids.reversed
        .map((id) =>
            memoryBank.firstWhere((row) => row['id'] == id, orElse: () => {}))
        .toList();
  } catch (e) {
    print('Error querying data: $e');
    return [];
  }
}
