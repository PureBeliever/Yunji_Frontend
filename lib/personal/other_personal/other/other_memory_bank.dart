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
  List<int> theIndexValueOfTheMemoryItem = [];

  // 题目
  Map<String, dynamic> theNumberOfProblems = {};

  // 答案
  Map<String, dynamic> theNumberOfAnswers = {};
  
  // 记忆库标题
  String theTitleOfTheMemory = '';

  // 初始化记忆库数据
  void initTheMemoryDataForThePost(Map<String, dynamic> theMemoryDataForThePost) {
    theMemoryBankValueOfThePost = theMemoryDataForThePost;
    theTitleOfTheMemory = theMemoryDataForThePost['theme'];
    numberOfMemories = (theMemoryDataForThePost['subscript'] as List).length;
    theIndexValueOfTheMemoryItem = List<int>.from(theMemoryDataForThePost['subscript']);
    theNumberOfProblems = jsonDecode(theMemoryDataForThePost['question']);
    theNumberOfAnswers = jsonDecode(theMemoryDataForThePost['reply']);
  }

  // 刷新ExpansionTile
  void refreshExpansionTile() => update();
}

List<Item> generateItems(int numberOfItems, List<int> subscript,
    Map<String, dynamic> question, Map<String, dynamic> reply) {
  return List<Item>.generate(numberOfItems, (index) {
    return Item(
      headerValue: question[subscript[index].toString()] ?? '',
      expandedValue: reply[subscript[index].toString()] ?? '',
    );
  });
}

// ignore: camel_case_types
class _OtherMemoryBankState extends State<OtherMemoryBank> {
  late final List<Item> _data;

  @override
  void initState() {
    super.initState();
    _data = generateItems(
      viewPostDataManagementForMemoryBanks.numberOfMemories,
      viewPostDataManagementForMemoryBanks.theIndexValueOfTheMemoryItem,
      viewPostDataManagementForMemoryBanks.theNumberOfProblems,
      viewPostDataManagementForMemoryBanks.theNumberOfAnswers,
    );
  }

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
            onTap: () async {
                switchPage(context, const OtherPersonalPage());
              await requestTheOtherPersonalData(
                  viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['user_name']);
            
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                            ? FileImage(File(viewPostDataManagementForMemoryBanks
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
                            '@${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['user_name']}',
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
            builder: (controller) {
              return ExpansionPanelList(
                materialGapSize: 15,
                elevation: 0,
                dividerColor: Colors.white,
                expansionCallback: (int index, bool isExpanded) {
                  _data[index].isExpanded = !isExpanded;
                  controller.refreshExpansionTile();
                },
                children: _data.map<ExpansionPanel>((Item item) {
                  return ExpansionPanel(
                    backgroundColor: Colors.white,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return GestureDetector(
                        onTap: () {
                          item.isExpanded = !isExpanded;
                          controller.refreshExpansionTile();
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
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const Divider(
                  color: Color.fromRGBO(223, 223, 223, 1),
                  thickness: 0.9,
                  height: 25,
                ),
                _buildInfoRow(),
                const Divider(
                  color: Color.fromRGBO(223, 223, 223, 1),
                  thickness: 0.9,
                  height: 25,
                ),
                GetBuilder<UserPersonalInformationManagement>(
                  init: userPersonalInformationManagement,
                  builder: (controller) {
                    return _buildLikeButtonsRow();
                  },
                ),
              ],
            ),
          ),
          const Divider(
            color: Color.fromRGBO(223, 223, 223, 1),
            thickness: 0.9,
            height: 25,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['pull']} ',
          '拉取',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['collect']} ',
          '收藏',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['like']} ',
          '喜欢',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.theMemoryBankValueOfThePost['review']} ',
          '回复',
        ),
      ],
    );
  }

  Widget _buildInfoText(String value, String label) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w900),
        ),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(84, 87, 105, 1),
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  Widget _buildLikeButtonsRow() {
    return Row(
      children: [
        const SizedBox(width: 10),
        _buildLikeButton(
          startColor: const Color.fromARGB(255, 42, 91, 255),
          endColor: const Color.fromARGB(255, 142, 204, 255),
          dotPrimaryColor: const Color.fromARGB(255, 0, 153, 255),
          dotSecondaryColor: const Color.fromARGB(255, 195, 238, 255),
          likedIcon: Icons.swap_calls,
          unlikedIcon: Icons.swap_calls,
          likedColor: Colors.blue,
          unlikedColor: const Color.fromRGBO(84, 87, 105, 1),
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          startColor: const Color.fromARGB(255, 253, 156, 46),
          endColor: const Color.fromARGB(255, 255, 174, 120),
          dotPrimaryColor: const Color.fromARGB(255, 255, 102, 0),
          dotSecondaryColor: const Color.fromARGB(255, 255, 212, 163),
          likedIcon: Icons.folder,
          unlikedIcon: Icons.folder_open,
          likedColor: Colors.orange,
          unlikedColor: const Color.fromRGBO(84, 87, 105, 1),
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          startColor: const Color.fromARGB(255, 255, 64, 64),
          endColor: const Color.fromARGB(255, 255, 206, 206),
          dotPrimaryColor: const Color.fromARGB(255, 255, 0, 0),
          dotSecondaryColor: const Color.fromARGB(255, 255, 186, 186),
          likedIcon: Icons.favorite,
          unlikedIcon: Icons.favorite_border,
          likedColor: Colors.red,
          unlikedColor: const Color.fromRGBO(84, 87, 105, 1),
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          startColor: const Color.fromARGB(255, 237, 42, 255),
          endColor: const Color.fromARGB(255, 185, 142, 255),
          dotPrimaryColor: const Color.fromARGB(255, 225, 0, 255),
          dotSecondaryColor: const Color.fromARGB(255, 233, 195, 255),
          likedIcon: Icons.messenger,
          unlikedIcon: Icons.messenger_outline,
          likedColor: Colors.purpleAccent,
          unlikedColor: const Color.fromRGBO(84, 87, 105, 1),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildLikeButton({
    required Color startColor,
    required Color endColor,
    required Color dotPrimaryColor,
    required Color dotSecondaryColor,
    required IconData likedIcon,
    required IconData unlikedIcon,
    required Color likedColor,
    required Color unlikedColor,
  }) {
    return LikeButton(
      circleColor: CircleColor(start: startColor, end: endColor),
      bubblesColor: BubblesColor(
        dotPrimaryColor: dotPrimaryColor,
        dotSecondaryColor: dotSecondaryColor,
      ),
      size: 25,
      onTap: (isLiked) async => !isLiked,
      likeBuilder: (bool isLiked) => Icon(
        isLiked ? likedIcon : unlikedIcon,
        color: isLiked ? likedColor : unlikedColor,
        size: 25,
      ),
      countBuilder: (int? count, bool isLiked, String text) {
        var color = isLiked ? likedColor : unlikedColor;
        return Text(
          count == 0 ? "love" : text,
          style: TextStyle(color: color, fontWeight: count == 0 ? FontWeight.normal : FontWeight.w700),
        );
      },
    );
  }
}
