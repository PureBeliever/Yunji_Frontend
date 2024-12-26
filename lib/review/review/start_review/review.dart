import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/review/creat_review/creat_review_page.dart';
import 'package:yunji/review/review/start_review/review_api.dart';
import 'package:yunji/review/notification_init.dart';

class Item {
  Item({
    required this.reply,
    required this.question,
    this.isExpanded = true,
  });

  String reply;
  String question;

  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> subscript,
    Map<String, dynamic> question, Map<String, dynamic> reply) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      question: question['${subscript[index]}'] ?? '',
      reply: reply['${subscript[index]}'] ?? '',
    );
  });
}

// 复习数据管理
class ReviewTheDataManagementOfMemoryBank extends GetxController {
  static ReviewTheDataManagementOfMemoryBank get to => Get.find();

  // 记忆库数据
  Map<String, dynamic> memoryBankDataValue = {};
  
  // 记忆库数量
  int numberOfMemories = 0;
  
  // 记忆库下标
  List<int> theIndexValueOfTheMemoryItem = List.empty();
  
  // 题目
  Map<String, dynamic> theNumberOfProblems = {};

  // 答案
  Map<String, dynamic> theNumberOfAnswers = {};

  // 记忆库标题
  String theTitleOfTheMemory = '';

  // 记忆库复习方案
  List<dynamic> memoryScheme = [];

  // 记忆库复习次数
  Map<String, dynamic> numberOfReviews = {};

  // 消息通知状态
  bool messageNotificationStatus = false;

  // 闹钟通知状态
  bool alarmInformationStatus = false;

  // 完成复习状态
  bool completeReviewStatus = false;

  // 记忆库复习方案名称
  String memorySchemeName = ' ';

  // 记忆库id
  int id = -1;

  void initTheMemoryData(Map<String, dynamic> memoryBankData) {
    id = memoryBankData['memory_bank_id'];
    memoryBankDataValue = memoryBankData;
    theTitleOfTheMemory = memoryBankData['theme'];
    numberOfMemories = memoryBankData['subscript'].length;
    theIndexValueOfTheMemoryItem = memoryBankData['subscript'];
    theNumberOfProblems = jsonDecode(memoryBankData['question']);
    theNumberOfAnswers = jsonDecode(memoryBankData['reply']);
    memoryScheme = jsonDecode(memoryBankData['memory_time']);
    numberOfReviews = jsonDecode(memoryBankData['review_record']);
    messageNotificationStatus = memoryBankData['information_notification'] == 1 ? true : false;
    alarmInformationStatus = memoryBankData['alarm_notification'] == 1 ? true : false;
    completeReviewStatus = memoryBankData['complete_state'] == 1 ? true : false;
    memorySchemeName = memoryBankData['review_scheme_name'];
  }

  void refreshExpansionTile() {
    update();
  }
}

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPage();
}

class _ReviewPage extends State<ReviewPage> {
  final NotificationHelper _notificationHelper = NotificationHelper();

  final FocusNode _focusNode = FocusNode();
  final List<Item> _data = generateItems(
      reviewTheDataManagementOfMemoryBank.numberOfMemories,
      reviewTheDataManagementOfMemoryBank.theIndexValueOfTheMemoryItem,
      reviewTheDataManagementOfMemoryBank.theNumberOfProblems,
      reviewTheDataManagementOfMemoryBank.theNumberOfAnswers);
  final _controller = TextEditingController(
      text: reviewTheDataManagementOfMemoryBank.theTitleOfTheMemory);
  String theme = reviewTheDataManagementOfMemoryBank.theTitleOfTheMemory;
  bool message = reviewTheDataManagementOfMemoryBank.messageNotificationStatus;
  bool alarm_information =
      reviewTheDataManagementOfMemoryBank.alarmInformationStatus;
  final creatReviewController = Get.put(CreatReviewController());

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _focusNode.requestFocus();
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
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25, top: 10, bottom: 20),
                              child: Text('是否清空所有讲解?',
                                  style: TextStyle(fontSize: 16)),
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
                                    onPressed: () {
                                      setState(() {
                                        _data.forEach((item) {
                                          item.reply = ' ';
                                        });
                                      });

                                      Navigator.of(context).pop();
                                    },
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
                  if (theme.length == 0) {
                    toast.toastification.show(
                        context: context,
                        type: toast.ToastificationType.success,
                        style: toast.ToastificationStyle.flatColored,
                        title: const Text("请填写主题",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        description: const Text(
                          "主题为空",
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.topCenter,
                        autoCloseDuration: const Duration(seconds: 4),
                        primaryColor: const Color(0xff047aff),
                        backgroundColor: const Color(0xffedf7ff),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: toast.lowModeShadow,
                        dragToClose: true);
                    FocusScope.of(context).requestFocus(_focusNode);
                  } else {
                    int zhi = 0;
                    Map<int, String> stringQuestion = {};
                    Map<int, String> stringReply = {};
                    DateTime setTime = DateTime.now();
                    List<int> memoryScheme = List.from(
                        reviewTheDataManagementOfMemoryBank.memoryScheme);
                    memoryScheme.removeAt(0);
                    Map<String, String> numberOfReviews =
                        reviewTheDataManagementOfMemoryBank.numberOfReviews.map(
                            (key, value) => MapEntry(key.toString(), value));

                    List<int> sortedList = [];

                    _data.forEach((uio) {
                      sortedList.add(zhi);
                      stringQuestion[zhi] = uio.question;
                      stringReply[zhi] = uio.reply;
                      zhi++;
                    });
                    Map<String, String> question = stringQuestion
                        .map((key, value) => MapEntry(key.toString(), value));
                    Map<String, String> reply = stringReply
                        .map((key, value) => MapEntry(key.toString(), value));

                    bool completeReviewStatus = reviewTheDataManagementOfMemoryBank
                        .completeReviewStatus;

                    if (memoryScheme.isNotEmpty) {
                      // dingshi = dingshi.add(Duration(hours: code[0]));
                      setTime = setTime.add(Duration(minutes: memoryScheme[0]));
                      if (alarm_information == true) {
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
                            body: '记忆库${theme}到达预定的复习时间',
                            stopButton: '停止闹钟',
                            icon: 'notification_icon',
                          ),
                        );
                        await Alarm.set(alarmSettings: alarmSettings);
                      }
                      if (message == true) {
                        _notificationHelper.zonedScheduleNotification(
                            id: 888,
                            title: '开始复习 !',
                            body: '记忆库${theme}到达预定的复习时间',
                            scheduledDateTime: setTime);
                      }
                    } else {
                      completeReviewStatus = true;
                      String memorySchemeName =
                          reviewTheDataManagementOfMemoryBank.memorySchemeName;
                      String? stringci;
                      for (final entry in numberOfReviews.entries) {
                        if (entry.value == memorySchemeName) {
                          stringci = entry.key;
                          break;
                        }
                      }
                      if (stringci != null) {
                        int ci = int.parse(stringci);
                        int key = ci + 1;
                        String value = numberOfReviews[stringci] ?? ' s';
                        Map<String, String> newEntries = {'${key}': value};
                        numberOfReviews.remove(stringci);
                        numberOfReviews.addEntries(newEntries.entries);
                      }
                    }

                    continueReview(
                        question,
                        reply,
                        reviewTheDataManagementOfMemoryBank.id,
                        theme,
                        memoryScheme,
                        setTime,
                        sortedList,
                        message,
                        alarm_information,
                        completeReviewStatus,
                        numberOfReviews,
                        reviewTheDataManagementOfMemoryBank.memorySchemeName,
                        userNameChangeManagement.userNameValue??'');
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
      body: GetBuilder<ReviewTheDataManagementOfMemoryBank>(
          init: reviewTheDataManagementOfMemoryBank,
          builder: (reviewTheDataManagementOfMemoryBank) {
            return ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Text(
                    '复读回顾 >> 清空讲解 >> 更加清晰简洁讲解 >> 完成复习',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 15, top: 50, bottom: 0),
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
                    _data[index].isExpanded = isExpanded;
                    reviewTheDataManagementOfMemoryBank.refreshExpansionTile();
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
                                borderSide:
                                    BorderSide(color: Color(0x00FF0000)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x00000000)),
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
                        contentPadding: EdgeInsets.only(left: 5, right: 10),
                        title: TextField(
                          onChanged: (value) {
                            item.reply = value;
                          },
                          controller: TextEditingController(text: item.reply),
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
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: SizedBox(
                                          height: 150,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 25, top: 20),
                                                child: Text(
                                                  '复习',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 25,
                                                    top: 10,
                                                    bottom: 20),
                                                child: Text('是否清空选择讲解?',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 7),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        '取消',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          item.reply = '';
                                                        });

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        '确定',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black),
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
                          ),
                        ),
                      ),
                      isExpanded: item.isExpanded,
                    );
                  }).toList(),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        elevation: 5.0,
        highlightElevation: 20.0,
        backgroundColor: Colors.blue,
        child: const Text(
          '退出\n键盘',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
