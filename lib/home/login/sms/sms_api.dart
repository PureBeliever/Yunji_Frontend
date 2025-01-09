import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:yunji/personal/personal/personal/personal_api.dart';

final _dio = Dio();

Map<String, String> _getHeaders() {
  return {'Content-Type': 'application/json'};
}

void smsVerificationCode(String mobileNumber) async {
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
  };

  await _dio.post('http://47.92.98.170:36233/getVerificationCode',
      data: jsonEncode(formdata), options: Options(headers: _getHeaders()));
}

Future<bool> verification(String mobileNumber, String code) async {
  Map<String, dynamic> formdata = {
    'mobileNumber': mobileNumber,
    'code': code,
  };

  bool verificationState = false;
  try {
    final response = await _dio.post('http://47.92.98.170:36233/verification',
        data: jsonEncode(formdata), options: Options(headers: _getHeaders()));

    if (response.statusCode == 200) {
      verificationState = true;
      requestTheUsersPersonalData(response.data['username']);
    }
  } on DioError catch (e, s) {
    print('Error: \$e');
    print('StackTrace: \$s');
  }
  return verificationState;
}
