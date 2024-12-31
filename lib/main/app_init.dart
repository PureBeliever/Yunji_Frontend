// dart包

import 'dart:core';

//依赖包
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:yunji/home/algorithm_home_api.dart';

//项目文件
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/home_sqlite.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

Future<void> requestPermission() async {
  // 请求通知权限
  await Permission.notification.request();
  // 请求精确闹钟权限
  await Permission.scheduleExactAlarm.request();
}

Future<Map<String, dynamic>?> chapersonal() async {
  final db = databaseManager.database;

  final List<Map<String, dynamic>> personalMaps =
      await db!.query('personal_data');
  return personalMaps.isEmpty ? null : personalMaps[0];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await _initializeApp();
  
  final homePageMemoryDatabaseData = await queryHomePageMemoryBank();
  final personalData = await chapersonal(); 
  await refreshHomePageMemoryBank(contexts!);

  if (homePageMemoryDatabaseData != null && personalData != null) {
    _initializeUserData(homePageMemoryDatabaseData, personalData);
    requestTheUsersPersonalData(userNameChangeManagement.userNameValue);
  } else {
    soginDependencySettings(contexts!);
  }
}

Future<void> _initializeApp() async {
  await Future.wait([
    requestPermission(),
    Alarm.init(),
    databaseManager.initDatabase(),
    _initializeNotification(),
  ]);
  tz.initializeTimeZones();
}

Future<void> _initializeNotification() async {
  final notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
}

void _initializeUserData(List<Map<String, dynamic>> homePageMemoryDatabaseData, Map<String, dynamic> personalData) {
  refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(homePageMemoryDatabaseData);

  loginStatus = true;
  backgroundImageChangeManagement.initBackgroundImage(personalData['background_image']);
  headPortraitChangeManagement.initHeadPortrait(personalData['head_portrait']);
  selectorResultsUpdateDisplay.dateOfBirthSelectorResultValueChange(personalData['birth_time']);
  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(personalData['residential_address']);
  editPersonalDataValueManagement.changePersonalInformation(
    name: personalData['name'],
    profile: personalData['introduction'],
    residentialAddress: personalData['residential_address'],
    dateOfBirth: personalData['birth_time'],
    applicationDate: personalData['join_date'],
  );

  userNameChangeManagement.userNameChanged(personalData['user_name']);

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
