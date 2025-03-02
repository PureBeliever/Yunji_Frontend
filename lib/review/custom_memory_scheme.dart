import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_module/default_cupertion.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/review/review/creat_review/creat_review_api.dart';
import 'package:yunji/review/review/start_review/review_api.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/review/review/continue_review/continue_review.dart';

class CustomMemoryScheme extends StatefulWidget {
  const CustomMemoryScheme(
      {super.key,
      required this.id,
      required this.question,
      required this.answer,
      required this.theme,
      required this.message,
      required this.alarmInformation,
      required this.continueReview});
  final Map<int, String> question;
  final Map<int, String> answer;
  final String theme;
  final bool message;
  final bool alarmInformation;
  final bool continueReview;
  final int id;
  @override
  State<CustomMemoryScheme> createState() => _CustomMemoryScheme();
}

class Item {
  Item({
    required this.dateByDays,
    required this.dateByMinute,
    required this.numberOfReviews,
  });

  String dateByDays;
  String dateByMinute;
  String numberOfReviews;
}

class _CustomMemoryScheme extends State<CustomMemoryScheme> {
  final notificationHelper = NotificationHelper();
  final _continueLearningAboutDataManagement =
      Get.put(ContinueLearningAboutDataManagement());
  final List<Item> _itemList = [];
  late final Map<int, String> question;
  late final Map<int, String> answer;
  late final String theme;
  late final bool message;
  late final bool alarmInformation;
  late final int id;

  @override
  void initState() {
    super.initState();
    question = widget.question;
    answer = widget.answer;
    theme = widget.theme;
    message = widget.message;
    alarmInformation = widget.alarmInformation;
    id = widget.id;
    now = DateTime.now();

    _itemList.add(Item(
        dateByDays: DateFormat('yyyy年MM月dd日').format(now),
        dateByMinute: DateFormat('HH:mm').format(now),
        numberOfReviews: '：第1次复习'));
  }

  late DateTime now;
  late String dateByDaysSelect = DateFormat('yyyy年MM月dd日').format(now);
  late String dateByMinuteSelect = DateFormat('HH:mm').format(now);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: AppColors.iconColorTwo,
            size: 30,
          ),
        ),
        title: Text(
          '自定义记忆方案',
          style: AppTextStyle.titleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await _handleCompletion();
            },
            child: Icon(
              Icons.check,
              size: 30,
              color: AppColors.iconColorTwo,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              '本次学习后',
              style: AppTextStyle.textStyle,
            ),
          ),
          Expanded(
            child: AnimatedList(
              initialItemCount: _itemList.length + 1,
              itemBuilder: (context, index, animation) {
                if (index == _itemList.length) {
                  return Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        backgroundColor: AppColors.background,
                        side: BorderSide(color: AppColors.Gray),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        setState(() {
                          _itemList.add(Item(
                              dateByDays: DateFormat('yyyy年MM月dd日').format(now),
                              dateByMinute: DateFormat('HH:mm').format(now),
                              numberOfReviews: '：第${_itemList.length + 1}次复习'));
                          AnimatedList.of(context).insertItem(
                              _itemList.length - 1,
                              duration: const Duration(milliseconds: 100));
                        });
                      },
                      child: Icon(
                        Icons.add,
                        color: AppColors.Gray,
                      ),
                    ),
                  );
                } else {
                  return SizeTransition(
                    sizeFactor: animation,
                    child: ListTile(
                      title: _buildItem(_itemList[index]),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() {
                            var removedItem = _itemList.removeAt(index);
                            AnimatedList.of(context).removeItem(
                              index,
                              (context, animation) => SizeTransition(
                                sizeFactor: animation,
                                child: ListTile(
                                  title: _buildItem(removedItem),
                                ),
                              ),
                              duration: const Duration(milliseconds: 100),
                            );
                            for (var i = 0; i < _itemList.length; i++) {
                              _itemList[i].numberOfReviews = '：第${i + 1}次复习';
                            }
                          });
                        },
                        child: Icon(
                          Icons.remove,
                          color: AppColors.Gray,
                          size: 26,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCompletion() async {
    bool status = false;
    Map<String, String> reviewRecord = {"0": "自定义记忆方案"};
    String reviewSchemeName = "自定义记忆方案";

    now = DateTime.now();
    List<int> memoryTime = _itemList.map((element) {
      DateTime elementDate = DateFormat('yyyy年MM月dd日 HH:mm')
          .parse('${element.dateByDays} ${element.dateByMinute}');
      return elementDate.difference(now).inMinutes + 1;
    }).toList();

    List<int> sortedList = {...question.keys, ...answer.keys}.toList()..sort();

    Map<String, String> stringQuestion =
        question.map((key, value) => MapEntry(key.toString(), value));
    Map<String, String> stringAnswer =
        answer.map((key, value) => MapEntry(key.toString(), value));

    DateTime setTime =
        memoryTime.isEmpty ? now : now.add(Duration(minutes: memoryTime[0]));

    if (memoryTime.isEmpty) {
      status = true;
      reviewRecord = {"0": "方案1"};
      reviewSchemeName = "方案1";
    } else {
      int notificationId = widget.continueReview
          ? userPersonalInformationManagement.userReviewMemoryBankIndex
                  .indexOf(_continueLearningAboutDataManagement.id) +
              1
          : userPersonalInformationManagement.userReviewMemoryBankIndex.length +
              1;

      if (alarmInformation) {
        final alarmSettings = AlarmSettings(
          id: notificationId,
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
            body: '记忆库$theme到达预定的复习时间',
            stopButton: '停止闹钟',
            icon: 'notification_icon',
          ),
        );
        await Alarm.set(alarmSettings: alarmSettings);
      }
      if (message) {
        notificationHelper.zonedScheduleNotification(
            id: notificationId,
            title: '开始复习 !',
            body: '记忆库$theme到达预定的复习时间',
            scheduledDateTime: setTime);
      }
    }

    if (widget.continueReview) {
      await continueReview(
          stringQuestion,
          stringAnswer,
          id,
          theme,
          memoryTime,
          setTime,
          sortedList,
          message,
          alarmInformation,
          status,
          reviewRecord,
          reviewSchemeName);
    } else {
      await creatReview(
        stringQuestion,
        stringAnswer,
        theme,
        memoryTime,
        setTime,
        sortedList,
        message,
        alarmInformation,
        status,
        reviewRecord,
        reviewSchemeName,
      );
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    switchPage(context, const PersonalPage());
  }

  Future _buildDatePickerDialog(BuildContext context, Item item,
      {bool isMinutePicker = false}) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: AppColors.background,
          child: SizedBox(
            height: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: AppTextStyle.titleStyle,
                      ),
                    ),
                    child: Localizations.override(
                      context: context,
                      locale: const Locale('en'),
                      delegates: const [
                        MyDefaultCupertinoLocalizations.delegate
                      ],
                      child: CupertinoDatePicker(
                        backgroundColor: AppColors.background,
                        mode: isMinutePicker
                            ? CupertinoDatePickerMode.time
                            : CupertinoDatePickerMode.date,
                        use24hFormat: isMinutePicker,
                        minimumDate: isMinutePicker ? null : now,
                        maximumDate: isMinutePicker
                            ? null
                            : DateTime(now.year + 2, 12, 31),
                        initialDateTime: now,
                        dateOrder:
                            isMinutePicker ? null : DatePickerDateOrder.ymd,
                        onDateTimeChanged: (date) {
                          if (isMinutePicker) {
                            dateByMinuteSelect =
                                DateFormat('HH:mm').format(date);
                          } else {
                            dateByDaysSelect =
                                DateFormat('yyyy年MM月dd日').format(date);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: AppColors.Gray,
                        size: 26,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          if (isMinutePicker) {
                            item.dateByMinute = dateByMinuteSelect;
                          } else {
                            item.dateByDays = dateByDaysSelect;
                          }
                        });
                      },
                      child: Icon(
                        Icons.check,
                        color: AppColors.Gray,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(Item item) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {
            _buildDatePickerDialog(context, item);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: AppColors.background,
            side: BorderSide(color: AppColors.Gray),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0, // 消除阴影
          ),
          child: Text(item.dateByDays, style: AppTextStyle.subsidiaryText),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          onPressed: () {
            _buildDatePickerDialog(context, item, isMinutePicker: true);
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            backgroundColor: AppColors.background,
            side: BorderSide(color: AppColors.Gray),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0, // 消除阴影
          ),
          child: Text(item.dateByMinute, style: AppTextStyle.subsidiaryText),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            item.numberOfReviews,
            style: AppTextStyle.textStyle,
          ),
        ),
      ],
    );
  }
}
