// dart包

import 'dart:core';

//依赖包
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;

//项目文件

import 'package:yunji/home/trial_recommendation_algorithm.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/notification_init.dart';

Future<void> requestPermission() async {
  // 请求通知权限
  await Permission.notification.request();
  // 请求精确闹钟权限
  await Permission.scheduleExactAlarm.request();
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
      await databaseManager.queryHomePageMemoryBank();
  // 初始化个人资料
  Map<String, dynamic>? personalData = await databaseManager.chapersonal();

  if (homePageMemoryDatabaseData != null && personalData != null) {
    refreshofHomepageMemoryBankextends
        .updateMemoryRefreshValue(homePageMemoryDatabaseData);
    personaljiyikucontroller.shuaxin(personalData);
    var personalDataValue = personalData;
    loginStatus = true;
    backgroundImageChangeManagement
        .initBackgroundImage(personalDataValue['beijing']);
    headPortraitChangeManagement
        .initHeadPortrait(personalDataValue['touxiang']);
    selectorResultsUpdateDisplay
        .dateOfBirthSelectorResultValueChange(personalDataValue['year']);
    selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
        personalDataValue['place']);
    editPersonalDataValueManagement.changePersonalInformation(
        personalDataValue['name'],
        personalDataValue['brief'],
        personalDataValue['place'],
        personalDataValue['year']);
    editPersonalDataValueManagement
        .applicationDateChange(personalDataValue['jiaru']);
    userNameChangeManagement.userNameChanged(personalDataValue['username']);
    postpersonalapi(userNameChangeManagement.userNameValue);
    await refreshHomePageMemoryBank(contexts!);
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
