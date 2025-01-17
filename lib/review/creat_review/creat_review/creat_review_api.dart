import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

Future<void> creatReview(
  Map<String, String> question,
  Map<String, String> answer,
  String theme,
  List<int> memoryTime,
  DateTime setTime,
  List<int> subscript,
  bool informationNotification,
  bool alarmNotification,
  bool completeState,
  Map<String, String> reviewRecord,
  String reviewSchemeName,
) async {
  String userName = userNameChangeManagement.userNameValue ?? '';
  

  Map<String, dynamic> formdata = {
    'userName': userName,
    'question': question,
    'answer': answer,
    'theme': theme,
    'memoryTime': memoryTime,
    'setTime': setTime.toIso8601String(),
    'subscript': subscript,
    'informationNotification': informationNotification,
    'alarmNotification': alarmNotification,
    'completeState': completeState,
    'reviewRecord': reviewRecord,
    'reviewSchemeName': reviewSchemeName
  };

  try {
    String jsonformdata = jsonEncode(formdata);
    final response = await dio.post(
      '$website/creatReview',
      data: jsonformdata,
      options: Options(headers: header),
    );




    await Future.delayed(const Duration(milliseconds: 500));
    requestTheUsersPersonalData(userName);
  } catch (e) {
    print('创建复习时出错: $e');
  }
}
