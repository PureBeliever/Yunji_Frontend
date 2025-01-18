import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/review/review/continue_review_option.dart';
import 'package:toastification/toastification.dart' as toast;

class Item {
  Item({
    required this.question,
    required this.answer,
    this.isExpanded = true,
  });

  String question;
  String answer;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> subscript,
    Map<String, dynamic> question, Map<String, dynamic> answer) {
  return List<Item>.generate(numberOfItems, (index) {
    return Item(
      question: question[subscript[index].toString()] ?? '',
      answer: answer[subscript[index].toString()] ?? '',
    );
  });
}

class ContinueLearningAboutDataManagement extends GetxController {
  static ContinueLearningAboutDataManagement get to => Get.find();

  Map<String, dynamic> memoryBankDataValue = {};
  int numberOfMemories = 0;
  List<int> memoryItemIndices = [];
  Map<String, dynamic> question = {};
  Map<String, dynamic> answer = {};
  String theme = '';
  List<dynamic> memoryScheme = [];
  Map<String, dynamic> reviewRecords = {};
  bool message = false;
  bool alarmInformation = false;
  bool isReviewComplete = false;
  String memorySchemeName = '';
  int id = -1;

  void initMemoryData(Map<String, dynamic> data) {
    id = data['id'];
    memoryBankDataValue = data;
    theme = data['theme'];
    numberOfMemories = data['subscript'].length;
    memoryItemIndices = List<int>.from(data['subscript']);
    question = jsonDecode(data['question']);
    answer = jsonDecode(data['answer']);
    memoryScheme = jsonDecode(data['memory_time']);
    reviewRecords = jsonDecode(data['review_record']);
    message = data['information_notification'] == 1;
    alarmInformation = data['alarm_notification'] == 1;
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
  final _continueLearningAboutDataManagement =
      Get.put(ContinueLearningAboutDataManagement());
  late List<Item> _data;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _data = generateItems(
      _continueLearningAboutDataManagement.numberOfMemories,
      _continueLearningAboutDataManagement.memoryItemIndices,
      _continueLearningAboutDataManagement.question,
      _continueLearningAboutDataManagement.answer,
    );
    _controller = TextEditingController(
      text: _continueLearningAboutDataManagement.theme,
    );
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
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 10, bottom: 20),
                  child:
                      Text('是否清空所有讲解?', style: TextStyle(fontSize: 16)),
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
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 10, bottom: 20),
                  child:
                      Text('清空还是删除当前讲解?', style: TextStyle(fontSize: 16)),
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

  void _handleNextStep(BuildContext context) {
    if (_continueLearningAboutDataManagement.theme.isEmpty) {
      showToast(context, "请填写主题", "主题为空", toast.ToastificationType.success,
          const Color(0xff047aff), const Color(0xFFEDF7FF));
      FocusScope.of(context).requestFocus(_focusNode);
    } else {
      int index = 0;
      for (var data in _data) {
        if (data.question.isNotEmpty || data.answer.isNotEmpty) {
          _continueLearningAboutDataManagement.question[index.toString()] =
              data.question;
          _continueLearningAboutDataManagement.answer[index.toString()] =
              data.answer;
          index++;
        }
      }
      switchPage(context, const ContinueReviewOption());
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
      body: ListView(
        children: [
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
                _continueLearningAboutDataManagement.theme = value;
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
                            _showDeleteDialog(context, item);
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
