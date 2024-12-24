import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:yunji/personal/personal/personal/personal_api.dart';

final _dio = Dio();
void smsVerificationCode(String mobileNumber) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };
  try {
    await _dio.post('http://47.92.90.93:36233/getVerificationCode',
        data: jsonEncode(formdata), options: Options(headers: header));
  } on DioError catch (e, s) {
    print('Error: $e');
    print('StackTrace: $s');
  }
}

Future<bool> verification(String mobileNumber, String code) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
    'code': code,
  };

  bool verificationState = false;
  final response = await _dio.post('http://47.92.90.93:36233/verification',
      data: jsonEncode(formdata), options: Options(headers: header));

  if (response.statusCode == 200) {
    verificationState = true;
    requestTheUsersPersonalData(response.data['username']);
  }
  return verificationState;
}
