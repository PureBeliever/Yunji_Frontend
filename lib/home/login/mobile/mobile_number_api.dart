import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yunji/main/global.dart';

void mobileNumberLogin(String mobileNumber) async {
  loginStatus = true;
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  try {
    await dio.post(
      '$website/mobileNumberLogin',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );

  } catch (e) {
    print('登录过程中发生错误: $e');
  }
}
