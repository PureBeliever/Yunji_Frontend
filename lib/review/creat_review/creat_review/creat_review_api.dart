import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/main/app/app_global_variable.dart';
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
  String? userName,
) async {
  Map<String, dynamic> formdata = {
    'userName': userName ?? '',
    'question': question,
    'answer': answer,
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
  final response = await dio.post(
    'http://47.92.98.170:36233/creatReview',
    data: jsonformdata,
    options: Options(headers: header),
  );
  await Future.delayed(const Duration(milliseconds: 500));
  requestTheUsersPersonalData(userName);
}
