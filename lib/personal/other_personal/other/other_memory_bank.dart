import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_api.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_sqlite.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/main/global.dart';
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

  Map<String, dynamic> memoryBankValue = {};
  int memoryCount = 0;
  List<int> memoryIndices = [];
  Map<String, dynamic> problemCount = {};
  Map<String, dynamic> answerCount = {};
  String memoryTitle = '';

  void initMemoryData(Map<String, dynamic> memoryData) {
    memoryBankValue = memoryData;
    memoryTitle = memoryData['theme'];
    memoryCount = (memoryData['subscript'] as List).length;
    memoryIndices = List<int>.from(memoryData['subscript']);
    problemCount = jsonDecode(memoryData['question']);
    answerCount = jsonDecode(memoryData['answer']);
  }
}

List<Item> generateItems(int itemCount, List<int> indices,
    Map<String, dynamic> questions, Map<String, dynamic> answers) {
  return List<Item>.generate(itemCount, (index) {
    return Item(
      headerValue: questions[indices[index].toString()] ?? '',
      expandedValue: answers[indices[index].toString()] ?? '',
    );
  });
}

class _OtherMemoryBankState extends State<OtherMemoryBank> {
  late final List<Item> _data;
  final viewPostDataManagementForMemoryBanks =
    Get.put(ViewPostDataManagementForMemoryBanks());
  @override
  void initState() {
    super.initState();
    _data = generateItems(
      viewPostDataManagementForMemoryBanks.memoryCount,
      viewPostDataManagementForMemoryBanks.memoryIndices,
      viewPostDataManagementForMemoryBanks.problemCount,
      viewPostDataManagementForMemoryBanks.answerCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: AppColors.iconColorTwo,
            )),
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.3),
          child: Container(
            color: AppColors.Gray,
            height: 0.3,
          ),
        ),
        title: Text(
          viewPostDataManagementForMemoryBanks.memoryTitle,
          style: AppTextStyle.titleStyle,
        ),
      ),
      body: ListView(
        children: [
          InkWell(
            onTap: () async {
              Navigator.pushNamed(context, '/other_memory_bank/other_personal_page');
              await requestTheOtherPersonalData(
                  viewPostDataManagementForMemoryBanks.memoryBankValue['user_name']);
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
                        backgroundImage: viewPostDataManagementForMemoryBanks.memoryBankValue['head_portrait'] != null
                            ? FileImage(File(viewPostDataManagementForMemoryBanks.memoryBankValue['head_portrait']))
                            : const AssetImage('assets/personal/gray_back_head.png'),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            viewPostDataManagementForMemoryBanks.memoryBankValue['name'],
                            style:AppTextStyle.coarseTextStyle
                          ),
                          Text(
                            '@${viewPostDataManagementForMemoryBanks.memoryBankValue['user_name']}',
                            style: AppTextStyle.subsidiaryText,
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
                        backgroundColor: AppColors.iconColor,
                      ),
                      child: Text(
                        "关注",
                        style: AppTextStyle.whiteTextStyle
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          ExpansionPanelList(
            materialGapSize: 15, 
            elevation: 0,
            dividerColor: AppColors.background,
            expandIconColor: AppColors.iconColorTwo,
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _data[index].isExpanded = isExpanded;
              });
            },
            children: _data.map<ExpansionPanel>((Item item) {
              return ExpansionPanel(
                backgroundColor: AppColors.background,
                headerBuilder: (BuildContext context, bool isExpanded) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        item.isExpanded = !isExpanded;
                      });
                    },
                    child: ListTile(
                      title: Text(
                        item.headerValue,
                        style: AppTextStyle.textStyle
                      ),
                    ),
                  );
                },
                body: ListTile(
                  title: Text(item.expandedValue,
                      style: AppTextStyle.textStyle),
                ),
                isExpanded: item.isExpanded,
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
               Divider(
                  color: AppColors.Gray,
                  thickness: 0.3,
                  height: 25,
                ),
                _buildInfoRow(),
                Divider(
                  color: AppColors.Gray,
                  thickness: 0.3,
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
           Divider(
            color: AppColors.Gray,
            thickness: 0.3,
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
          '${viewPostDataManagementForMemoryBanks.memoryBankValue['pull']} ',
          '拉取',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.memoryBankValue['collect']} ',
          '收藏',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.memoryBankValue['like']} ',
          '喜欢',
        ),
        const Spacer(flex: 2),
        _buildInfoText(
          '${viewPostDataManagementForMemoryBanks.memoryBankValue['reply']} ',
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
          style: AppTextStyle.coarseTextStyle
        ),
        Text(
          label,
          style: AppTextStyle.textStyle
        ),
      ],
    );
  }

  Widget _buildLikeButtonsRow() {
    return Row(
      children: [
        const SizedBox(width: 10),
        _buildLikeButton(
          likeIcon: Icons.swap_calls,
          unLikeIcon: Icons.swap_calls,
          color: Colors.blue,
          circleColor: const CircleColor(
            start: Color.fromARGB(255, 42, 91, 255),
            end: Color.fromARGB(255, 142, 204, 255),
          ),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Color.fromARGB(255, 0, 153, 255),
            dotSecondaryColor: Color.fromARGB(255, 195, 238, 255),
          ),
          onTap: (isLiked) async {
            final List<int> changeUserPulledMemoryBankIndex =
                userPersonalInformationManagement.userPulledMemoryBankIndex;
            if (isLiked == false) {
              addPersonalMemoryBankData(viewPostDataManagementForMemoryBanks.memoryBankValue);
              changeUserPulledMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? null
                  : changeUserPulledMemoryBankIndex.add(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              await synchronizeMemoryBankData(
                  changeUserPulledMemoryBankIndex,
                  'pull_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  1,
                  'pull');
            } else {
              changeUserPulledMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? changeUserPulledMemoryBankIndex.remove(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  : null;
              await synchronizeMemoryBankData(
                  changeUserPulledMemoryBankIndex,
                  'pull_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  -1,
                  'pull');
              if (!userPersonalInformationManagement.userPulledMemoryBankIndex
                        .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id']) &&
                  !userPersonalInformationManagement.userLikedMemoryBankIndex
                      .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id']) &&
                  !userPersonalInformationManagement.userReviewMemoryBankIndex
                      .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id'])) {
                deletePersonalMemoryBankData(
                    viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              }
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userPulledMemoryBankIndex,
          memoryBank:
              viewPostDataManagementForMemoryBanks.memoryBankValue,
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          likeIcon: Icons.folder,
          unLikeIcon: Icons.folder_open,
          color: Colors.orange,
          circleColor: const CircleColor(
            start: Color.fromARGB(255, 253, 156, 46),
            end: Color.fromARGB(255, 255, 174, 120),
          ),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Color.fromARGB(255, 255, 102, 0),
            dotSecondaryColor: Color.fromARGB(255, 255, 212, 163),
          ),
          onTap: (isLiked) async {
            List<int> changeUserCollectedMemoryBankIndex =
                userPersonalInformationManagement.userCollectedMemoryBankIndex;
            if (isLiked == false) {
              changeUserCollectedMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? null
                  : changeUserCollectedMemoryBankIndex.add(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              synchronizeMemoryBankData(
                  changeUserCollectedMemoryBankIndex,
                  'collect_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  1,
                  'collect');
            } else {
              changeUserCollectedMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? changeUserCollectedMemoryBankIndex.remove(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  : null;
              synchronizeMemoryBankData(
                  changeUserCollectedMemoryBankIndex,
                  'collect_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  -1,
                  'collect');
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userCollectedMemoryBankIndex,
          memoryBank:
              viewPostDataManagementForMemoryBanks.memoryBankValue,
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          likeIcon: Icons.favorite,
          unLikeIcon: Icons.favorite_border,
          color: Colors.red,
          circleColor: const CircleColor(
            start: Color.fromARGB(255, 255, 64, 64),
            end: Color.fromARGB(255, 255, 206, 206),
          ),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Color.fromARGB(255, 255, 0, 0),
            dotSecondaryColor: Color.fromARGB(255, 255, 186, 186),
          ),
          onTap: (isLiked) async {
            List<int> changeUserLikedMemoryBankIndex =
                userPersonalInformationManagement.userLikedMemoryBankIndex;
            if (isLiked == false) {
              addPersonalMemoryBankData(viewPostDataManagementForMemoryBanks.memoryBankValue);
              changeUserLikedMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? null
                  : changeUserLikedMemoryBankIndex.add(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              synchronizeMemoryBankData(
                  changeUserLikedMemoryBankIndex,
                  'like_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  1,
                  '`like`');
            } else {
              changeUserLikedMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? changeUserLikedMemoryBankIndex.remove(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  : null;
              synchronizeMemoryBankData(
                  changeUserLikedMemoryBankIndex,
                  'like_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  -1,
                  '`like`');
              if (!userPersonalInformationManagement.userPulledMemoryBankIndex
                        .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id']) &&
                  !userPersonalInformationManagement.userLikedMemoryBankIndex
                      .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id']) &&
                  !userPersonalInformationManagement.userReviewMemoryBankIndex
                      .contains(viewPostDataManagementForMemoryBanks.memoryBankValue['id'])) {
                deletePersonalMemoryBankData(
                    viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              }
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userLikedMemoryBankIndex,
          memoryBank:
              viewPostDataManagementForMemoryBanks.memoryBankValue,
        ),
        const Spacer(flex: 1),
        _buildLikeButton(
          likeIcon: Icons.messenger,
          unLikeIcon: Icons.messenger_outline,
          color: Colors.purpleAccent,
          circleColor: const CircleColor(
            start: Color.fromARGB(255, 237, 42, 255),
            end: Color.fromARGB(255, 185, 142, 255),
          ),
          bubblesColor: const BubblesColor(
            dotPrimaryColor: Color.fromARGB(255, 225, 0, 255),
            dotSecondaryColor: Color.fromARGB(255, 233, 195, 255),
          ),
          onTap: (isLiked) async {
            List<int> changeUserReplyMemoryBankIndex =
                userPersonalInformationManagement.userReplyMemoryBankIndex;
            if (isLiked == false) {
              changeUserReplyMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? null
                  : changeUserReplyMemoryBankIndex.add(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id']);
              synchronizeMemoryBankData(
                  changeUserReplyMemoryBankIndex,
                  'reply_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  1,
                  'reply');
            } else {
              changeUserReplyMemoryBankIndex.contains(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  ? changeUserReplyMemoryBankIndex.remove(
                      viewPostDataManagementForMemoryBanks.memoryBankValue['id'])
                  : null;
              synchronizeMemoryBankData(
                  changeUserReplyMemoryBankIndex,
                  'reply_list',
                  viewPostDataManagementForMemoryBanks.memoryBankValue['id'],
                  -1,
                  'reply');
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userReplyMemoryBankIndex,
          memoryBank:
              viewPostDataManagementForMemoryBanks.memoryBankValue,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildLikeButton({
    required IconData likeIcon,
    required IconData unLikeIcon,
    required Color color,
    required CircleColor circleColor,
    required BubblesColor bubblesColor,
    required Future<bool> Function(bool) onTap,
    required List<int> memoryBankIds,
    required dynamic memoryBank,
  }) {
    return LikeButton(
      circleColor: circleColor,
      bubblesColor: bubblesColor,
      onTap: onTap,
      likeBuilder: (bool isLiked) => Icon(
        isLiked ? likeIcon : unLikeIcon,
        color: isLiked ? color : AppColors.Gray,
        size: 25,
      ),
      isLiked: memoryBankIds.contains(memoryBank['id']),
      countBuilder: (int? count, bool isLiked, String text) {
        var colorValue = isLiked ? color : const Color.fromRGBO(84, 87, 105, 1);
        return Text(
          count == 0 ? "love" : text,
          style: TextStyle(
              color: colorValue,
              fontWeight: count == 0 ? FontWeight.normal : FontWeight.w700),
        );
      },
    );
  }
}
