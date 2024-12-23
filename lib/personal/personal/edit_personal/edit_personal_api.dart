import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_sqlite.dart';

class EditPersonalData {
  final String? userName;
  final String? name;
  final String? introduction;
  final String? residentialAddress;
  final String? birthTime;
  final String? backgroundImage;
  final String? headPortrait;

  const EditPersonalData({
    required this.userName,
    required this.name,
    required this.introduction,
    required this.residentialAddress,
    required this.birthTime,
    required this.backgroundImage,
    required this.headPortrait,
  });

  Map<String, String?> toMap() {
    return {
      'user_name': userName,
      'name': name,
      'introduction': introduction,
      'residential_address': residentialAddress,
      'birth_time': birthTime,
      'background_image': backgroundImage,
      'head_portrait': headPortrait,
    };
  }
}

Future<String> imageFile(File imageFile) async {
  List<int> imageBytes = await imageFile.readAsBytes();
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}

void editPersonal(
    String? userName,
    String? name,
    String? introduction,
    String? residentialAddress,
    String? birthTime,
    File? backgroundImage,
    File? headPortrait) async {
  final dio = Dio();
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> requestData = ({
    'userName': userName,
    'name': name,
    'introduction': introduction,
    'residentialAddress': residentialAddress,
    'birthTime': birthTime,
    'backgroundImage':
        backgroundImage == null ? null : await imageFile(backgroundImage),
    'headPortrait': headPortrait == null ? null : await imageFile(headPortrait)
  });

  final response = await dio.post('http://47.92.90.93:36233/editTheUsersPersonalData',
      data: requestData, options: Options(headers: header));

  if (response.statusCode == 200) {
    String? backgroundImageValue =
        backgroundImageChangeManagement.backgroundImageValue?.path;
    String? headPortraitValue =
        headPortraitChangeManagement.headPortraitValue?.path;
    if (backgroundImage != null) {
      backgroundImageValue = backgroundImage.path;
    }
    if (headPortrait != null) {
      headPortraitValue = headPortrait.path;
    }

    var result = EditPersonalData(
      userName: userName,
      name: name,
      introduction: introduction,
      residentialAddress: residentialAddress,
      birthTime: birthTime,
      backgroundImage: backgroundImageValue,
      headPortrait: headPortraitValue,
    );
    updatePersonal(result);
  }
}
