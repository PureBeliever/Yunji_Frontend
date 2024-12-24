import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/review/review/continue_review/continue_review_option.dart';
import 'package:toastification/toastification.dart' as toast;

class Item {
  Item({
    required this.huida,
    required this.tiwen,
    this.isExpanded = true,
  });

  String huida;
  String tiwen;

  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> xiabiao,
    Map<String, dynamic> timu, Map<String, dynamic> huida) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      tiwen: timu['${xiabiao[index]}'] ?? '',
      huida: huida['${xiabiao[index]}'] ?? '',
    );
  });
}

// 继续学习数据管理
class ContinueLearningAboutDataManagement extends GetxController {
  static ContinueLearningAboutDataManagement get to => Get.find();
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

  // String类型的题目
  Map<int, String> theNumberOfProblemsString = {};

  // String类型的答案
  Map<int, String> theNumberOfAnswersString = {};

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

  void initTheMemoryData(Map<String, dynamic> data) {
    id = data['memory_bank_id'];
    memoryBankDataValue = data;
    theTitleOfTheMemory = data['theme'];
    numberOfMemories = data['subscript'].length;
    theIndexValueOfTheMemoryItem = data['subscript'];
    theNumberOfProblems = jsonDecode(data['question']);
    theNumberOfAnswers = jsonDecode(data['reply']);
    theNumberOfProblemsString = jsonDecode(data['question']);
    theNumberOfAnswersString = jsonDecode(data['reply']);
    memoryScheme = jsonDecode(data['memory_time']);
    numberOfReviews = jsonDecode(data['review_record']);
    messageNotificationStatus = data['information_notification'] == 1 ? true : false;
    alarmInformationStatus = data['alarm_notification'] == 1 ? true : false;
    completeReviewStatus = data['complete_state'] == 1 ? true : false;
    memorySchemeName = data['review_scheme_name'];
  }

  void refreshExpansionTile() {
    update();
  }
}

class JixvfuxiPage extends StatefulWidget {
  const JixvfuxiPage({super.key});

  @override
  State<JixvfuxiPage> createState() => _JixvfuxiPage();
}

class _JixvfuxiPage extends State<JixvfuxiPage> {
  final List<Item> _data = generateItems(
      continueLearningAboutDataManagement.numberOfMemories,
      continueLearningAboutDataManagement.theIndexValueOfTheMemoryItem,
      continueLearningAboutDataManagement.theNumberOfProblems,
      continueLearningAboutDataManagement.theNumberOfAnswers);
  final _controller = TextEditingController(text: continueLearningAboutDataManagement.theTitleOfTheMemory);
  final FocusNode _focusNode = FocusNode();
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
                                          item.huida = ' ';
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
                      left: 10, right: 10, top: 0, bottom: 0),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "下一步",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                onPressed: () async {
                  if (continueLearningAboutDataManagement.theTitleOfTheMemory.length == 0) {
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
                    _data.forEach((uio) {
                      continueLearningAboutDataManagement.theNumberOfProblemsString[zhi] = uio.tiwen;
                      continueLearningAboutDataManagement.theNumberOfAnswersString[zhi] = uio.huida;
                      zhi++;
                    });
                    switchPage(context, Jixvfuxiyiwang());
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
      body: GetBuilder<ContinueLearningAboutDataManagement>(
          init: continueLearningAboutDataManagement,
          builder: (continueLearningAboutDataManagement) {
            return ListView(
              children: [
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
                      continueLearningAboutDataManagement.theTitleOfTheMemory = value;
                    },
                    controller: _controller,
                    maxLength: 50,
                    focusNode: _focusNode,
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
                    continueLearningAboutDataManagement.refreshExpansionTile();
                  },
                  children: _data.map<ExpansionPanel>((Item item) {
                    return ExpansionPanel(
                      backgroundColor: Colors.white,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: TextField(
                            onChanged: (value) {
                              item.tiwen = value;
                            },
                            controller: TextEditingController(text: item.tiwen),
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
                            item.huida = value;
                          },
                          controller: TextEditingController(text: item.huida),
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
                                                          item.huida = '';
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
