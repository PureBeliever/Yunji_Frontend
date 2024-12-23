import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/personal/personal_sqlite.dart';

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
       
      };
}

//请求用户个人资料
void requestTheUsersPersonalData(String? userName) async {
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {'userName': userName};
  

    final response = await dio.post(
        'http://47.92.90.93:36233/requestUserThePersonalData',
        data: jsonEncode(formdata),
        options: Options(headers: header));
    final beforeDir = await getApplicationDocumentsDirectory();
    final dir = Directory(join(beforeDir.path, 'personalimage'));
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

  final results = PersonalData(
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
     );

  await insertPersonalData(results);
  selectorResultsUpdateDisplay
      .dateOfBirthSelectorResultValueChange(personalDataValue['birth_time']);
  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
      personalDataValue['residential_address']);
  backgroundImageChangeManagement.initBackgroundImage(backgroundImage);
  headPortraitChangeManagement.initHeadPortrait(headPortrait);
  editPersonalDataValueManagement.changePersonalInformation(
    personalDataValue['name'],
    personalDataValue['introduction'],
    personalDataValue['residential_address'],
    personalDataValue['birth_time'],
  );
  userNameChangeManagement.userNameChanged(personalDataValue['user_name']);
  editPersonalDataValueManagement
      .applicationDateChange(personalDataValue['join_date']);

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

      await insertUserPersonalMemoryBank(memoryBankResults);
      userPersonalInformationManagement
          .requestUserPersonalInformationDataOnTheBackEnd(personalDataValue);
    }



}