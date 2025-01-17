import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yunji/global.dart';

void mobileNumberLogin(String mobileNumber) async {
  loginStatus = true;
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  try {
    final response = await dio.post(
      '$website/mobileNumberLogin',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );

  } catch (e) {
    print('登录过程中发生错误: $e');
  }
}
