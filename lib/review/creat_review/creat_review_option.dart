import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/review/creat_review/creat_review_api.dart';

import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/review/creat_review/creat_review_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/review/creat_review/custom_memory/custom_memory_scheme.dart';
import 'package:yunji/review/notification_init.dart';

// 通用字体大小
const commonFontSize = 17.0;

class CreatReviewOption extends StatefulWidget {
  const CreatReviewOption({super.key});

  @override
  State<CreatReviewOption> createState() => _CreatReviewOption();
}

class _CreatReviewOption extends State<CreatReviewOption> {
  final creatReviewController = Get.put(CreatReviewController());
  final NotificationHelper _notificationHelper = NotificationHelper();
  bool message = false;
  bool alarmInformation = false;
  final List<List<int>> memoryTime = [
    [0],
    [2, 2],
    // [1440,10080,20160],
    [1440, 10080, 20160, 43200],
    [1440, 10080, 20160, 43200, 129600],
    [1440, 10080, 20160, 43200, 129600, 259200],
    [60, 360, 1440, 4320, 10080, 20160, 43200, 129600, 259200]
  ];
  int _valueChoice = 2;

  final List<String> reviewScheme = [
    '不复习',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n记忆时长超过3个月',
    '[推荐]\n第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n记忆时长超过6个月',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n第5次复习:  第4次复习3个月后\n记忆时长超过1年',
    '第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后\n第4次复习:  第3次复习1个月后\n第5次复习:  第4次复习3个月后\n第6次复习:  第5次复习6个月后\n记忆时长超过2年',
    '(适用于无意义的音节或无逻辑的知识)\n第1次复习:  学习的1个小时后\n第2次复习:  第1次复习6小时后\n第3次复习:  第2次复习1天后\n第4次复习:  第3次复习3天后\n第5次复习:  第4次复习1周后\n第6次复习:  第5次复习2周后\n第7次复习:  第6次复习1个月后\n第8次复习:  第7次复习3个月后\n第9次复习:  第8次复习6个月后'
  ];

  Widget _buildChoiceItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 17.0, top: commonFontSize),
      child: ChoiceChip(
        backgroundColor: Colors.white,
        label: Text(
          reviewScheme[index],
          softWrap: true,
          maxLines: 20,
          style: TextStyle(
            fontSize: commonFontSize,
            color: _valueChoice == index ? Colors.white : Colors.black54,
          ),
        ),
        selectedColor: Colors.blue,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _valueChoice = index;
            }
          });
        },
        showCheckmark: false,
        selected: _valueChoice == index,
      ),
    );
  }

  Future<void> _handleCompletion() async {
    bool status = false;
    Map<String, String> reviewRecord = {"0": "方案${_valueChoice + 1}"};
    String reviewSchemeName = "方案${_valueChoice + 1}";
    DateTime now = DateTime.now();

    List<int> questionKey = creatReviewController.question.keys.toList();
    List<int> answerKey = creatReviewController.answer.keys.toList();

    Set<int> combinedSet = {...questionKey, ...answerKey};
    List<int> sortedList = combinedSet.toList()..sort();

    Map<String, String> stringQuestion = creatReviewController.question
        .map((key, value) => MapEntry(key.toString(), value));
    Map<String, String> stringAnswer = creatReviewController.answer
        .map((key, value) => MapEntry(key.toString(), value));

    DateTime setTime = now.add(Duration(minutes: memoryTime[_valueChoice][0]));
    if (_valueChoice == 0) {
      status = true;
    } else {
      if (alarmInformation) {
        final alarmSettings = AlarmSettings(
          id: 42,
          dateTime: setTime,
          assetAudioPath: 'assets/review/alarm.mp3',
          loopAudio: true,
          vibrate: true,
          volume: 0.6,
          fadeDuration: 3.0,
          warningNotificationOnKill: Platform.isIOS,
          androidFullScreenIntent: true,
          notificationSettings: NotificationSettings(
            title: '开始复习 !',
            body: '记忆库${creatReviewController.theme}到达预定的复习时间',
            stopButton: '停止闹钟',
            icon: 'notification_icon',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      }
      if (message) {
        _notificationHelper.zonedScheduleNotification(
            id: 2,
            title: '开始复习 !',
            body: '记忆库${creatReviewController.theme}到达预定的复习时间',
            scheduledDateTime: setTime);
      }
    }
    await creatReview(
        stringQuestion,
        stringAnswer,
        creatReviewController.theme!,
        memoryTime[_valueChoice],
        setTime,
        sortedList,
        message,
        alarmInformation,
        status,
        reviewRecord,
        reviewSchemeName,
        userNameChangeManagement.userNameValue ?? '');

    Navigator.of(context).pop();
    Navigator.of(context).pop();
    switchPage(context, const PersonalPage());
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                "完成",
                style: TextStyle(
                    fontSize: commonFontSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              onPressed: _handleCompletion,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 5),
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
                      const Text('信息通知',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: commonFontSize)),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 5),
                      SizedBox(
                        height: 30,
                        child: Transform.scale(
                          scale: 0.7,
                          child: CupertinoSwitch(
                            value: alarmInformation,
                            onChanged: (value) {
                              setState(() {
                                alarmInformation = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const Text('闹钟信息通知',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: commonFontSize)),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  color: const Color.fromARGB(255, 232, 232, 232),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                        text: TextSpan(children: <TextSpan>[
                      const TextSpan(
                          text: '若需信息或闹钟提醒复习\n',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: commonFontSize)),
                      const TextSpan(
                          text: '需点击打开：',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: commonFontSize)),
                      TextSpan(
                          text: '自启动权限',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                            fontSize: commonFontSize,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.settings);
                            })
                    ])),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          Center(
            child: Image.asset(
              "assets/review/forget_curve.jpg",
              width: double.infinity,
            ),
          ),
          Padding(
            padding:
                EdgeInsets.only(left: 17.0, right: 17.0, top: 15, bottom: 5),
            child: Column(
              children: [
                Text(
                    '艾宾浩斯遗忘曲线表明，学习的知识会随着时间流逝而遗忘，因此随着遗忘曲线复习，将会让更多知识形成长期记忆\n\n过度重复的复习难以坚持，在记忆方案完成后的每次使用知识都可以称为复习，在生活中间断性的使用知识，可达到永久记忆的效果\n',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(84, 87, 105, 1),
                        fontSize: commonFontSize)),
                Row(
                  children: [
                    Expanded(
                      child: Text('请选择您的记忆方案:',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontSize: commonFontSize)),
                     ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.black54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        switchPage(context, const CustomMemoryScheme());
                      },
                      child: Text(
                        '自定义记忆方案',
                        style: TextStyle(
                            color: Colors.black54, fontSize: commonFontSize),
                      ),
                    ),
                    const SizedBox(width: 15),
                  ],
                ),
              ],
            ),
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
