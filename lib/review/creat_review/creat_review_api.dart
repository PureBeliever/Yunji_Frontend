import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/personal/personal/personal_api.dart';

void creatReview(
  Map<String, String> question,
  Map<String, String> reply,
  String theme,
  List<int> memoryTime,
  DateTime setTime,
  List<int> subscript,
  bool informationNotification,
  bool alarmNotification,
  bool completeState,
  Map<String, String> reviewRecord,
  String reviewSchemeName,
  String userName,
) async {
  final dio = Dio();
  Map<String, dynamic> formdata = {
    'userName': userName,
    'question': question,
    'reply': reply,
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
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  String jsonformdata = jsonEncode(formdata);
  final response = await dio.post(
    'http://47.92.90.93:36233/creatReview',
    data: jsonformdata,
    options: Options(headers: header),
  );
  await Future.delayed(const Duration(milliseconds: 500));
  requestTheUsersPersonalData(userName);
}
