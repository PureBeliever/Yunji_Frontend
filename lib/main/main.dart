// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:ui';
import 'dart:io';
import 'dart:math';

import 'package:alarm/alarm.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ali_auth/flutter_ali_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:keframe/keframe.dart';
import 'package:path_provider/path_provider.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/fuxi/fuxi_page.dart';
import 'package:yunji/jixv_fuxi/jixvfuxi_page.dart';
import 'package:yunji/modified_component/ball_indicator.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/chuangjianjiyiku/jiyiku.dart';
import 'package:yunji/jiyikudianji/jiyikudianji.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonal.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/personal/personal_bei.dart';
import 'package:yunji/personal/personal_head.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/setting/setting.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/sql/sqlite.dart';
import '../modified_component/sizeExpansionTileState.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../cut/cut.dart';
import 'package:get/get.dart';
import 'package:app_settings/app_settings.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../chuangjianjiyiku/jiyiku.dart';

class Maincontroller extends GetxController {
  static Maincontroller get to => Get.find();
  List<Map<String, dynamic>>? zhi;

  void mainzhi(List<Map<String, dynamic>>? uio) {
    if (uio != null) {
      zhi = uio.reversed.toList();
      update();
    }
  }
}

class NotificationHelper {
  // 使用单例模式进行初始化
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  // FlutterLocalNotificationsPlugin是一个用于处理本地通知的插件，它提供了在Flutter应用程序中发送和接收本地通知的功能。
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 初始化函数
  Future<void> initialize() async {

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    // 初始化
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> zonedScheduleNotification(
      {required int id,
      required String title,
      required String body,
      required DateTime scheduledDateTime}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your.channel.id', '新信息通知',
            channelDescription: '提醒复习时使用的通知类别',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');

    // ios的通知
    const String darwinNotificationCategoryPlain = 'plainCategory';
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: darwinNotificationCategoryPlain, // 通知分类
    );
    // 创建跨平台通知
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetails);
    // 发起通知
    await _notificationsPlugin.zonedSchedule(
      id, title, body,
      tz.TZDateTime.from(scheduledDateTime, tz.local), 
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.alarmClock, 
    );
  }
}

List<String> lie = [];
final datetimecontroller = Get.put(DateTimeController());
final databaseManager = DatabaseManager();
final bianpersonalController = Get.put(BianpersonalController());
final placecontroller = Get.put(Placecontroller());
final settingzhanghaoxiugaicontroller =
    Get.put(Settingzhanghaoxiugaicontroller());
final beicontroller = Get.put(Beicontroller());
final headcontroller = Get.put(Headcontroller());
final maincontroller = Get.put(Maincontroller());
final jiyikudianjicontroller = Get.put(Jiyikudianjicontroller());
final fuxiController = Get.put(FuxiController());
final jixvfuxiController = Get.put(JixvFuxiController());
final jiyikudianjipersonalController =
    Get.put(JiyikudianjipersonalController());
bool denglu = false;

BuildContext? contexts;

Future<void> requestNotificationPermission() async {
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
}

void main() async {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Alarm.init();
  tz.initializeTimeZones();
  NotificationHelper notificationHelper = NotificationHelper();
  await notificationHelper.initialize();
  requestNotificationPermission();
  await databaseManager.initDatabase();

  List<Map<String, dynamic>>? mainzhi = await databaseManager.chajiyiku();
  Map<String, dynamic>? zhi = await databaseManager.chapersonal();

  if (zhi != null) {
    maincontroller.mainzhi(mainzhi);
    personaljiyikucontroller.shuaxin(zhi);
    var shu = zhi;
    denglu = true;
    beicontroller.chushi(shu['beijing']);
    headcontroller.chushi(shu['touxiang']);
    placecontroller.riqi(shu['year']);
    placecontroller.weizhi(shu['place']);
    bianpersonalController.namevalue(
        shu['name'], shu['brief'], shu['place'], shu['year']);
    bianpersonalController.jiaruvalue(shu['jiaru']);
    settingzhanghaoxiugaicontroller.xiugaiusername(shu['username']);
    postpersonalapi(settingzhanghaoxiugaicontroller.username);
    await shuaxin();
  } else {
    chushi();
  }
}

void chushi() async {
  await AliAuthClient.initSdk(
    authConfig: AuthConfig(
        enableLog: false,
        authUIStyle: AuthUIStyle.alert,
        authUIConfig: const AlertUIConfig(
            alertWindowHeight: 250,
            alertWindowWidth: 360,
            logoConfig: LogoConfig(logoIsHidden: true, logoWidth: 30),
            sloganConfig:
                SloganConfig(sloganIsHidden: true, sloganTextSize: 20),
            phoneNumberConfig: PhoneNumberConfig(numberFontSize: 25),
            loginButtonConfig:
                LoginButtonConfig(loginBtnHeight: 40, loginBtnWidth: 200),
            privacyConfig: PrivacyConfig(privacyConnectTexts: ' ')),
        iosSdk:
            'iXUQkFvwckIqJ1gmASe+DwiFSsvCISFDRcWDn+wnt3DC03ZKs/QQYuItcjCf1u2X7V2UyOC0zLmuODytM6IWR232P4bxsIErwMc9hMxrh+CAPbKWRLsw6X2ecMxT44ykjgaV3HjRermybiluDxV8uHVgEHbJ852Y4VKkvQOgMG/VpnACdQPN9kjB7lIgGjnK76LA49U64ynUqvxKR30x5tiV9DMXJKhkLkDJGBwvBzTruxwLUdHzJFR00futqGp1PLrepZzFFnU=',
        androidSdk:
            '+MTbA7Mr9/7DGkGl5auu/ZyfPOWfhHNF860ms6uc9RoaX175uW0oWxxS35oPmzL6QH2lQSbDNkZ9eh0PryTJP0cZaQ6W2lSgYJ5hOOT1qQwrpCaL1cXYUcIbQy4rHwC+PLavlHX6rfRLrQ8t5LR8saqnD7PtoxS/i+40g6K6iumJd5YlO1ppbHjfpnZNyi/No0d6WjqaR1EA4TkBX5cPBknHLtHIsc/Ic2I4UASnoxspDHNtTakv7nE00WHRH6zL+93ihFYJ4vOBYOuBcMRCVfOjmb0dIOn0t1Dlnxla7NgDtr8fi6gZWg=='),
  );

  AliAuthClient.handleEvent(onEvent: _onEvent);
}

String base64Decodes(String digest) {
  var contentBuffer = base64Decode(digest);
  String content = utf8.decode(contentBuffer);
  return content;
}

bool zhi = true;
Future<void> _onEvent(AuthResponseModel event) async {
  if (event.resultCode == "600024") {
    await AliAuthClient.login();
  }

  if (zhi == true && event.resultCode == "600000") {
    String? uio = event.token;
    shouji(uio!);
    toast.toastification.show(
        context: contexts,
        type: toast.ToastificationType.success,
        style: toast.ToastificationStyle.flatColored,
        title: const Text("右滑可查看个人资料",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        description: const Text(
          "右滑可查看个人资料",
          style: TextStyle(
              color: Color.fromARGB(255, 119, 118, 118),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 10),
        primaryColor: const Color(0xff047aff),
        backgroundColor: const Color(0xffedf7ff), 
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: toast.lowModeShadow,
        dragToClose: true);
    toast.toastification.show(
        context: contexts,
        type: toast.ToastificationType.success,
        style: toast.ToastificationStyle.flatColored,
        title: const Text("登录成功,欢迎您使用本应用！",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        description: const Text(
          "这是一款帮助学习和记忆的应用,希望对您产生帮助",
          style: TextStyle(
              color: Color.fromARGB(255, 119, 118, 118),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        alignment: Alignment.topRight,
        autoCloseDuration: const Duration(seconds: 10),
        primaryColor: const Color(0xff047aff),
        backgroundColor: const Color(0xffedf7ff),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: toast.lowModeShadow,
        dragToClose: true);
    await shuaxin();
    zhi = false;
  } else if (zhi == true &&
      event.resultCode != '600024' &&
      event.resultCode != '600001' &&
      event.resultCode != '600016' &&
      event.resultCode != '600015' &&
      event.resultCode != '600012') {
    duanxinyanzheng();
  }
}

void duanxinyanzheng() {
  String code = ' ';
  bool sendCodeBtn = true;
  int seconds = 60;
  bool shoujifou = false;
  bool cishu = true;
  zhi = false;
  String shoujihao = ' ';
  showTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds--;
      if (seconds == 0) {
        timer.cancel();
        sendCodeBtn = true;
        seconds = 60;
      }
    });
  }

  showDialog(
    context: contexts!,
    builder: (BuildContext context) {
      // ignore: deprecated_member_use
      return WillPopScope(
        onWillPop: () async {
          FocusManager.instance.primaryFocus?.unfocus();
          return false;
        },
        child: Dialog(
            child: SizedBox(
          height: 320,
          width: 200,
          child: Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 8),
                    const Text(
                      '注册登录',
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.clear,
                          color: Colors.black,
                        ))
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  cursorColor: Colors.blue,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  maxLength: 11,
                  onChanged: (value) {
                    shoujihao = value;
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide:
                          const BorderSide(color: Colors.black, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    border: const OutlineInputBorder(),
                    labelText: '手机号',
                    labelStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                    counterText: "",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        cursorColor: Colors.blue,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        maxLength: 4,
                        onChanged: (value) {
                          code = value;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blue, width: 2),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          border: const OutlineInputBorder(),
                          labelText: '验证码',
                          labelStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color.fromARGB(255, 119, 118, 118),
                          ),
                          counterText: "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    TextButton(
                      child: const Text(
                        "获取验证码",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                      onPressed: () {
                        RegExp regex = RegExp(r'^\d*$');
                        if (shoujihao.length < 11) {
                          shoujifou = false;
                          toast.toastification.show(
                              context: context,
                              type: toast.ToastificationType.warning,
                              style: toast.ToastificationStyle.flatColored,
                              title: const Text("手机号位数异常",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17)),
                              description: const Text(
                                "手机号位数异常",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 119, 118, 118),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              alignment: Alignment.topLeft,
                              autoCloseDuration: const Duration(seconds: 4),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: toast.lowModeShadow,
                              dragToClose: true);
                        } else if (!regex.hasMatch(shoujihao)) {
                          shoujifou = false;
                          toast.toastification.show(
                              context: context,
                              type: toast.ToastificationType.warning,
                              style: toast.ToastificationStyle.flatColored,
                              title: const Text("手机号数值异常",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17)),
                              description: const Text(
                                "手机号数值异常",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 119, 118, 118),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              alignment: Alignment.topLeft,
                              autoCloseDuration: const Duration(seconds: 4),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: toast.lowModeShadow,
                              dragToClose: true);
                        } else {
                          if (sendCodeBtn == true) {
                            shoujifou = true;
                            duanxin(shoujihao);
                            toast.toastification.show(
                                context: context,
                                type: toast.ToastificationType.success,
                                style: toast.ToastificationStyle.flatColored,
                                title: const Text("验证码已发送",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17)),
                                description: const Text(
                                  "验证码已发送",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 119, 118, 118),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                alignment: Alignment.topRight,
                                autoCloseDuration: const Duration(seconds: 4),
                                primaryColor: const Color(0xff047aff),
                                backgroundColor: const Color(0xffedf7ff),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: toast.lowModeShadow,
                                dragToClose: true);
                            sendCodeBtn = false;
                            showTimer();
                          } else {
                            toast.toastification.show(
                                context: context,
                                type: toast.ToastificationType.success,
                                style: toast.ToastificationStyle.flatColored,
                                title: Text("需等待$seconds秒",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 17)),
                                description: Text(
                                  "需等待$seconds秒",
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 119, 118, 118),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                alignment: Alignment.topRight,
                                autoCloseDuration: const Duration(seconds: 4),
                                primaryColor: const Color(0xff047aff),
                                backgroundColor: const Color(0xffedf7ff),
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: toast.lowModeShadow,
                                dragToClose: true);
                          }
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Checkbox(
                        value: true,
                        activeColor: Colors.blue,
                        onChanged: (bool? value) {},
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 14),
                          children: [
                            TextSpan(text: '我已阅读并同意'),
                            TextSpan(
                              text: '使用协议',
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: '和'),
                            TextSpan(
                              text: '隐私协议,',
                              style: TextStyle(color: Colors.blue),
                            ),
                            TextSpan(text: '未注册绑定的手机号验证成功后将自动注册')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 5, left: 90, right: 90),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    "验证登录",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  onPressed: () async {
                    if (shoujifou == true &&
                        sendCodeBtn == false &&
                        cishu == true) {
                      bool zhi = await yanzheng(shoujihao, code);
                      cishu = false;
                      if (zhi == false) {
                        toast.toastification.show(
                       
                            context: context,
                            type: toast.ToastificationType.warning,
                            style: toast.ToastificationStyle.flatColored,
                            title: const Text("验证码错误",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                            description: const Text(
                              "验证码错误",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 119, 118, 118),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.topLeft,
                            autoCloseDuration: const Duration(seconds: 4),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: toast.lowModeShadow,
                            dragToClose: true);
                        cishu = true;
                      } else {
                        toast.toastification.show(
                            context: contexts,
                            type: toast.ToastificationType.success,
                            style: toast.ToastificationStyle.flatColored,
                            title: const Text("右滑可查看个人资料",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                            description: const Text(
                              "右滑可查看个人资料",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 119, 118, 118),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.topCenter,
                            autoCloseDuration: const Duration(seconds: 10),
                            primaryColor: const Color(0xff047aff),
                            backgroundColor: const Color(0xffedf7ff),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: toast.lowModeShadow,
                            dragToClose: true);
                        toast.toastification.show(
                            context: contexts,
                            type: toast.ToastificationType.success,
                            style: toast.ToastificationStyle.flatColored,
                            title: const Text("登录成功,欢迎您使用本应用！",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17)),
                            description: const Text(
                              "这是一款帮助学习和记忆的应用,希望对您产生帮助",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 119, 118, 118),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            alignment: Alignment.topCenter,
                            autoCloseDuration: const Duration(seconds: 10),
                            primaryColor: const Color(0xff047aff),
                            backgroundColor: const Color(0xffedf7ff),
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: toast.lowModeShadow,
                            dragToClose: true);
                        Navigator.pop(contexts!);
                        cishu = true;
                        denglu = true;
                      }
                    } else {
                      toast.toastification.show(
                          context: context,
                          type: toast.ToastificationType.warning,
                          style: toast.ToastificationStyle.flatColored,
                          title: const Text("验证码过期",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17)),
                          description: const Text(
                            "验证码过期",
                            style: TextStyle(
                                color: Color.fromARGB(255, 119, 118, 118),
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                          alignment: Alignment.topLeft,
                          autoCloseDuration: const Duration(seconds: 4),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: toast.lowModeShadow,
                          dragToClose: true);
                      cishu = true;
                    }
                  },
                ),
              ],
            ),
          ),
        )),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '云吉记忆',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '主页'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<void> shuaxin() async {
  await Future.delayed(const Duration(seconds: 1));

  Map<String, dynamic> nString = await databaseManager.chaint();

  String numbersString = nString["number"];

  if (numbersString == '[]') {
    int length = nString["length"] + 1;
    numbersString = "[$length]";
  }

  List<int> numberAsList = numbersString
      .replaceAll('[', '')
      .replaceAll(']', '')
      .split(',')
      .map((String num) => int.parse(num.trim()))
      .toList();

  Random random = Random();
  Set<int> randomSelection = {};

  while (randomSelection.length < 100 &&
      randomSelection.length < numberAsList.length) {
    int index = random.nextInt(numberAsList.length);
    randomSelection.add(numberAsList[index]);
  }

  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  List<int> zhiList = randomSelection.toList();
  final response = await dio.post('http://47.92.90.93:36233/getjiyiku',
      data: jsonEncode(zhiList), options: Options(headers: header));

  var data = response.data;
  var result = data["results"];
  var personal = data["personal"];

  if (result.isEmpty) {
    toast.toastification.show(
        context: contexts,
        type: toast.ToastificationType.success,
        style: toast.ToastificationStyle.flatColored,
        title: const Text("暂无更多记忆库",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        description: const Text(
          "让我们一起创建新的记忆库吧！",
          style: TextStyle(
              color: Color.fromARGB(255, 119, 118, 118),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 4),
        primaryColor: const Color(0xff047aff),
        backgroundColor: const Color(0xffedf7ff),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: toast.lowModeShadow,
        dragToClose: true);
  } else {
    String generateRandomFilename() {
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      Random random = Random();
      String randomFileName =
          List.generate(10, (_) => chars[random.nextInt(chars.length)])
              .join('');
      return '$randomFileName.jpg';
    }

    for (int i = 0; i < personal.length; i++) {
      if (personal[i]['beijing'] != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ming = generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['beijing']);
        personal[i]['beijing'] = '${dir.path}/$ming';
        await File(personal[i]['beijing']).writeAsBytes(imageBytes);
      }
      if (personal[i]['touxiang'] != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ming = generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['touxiang']);
        personal[i]['touxiang'] = '${dir.path}/$ming';
        await File(personal[i]['touxiang']).writeAsBytes(imageBytes);
      }

      for (int y = 0; y < result.length; y++) {
        if (result[y]['username'] == personal[i]['username']) {
          result[y]['name'] = personal[i]['name'];
          result[y]['brief'] = personal[i]['brief'];
          result[y]['place'] = personal[i]['place'];
          result[y]['year'] = personal[i]['year'];
          result[y]['beijing'] = personal[i]['beijing'];
          result[y]['touxiang'] = personal[i]['touxiang'];
          result[y]['jiaru'] = personal[i]['jiaru'];
        }
      }
    }

    await databaseManager.insertjiyiku(result);
    List<Map<String, dynamic>>? mainzhi = await databaseManager.chajiyiku();

    maincontroller.mainzhi(mainzhi);
  }

  var count = data["count"];
  List<int> filterweizhi = numberAsList
      .where((number) => !randomSelection.contains(number))
      .toList();

  int lengthjiyi = nString["length"];
  final zuidazhi = count - nString["length"];
  List<int> numbers = List.generate(zuidazhi, (i) => i + lengthjiyi + 1);
  filterweizhi.addAll(numbers);

  await databaseManager.updateint(filterweizhi.toString(), count);
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final headcontroller = Get.put(Headcontroller());
  late TabController tabController;

  Future<void> _refresh() async {
    await shuaxin();
  }

  String timuzhi(String? timu, var xiabiao) {
    if (timu != null) {
      var zhi = jsonDecode(timu);
      var index = xiabiao;

      return zhi.containsKey('${index[0]}') ? zhi['${index[0]}'] : '';
    } else {
      return ' ';
    }
  }

  String huida(String? huida, var xiabiao) {
    if (huida != null) {
      var zhi = jsonDecode(huida);
      var index = xiabiao;

      return zhi.containsKey('${index[0]}') ? zhi['${index[0]}'] : '';
    } else {
      return ' ';
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white, // 状态栏底色
      statusBarBrightness: Brightness.dark, // 状态栏文字颜色
    ));
    contexts = context;
    double chang = MediaQuery.of(context).size.height * 0.055;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: Drawer(
        width: 335,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: Container(
          color: Colors.white,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 26, left: 28, top: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetBuilder<Headcontroller>(
                                  init: headcontroller,
                                  builder: (headcontroller) {
                                    return IconButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          handleClick(
                                              context, const PersonalPage());
                                        },
                                        padding: EdgeInsets.zero,
                                        icon: CircleAvatar(
                                          backgroundColor: Colors.grey,
                                          radius: 23,
                                          backgroundImage:
                                              headcontroller.headimage != null
                                                  ? FileImage(
                                                      headcontroller.headimage!)
                                                  : const AssetImage(
                                                      'assets/chuhui.png'),
                                        ));
                                  }),
                              IconButton(
                                splashColor:
                                    const Color.fromRGBO(145, 145, 145, 1),
                                icon: SvgPicture.asset(
                                  'assets/sunny.svg',
                                  width: 30,
                                  height: 30,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      GetBuilder<BianpersonalController>(
                        init: bianpersonalController,
                        builder: (biancontroller) {
                          return Text(
                            biancontroller.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 21,
                            ),
                          );
                        },
                      ),
                      GetBuilder<Settingzhanghaoxiugaicontroller>(
                          init: settingzhanghaoxiugaicontroller,
                          builder: (settingcontroller) {
                            return Text(
                              '@${settingcontroller.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontSize: 16,
                              ),
                            );
                          }),
                      const SizedBox(height: 11),
                      const Row(
                        children: [
                          Text(
                            '10 ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '正在关注  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '0 ',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '关注者  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(
                        height: 0.3,
                        width: double.infinity,
                        child: Divider(
                          color: Color.fromRGBO(201, 201, 201, 1),
                          thickness: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            handleClick(context, const PersonalPage());
                          },
                          child: ListTile(
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                'assets/gerenziliao.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),

                            title: const Text(
                              '个人资料',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            // 其他ListTile的属性...
                          ),
                        ),
                        InkWell(
                          onTap: () async {},
                          child: ListTile(
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                'assets/huiyuan.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),

                            title: const Text(
                              '会员',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            // 其他ListTile的属性...
                          ),
                        ),
                        InkWell(
                          onTap: () async {},
                          child: ListTile(
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                'assets/shuocang.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),

                            title: const Text(
                              '收藏',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            // 其他ListTile的属性...
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            zhuce();
                          },
                          child: ListTile(
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                'assets/fankui.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),

                            title: const Text(
                              '反馈',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            // 其他ListTile的属性...
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            handleClick(context, const Setting());
                          },
                          child: ListTile(
                            leading: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 5),
                              child: SvgPicture.asset(
                                'assets/settings.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),

                            title: const Text(
                              '设置',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            // 其他ListTile的属性...
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 28, right: 26),
                          child: Divider(
                            // 添加分割线
                            color: Color.fromRGBO(201, 201, 201, 1), // 设置分割线颜色
                            thickness: 0.3, // 设置分割线宽度
                            height: 50,
                          ),
                        ),
                        const Memory()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegateshijian.fixedHeight(
                height: 23,
                child: Material(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 0,
              collapsedHeight: chang,
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              toolbarHeight: chang,
              leading: GetBuilder<Headcontroller>(
                init: headcontroller,
                builder: (hcontroller) {
                  return hcontroller.headimage != null
                      ? IconButton(
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                          icon: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  FileImage(headcontroller.headimage!)))
                      : IconButton(
                          icon: SvgPicture.asset(
                            'assets/person.svg',
                            // 将此处的icon_name替换为您的SVG图标名称
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        );
                },
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
             
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate.fixedHeight(
                height: 40,
                child: Material(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: TabBar(
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Colors.black,
                        fontFamily: 'Raleway',
                        decoration: TextDecoration.none,
                      ),
                      indicatorColor: Colors.blue,
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Color.fromARGB(255, 119, 118, 118),
                        fontFamily: 'Raleway',
                        decoration: TextDecoration.none,
                      ),
                      controller: tabController,
                      tabs: [
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: Center(
                            child: Text(
                              '推荐',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              '正在关注',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 5) {
                  _scaffoldKey.currentState?.openDrawer();
                } else if (details.primaryVelocity! < -5) {
                  tabController.animateTo(1);
                }
              },
              child: BallIndicator(
                  onRefresh: _refresh,
                  ballColors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.amber,
                    Colors.pink,
                    Colors.purple,
                    Colors.cyan,
                    Colors.orange,
                    Colors.yellow,
                  ],
                  child: GetBuilder<Maincontroller>(
                      init: maincontroller,
                      builder: (maincontroller) {
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: SizeCacheWidget(
                            child: ListView.builder(
                                cacheExtent: 500,
                                itemCount: maincontroller.zhi == null
                                    ? 0
                                    : maincontroller.zhi?.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      jiyikudianjicontroller
                                          .cizhi(maincontroller.zhi![index]);
                                      handleClick(
                                          context, const jiyikudianji());
                                    },
                                    child: Column(
                                      children: [
                                        const Divider(
                                          color:
                                              Color.fromRGBO(223, 223, 223, 1),
                                          thickness: 0.9,
                                          height: 0.9,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3.0,
                                              bottom: 3.0,
                                              right: 15,
                                              left: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    jiyikudianjipersonalController
                                                        .cizhi(maincontroller
                                                            .zhi![index]);
                                                    jiyikupostpersonalapi(
                                                        maincontroller
                                                                .zhi![index]
                                                            ['username']);
                                                    handleClick(context,
                                                        const Jiyikudianjipersonal());
                                                  },
                                                  icon: CircleAvatar(
                                                    radius: 21,
                                                    backgroundImage: maincontroller
                                                                    .zhi?[index]
                                                                ['touxiang'] !=
                                                            null
                                                        ? FileImage(File(
                                                            maincontroller
                                                                    .zhi![index]
                                                                ['touxiang']))
                                                        : const AssetImage(
                                                            'assets/chuhui.png'),
                                                  )),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: RichText(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: maincontroller
                                                                              .zhi?[
                                                                          index]
                                                                      ['name'],
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      ' @${maincontroller.zhi?[index]['username']}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ' ·',
                                                          style: TextStyle(
                                                              fontSize: 17,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      84,
                                                                      87,
                                                                      105,
                                                                      1),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900),
                                                        ),
                                                        Text(
                                                          '${maincontroller.zhi?[index]['xiabiao'].length}个记忆项',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromRGBO(
                                                                    84,
                                                                    87,
                                                                    105,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      '${maincontroller.zhi?[index]['zhuti']}',
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      timuzhi(
                                                          maincontroller
                                                                  .zhi?[index]
                                                              ['timu'],
                                                          maincontroller
                                                                  .zhi?[index]
                                                              ['xiabiao']),
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      timuzhi(
                                                          maincontroller
                                                                  .zhi?[index]
                                                              ['huida'],
                                                          maincontroller
                                                                  .zhi?[index]
                                                              ['xiabiao']),
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                      maxLines: 7,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    GetBuilder<
                                                            PersonaljiyikuController>(
                                                        init:
                                                            personaljiyikucontroller,
                                                        builder:
                                                            (personaljiyikuController) {
                                                          return Row(
                                                            children: [
                                                              SizedBox(
                                                                width: 70,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    LikeButton(
                                                                      circleColor: const CircleColor(
                                                                          start: Color.fromARGB(
                                                                              255,
                                                                              42,
                                                                              91,
                                                                              255),
                                                                          end: Color.fromARGB(
                                                                              255,
                                                                              142,
                                                                              204,
                                                                              255)),
                                                                      bubblesColor:
                                                                          const BubblesColor(
                                                                        dotPrimaryColor: Color.fromARGB(
                                                                            255,
                                                                            0,
                                                                            153,
                                                                            255),
                                                                        dotSecondaryColor: Color.fromARGB(
                                                                            255,
                                                                            195,
                                                                            238,
                                                                            255),
                                                                      ),
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinlaqu(
                                                                              maincontroller.zhi?[index]['id'],
                                                                              maincontroller.zhi?[index]['laqu'],
                                                                              maincontroller.zhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          duanxinyanzheng();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushilaqu(
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'id']),
                                                                      likeBuilder:
                                                                          (bool
                                                                              isLiked) {
                                                                        return Icon(
                                                                          isLiked
                                                                              ? Icons.swap_calls
                                                                              : Icons.swap_calls,
                                                                          color: isLiked
                                                                              ? Colors.blue
                                                                              : const Color.fromRGBO(84, 87, 105, 1),
                                                                          size:
                                                                              20,
                                                                        );
                                                                      },
                                                                      likeCount:
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'laqu'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .blue
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
                                                                        );
                                                                        return result;
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Spacer(
                                                                  flex: 1),
                                                              SizedBox(
                                                                width: 70,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    LikeButton(
                                                                      circleColor: const CircleColor(
                                                                          start: Color.fromARGB(
                                                                              255,
                                                                              253,
                                                                              156,
                                                                              46),
                                                                          end: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              174,
                                                                              120)),
                                                                      bubblesColor:
                                                                          const BubblesColor(
                                                                        dotPrimaryColor: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            102,
                                                                            0),
                                                                        dotSecondaryColor: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            212,
                                                                            163),
                                                                      ),
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinshoucang(
                                                                              maincontroller.zhi?[index]['id'],
                                                                              maincontroller.zhi?[index]['shoucang'],
                                                                              maincontroller.zhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          duanxinyanzheng();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushishoucang(
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'id']),
                                                                      likeBuilder:
                                                                          (bool
                                                                              isLiked) {
                                                                        return Icon(
                                                                          isLiked
                                                                              ? Icons.folder
                                                                              : Icons.folder_open,
                                                                          color: isLiked
                                                                              ? Colors.orange
                                                                              : const Color.fromRGBO(84, 87, 105, 1),
                                                                          size:
                                                                              20,
                                                                        );
                                                                      },
                                                                      likeCount:
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'shoucang'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .orange
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
                                                                        );
                                                                        return result;
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Spacer(
                                                                  flex: 1),
                                                              SizedBox(
                                                                width: 70,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    LikeButton(
                                                                      size: 20,
                                                                      circleColor: const CircleColor(
                                                                          start: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              64,
                                                                              64),
                                                                          end: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              206,
                                                                              206)),
                                                                      bubblesColor:
                                                                          const BubblesColor(
                                                                        dotPrimaryColor: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            0,
                                                                            0),
                                                                        dotSecondaryColor: Color.fromARGB(
                                                                            255,
                                                                            255,
                                                                            186,
                                                                            186),
                                                                      ),
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinxihuan(
                                                                              maincontroller.zhi?[index]['id'],
                                                                              maincontroller.zhi?[index]['xihuan'],
                                                                              maincontroller.zhi![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          duanxinyanzheng();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushixihuan(
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'id']),
                                                                      likeBuilder:
                                                                          (bool
                                                                              isLiked) {
                                                                        return Icon(
                                                                          isLiked
                                                                              ? Icons.favorite
                                                                              : Icons.favorite_border,
                                                                          color: isLiked
                                                                              ? Colors.red
                                                                              : const Color.fromRGBO(84, 87, 105, 1),
                                                                          size:
                                                                              20,
                                                                        );
                                                                      },
                                                                      likeCount:
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'xihuan'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .red
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
                                                                        );
                                                                        return result;
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Spacer(
                                                                  flex: 1),
                                                              SizedBox(
                                                                width: 70,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    LikeButton(
                                                                      circleColor: const CircleColor(
                                                                          start: Color.fromARGB(
                                                                              255,
                                                                              237,
                                                                              42,
                                                                              255),
                                                                          end: Color.fromARGB(
                                                                              255,
                                                                              185,
                                                                              142,
                                                                              255)),
                                                                      bubblesColor:
                                                                          const BubblesColor(
                                                                        dotPrimaryColor: Color.fromARGB(
                                                                            255,
                                                                            225,
                                                                            0,
                                                                            255),
                                                                        dotSecondaryColor: Color.fromARGB(
                                                                            255,
                                                                            233,
                                                                            195,
                                                                            255),
                                                                      ),
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxintiwen(
                                                                              maincontroller.zhi?[index]['id'],
                                                                              maincontroller.zhi?[index]['tiwen'],
                                                                              maincontroller.zhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          duanxinyanzheng();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushitiwen(
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'id']),
                                                                      likeBuilder:
                                                                          (bool
                                                                              isLiked) {
                                                                        return Icon(
                                                                          isLiked
                                                                              ? Icons.messenger
                                                                              : Icons.messenger_outline,
                                                                          color: isLiked
                                                                              ? Colors.purpleAccent
                                                                              : const Color.fromRGBO(84, 87, 105, 1),
                                                                          size:
                                                                              20,
                                                                        );
                                                                      },
                                                                      likeCount:
                                                                          maincontroller.zhi?[index]
                                                                              [
                                                                              'tiwen'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .purple
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
                                                                        );
                                                                        return result;
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const Spacer(
                                                                  flex: 1),
                                                              const Spacer(
                                                                  flex: 1),
                                                            ],
                                                          );
                                                        })
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        );
                      })),
            ),
            ListView(
              children: <Widget>[
                for (int i = 0; i < 20; ++i)
                  Container(
                    height: 50,
                    color: i % 2 == 0 ? Colors.blue : Colors.green,
                    child: Center(
                      child: Text(
                        'Item $i',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
          backgroundColor: Colors.blue,
          buttonSize: const Size(60, 60),
          animatedIcon: AnimatedIcons.add_event,
          animatedIconTheme: const IconThemeData(color: Colors.white, size: 28),
          spacing: 12,
          childrenButtonSize: const Size(53, 53),
          shape: const CircleBorder(),
          children: [
            SpeedDialChild(
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/jiyiku.svg',
                  // ignore: deprecated_member_use
                  color: Colors.blue,
                  width: 25,
                  height: 25,
                ),
                backgroundColor: Colors.white,
                label: '创建记忆库',
                labelShadow: List.empty(),
                labelBackgroundColor: Colors.white,
                labelStyle: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.w700),
                onTap: () {
                  if (denglu == false) {
                    duanxinyanzheng();
                    toast.toastification.show(
                        context: contexts,
                        type: toast.ToastificationType.success,
                        style: toast.ToastificationStyle.flatColored,
                        title: const Text("未登录",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        description: const Text(
                          "未登录",
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.topRight,
                        autoCloseDuration: const Duration(seconds: 4),
                        primaryColor: const Color(0xff047aff),
                        backgroundColor: const Color(0xffedf7ff),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: toast.lowModeShadow,
                        dragToClose: true);
                  } else {
                    handleClick(context, const Jiyiku());
                  }
                }),
          ]),
    );
  }
}

class Memory extends StatefulWidget {
  const Memory({super.key});

  @override
  State<Memory> createState() => _Memory();
}

class _Memory extends State<Memory> {
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: const sizeExpansionTile(
            collapsedIconColor: Colors.black,
            iconColor: Colors.blue,
            trailing: null,
            title: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text('记忆分析',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  )),
            ),
            children: [
              ListTile(title: Text('示例')),
              ListTile(title: Text('示例')),
              ListTile(title: Text('示例')),
              ListTile(title: Text('示例')),
              ListTile(title: Text('示例')),
            ]));
  }
}

typedef SliverHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegate({
    required this.maxHeight,
    this.minHeight = 0,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegate.fixedHeight({
    required double height,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        maxHeight = height,
        minHeight = height;

  //需要自定义builder时使用
  SliverHeaderDelegate.builder({
    required this.maxHeight,
    this.minHeight = 0,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);

    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            //阴影

            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 0.3),
                blurRadius: 1.8),
          ],
        ),
        child: SizedBox.expand(child: child));
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}

class SliverHeaderDelegateshijian extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegateshijian({
    required this.maxHeight,
    this.minHeight = 0,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegateshijian.fixedHeight({
    required double height,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        maxHeight = height,
        minHeight = height;

  //需要自定义builder时使用
  SliverHeaderDelegateshijian.builder({
    required this.maxHeight,
    this.minHeight = 0,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);

    return Container(child: SizedBox.expand(child: child));
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegateshijian oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
