import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

void mobileNumberLogin(String mobileNumber) async {
  final dio = Dio();
  loginStatus = true;
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  try {
    final response = await dio.post(
      'http://47.92.98.170:36233/mobileNumberLogin',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );
    if (response.statusCode == 200) {
      requestTheUsersPersonalData(response.data['username']);
    } else {
      // 处理非200状态码的情况
      print('登录失败，状态码: ${response.statusCode}');
    }
  } catch (e) {
    // 处理请求错误
    print('网络请求失败: $e');
  }
}