import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/home/home_module/size_expansion_tile_state.dart';
import 'package:yunji/review/creat_review/creat_review_option.dart';
import 'package:toastification/toastification.dart' as toast;

class CreatReviewController extends GetxController {
  static CreatReviewController get to => Get.find();
  Map<int, String> question = {};
  Map<int, String> reply = {};
  String? theme;
  void initData(Map<int, String> question, Map<int, String> reply, String theme) {
    this.question = question;
    this.reply = reply;
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
    required this.reply,
    required this.subscript,
    this.isReadOnly = true,
    this.isExpanded = true,
  });
  int subscript;
  String question;
  String reply;
  bool isReadOnly;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      isReadOnly: false,
      isExpanded: false,
      question: 'e.g.示例：学习新知识后的遗忘曲线是什么?',
      reply: '遗忘曲线表示人在学习新知识后，最初一段时间遗忘的最快，然后慢慢减缓，能记住的知识会越来越少\n\n根据遗忘曲线，人们获得了更加有效的记忆方式\n例如：\n第1次复习:  学习后的第2天\n第2次复习:  第1次复习1周后\n第3次复习:  第2次复习2周后',
      subscript: 0,
    );
  });
}

class _CreatReviewPage extends State<CreatReviewPage> {
  final creatReviewController = Get.put(CreatReviewController());
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Item> _data = generateItems(1);

  int subscript = 0;
  String theme = '';

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void initState() {
    setState(() {
      _data.add(Item(subscript: subscript, question: '您有什么疑惑或学习目标', reply: '请输入讲解的内容'));
    });
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.close, size: 30)),
          title: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextField(
              onChanged: (value) {
                theme = value;
              },
              focusNode: _focusNode,
              maxLength: 50,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontSize: 17),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                counterText: "",
                filled: true,
                fillColor: Color.fromRGBO(238, 239, 243, 1),
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
                hintStyle: TextStyle(
                    color: Color.fromRGBO(84, 87, 105, 1),
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
                hintText: " 今天您想学习些什么呢?",
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
                    if (question.length==0 && reply.length==0) {
                    toast.toastification.show(
                        context: context,
                        type: toast.ToastificationType.success,
                        style: toast.ToastificationStyle.flatColored,
                        title: const Text("请添加填写记忆项",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        description: const Text(
                          "记忆项为空",
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.center,
                        autoCloseDuration: const Duration(seconds: 4),
                        primaryColor: const Color(0xff047aff),
                        backgroundColor: const Color(0xffedf7ff),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: toast.lowModeShadow,
                        dragToClose: true);
                  } else {
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
                          alignment: Alignment.center,
                          autoCloseDuration: const Duration(seconds: 4),
                          primaryColor: const Color(0xff047aff),
                          backgroundColor: const Color(0xffedf7ff),
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: toast.lowModeShadow,
                          dragToClose: true);
                      FocusScope.of(context).requestFocus(_focusNode);
                    } else {
                      FocusManager.instance.primaryFocus?.unfocus();
                      creatReviewController.initData(question, reply, theme!);
                      switchPage(context, const Yiwang());
                    }
                  }
                },
              ),
            ),
          ],
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: SizeCacheWidget(
            child: ListView(
              cacheExtent: 500,
              controller: _scrollController,
              children: [
                SizedBox(height: 10),
                Image.asset(
                  "assets/review/feynman.jpg",
                  width: double.infinity,
                ),
                Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: const sizeExpansionTile(
                    collapsedIconColor: Colors.black,
                    iconColor: Colors.blue,
                    trailing: null,
                    title: Text('费曼学习法详解',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        )),
                    subtitle: Text(
                      '您将以扮演学生与老师，提问与讲解的方法，提高学习内容的留存率',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(84, 87, 105, 1),
                        fontSize: 16,
                      ),
                    ),
                    children: [
                      ListTile(
                          title: Text.rich(TextSpan(children: [
                        TextSpan(
                          text:
                              "费曼学习法：由诺贝尔奖得主理查德·费曼创立，它的核心是通过简单易懂的语言去解释知识，并不断修正和完善自己的解释，以达到高效学习的目的，\n\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "软件依照费曼学习法设定，旨在建立一个帮助学习和记忆的学习平台\n\n",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text:
                              "简单来说，费曼学习法就是能够把深奥的知识以简单易懂的方式解释给一个外行、无任何背景知识的人听，这种能力越强，代表我们对所学知识的理解越透彻\n\n费曼学习法的具体步骤:\n\n第一步：选择目标\n\n确定您要学什么，在这里比如学习一门技术、学习一门语言等，都可以作为目标，",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "即作为学生问出想要学习和了解的问题(设定目标）\n\n",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: "第二步：教学\n\n"
                              "创造一个场景，在这个场景中将自己学到的知识讲授给“别人”，过程中遇到的问题，比如说不清楚的，模棱两可的，就说明这些知识点并没有熟练掌握，尝试教授和发现薄弱点就是这一步的重点\n\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "即作为老师讲解问题\n\n",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: "第三步：纠错\n\n"
                              "在教授的过程中说错的、说不清楚的、模棱两可的知识，需要进行纠错和重新学习，得以强化，直到可以顺利的教授相应的知识\n\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "可通过查询学习书籍或ai，浏览器等，完善讲解\n\n",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                        TextSpan(
                          text: "第四步：简化\n\n"
                              "对上面学习的内容进行提炼、简化，到让一个非专业人士都能听懂，简化知识的过程，将极大程度的学习知识\n\n",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: "此时，您以费曼学习法最有效的学习了知识",
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                      ]))),
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
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                if (_data.length < 100) {
                  setState(() {
                    _data.add(
                        Item(subscript: subscript, question: '您有什么疑惑或学习目标', reply: '请输入讲解的内容'));
                  });
                  subscript += 1;
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease);
                } else {
                  toast.toastification.show(
                      context: context,
                      type: toast.ToastificationType.warning,
                      style: toast.ToastificationStyle.flatColored,
                      title: const Text("记忆项数量已到上限",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              fontSize: 17)),
                      description: const Text(
                        "记忆项数量已到上限",
                        style: TextStyle(
                            color: Color.fromARGB(255, 119, 118, 118),
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      alignment: Alignment.topLeft,
                      autoCloseDuration: const Duration(seconds: 4),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: toast.lowModeShadow,
                      dragToClose: true);
                }
              },
              child: const Text(
                "添加",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              )),
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
      ),
    );
  }

  Map<int, String> question = {};
  Map<int, String> reply = {};
  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 230.0),
      child: ExpansionPanelList(
        materialGapSize: 16,
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
              return Column(
                children: [
                  const SizedBox(height: 8),
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          item.isExpanded = !isExpanded;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: TextFormField(
                          onChanged: (value) {
                            question[item.subscript] = value;
                          },
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 17),
                          enabled: item.isExpanded == false ? false : item.isReadOnly,
                          minLines: 1,
                          maxLines: 10,
                          maxLength: 150,
                          decoration: InputDecoration(
                            hintText: item.question,
                            hintStyle: const TextStyle(
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontSize: 17),
                            border: InputBorder.none,
                            counterText: "",
                          ),
                        ),
                      )),
                  const SizedBox(height: 8)
                ],
              );
            },
            body: Padding(
                padding: const EdgeInsets.only(left: 17.0, right: 9),
                child: TextFormField(
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 17),
                  minLines: 1,
                  maxLines: 30,
                  maxLength: 1500,
                  onChanged: (value) {
                    reply[item.subscript] = value;
                  },
                  decoration: InputDecoration(
                      hintText: item.reply,
                    hintStyle: const TextStyle(
                        color: Color.fromRGBO(84, 87, 105, 1), fontSize: 17),
                    suffixIcon: GestureDetector(
                        onTap: () {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.only(left: 25, top: 20),
                                        child: Text(
                                          '编辑记忆库',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 25, top: 10, bottom: 20),
                                        child: Text('是否删除选择项?',
                                            style: TextStyle(fontSize: 16)),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 7),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                                  _data.removeWhere(
                                                      (Item currentItem) =>
                                                          item == currentItem);
                                                });
                                                question.remove(item.subscript);
                                                reply.remove(item.subscript);
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
                        child: const Icon(
                          color: Color.fromRGBO(134, 134, 134, 1),
                          Icons.remove,
                          size: 26,
                        )),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                )),
            isExpanded: item.isExpanded,
          );
        }).toList(),
      ),
    );
  }
}
