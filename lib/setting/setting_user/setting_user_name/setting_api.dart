import 'dart:convert';
import 'package:yunji/main/global.dart';
import 'package:dio/dio.dart';

final dio = Dio();

void editUserName(String? editUserName, String? userName) async {
  Map<String, dynamic> formdata = {
    'editUserName': editUserName,
    'userName': userName,
  };

  try {
    final response = await dio.put('$website/editUserName',
        data: jsonEncode(formdata), options: Options(headers: header));
  } catch (e) {
    print('编辑用户名时出错: $e');
  }
}

Future<bool> verifyUserName(String? editUserName) async {
  Map<String, dynamic> formdata = {
    'editUserName': editUserName,
  };

  try {
    final response = await dio.post('$website/verifyUserName',
        data: jsonEncode(formdata), options: Options(headers: header));

    return response.data['saveState'];
  } catch (e) {
    print('验证用户名时出错: $e');
    return false;
  }
}
