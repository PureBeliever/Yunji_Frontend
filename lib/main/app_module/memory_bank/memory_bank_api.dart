import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yunji/main/app_global_variable.dart';

Future<void> synchronizeMemoryBankData(
    int memoryBankId, int type, String userName) async {
  final formdata = {'userName': userName, 'memoryBankId': memoryBankId, 'type': type};

  final response = await dio.post(
    'http://47.92.98.170:36233/synchronizeMemoryBankData',
    data: jsonEncode(formdata),
    options: Options(headers: header),
  );
}
