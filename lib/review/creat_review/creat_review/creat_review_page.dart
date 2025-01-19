import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/home/home_module/size_expansion_tile_state.dart';
import 'package:yunji/review/creat_review/creat_review/creat_review_option.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/main/main_module/dialog.dart';

class CreatReviewController extends GetxController {
  static CreatReviewController get to => Get.find();
  Map<int, String> question = {};
  Map<int, String> answer = {};
  String? theme;
  bool message = false;
  bool alarmInformation = false;

  void initData(
      Map<int, String> question, Map<int, String> answer, String theme) {
    this.question = question;
    this.answer = answer;
    this.theme = theme;
  }
}

class CreatReviewPage extends StatefulWidget {
  const CreatReviewPage({super.key});

  @override
  State<CreatReviewPage> createState() => _CreatReviewPage();
}

class Item {
  Item({
    required this.question,
    required this.answer,
    required this.subscript,
    this.isReadOnly = false,
    this.isExpanded = true,
  });

  int subscript;
  String question;
  String answer;
  bool isReadOnly;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      isReadOnly: true,
      isExpanded: false,
      question: 'e.g.示例：学习新知识后的遗忘曲线是什么?',
      answer:
          '遗忘曲线表示人在学习新知识后，最初一段时间遗忘的最快，然后慢慢减缓，能记住的知识会越来越少\n\n根据遗忘曲线，人们获得了更加有效的记忆方式\n例如：\n第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后',
      subscript: 0,
    );
  });
}

class _CreatReviewPage extends State<CreatReviewPage> {
  final creatReviewController = Get.put(CreatReviewController());
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Item> _data = generateItems(1);

  int subscript = 1;
  String theme = '';

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _data.add(Item(
      subscript: subscript,
      question: '您有什么疑惑或学习目标',
      answer: '请输入讲解的内容',
    ));
    subscript += 1;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.close, size: 30, color: AppColors.iconColorTwo),
          ),
          title: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: TextField(
              onChanged: (value) {
                theme = value;
              },
              focusNode: _focusNode,
              maxLength: 50,
              style: AppTextStyle.textStyle,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                counterText: "",
                filled: true,
                fillColor: AppColors.background,
                enabledBorder: _transparentInput(),
                focusedBorder: _transparentInput(),
                contentPadding: EdgeInsets.all(10),
                hintStyle: AppTextStyle.subsidiaryText,
                hintText: "今天您想学习些什么呢?",
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 0, bottom: 0),
                  backgroundColor: AppColors.iconColor,
                ),
                child: Text(
                  "下一步",
                  style: AppTextStyle.whiteTextStyle,
                ),
                onPressed: () {
                  if (question.isEmpty && answer.isEmpty) {
                    showToast(
                        context,
                        "请添加填写记忆项",
                        "记忆项为空",
                        toast.ToastificationType.success,
                        const Color(0xff047aff),
                        const Color(0xFFEDF7FF));
                  } else if (theme.isEmpty) {
                    showToast(
                        context,
                        "请填写主题",
                        "主题为空",
                        toast.ToastificationType.success,
                        const Color(0xff047aff),
                        const Color(0xFFEDF7FF));
                    FocusScope.of(context).requestFocus(_focusNode);
                  } else {
                    FocusManager.instance.primaryFocus?.unfocus();
                    creatReviewController.initData(question, answer, theme);
                    switchPage(context, const CreatReviewOption());
                  }
                },
              ),
            ),
          ],
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
        ),
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: SizeCacheWidget(
            child: ListView(
              cacheExtent: 500,
              controller: _scrollController,
              children: [
                const SizedBox(height: 10),
                Image.asset(
                  "assets/review/feynman.jpg",
                  width: double.infinity,
                ),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: sizeExpansionTile(
                    collapsedIconColor: AppColors.text,
                    iconColor: AppColors.iconColor,
                    trailing: null,
                    title: Text(
                      '费曼学习法详解',
                      style: AppTextStyle.coarseTextStyle,
                    ),
                    subtitle: Text(
                      '您将以扮演学生与老师，提问与讲解的方法，提高学习内容的留存率',
                      style: AppTextStyle.subsidiaryText,
                    ),
                    children: [
                      ListTile(
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text:
                                    "费曼学习法：由诺贝尔奖得主理查德·费曼创立，它的核心是通过简单易懂的语言去解释知识，并不断修正和完善自己的解释，以达到高效学习的目的，\n\n",
                                style: AppTextStyle.textStyle,
                              ),
                              TextSpan(
                                text: "软件依照费曼学习法设定，旨在建立一个帮助学习和记忆的学习平台\n\n",
                                style: AppTextStyle.blueTextStyle,
                              ),
                              TextSpan(
                                text:
                                    "简单来说，费曼学习法就是能够把深奥的知识以简单易懂的方式解释给一个外行、无任何背景知识的人听，这种能力越强，代表我们对所学知识的理解越透彻\n\n费曼学习法的具体步骤:\n\n第一步：选择目标\n\n确定您要学什么，在这里比如学习一门技术、学习一门语言等，都可以作为目标，",
                                style: AppTextStyle.textStyle,
                              ),
                              TextSpan(
                                text: "即作为学生问出想要学习和了解的问题(设定目标）\n\n",
                                style: AppTextStyle.blueTextStyle,
                              ),
                              TextSpan(
                                text:
                                    "第二步：教学\n\n创造一个场景，在这个场景中将自己学到的知识讲授给“别人”，过程中遇到的问题，比如说不清楚的，模棱两可的，就说明这些知识点并没有熟练掌握，尝试教授和发现薄弱点就是这一步的重点\n\n",
                                style: AppTextStyle.textStyle,
                              ),
                              TextSpan(
                                text: "即作为老师讲解问题\n\n",
                                style: AppTextStyle.blueTextStyle,
                              ),
                              TextSpan(
                                text:
                                    "第三步：纠错\n\n在教授的过程中说错的、说不清楚的、模棱两可的知识，需要进行纠错和重新学习，得以强化，直到可以顺利的教授相应的知识\n\n",
                                style: AppTextStyle.textStyle,
                              ),
                              TextSpan(
                                text: "可通过查询学习书籍或ai，浏览器等，完善讲解\n\n",
                                style: AppTextStyle.blueTextStyle,
                              ),
                              TextSpan(
                                text:
                                    "第四步：简化\n\n对上面学习的内容进行提炼、简化，到让一个非专业人士都能听懂，简化知识的过程，将极大程度的学习知识\n\n",
                                style: AppTextStyle.textStyle,
                              ),
                              TextSpan(
                                text: "此时，您以费曼学习法最有效的学习了知识",
                                style: AppTextStyle.blueTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: double.infinity, height: 20),
                _buildPanel(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.only(top: 0, bottom: 0),
              backgroundColor: AppColors.iconColor,
            ),
            onPressed: () {
              if (_data.length < 100) {
                setState(() {
                  _data.add(Item(
                    subscript: subscript,
                    question: '您有什么疑惑或学习目标',
                    answer: '请输入讲解的内容',
                  ));
                });

                subscript += 1;
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              } else {
                showToast(
                    context,
                    "记忆项数量已到上限",
                    "记忆项数量已到上限",
                    toast.ToastificationType.success,
                    const Color(0xff047aff),
                    const Color(0xFFEDF7FF));
              }
            },
            child: Text(
              "添加",
              style: AppTextStyle.whiteTextStyle,
            ),
          ),
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
      ),
    );
  }

  Map<int, String> question = {};
  Map<int, String> answer = {};

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 230.0),
      child: ExpansionPanelList(
        materialGapSize: commonFontSize,
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
              return Column(
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isExpanded = isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 17.0),
                      child: TextFormField(
                        controller: TextEditingController(
                            text: question[item.subscript]),
                        onChanged: (value) {
                          question[item.subscript] = value;
                        },
                        style: AppTextStyle.textStyle,
                        enabled: item.isExpanded,
                        minLines: 1,
                        readOnly: item.isReadOnly,
                        maxLines: 10,
                        maxLength: 150,
                        decoration: InputDecoration(
                          hintText: item.question,
                          hintStyle: AppTextStyle.subsidiaryText,
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
            body: Padding(
              padding: const EdgeInsets.only(left: 17.0, right: 9),
              child: TextFormField(
                controller: TextEditingController(text: answer[item.subscript]),
                style: AppTextStyle.textStyle,
                minLines: 1,
                maxLines: 30,
                maxLength: 1500,
                onChanged: (value) {
                  answer[item.subscript] = value;
                },
                decoration: InputDecoration(
                  hintText: item.answer,
                  hintStyle: AppTextStyle.subsidiaryText,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      buildDialog(
                        context: context,
                        title: '创建记忆库',
                        content: '是否删除选择项?',
                        onConfirm: () {
                          setState(() {
                            question.remove(item.subscript);
                            answer.remove(item.subscript);
                            _data.removeWhere((element) =>
                                element.subscript == item.subscript);
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    child:  Icon(
                      color: AppColors.Gray,
                      Icons.remove,
                      size: 26,
                    ),
                  ),
                  border: InputBorder.none,
                  counterText: "",
                ),
              ),
            ),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }
}

OutlineInputBorder _transparentInput() {
  return OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent), // 设置为透明
    borderRadius: BorderRadius.all(
      Radius.circular(100),
    ),
  );
}
