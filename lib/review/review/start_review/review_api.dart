import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

void continueReview(
    Map<String, String> question,
    Map<String, String> reply,
    int memorybankId,
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
    'username': userName,
    'question': question,
    'reply': reply,
    'memoryBankId': memorybankId,
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
 await dio.post(
    'http://47.92.98.170:36233/continueReview',
    data: jsonformdata,
    options: Options(headers: header),
  );
  requestTheUsersPersonalData(userName);
}
