import 'dart:convert';
import 'package:dio/dio.dart';

final dio = Dio();

void editUserName(String? editUserName, String? userName) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'editUserName': editUserName,
    'userName': userName,
  };

  await dio.put('http://47.92.98.170:36233/editUserName',
      data: jsonEncode(formdata), options: Options(headers: header));
}

Future<bool> verifyUserName(String? editUserName) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'editUserName': editUserName,
  };

  final response = await dio.post('http://47.92.98.170:36233/verifyUserName',
      data: jsonEncode(formdata), options: Options(headers: header));
  return response.data['saveState'];
}
