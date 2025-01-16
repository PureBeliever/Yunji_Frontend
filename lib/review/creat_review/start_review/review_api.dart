import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';
import 'package:yunji/global.dart';

Future<void> continueReview(
    Map<String, String> question,
    Map<String, String> answer,
    int id,
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
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  String userName = userNameChangeManagement.userNameValue ?? '';
  

  Map<String, dynamic> formdata = {
    'username': userName,
    'question': question,
    'answer': answer,
    'id': id,
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
      '$website/continueReview',
      data: jsonformdata,
      options: Options(headers: header),
    ); 
    requestTheUsersPersonalData(userName);
  } catch (e) {
    print('继续复习时出错: $e');
  }
}
