import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/other_personal/other_personal_sqlite.dart';


void requestTheOtherPersonalData(String userName) async {
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {'userName': userName};

  final response = await dio.post(
      'http://47.92.90.93:36233/requestThePersonalData',
      data: jsonEncode(formdata),
      options: Options(headers: header));
  final beforeDir = await getApplicationDocumentsDirectory();
  final dir = Directory(join(beforeDir.path, 'otherPersonalImage'));
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);

  final Results = response.data;
  Map<String, dynamic> personalDataValue = Results['personalDataValue'];
  if (Results['memoryBankResults'] != null) {
    var memoryBankResults = Results["memoryBankResults"];
    var memoryBankPersonalResults = Results["memoryBankPersonalResults"];
    for (int i = 0; i < memoryBankPersonalResults.length; i++) {
      if (memoryBankPersonalResults[i]['head_portrait'] != null) {
        final filename = generateRandomFilename();
        List<int> imageBytes =
            base64.decode(memoryBankPersonalResults[i]['head_portrait']);
        memoryBankPersonalResults[i]['head_portrait'] = '${dir.path}/$filename';
        await File(memoryBankPersonalResults[i]['head_portrait'])
            .writeAsBytes(imageBytes);
      }
      if (memoryBankPersonalResults[i]['background_image'] != null) {
        final filename = generateRandomFilename();
        List<int> imageBytes =
            base64.decode(memoryBankPersonalResults[i]['background_image']);
        memoryBankPersonalResults[i]['background_image'] =
            '${dir.path}/$filename';
        await File(memoryBankPersonalResults[i]['background_image'])
            .writeAsBytes(imageBytes);
      }

      for (int y = 0; y < memoryBankResults.length; y++) {
        if (memoryBankResults[y]['user_name'] ==
            memoryBankPersonalResults[i]['user_name']) {
          memoryBankResults[y]['name'] = memoryBankPersonalResults[i]['name'];
          memoryBankResults[y]['head_portrait'] =
              memoryBankPersonalResults[i]['head_portrait'];
        }
      }
    }

    await insertOtherPeoplePersonalMemoryBank(memoryBankResults);

    otherPeoplePersonalInformationManagement
        .requestOtherPeoplePersonalInformationDataOnTheBackEnd(
            personalDataValue);
  }
}
