import 'dart:io';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
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
  final otherPeopleInformationListScrollDataManagement =
      Get.put(OtherPeopleInformationListScrollDataManagement());
  final otherPeoplePersonalInformationManagement =
      Get.put(OtherPeoplePersonalInformationManagement());
  final formdata = {'userName': userName};

  try {
    final response = await dio.post(
      '$website/requestOtherPersonalData',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );

    if (response.statusCode == 200) {
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
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
    // 可以在这里添加更多的错误处理逻辑，比如显示错误提示
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
