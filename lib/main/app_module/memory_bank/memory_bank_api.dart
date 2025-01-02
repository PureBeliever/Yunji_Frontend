import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/main/app/app_global_variable.dart';

Future<void> synchronizeMemoryBankData(
    String userName, int memoryBankId, int type) async {
  final formdata = {'userName': userName, 'memoryBankId': memoryBankId, 'type': type};

  final response = await dio.post(
    'http://47.92.98.170:36233/synchronizeMemoryBankData',
    data: jsonEncode(formdata),
    options: Options(headers: header),
  );
}
