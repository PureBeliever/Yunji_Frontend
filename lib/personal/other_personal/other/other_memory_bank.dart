import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';


// ignore: camel_case_types
class OtherMemoryBank extends StatefulWidget {
  const OtherMemoryBank({super.key});

  @override
  State<OtherMemoryBank> createState() => _OtherMemoryBankState();
}

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = true,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

// 查看帖子的记忆库数据管理
class ViewPostDataManagementForMemoryBanks extends GetxController {
  static ViewPostDataManagementForMemoryBanks get to => Get.find();

  // 帖子的记忆库数据
  Map<String, dynamic> theMemoryBankValueOfThePost = {};

  // 记忆库
  int numberOfMemories = 0;

  // 记忆库下标
  List<int> theIndexValueOfTheMemoryItem = List.empty();

  // 题目
  Map<String, dynamic> theNumberOfProblems = {};

  // 答案
  Map<String, dynamic> theNumberOfAnswers = {};
  
  // 记忆库标题
  String theTitleOfTheMemory = '';

  // 初始化记忆库数据
  void initTheMemoryDataForThePost(Map<String, dynamic> theMemoryDataForThePost) {
    print(theMemoryDataForThePost);
    theMemoryBankValueOfThePost = theMemoryDataForThePost;
    theTitleOfTheMemory = theMemoryDataForThePost['theme'];
    numberOfMemories = theMemoryDataForThePost['subscript'].length;
    theIndexValueOfTheMemoryItem = theMemoryDataForThePost['subscript'];
    theNumberOfProblems = jsonDecode(theMemoryDataForThePost['question']);
    theNumberOfAnswers = jsonDecode(theMemoryDataForThePost['reply']);
  }

  // 刷新ExpansionTile
  void refreshExpansionTile() {
    update();
  }
}

List<Item> generateItems(int numberOfItems, List<int> xiabiao,
    Map<String, dynamic> timu, Map<String, dynamic> huida) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: timu['${xiabiao[index]}'] ?? '',
      expandedValue: huida['${xiabiao[index]}'] ?? '',
    );
  });
}

// ignore: camel_case_types
class _OtherMemoryBankState extends State<OtherMemoryBank> {
  final List<Item> _data = generateItems(
      viewPostDataManagementForMemoryBanks.numberOfMemories,
      viewPostDataManagementForMemoryBanks.theIndexValueOfTheMemoryItem,
      viewPostDataManagementForMemoryBanks.theNumberOfProblems,
      viewPostDataManagementForMemoryBanks.theNumberOfAnswers);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.9),
            child: Container(
              color: const Color.fromRGBO(223, 223, 223, 1),
              height: 0.9,
            ),
          ),
          title: Text(
            viewPostDataManagementForMemoryBanks.theTitleOfTheMemory,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          children: [
            InkWell(
              onTap: ()async {
               
                await requestTheOtherPersonalData(
                    viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['user_name']);
                
                switchPage(context, const OtherPersonalPage());
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 14, right: 15, top: 8, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundImage: viewPostDataManagementForMemoryBanks
                                      .theMemoryBankValueOfThePost['head_portrait'] !=
                                  null
                              ? FileImage(
                                  File(viewPostDataManagementForMemoryBanks
                                      .theMemoryBankValueOfThePost['head_portrait']))
                              : const AssetImage('assets/personal/gray_back_head.png'),
                        ),
                        const SizedBox(width: 11),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                             
                              '@${ viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['user_name']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontSize: 16,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                      width: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "关注",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GetBuilder<ViewPostDataManagementForMemoryBanks>(
                init: ViewPostDataManagementForMemoryBanks(),
                builder: (ViewPostDataManagementForMemoryBanks) {
                  return ExpansionPanelList(
                    materialGapSize: 15,
                    elevation: 0,
                    dividerColor: Colors.white,
                    expansionCallback: (int index, bool isExpanded) {
                      _data[index].isExpanded = isExpanded;
                      ViewPostDataManagementForMemoryBanks.refreshExpansionTile();
                    },
                    children: _data.map<ExpansionPanel>((Item item) {
                      return ExpansionPanel(
                        backgroundColor: Colors.white,
                        headerBuilder: (BuildContext context, bool isExpanded) {
                          return GestureDetector(
                            onTap: () {
                              item.isExpanded = !isExpanded;
                              ViewPostDataManagementForMemoryBanks.refreshExpansionTile();
                            },
                            child: ListTile(
                              title: Text(
                                item.headerValue,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                          );
                        },
                        body: ListTile(
                          title: Text(item.expandedValue,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                        ),
                        isExpanded: item.isExpanded,
                      );
                    }).toList(),
                  );
                }),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                children: [
                  const Divider(
                    color: Color.fromRGBO(223, 223, 223, 1),
                    thickness: 0.9,
                    height: 25,
                  ),
                  Row(
                    children: [
                      Text('${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['pull']} ',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      const Text(
                        '拉取',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(84, 87, 105, 1),
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text('${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['collect']} ',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      const Text(
                        '收藏',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(84, 87, 105, 1),
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text('${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['like']} ',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      const Text(
                        '喜欢',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(84, 87, 105, 1),
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Text('${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['review']} ',
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w900)),
                      const Text(
                        '回复',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(84, 87, 105, 1),
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Color.fromRGBO(223, 223, 223, 1),
                    thickness: 0.9,
                    height: 25,
                  ),
                  GetBuilder<UserPersonalInformationManagement>(
                      init: userPersonalInformationManagement,
                      builder: (userPersonalInformationManagement) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            LikeButton(
                              circleColor: const CircleColor(
                                  start: Color.fromARGB(255, 42, 91, 255),
                                  end: Color.fromARGB(255, 142, 204, 255)),
                              bubblesColor: const BubblesColor(
                                dotPrimaryColor:
                                    Color.fromARGB(255, 0, 153, 255),
                                dotSecondaryColor:
                                    Color.fromARGB(255, 195, 238, 255),
                              ),
                              size: 25,
                              onTap: (isLiked) async {
                              
                              },
                           
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isLiked ? Icons.swap_calls : Icons.swap_calls,
                                  color: isLiked
                                      ? Colors.blue
                                      : const Color.fromRGBO(84, 87, 105, 1),
                                  size: 25,
                                );
                              },
                              countBuilder:
                                  (int? count, bool isLiked, String text) {
                                var color = isLiked
                                    ? Colors.blue
                                    : const Color.fromRGBO(84, 87, 105, 1);
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "love",
                                    style: TextStyle(color: color),
                                  );
                                }
                                result = Text(
                                  text,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700),
                                );
                                return result;
                              },
                            ),
                            const Spacer(flex: 1),
                            LikeButton(
                              circleColor: const CircleColor(
                                  start: Color.fromARGB(255, 253, 156, 46),
                                  end: Color.fromARGB(255, 255, 174, 120)),
                              bubblesColor: const BubblesColor(
                                dotPrimaryColor:
                                    Color.fromARGB(255, 255, 102, 0),
                                dotSecondaryColor:
                                    Color.fromARGB(255, 255, 212, 163),
                              ),
                              size: 25,
                              onTap: (isLiked) async {
                            
                              },
                 
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isLiked ? Icons.folder : Icons.folder_open,
                                  color: isLiked
                                      ? Colors.orange
                                      : const Color.fromRGBO(84, 87, 105, 1),
                                  size: 25,
                                );
                              },
                              countBuilder:
                                  (int? count, bool isLiked, String text) {
                                var color = isLiked
                                    ? Colors.orange
                                    : const Color.fromRGBO(84, 87, 105, 1);
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "love",
                                    style: TextStyle(color: color),
                                  );
                                }
                                result = Text(
                                  text,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700),
                                );
                                return result;
                              },
                            ),
                            const Spacer(flex: 1),
                            LikeButton(
                              size: 25,
                              circleColor: const CircleColor(
                                  start: Color.fromARGB(255, 255, 64, 64),
                                  end: Color.fromARGB(255, 255, 206, 206)),
                              bubblesColor: const BubblesColor(
                                dotPrimaryColor: Color.fromARGB(255, 255, 0, 0),
                                dotSecondaryColor:
                                    Color.fromARGB(255, 255, 186, 186),
                              ),
                              onTap: (isLiked) async {
                              
                              },
                         
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked
                                      ? Colors.red
                                      : const Color.fromRGBO(84, 87, 105, 1),
                                  size: 25,
                                );
                              },
                              countBuilder:
                                  (int? count, bool isLiked, String text) {
                                var color = isLiked
                                    ? Colors.red
                                    : const Color.fromRGBO(84, 87, 105, 1);
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "love",
                                    style: TextStyle(color: color),
                                  );
                                }
                                result = Text(
                                  text,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700),
                                );
                                return result;
                              },
                            ),
                            const Spacer(flex: 1),
                            LikeButton(
                              circleColor: const CircleColor(
                                  start: Color.fromARGB(255, 237, 42, 255),
                                  end: Color.fromARGB(255, 185, 142, 255)),
                              bubblesColor: const BubblesColor(
                                dotPrimaryColor:
                                    Color.fromARGB(255, 225, 0, 255),
                                dotSecondaryColor:
                                    Color.fromARGB(255, 233, 195, 255),
                              ),
                              size: 25,
                              onTap: (isLiked) async {
                                
                              },
                            
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  isLiked
                                      ? Icons.messenger
                                      : Icons.messenger_outline,
                                  color: isLiked
                                      ? Colors.purpleAccent
                                      : const Color.fromRGBO(84, 87, 105, 1),
                                  size: 25,
                                );
                              },
                              countBuilder:
                                  (int? count, bool isLiked, String text) {
                                var color = isLiked
                                    ? Colors.purple
                                    : const Color.fromRGBO(84, 87, 105, 1);
                                Widget result;
                                if (count == 0) {
                                  result = Text(
                                    "love",
                                    style: TextStyle(color: color),
                                  );
                                }
                                result = Text(
                                  text,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.w700),
                                );
                                return result;
                              },
                            ),
                            const SizedBox(width: 10)
                          ],
                        );
                      }),
                ],
              ),
            ),
            const Divider(
              color: Color.fromRGBO(223, 223, 223, 1),
              thickness: 0.9,
              height: 25,
            ),
          ],
        ));
  }
}
