import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/main/app_module/memory_bank/memory_bank_sqlite.dart';

Future<void> synchronizeMemoryBankData(String userName, List<int> idList,
    String typeList, int id, int quantity, String type) async {
  final formdata = {
    'userName': userName,
    'idList': idList,
    'typeList': typeList,
    'id': id,
    'quantity': quantity,
    'type': type
  };

  final response = await dio.post(
    'http://47.92.98.170:36233/synchronizeMemoryBankData',
    data: jsonEncode(formdata),
    options: Options(headers: header),
  );

  await updateMemoryBankData(userName, idList, typeList, id, quantity, type);
  

}
