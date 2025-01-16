import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

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
    String? userName,
) async {
  final dio = Dio();
    Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = {
    'username': userName,
    'question': question,
    'answer': answer,
    'id': id,
    'theme': theme,
    'memoryTime': memoryTime,
    'setTime': setTime.toString(),
    'subscript': subscript,
    'informationNotification': informationNotification,
    'alarmNotification': alarmNotification,
    'completeState': completeState,
    'reviewRecord': reviewRecord,
    'reviewSchemeName': reviewSchemeName
  };

  String jsonformdata = jsonEncode(formdata);
 await dio.post(
    'http://47.92.98.170:36233/continueReview',
    data: jsonformdata,
    options: Options(headers: header),
  );
  requestTheUsersPersonalData(userName);
}
