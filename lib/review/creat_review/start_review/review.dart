import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/global.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/review/creat_review/creat_review/creat_review_page.dart';
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
    _controller = TextEditingController(text: _reviewDataManagement.memoryTheme);
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 20),
                  child: Text(
                    '复习',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 10, bottom: 20),
                  child:
                      Text('是否清空所有讲解?', style: const TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '取消',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearAllExplanations,
                        child: const Text(
                          '确定',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 20),
                  child: Text(
                    '复习',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 10, bottom: 20),
                  child:
                      Text('清空还是删除当前讲解?', style: const TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '取消',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                      ),
                      Row(children: [
                        TextButton(
                          onPressed: () {
                            _deleteSpecificExplanation(item);
                          },
                          child: const Text(
                            '删除',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _clearSpecificExplanation(item);
                          },
                          child: const Text(
                            '清空',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.black),
                          ),
                        )
                      ])
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearAllExplanations() {
    setState(() {
      _data.forEach((item) {
        item.answer = ' ';
      });
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
            child: const Icon(Icons.close, size: 30)),
        actions: [
          SizedBox(
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 0, bottom: 0),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "清空讲解",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
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
                  if (theme.isEmpty) {
                    showToast(
                        context,
                        "请填写主题",
                        "主题为空",
                        toast.ToastificationType.success,
                        const Color(0xff047aff),
                        const Color(0xFFEDF7FF));
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
                            body: '记忆库${theme}到达预定的复习时间',
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
                            body: '记忆库${theme}到达预定的复习时间',
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
                        Map<String, String> newEntries = {'${key}': value};
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
                        _reviewDataManagement.reviewSchemeName
                       );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
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
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Text(
              '复读回顾 >> 清空讲解 >> 更加清晰简洁的讲解 >> 遗忘处查漏补缺 >> 完成讲解',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
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
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 17),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Colors.white,
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
            materialGapSize: 15,
            elevation: 0,
            dividerColor: Colors.white,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                backgroundColor: Colors.white,
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
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontSize: 17),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Colors.white,
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 17),
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                          onTap: () {
                            _showDeleteDialog(
                              context,
                              item,
                            );
                          },
                          child: const Icon(
                            color: Color.fromRGBO(134, 134, 134, 1),
                            Icons.remove,
                            size: 26,
                          )),
                      border: InputBorder.none,
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
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
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color.fromRGBO(84, 87, 105, 1)),
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
                child: const Icon(
                  Icons.add,
                  color: Color.fromRGBO(84, 87, 105, 1),
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
        backgroundColor: Colors.blue,
        child: const Text(
          '退出\n键盘',
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    );
  }
}
