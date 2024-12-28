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

Future<String> encodeImageToBase64(File imageFile) async {
  final imageBytes = await imageFile.readAsBytes();
  return base64Encode(imageBytes);
}

Future<void> editPersonal(
  String? userName,
  String? name,
  String? introduction,
  String? residentialAddress,
  String? birthTime,
  File? backgroundImage,
  File? headPortrait,
) async {
  final dio = Dio();
  final headers = {'Content-Type': 'application/json'};

  final requestData = {
    'userName': userName,
    'name': name,
    'introduction': introduction,
    'residentialAddress': residentialAddress,
    'birthTime': birthTime,
    'backgroundImage': backgroundImage != null ? await encodeImageToBase64(backgroundImage) : null,
    'headPortrait': headPortrait != null ? await encodeImageToBase64(headPortrait) : null,
  };

  final response = await dio.post(
    'http://47.92.98.170:36233/editTheUsersPersonalData',
    data: requestData,
    options: Options(headers: headers),
  );

  if (response.statusCode == 200) {
    final backgroundImageValue = backgroundImage?.path ?? backgroundImageChangeManagement.backgroundImageValue?.path;
    final headPortraitValue = headPortrait?.path ?? headPortraitChangeManagement.headPortraitValue?.path;

    final result = EditPersonalData(
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
