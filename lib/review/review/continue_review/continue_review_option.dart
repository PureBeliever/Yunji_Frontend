import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:yunji/review/notification_init.dart';
import 'package:yunji/review/review/continue_review/continue_review.dart';
import 'package:yunji/review/review/start_review/review_api.dart';
import 'package:yunji/setting/setting_account_user_name.dart';

class ContinueReviewOption extends StatefulWidget {
  const ContinueReviewOption({super.key});

  @override
  State<ContinueReviewOption> createState() => _ContinueReviewOption();
}
class _ContinueReviewOption extends State<ContinueReviewOption> {
  final continueLearningAboutDataManagement = Get.put(ContinueLearningAboutDataManagement());
  final userNameChangeManagement = Get.put(UserNameChangeManagement());

  final NotificationHelper _notificationHelper = NotificationHelper();
  bool message = false;
  bool alarmInformation = false;
  final List<List<int>> reviewTime = [
    [0],
    [1440, 10080, 20160],
    [1440, 10080, 20160, 43200],
    [1440, 10080, 20160, 43200, 129600],
    [1440, 10080, 20160, 43200, 129600, 259200],
    [60, 360, 1440, 4320, 10080, 20160, 43200, 129600, 259200]
  ];
  int _valueChoice = 2;
  final List<String>reviewScheme = [
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
          reviewScheme[index],
          softWrap: true,
          maxLines: 20,
          style: TextStyle(
            fontSize: 17.0,
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

  Future<void> _handleCompleteButtonPress() async {
    bool state = false;
    String reviewSchemeName = "方案${_valueChoice + 1}";
    Map<String, String> reviewRecord = continueLearningAboutDataManagement
        .reviewRecords
        .map((key, value) => MapEntry(key.toString(), value));
    String? reviewRecordKey;

    for (final entry in reviewRecord.entries) {
      if (entry.value == reviewSchemeName) {
        reviewRecordKey = entry.key;
        break;
      }
    }

    if (reviewRecordKey != null) {
      reviewSchemeName = reviewRecord[reviewRecordKey]!;
    } else {
      reviewRecord["0"] = "方案${_valueChoice + 1}";
    }

    DateTime now = DateTime.now();
    Map<String, String> stringQuestion = continueLearningAboutDataManagement
        .problems
        .map((key, value) => MapEntry(key.toString(), value));
    Map<String, String> stringReply = continueLearningAboutDataManagement
        .reply
        .map((key, value) => MapEntry(key.toString(), value));
    DateTime setTime = now.add(Duration(minutes: reviewTime[_valueChoice][0]));

    if (_valueChoice == 0) {
      state = true;
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
            body: '记忆库${continueLearningAboutDataManagement.memoryTheme}到达预定的复习时间',
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
            body: '记忆库${continueLearningAboutDataManagement.memoryTheme}到达预定的复习时间',
            scheduledDateTime: setTime);
      }
    }

    continueReview(
        stringQuestion,
        stringReply,
        continueLearningAboutDataManagement.id,
        continueLearningAboutDataManagement.memoryTheme,
        reviewTime[_valueChoice],
        setTime,
        continueLearningAboutDataManagement.memoryItemIndices,
        message,
        alarmInformation,
        state,
        reviewRecord,
        reviewSchemeName,
        userNameChangeManagement.userNameValue ?? '');

    Navigator.of(context).pop();
    Navigator.of(context).pop();
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
                onPressed: _handleCompleteButtonPress,
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
                      fontSize: 17)),
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
