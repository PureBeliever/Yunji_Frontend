import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/global.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_sqlite.dart';

class PersonalData {
  final String? userName;
  final String? name;
  final String? introduction;
  final String? residentialAddress;
  final String? birthTime;
  final String? backgroundImage;
  final String? headPortrait;
  final String? joinDate;
  final String? likeList;
  final String? collectList;
  final String? pullList;
  final String? reviewList;
  final String? replyList;
  const PersonalData({
    required this.userName,
    required this.name,
    required this.introduction,
    required this.residentialAddress,
    required this.birthTime,
    required this.backgroundImage,
    required this.headPortrait,
    required this.joinDate,
    required this.likeList,
    required this.collectList,
    required this.pullList,
    required this.reviewList,
    required this.replyList,
  });

  Map<String, String?> toMap() => {
        'user_name': userName,
        'name': name,
        'introduction': introduction,
        'residential_address': residentialAddress,
        'birth_time': birthTime,
        'background_image': backgroundImage,
        'head_portrait': headPortrait,
        'join_date': joinDate,
        'like_list': likeList,
        'collect_list': collectList,
        'pull_list': pullList,
        'review_list': reviewList,
        'reply_list': replyList,
      };
}

//请求用户个人资料
Future<void> requestTheUsersPersonalData(String? userName) async {

  final formdata = {'userName': userName};

  try {
    final response = await dio.post(
      '$website/requestUserThePersonalData',
      data: jsonEncode(formdata),
      options: Options(headers: header),
    );

    final beforeDir = await getApplicationDocumentsDirectory();
    final dir = Directory(join(beforeDir.path, 'personalimage'));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    final results = response.data;
    if (results == null || results['personalDataValue'] == null) {
      print('响应数据无效');
      return;
    }

    final personalDataValue = results['personalDataValue'];

    String? backgroundImage =
        await _saveImageToFile(personalDataValue['background_image'], dir);
    String? headPortrait =
        await _saveImageToFile(personalDataValue['head_portrait'], dir);

    final personalData = PersonalData(
      collectList: jsonEncode(personalDataValue['collect_list']),
      pullList: jsonEncode(personalDataValue['pull_list']),
      reviewList: jsonEncode(personalDataValue['review_list']),
      likeList: jsonEncode(personalDataValue['like_list']),
      userName: personalDataValue['user_name'],
      name: personalDataValue['name'],
      introduction: personalDataValue['introduction'],
      residentialAddress: personalDataValue['residential_address'],
      birthTime: personalDataValue['birth_time'],
      backgroundImage: backgroundImage,
      headPortrait: headPortrait,
      joinDate: personalDataValue['join_date'],
      replyList: jsonEncode(personalDataValue['reply_list']),
    );

    await insertPersonalData(personalData);
    _updateDisplay(personalDataValue, backgroundImage, headPortrait);

    if (results['memoryBankResults'] != null) {
      await _processMemoryBankResults(results['memoryBankResults'],
          results['memoryBankPersonalResults'], dir);
      userPersonalInformationManagement
          .requestUserPersonalInformationDataOnTheBackEnd(personalDataValue);
    }
  } catch (e) {
    print('请求用户个人资料时发生错误: $e');
  }
}

Future<String?> _saveImageToFile(String? base64Image, Directory dir) async {
  if (base64Image != null) {
    final filename = generateRandomFilename();
    final imageBytes = base64.decode(base64Image);
    final filePath = '${dir.path}/$filename';
    await File(filePath).writeAsBytes(imageBytes);
    return filePath;
  }
  return null;
}

void _updateDisplay(Map<String, dynamic> personalDataValue,
    String? backgroundImage, String? headPortrait) {
  final editPersonalDataValueManagement =
      Get.put(EditPersonalDataValueManagement());
  final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());
  selectorResultsUpdateDisplay
      .dateOfBirthSelectorResultValueChange(personalDataValue['birth_time']);
  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
      personalDataValue['residential_address']);
  backgroundImageChangeManagement.initBackgroundImage(backgroundImage);
  headPortraitChangeManagement.initHeadPortrait(headPortrait);
  editPersonalDataValueManagement.changePersonalInformation(
    name: personalDataValue['name'],
    profile: personalDataValue['introduction'],
    residentialAddress: personalDataValue['residential_address'],
    dateOfBirth: personalDataValue['birth_time'],
    applicationDate: personalDataValue['join_date'],
  );
  userNameChangeManagement.userNameChanged(personalDataValue['user_name']);
}

Future<void> _processMemoryBankResults(List<dynamic> memoryBankResults,
    List<dynamic> memoryBankPersonalResults, Directory dir) async {
  for (var personalResult in memoryBankPersonalResults) {
    if (personalResult['head_portrait'] != null) {
      final filename = generateRandomFilename();
      final imageBytes = base64.decode(personalResult['head_portrait']);
      personalResult['head_portrait'] = '${dir.path}/$filename';
      await File(personalResult['head_portrait']).writeAsBytes(imageBytes);
    }
    for (var memoryResult in memoryBankResults) {
      if (memoryResult['user_name'] == personalResult['user_name']) {
        memoryResult['name'] = personalResult['name'];
        memoryResult['head_portrait'] = personalResult['head_portrait'];
      }
    }
  }
  await insertUserPersonalMemoryBank(memoryBankResults);
}
