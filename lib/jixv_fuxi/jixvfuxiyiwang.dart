import 'dart:async';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/cut/cut.dart';
import 'package:yunji/chuangjianjiyiku/jiyiku.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/jixv_fuxi/jixvfuxi_page.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/main/main.dart';

class Jixvfuxiyiwang extends StatefulWidget {
  const Jixvfuxiyiwang({super.key});

  @override
  State<Jixvfuxiyiwang> createState() => _Jixvfuxiyiwang();
}

class _Jixvfuxiyiwang extends State<Jixvfuxiyiwang> {
  final jixvfuxiController = Get.put(JixvFuxiController());
  final settingzhanghaoxiugaicontroller =
      Get.put(Settingzhanghaoxiugaicontroller());

  final NotificationHelper _notificationHelper = NotificationHelper();
  bool message = false;
  bool alarm_information = false;
  List<List<int>> shijian = [
    [0],
    [1, 1],
    [1, 1],
    // [24, 168, 336],
    // [24, 168, 336, 720],
    [24, 168, 336, 720, 2160],
    [24, 168, 336, 720, 2160, 4320],
    [1, 6, 24, 72, 168, 336, 720, 2160, 4320]
  ];
  int _valueChoice = 2;
  List<String> jiyi = [
    '不复习',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n记忆时长超过3个月',
    '[推荐]\n第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n记忆时长超过6个月',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n第5次复习:  第4次复习3个月后\n记忆时长超过1年',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n第5次复习:  第4次复习3个月后\n第6次复习:  第5次复习6个月后\n记忆时长超过2年',
    '(适用于无意义的音节或无逻辑的知识)\n第1次复习:  学习的1个小时后\n第2次复习:  第1次复习6小时后\n第3次复习:  第2次复习1天后\n第4次复习:  第3次复习3天后\n第5次复习:  第4次复习1周后\n第6次复习:  第5次复习2周后\n第7次复习:  第6次复习1个月后\n第8次复习:  第7次复习3个月后\n第9次复习:  第8次复习6个月后'
  ];

  Widget _buildChoiceItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 17.0, top: 16),
      child: ChoiceChip(
        backgroundColor: Colors.white,
        label: Text(
          jiyi[index],
          softWrap: true,
          maxLines: 20,
          style: TextStyle(
            fontSize: 17.0,
            color: _valueChoice == index ? Colors.white : Colors.black54,
          ),
        ),

        selectedColor: Colors.blue, //选中的颜色

        onSelected: (bool selected) {
          setState(() {
            if (selected == true) {
              _valueChoice = index;
            }
          });
        },
        showCheckmark: false,
        selected: _valueChoice == index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              size: 28,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 0, bottom: 0),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "完成",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                onPressed: () async {
                  bool zhuangtai = false;
                  String fanganming = "方案${_valueChoice + 1}";
                  Map<String, String> cishu = jixvfuxiController.cishu
                      .map((key, value) => MapEntry(key.toString(), value));
                  String? stringci;
                  print('循环');
                  for (final entry in cishu.entries) {
                    print(entry.value);
                    if (entry.value == fanganming) {
                      print('以完成');
                      stringci = entry.key;
                      break;
                    }
                  }
                  print('stringci为${stringci}');
                  if (stringci != null) {
                    fanganming = cishu[stringci]!;
                  } else {
                    Map<String, String> cishu1 = {"0": "方案${_valueChoice + 1}"};
                    cishu.addEntries(cishu1.entries);
                  }

                  DateTime now = DateTime.now();
                  // DateTime dingshi =
                  //     now.add(Duration(hours: shijian[_valueChoice][0]));

                  Map<String, String> stringTimu = jixvfuxiController.stringTimu
                      .map((key, value) => MapEntry(key.toString(), value));
                  Map<String, String> stringhuida = jixvfuxiController
                      .stringHuida
                      .map((key, value) => MapEntry(key.toString(), value));
                  DateTime dingshi =
                      now.add(Duration(minutes: shijian[_valueChoice][0]));
                  if (_valueChoice == 0) {
                    zhuangtai = true;
                  } else {
                    if (alarm_information == true) {
                      final alarmSettings = AlarmSettings(
                        id: 42,
                        dateTime: dingshi,
                        assetAudioPath: 'assets/alarm.mp3',
                        loopAudio: true,
                        vibrate: true,
                        volume: 0.6,
                        fadeDuration: 3.0,
                        warningNotificationOnKill: Platform.isIOS,
                        androidFullScreenIntent: true,
                        notificationSettings: NotificationSettings(
                          title: '开始复习 !',
                          body: '记忆库${jixvfuxiController.zhuti}到达预定的复习时间',
                          stopButton: '停止闹钟',
                          icon: 'notification_icon',
                        ),
                      );
                      await Alarm.set(alarmSettings: alarmSettings);
                    }
                    if (message == true) {
                      _notificationHelper.zonedScheduleNotification(
                          id: 2,
                          title: '开始复习 !',
                          body: '记忆库${jixvfuxiController.zhuti}到达预定的复习时间',
                          scheduledDateTime: dingshi);
                    }
                  }
                  xiugaijiyiku(
                      stringTimu,
                      stringhuida,
                      jixvfuxiController.id,
                      jixvfuxiController.zhuti,
                      settingzhanghaoxiugaicontroller.username,
                      shijian[_valueChoice],
                      dingshi,
                      jixvfuxiController.sortedList,
                      message,
                      alarm_information,
                      zhuangtai,
                      cishu,
                      fanganming);

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView(
        children: [
          Row(
            children: [
              SizedBox(width: 5),
              SizedBox(
                height: 30,
                child: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: message,
                    onChanged: (value) {
                      setState(() {
                        message = value;
                      });
                    },
                  ),
                ),
              ),
              Text('信息通知',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(84, 87, 105, 1),
                      fontSize: 17)),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 5),
              SizedBox(
                height: 30,
                child: Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: alarm_information,
                    onChanged: (value) {
                      setState(() {
                        alarm_information = value;
                      });
                    },
                  ),
                ),
              ),
              Text('闹钟信息通知',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(84, 87, 105, 1),
                      fontSize: 17)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(6, (int index) {
              return _buildChoiceItem(index);
            }),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
