import 'dart:core';

//依赖包
import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:yunji/home/algorithm_home_api.dart';

//项目文件
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/global.dart';
import 'package:yunji/home/login/login_init.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/main/main_init/app_sqlite.dart';
import 'package:yunji/main.dart';

Future<void> requestPermission() async {
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
}

void OnRingCallback(String body, int id) {
  showDialog(
    context: contexts!,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SizedBox(
          height: 110,
          width: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/yunji.png',
                width: 100,
                height: 100,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        body,
                        style: const TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 90,
                        height: 35,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey[350],
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Alarm.stop(id);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '停止闹钟',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await _initializeApp();

  final homePageMemoryDatabaseData = await queryHomePageMemoryBank();
  final personalData = await queryPersonalData();
  await refreshHomePageMemoryBank(contexts!);

  if (homePageMemoryDatabaseData != null && personalData != null) {
    _initializeUserData(homePageMemoryDatabaseData, personalData);
  } else {
    soginDependencySettings(contexts!);
  }

  Alarm.ringStream.stream.listen(
      (OnData) => OnRingCallback(OnData.notificationSettings.body, OnData.id));
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

void _initializeUserData(List<Map<String, dynamic>> homePageMemoryDatabaseData,
    Map<String, dynamic> personalData) async {
       final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());
       final editPersonalDataValueManagement =
    Get.put(EditPersonalDataValueManagement());

  refreshofHomepageMemoryBankextends
      .updateMemoryRefreshValue(homePageMemoryDatabaseData);

  loginStatus = true;

  // 初始化背景图和头像
  backgroundImageChangeManagement
      .initBackgroundImage(personalData['background_image']);
  headPortraitChangeManagement.initHeadPortrait(personalData['head_portrait']);

  // 更新选择器结果
  selectorResultsUpdateDisplay
      .dateOfBirthSelectorResultValueChange(personalData['birth_time']);
  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
      personalData['residential_address']);

  // 更新个人信息
  editPersonalDataValueManagement.changePersonalInformation(
    name: personalData['name'],
    profile: personalData['introduction'],
    residentialAddress: personalData['residential_address'],
    dateOfBirth: personalData['birth_time'],
    applicationDate: personalData['join_date'],
  );

  userPersonalInformationManagement
      .requestUserPersonalInformationDataOnTheBackEnd(personalData);

  userNameChangeManagement.userNameChanged(personalData['user_name']);
}

