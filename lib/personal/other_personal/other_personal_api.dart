import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/main/app/app_global_variable.dart';
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

  final formdata = {'userName': userName};

  final response = await dio.post(
    'http://47.92.98.170:36233/requestOtherPersonalData',
    data: jsonEncode(formdata),
    options: Options(headers: header),
  );


  final dir = await _prepareDirectory();

  final results = response.data;
  final personalDataValue = results['personalDataValue'];

  final backgroundImage = await _processImage(
    dir,
    personalDataValue['background_image'],
  );
  final headPortrait = await _processImage(
    dir,
    personalDataValue['head_portrait'],
  );

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

  if (results['memoryBankResults'] != null) {
    await _processMemoryBankResults(
      dir,
      List<Map<String, dynamic>>.from(results['memoryBankResults'] ?? []),
      List<Map<String, dynamic>>.from(
          results['memoryBankPersonalResults'] ?? []),
    );

    await otherPeoplePersonalInformationManagement
        .requestOtherPeoplePersonalInformationDataOnTheBackEnd(
            personalDataValue);

  }
}

Future<Directory> _prepareDirectory() async {
  final beforeDir = await getApplicationDocumentsDirectory();
  final dir = Directory(join(beforeDir.path, 'otherPersonalImage'));
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);
  return dir;
}

Future<String?> _processImage(Directory dir, String? base64Image) async {
  if (base64Image == null) return null;
  final filename = generateRandomFilename();
  final imageBytes = base64.decode(base64Image);
  final imagePath = '${dir.path}/$filename';
  await File(imagePath).writeAsBytes(imageBytes);
  return imagePath;
}

Future<void> _processMemoryBankResults(
  Directory dir,
  List<Map<String, dynamic>> memoryBankResults,
  List<Map<String, dynamic>> memoryBankPersonalResults,
) async {
  for (var personalResult in memoryBankPersonalResults) {
    if (personalResult['head_portrait'] != null) {
      personalResult['head_portrait'] = await _processImage(
        dir,
        personalResult['head_portrait'],
      );
    }

    for (var memoryResult in memoryBankResults) {
      if (memoryResult['user_name'] == personalResult['user_name']) {
        memoryResult['name'] = personalResult['name'];
        memoryResult['head_portrait'] = personalResult['head_portrait'];
      }
    }
  }

  await insertOtherPeoplePersonalMemoryBank(memoryBankResults);
}
