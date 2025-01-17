import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

void smsVerificationCode(String mobileNumber) async {
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  try {
    await dio.post('$website/getVerificationCode',
        data: jsonEncode(formdata), options: Options(headers: header));
  } catch (e) {
    print('发送验证码失败: $e');
  }
}

Future<bool> verification(String mobileNumber, String code) async {
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
    'code': code,
  };

  bool verificationState = false;

  try {
    final response = await dio.post('$website/verification',
        data: jsonEncode(formdata), options: Options(headers: header));

    if (response.statusCode == 200) {
      verificationState = true;
      requestTheUsersPersonalData(response.data['username']);
    }
  } catch (e) {
    print('验证失败: $e');
  }

  return verificationState;
}
