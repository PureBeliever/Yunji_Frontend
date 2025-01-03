import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/app_module/show_toast.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/review/review/continue_review/continue_review_option.dart';
import 'package:toastification/toastification.dart' as toast;

class Item {
  Item({
    required this.question,
    required this.reply,
    this.isExpanded = true,
  });

  String question;
  String reply;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> subscript,
    Map<String, dynamic> question, Map<String, dynamic> reply) {
  return List<Item>.generate(numberOfItems, (index) {
    return Item(
      question: question[subscript[index].toString()] ?? '',
      reply: reply[subscript[index].toString()] ?? '',
    );
  });
}

class ContinueLearningAboutDataManagement extends GetxController {
  static ContinueLearningAboutDataManagement get to => Get.find();

  Map<String, dynamic> memoryBankDataValue = {};
  int numberOfMemories = 0;
  List<int> memoryItemIndices = [];
  Map<String, dynamic> problems = {};
  Map<String, dynamic> answer = {};
  String memoryTheme = '';
  List<dynamic> memoryScheme = [];
  Map<String, dynamic> reviewRecords = {};
  bool isMessageNotificationEnabled = false;
  bool isAlarmNotificationEnabled = false;
  bool isReviewComplete = false;
  String memorySchemeName = '';
  int id = -1;

  void initMemoryData(Map<String, dynamic> data) {
    id = data['id'];
    memoryBankDataValue = data;
    memoryTheme = data['theme'];
    numberOfMemories = data['subscript'].length;
    memoryItemIndices = List<int>.from(data['subscript']);
    problems = jsonDecode(data['question']);
    answer = jsonDecode(data['answer']);
    memoryScheme = jsonDecode(data['memory_time']);
    reviewRecords = jsonDecode(data['review_record']);
    isMessageNotificationEnabled = data['information_notification'] == 1;
    isAlarmNotificationEnabled = data['alarm_notification'] == 1;
    isReviewComplete = data['complete_state'] == 1;
    memorySchemeName = data['review_scheme_name'];
  }

  void refreshExpansionTile() {
    update();
  }
}

class ContinueReview extends StatefulWidget {
  const ContinueReview({super.key});

  @override
  State<ContinueReview> createState() => _ContinueReview();
}

class _ContinueReview extends State<ContinueReview> {
  final List<Item> _data = generateItems(
      continueLearningAboutDataManagement.numberOfMemories,
      continueLearningAboutDataManagement.memoryItemIndices,
      continueLearningAboutDataManagement.problems,
      continueLearningAboutDataManagement.answer);
  final _controller = TextEditingController(text: continueLearningAboutDataManagement.memoryTheme);
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  void _showClearDialog(BuildContext context, VoidCallback onConfirm,bool isClearAll) {
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
                  child: Text(isClearAll ? '是否清空所有讲解?' : '是否清空当前讲解?', style: const TextStyle(fontSize: 16)),
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
                        onPressed: onConfirm,
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

  void _clearAllExplanations() {
    setState(() {
      for (var item in _data) {
        item.reply = ' ';
      }
    });
  }

  void _clearSpecificExplanation(Item item) {
    setState(() {
      item.reply = '';
    });
  }


  void _handleNextStep(BuildContext context) {
    if (continueLearningAboutDataManagement.memoryTheme.isEmpty) {
      showToast(context, "请填写主题", "主题为空", toast.ToastificationType.success, const Color(0xff047aff), const Color(0xFFEDF7FF));
      FocusScope.of(context).requestFocus(_focusNode);
    } else {
      int index = 0;
      for (var data in _data) {
        continueLearningAboutDataManagement.problems[index.toString()] = data.question;
        continueLearningAboutDataManagement.answer[index.toString()] = data.reply;
        index++;
      }
      switchPage(context, ContinueReviewOption());
    }
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
                _showClearDialog(context, () {
                  _clearAllExplanations();
                  Navigator.of(context).pop();
                },true);
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
                onPressed: () {
                  _handleNextStep(context);
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body:  ListView(
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
                      continueLearningAboutDataManagement.memoryTheme = value;
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
                                  _showClearDialog(context, () {
                                    _clearSpecificExplanation(item);
                                    Navigator.of(context).pop();
                                  },false);
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
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
