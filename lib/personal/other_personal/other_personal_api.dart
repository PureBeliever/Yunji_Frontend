import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/other_personal/other_personal_sqlite.dart';

class OtherPersonalMemoryBank {
  final String? userName;
  final String? name;
  final String? introduction;
  final String? residentialAddress;
  final String? birthTime;
  final String? backgroundImage;
  final String? headPortrait;
  final String? joinDate;


  OtherPersonalMemoryBank({
    required this.userName,
    required this.name,
    required this.introduction,
    required this.residentialAddress,
    required this.birthTime,
    required this.backgroundImage,
    required this.headPortrait,
    required this.joinDate,
  });


  // 转换为 Map
  Map<String, dynamic> toMap() {
    return {
        'user_name': userName,
        'name': name,
        'introduction': introduction,
        'residential_address': residentialAddress,
        'birth_time': birthTime,
        'background_image': backgroundImage,
        'head_portrait': headPortrait,
        'join_date': joinDate,
    };
  }
}


Future<void> requestTheOtherPersonalData(String userName) async {
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {'userName': userName};

  final response = await dio.post(
      'http://47.92.90.93:36233/requestOtherPersonalData',
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

    String? backgroundImage;
  String? headPortrait;

  if (personalDataValue['background_image'] != null) {
    final filename = generateRandomFilename();
    List<int> imageBytes = base64.decode(personalDataValue['background_image']);
    backgroundImage = '${dir.path}/$filename';
    await File(backgroundImage).writeAsBytes(imageBytes);
  }

  if (personalDataValue['head_portrait'] != null) {
    final filename = generateRandomFilename();
    List<int> imageBytes = base64.decode(personalDataValue['head_portrait']);
    headPortrait = '${dir.path}/$filename';
    await File(headPortrait).writeAsBytes(imageBytes);
  }
  final otherPersonalMemoryBank = OtherPersonalMemoryBank(
    userName: personalDataValue['user_name'],
    name: personalDataValue['name'],
    headPortrait: headPortrait,
    backgroundImage: backgroundImage,
    introduction: personalDataValue['introduction'],
    residentialAddress: personalDataValue['residential_address'],
    birthTime: personalDataValue['birth_time'],
    joinDate: personalDataValue['join_date'],
  );
  otherPeopleInformationListScrollDataManagement
      .initialScrollData(otherPersonalMemoryBank.toMap());
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
