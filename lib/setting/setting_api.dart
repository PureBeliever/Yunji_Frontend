import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/setting/setting_sqlite.dart';
void editUserName(String editusername, String username) async {
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'editusername': editusername,
    'username': username,
  };

  final response = await dio.put('http://47.92.90.93:36233/editUserName',
      data: jsonEncode(formdata), options: Options(headers: header));
  if (response.statusCode == 200) {
    updateUserName(editusername, username);
  }
}

