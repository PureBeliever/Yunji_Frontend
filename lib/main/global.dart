import 'dart:math';

import 'package:flutter/material.dart';
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

// 颜色
Map<String, Color> color = {
  'background': Colors.black,
  'textGray': Color.fromRGBO(84, 87, 105, 1),
  'text': Colors.white,
};

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
