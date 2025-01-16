import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yunji/global.dart';
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
  try {
    final imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  } catch (e) {
    // 处理读取文件错误
    print('Error encoding image to Base64: $e');
    return '';
  }
}

Future<void> editPersonal(
  String? name,
  String? introduction,
  String? residentialAddress,
  String? birthTime,
  File? backgroundImage,
  File? headPortrait,
) async {
  try {
    String userName = userNameChangeManagement.userNameValue ?? '';
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
      '$website/editTheUsersPersonalData',
      data: requestData,
      options: Options(headers: header),
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
    } else {
      // 处理非200状态码
      print('Failed to edit personal data: ${response.statusCode}');
    }
  } catch (e) {
    // 处理网络请求错误
    print('Error editing personal data: $e');
  }
}
