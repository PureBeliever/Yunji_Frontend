import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/global.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_sqlite.dart';

Future<void> synchronizeMemoryBankData( List<int> idList,
    String typeList, int id, int quantity, String type) async {
  final userName = userNameChangeManagement.userNameValue??'';

  final formdata = {
    'userName': userName,
    'idList': idList,
    'typeList': typeList,
    'id': id,
    'quantity': quantity,
    'type': type
  };

  try {
    final response = await dio.post(
      '$website/synchronizeMemoryBankData',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );

    if (response.statusCode == 200) {
      await updateMemoryBankData(userName, idList, typeList, id, quantity, type);
    } else {
      throw Exception('同步记忆库数据失败: ${response.statusCode}');
    }
  } catch (e) {
    print('同步记忆库数据时发生错误: $e');
    throw Exception('同步记忆库数据时发生错误');
  }
}
