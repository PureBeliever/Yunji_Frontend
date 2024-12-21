
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/personal/personal_api.dart';

void mobileNumberLogin(String mobileNumber) async {
    final dio = Dio();
  loginStatus = true;
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  final response = await dio.post('http://47.92.90.93:36233/mobileNumberLogin',
      data: jsonEncode(formdata), options: Options(headers: header));
  if (response.statusCode == 200) {
    requestTheUsersPersonalData(response.data['username']);
  }
}