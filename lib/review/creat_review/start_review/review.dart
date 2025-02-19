import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/dialog.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/review/creat_review/start_review/review_api.dart';
import 'package:yunji/review/notification_init.dart';

class Item {
  Item({
    required this.answer,
    required this.question,
    this.isExpanded = true,
  });

  String answer;
  String question;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> subscript,
    Map<String, dynamic> question, Map<String, dynamic> answer) {
  return List<Item>.generate(
      numberOfItems,
      (index) => Item(
            question: question[subscript[index].toString()] ?? '',
            answer: answer[subscript[index].toString()] ?? '',
          ));
}

class ReviewDataManagement extends GetxController {
  static ReviewDataManagement get to => Get.find();

  Map<String, dynamic> memoryBankData = {};
  int memoryCount = 0;
  List<int> memoryIndices = [];
  Map<String, dynamic> questions = {};
  Map<String, dynamic> answer = {};
  String memoryTheme = '';
  List<dynamic> reviewScheme = [];
  Map<String, dynamic> reviewCounts = {};
  bool isMessageNotificationEnabled = false;
  bool isAlarmNotificationEnabled = false;
  bool isReviewComplete = false;
  String reviewSchemeName = '';
  int memoryBankId = -1;

  void initMemoryData(Map<String, dynamic> data) {
    memoryBankId = data['id'];
    memoryBankData = data;
    memoryTheme = data['theme'];
    memoryCount = data['subscript'].length;
    memoryIndices = data['subscript'];
    questions = jsonDecode(data['question']);
    answer = jsonDecode(data['answer']);
    reviewScheme = jsonDecode(data['memory_time']);
    reviewCounts = jsonDecode(data['review_record']);
    isMessageNotificationEnabled = data['information_notification'] == 1;
    isAlarmNotificationEnabled = data['alarm_notification'] == 1;
    isReviewComplete = data['complete_state'] == 1;
    reviewSchemeName = data['review_scheme_name'];
  }
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  final _reviewDataManagement = Get.put(ReviewDataManagement());
  final NotificationHelper _notificationHelper = NotificationHelper();
  final FocusNode _focusNode = FocusNode();
  late List<Item> _data;
  late TextEditingController _controller;
  late String theme;
  late bool message;
  late bool alarmInformation;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _data = generateItems(
      _reviewDataManagement.memoryCount,
      _reviewDataManagement.memoryIndices,
      _reviewDataManagement.questions,
      _reviewDataManagement.answer,
    );
    _controller =
        TextEditingController(text: _reviewDataManagement.memoryTheme);
    theme = _reviewDataManagement.memoryTheme;
    message = _reviewDataManagement.isMessageNotificationEnabled;
    alarmInformation = _reviewDataManagement.isAlarmNotificationEnabled;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showClearDialog(BuildContext context) {
    buildDialog(
        context: context,
        title: '复习',
        content: '是否清空所有讲解?',
        onConfirm: _clearAllExplanations,
        buttonRight: '确定');
  }

  void _showDeleteDialog(BuildContext context, Item item) {
    dialogTwoButton(
        context: context,
        title: '复习',
        message: '是否删除当前讲解?',
        onConfirmLifeMode: () => _deleteSpecificExplanation(item),
        onConfirmRightMode: () => _clearSpecificExplanation(item),
        buttonLeft: '删除',
        buttonRight: '清空');
  }

  void _clearAllExplanations() {
    setState(() {
      for (var item in _data) {
        item.answer = ' ';
      }
    });
    Navigator.of(context).pop();
  }

  void _clearSpecificExplanation(Item item) {
    setState(() {
      item.answer = '';
    });
    Navigator.of(context).pop();
  }

  void _deleteSpecificExplanation(Item item) {
    setState(() {
      _data.remove(item);
    });
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
            child: Icon(Icons.close, size: 30, color: AppColors.iconColorTwo)),
        actions: [
          SizedBox(
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 0, bottom: 0),
                backgroundColor: AppColors.iconColorThree,
              ),
              child: Text(
                "清空讲解",
                style: AppTextStyle.whiteTextStyle,
              ),
              onPressed: () {
                _showClearDialog(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 0, bottom: 0),
                  backgroundColor: AppColors.iconColor,
                ),
                child: Text(
                  "完成",
                  style: AppTextStyle.whiteTextStyle,
                ),
                onPressed: () async {
                  if (theme.isEmpty) {
                    showToast(
                      context,
                      "请填写主题",
                      "主题为空",
                    );
                    FocusScope.of(context).requestFocus(_focusNode);
                  } else {
                    int value = 0;
                    Map<int, String> stringQuestion = {};
                    Map<int, String> stringAnswer = {};
                    DateTime setTime = DateTime.now();
                    List<int> memoryScheme =
                        List.from(_reviewDataManagement.reviewScheme);
                    memoryScheme.removeAt(0);
                    Map<String, String> numberOfReviews = _reviewDataManagement
                        .reviewCounts
                        .map((key, value) => MapEntry(key.toString(), value));

                    List<int> sortedList = [];

                    for (var data in _data) {
                      if (data.question.isNotEmpty || data.answer.isNotEmpty) {
                        sortedList.add(value);
                        stringQuestion[value] = data.question;
                        stringAnswer[value] = data.answer;
                        value++;
                      }
                    }
                    Map<String, String> question = stringQuestion
                        .map((key, value) => MapEntry(key.toString(), value));
                    Map<String, String> answer = stringAnswer
                        .map((key, value) => MapEntry(key.toString(), value));

                    bool completeReviewStatus =
                        _reviewDataManagement.isReviewComplete;

                    if (memoryScheme.isNotEmpty) {
                      setTime = setTime.add(Duration(minutes: memoryScheme[0]));
                      if (alarmInformation) {
                        final alarmSettings = AlarmSettings(
                          id: userPersonalInformationManagement
                                  .userReviewMemoryBankIndex
                                  .indexOf(_reviewDataManagement.memoryBankId) +
                              1,
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
                        _notificationHelper.zonedScheduleNotification(
                            id: userPersonalInformationManagement
                                    .userReviewMemoryBankIndex
                                    .indexOf(
                                        _reviewDataManagement.memoryBankId) +
                                1,
                            title: '开始复习 !',
                            body: '记忆库$theme到达预定的复习时间',
                            scheduledDateTime: setTime);
                      }
                    } else {
                      completeReviewStatus = true;
                      String memorySchemeName =
                          _reviewDataManagement.reviewSchemeName;
                      String? stringFrequency;
                      for (final entry in numberOfReviews.entries) {
                        if (entry.value == memorySchemeName) {
                          stringFrequency = entry.key;
                          break;
                        }
                      }
                      if (stringFrequency != null) {
                        int frequency = int.parse(stringFrequency);
                        int key = frequency + 1;
                        String value = numberOfReviews[stringFrequency] ?? ' s';
                        Map<String, String> newEntries = {'$key': value};
                        numberOfReviews.remove(stringFrequency);
                        numberOfReviews.addEntries(newEntries.entries);
                      }
                    }

                    continueReview(
                        question,
                        answer,
                        _reviewDataManagement.memoryBankId,
                        theme,
                        memoryScheme,
                        setTime,
                        sortedList,
                        message,
                        alarmInformation,
                        completeReviewStatus,
                        numberOfReviews,
                        _reviewDataManagement.reviewSchemeName);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
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
                  Text('信息通知', style: AppTextStyle.textStyle),
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
                  Text('闹钟信息通知', style: AppTextStyle.textStyle),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Text(
              '复读回顾 >> 清空讲解 >> 更加清晰简洁的讲解 >> 遗忘处查漏补缺 >> 完成讲解',
              style: AppTextStyle.textStyle,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 15, top: 50, bottom: 0),
            child: TextField(
              onChanged: (value) {
                theme = value;
              },
              focusNode: _focusNode,
              controller: _controller,
              maxLength: 50,
              style: AppTextStyle.textStyle,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: AppColors.background,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0x00FF0000)),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0x00000000)),
                  borderRadius: BorderRadius.all(
                    Radius.circular(100),
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          ExpansionPanelList(
            materialGapSize: 17,
            expandIconColor: AppColors.Gray,
            elevation: 0,
            dividerColor: AppColors.background,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                backgroundColor: AppColors.background,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return ListTile(
                    title: TextField(
                      onChanged: (value) {
                        item.question = value;
                      },
                      controller: TextEditingController(text: item.question),
                      maxLength: 150,
                      maxLines: 10,
                      minLines: 1,
                      style: AppTextStyle.textStyle,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: AppColors.background,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00FF0000)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0x00000000)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                        contentPadding: EdgeInsets.all(0),
                      ),
                    ),
                  );
                },
                body: ListTile(
                  contentPadding: const EdgeInsets.only(left: 5, right: 10),
                  title: TextField(
                    onChanged: (value) {
                      item.answer = value;
                    },
                    controller: TextEditingController(text: item.answer),
                    maxLength: 1500,
                    maxLines: 30,
                    minLines: 1,
                    style: AppTextStyle.textStyle,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _showDeleteDialog(
                              context,
                              item,
                            );
                          },
                          child: Icon(
                            color: AppColors.Gray,
                            Icons.remove,
                            size: 26,
                          )),
                      border: InputBorder.none,
                      counterText: "",
                      filled: true,
                      fillColor: AppColors.background,
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00FF0000)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
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
                    _data.add(Item(question: '', answer: '', isExpanded: true));
                  });
                },
                child: Icon(
                  Icons.add,
                  color: AppColors.iconColor,
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        elevation: 5.0,
        highlightElevation: 20.0,
        backgroundColor: AppColors.iconColor,
        child: Text(
          '退出\n键盘',
          style: AppTextStyle.whiteTextStyle,
        ),
      ),
    );
  }
}
