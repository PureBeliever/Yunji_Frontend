import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yunji/main/main_init/sqlite_init.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/setting/setting_user/setting_user.dart';

// 登录状态
bool loginStatus = false;

Future<void> saveLoginStatus(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('color', status);
}

Future<bool> getLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('color') ?? false; // 默认值为false
}

Future<void> initializeNightMode() async {
  bool isNight = await getLoginStatus();
  AppColors.isNight = isNight;
}

class AppColors {
  static bool isNight = false;
  static Color get background =>
      isNight ? Color.fromRGBO(42, 42, 42, 1) : Colors.white;
  static Color get textGray => isNight
      ? Color.fromRGBO(115, 115, 115, 1)
      : Color.fromRGBO(84, 87, 105, 1);
  static Color get divider => isNight
      ? Color.fromRGBO(115, 115, 115, 1)
      : Color.fromRGBO(84, 87, 105, 1);
  static Color get text => isNight ? Colors.white : Colors.black;
  static Color get svg => isNight
      ? Color.fromRGBO(115, 115, 115, 1)
      : Color.fromRGBO(84, 87, 105, 1);
  static Brightness get statusBarBrightness =>
      isNight ? Brightness.dark : Brightness.light;
}

class AppTextStyle {
  static TextStyle get textStyle => TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      );
  static TextStyle get titleStyle => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: AppColors.text,
      );
}

final header = {'Content-Type': 'application/json'};

const website = 'http://47.92.98.170:36233';

final dio = Dio();
// 数据库管理
final databaseManager = DatabaseManager();
final db = databaseManager.database;
// 用户名管理
final userNameChangeManagement = Get.put(UserNameChangeManagement());

// 背景图管理
final backgroundImageChangeManagement =
    Get.put(BackgroundImageChangeManagement());

// 头像管理
final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());

// 主页记忆库刷新
final refreshofHomepageMemoryBankextends =
    Get.put(RefreshofHomepageMemoryBankextends());

// 用户个人信息管理
final userPersonalInformationManagement =
    Get.put(UserPersonalInformationManagement());

String generateRandomFilename() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return '${List.generate(10, (_) => chars[random.nextInt(chars.length)]).join('')}.jpg';
}
