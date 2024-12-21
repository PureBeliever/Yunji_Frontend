// dart包

import 'dart:core';

//依赖包
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

//项目文件
import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/home_sqlite.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/notification_init.dart';
import 'package:yunji/personal/personal/personal_api.dart';



Future<void> requestPermission() async {
  // 请求通知权限
  await Permission.notification.request();
  // 请求精确闹钟权限
  await Permission.scheduleExactAlarm.request();
}
  Future<Map<String, dynamic>?> chapersonal() async {
    final db = databaseManager.database;

    final List<Map<String, dynamic>> personalMaps = await db!.query('personal_data');

    return personalMaps.isEmpty ? null : personalMaps[0];
  }
void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  // 请求权限
  await requestPermission();
  // 初始化闹钟
  await Alarm.init();
  // 初始化时区
  tz.initializeTimeZones();
  // 初始化通知
  NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  // 初始化数据库
  await databaseManager.initDatabase();
  // 初始化主页记忆库
  List<Map<String, dynamic>>? homePageMemoryDatabaseData =
      await queryHomePageMemoryBank();


  // 初始化个人资料

  Map<String, dynamic>? personalData = await chapersonal();

  if (homePageMemoryDatabaseData != null && personalData != null) {
    refreshofHomepageMemoryBankextends
        .updateMemoryRefreshValue(homePageMemoryDatabaseData);

    var personalDataValue = personalData;
    loginStatus = true;
    backgroundImageChangeManagement
        .initBackgroundImage(personalDataValue['background_image']);
    headPortraitChangeManagement
        .initHeadPortrait(personalDataValue['head_portrait']);
    selectorResultsUpdateDisplay
        .dateOfBirthSelectorResultValueChange(personalDataValue['birth_time']);
    selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
        personalDataValue['residential_address']);
    editPersonalDataValueManagement.changePersonalInformation(
        personalDataValue['name'],
        personalDataValue['introduction'],
        personalDataValue['residential_address'],
        personalDataValue['birth_time']);
    editPersonalDataValueManagement
        .applicationDateChange(personalDataValue['join_date']);
    userNameChangeManagement.userNameChanged(personalDataValue['user_name']);
    requestTheUsersPersonalData(userNameChangeManagement.userNameValue);
    // await refreshHomePageMemoryBank(contexts!);
  } else {
    soginDependencySettings(contexts!);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '云忆',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomePage(title: '主页'),
    );
  }
}
