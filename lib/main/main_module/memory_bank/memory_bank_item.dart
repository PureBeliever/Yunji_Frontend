import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_api.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_sqlite.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';

class MemoryBankList extends StatelessWidget {
  final List<Map<String, dynamic>>? refreshofMemoryBankextends;
  final Function(int) onItemTap;

  const MemoryBankList({super.key, 
    required this.refreshofMemoryBankextends,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 500,
      itemCount: refreshofMemoryBankextends?.length ?? 0,
      itemBuilder: (context, index) {
        return MemoryBankItem(
          data: refreshofMemoryBankextends?[index],
          onTap: () => onItemTap(index),
        );
      },
    );
  }
}

class MemoryBankItem extends StatelessWidget {
  final dynamic data;
  final VoidCallback onTap;

  const MemoryBankItem({super.key, required this.data, required this.onTap});

  String parseJson(String? jsonString, List<dynamic> subscript) {
    if (jsonString == null) return ' ';
    var value = jsonDecode(jsonString);
    return value['${subscript[0]}'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
        ),
        child: Column(
          children: [
             Divider(
              color: AppColors.Gray,
               thickness: 0.3,
              height: 0.9,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () async {
                      switchPage(context, const OtherPersonalPage());
                      await requestTheOtherPersonalData(data['user_name']);
                    },
                    icon: CircleAvatar(
                      radius: 21,
                      backgroundImage: data['head_portrait'] != null
                          ? FileImage(File(data['head_portrait']))
                          : const AssetImage(
                              'assets/personal/gray_back_head.png'),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Flexible(
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: data['name'],
                                      style: AppTextStyle.coarseTextStyle,
                                    ),
                                    TextSpan(
                                      text: ' @${data['user_name']}',
                                      style: AppTextStyle.subsidiaryText,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                             Text(
                              '·',
                              style: AppTextStyle.subsidiaryText,
                            ),
                            Text(
                              '${data['subscript'].length}个记忆项',
                              style: AppTextStyle.subsidiaryText,
                            )
                          ],
                        ),
                        Text(
                          '${data['theme']}',
                          style: AppTextStyle.textStyle,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          parseJson(data['question'], data['subscript']),
                          style: AppTextStyle.textStyle,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          parseJson(data['answer'], data['subscript']),
                          style: AppTextStyle.textStyle,
                          maxLines: 7,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        LikeButtonRow(data: data),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class LikeButtonRow extends StatelessWidget {
  final dynamic data;
  const LikeButtonRow({super.key, required this.data});

  Widget buildLikeButton({
    required Color startColor,
    required Color endColor,
    required Color dotPrimaryColor,
    required Color dotSecondaryColor,
    required IconData likedIcon,
    required IconData unlikedIcon,
    required Color likedColor,
    required int likeCount,
    required Future<bool> Function(bool) onTap,
    required List<int> memoryBankIds,
  }) {
    return LikeButton(
      circleColor: CircleColor(start: startColor, end: endColor),
      bubblesColor: BubblesColor(
        dotPrimaryColor: dotPrimaryColor,
        dotSecondaryColor: dotSecondaryColor,
      ),
      size: 20,
      onTap: onTap,
      likeBuilder: (bool isLiked) {
        return Icon(
          isLiked ? likedIcon : unlikedIcon,
          color: isLiked ? likedColor : AppColors.Gray,
          size: 20,
        );
      },
      isLiked: memoryBankIds.contains(data['id']),
      likeCount: likeCount,
      countBuilder: (int? count, bool isLiked, String text) {
        var color = isLiked ? likedColor : AppColors.Gray;
        return Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildLikeButtonContainer(
          startColor: const Color.fromARGB(255, 42, 91, 255),
          endColor: const Color.fromARGB(255, 142, 204, 255),
          dotPrimaryColor: const Color.fromARGB(255, 0, 153, 255),
          dotSecondaryColor: const Color.fromARGB(255, 195, 238, 255),
          likedIcon: Icons.swap_calls,
          unlikedIcon: Icons.swap_calls,
          likedColor: Colors.blue,
          likeCount: data['pull'],
          onTap: (isLiked) async {
            final List<int> changeUserPulledMemoryBankIndex =
                userPersonalInformationManagement.userPulledMemoryBankIndex;
            if (!isLiked) {
              await addPersonalMemoryBankData(data);
              if (!changeUserPulledMemoryBankIndex.contains(data['id'])) {
                changeUserPulledMemoryBankIndex.add(data['id']);
              }
              await synchronizeMemoryBankData(
                  changeUserPulledMemoryBankIndex,
                  'pull_list',
                  data['id'],
                  1,
                  'pull');
            } else {
              if (changeUserPulledMemoryBankIndex.contains(data['id'])) {
                changeUserPulledMemoryBankIndex.remove(data['id']);
              }
              await synchronizeMemoryBankData(
                  changeUserPulledMemoryBankIndex,
                  'pull_list',
                  data['id'],
                  -1,
                  'pull');
              if (!userPersonalInformationManagement
                      .userPulledMemoryBankIndex
                      .contains(data['id']) &&
                  !userPersonalInformationManagement
                      .userLikedMemoryBankIndex
                      .contains(data['id']) &&
                  !userPersonalInformationManagement
                      .userReviewMemoryBankIndex
                      .contains(data['id'])) {
                deletePersonalMemoryBankData(data['id']);
              }
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userPulledMemoryBankIndex,
        ),
        const Spacer(flex: 1),
        buildLikeButtonContainer(
          startColor: const Color.fromARGB(255, 253, 156, 46),
          endColor: const Color.fromARGB(255, 255, 174, 120),
          dotPrimaryColor: const Color.fromARGB(255, 255, 102, 0),
          dotSecondaryColor: const Color.fromARGB(255, 255, 212, 163),
          likedIcon: Icons.folder,
          unlikedIcon: Icons.folder_open,
          likedColor: Colors.orange,
          likeCount: data['collect'],
          onTap: (isLiked) async {
            List<int> changeUserCollectedMemoryBankIndex =
                userPersonalInformationManagement.userCollectedMemoryBankIndex;
            if (!isLiked) {
              if (!changeUserCollectedMemoryBankIndex.contains(data['id'])) {
                changeUserCollectedMemoryBankIndex.add(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserCollectedMemoryBankIndex,
                  'collect_list',
                  data['id'],
                  1,
                  'collect');
            } else {
              if (changeUserCollectedMemoryBankIndex.contains(data['id'])) {
                changeUserCollectedMemoryBankIndex.remove(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserCollectedMemoryBankIndex,
                  'collect_list',
                  data['id'],
                  -1,
                  'collect');
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userCollectedMemoryBankIndex,
        ),
        const Spacer(flex: 1),
        buildLikeButtonContainer(
          startColor: const Color.fromARGB(255, 255, 64, 64),
          endColor: const Color.fromARGB(255, 255, 206, 206),
          dotPrimaryColor: const Color.fromARGB(255, 255, 0, 0),
          dotSecondaryColor: const Color.fromARGB(255, 255, 186, 186),
          likedIcon: Icons.favorite,
          unlikedIcon: Icons.favorite_border,
          likedColor: Colors.red,
          likeCount: data['like'],
          onTap: (isLiked) async {
            List<int> changeUserLikedMemoryBankIndex =
                userPersonalInformationManagement.userLikedMemoryBankIndex;
            if (!isLiked) {
              addPersonalMemoryBankData(data);
              if (!changeUserLikedMemoryBankIndex.contains(data['id'])) {
                changeUserLikedMemoryBankIndex.add(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserLikedMemoryBankIndex,
                  'like_list',
                  data['id'],
                  1,
                  '`like`');
            } else {
              if (changeUserLikedMemoryBankIndex.contains(data['id'])) {
                changeUserLikedMemoryBankIndex.remove(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserLikedMemoryBankIndex,
                  'like_list',
                  data['id'],
                  -1,
                  '`like`');
              if (!userPersonalInformationManagement
                      .userPulledMemoryBankIndex
                      .contains(data['id']) &&
                  !userPersonalInformationManagement
                      .userLikedMemoryBankIndex
                      .contains(data['id']) &&
                  !userPersonalInformationManagement
                      .userReviewMemoryBankIndex
                      .contains(data['id'])) {
                deletePersonalMemoryBankData(data['id']);
              }
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userLikedMemoryBankIndex,
        ),
        const Spacer(flex: 1),
        buildLikeButtonContainer(
          startColor: const Color.fromARGB(255, 237, 42, 255),
          endColor: const Color.fromARGB(255, 185, 142, 255),
          dotPrimaryColor: const Color.fromARGB(255, 225, 0, 255),
          dotSecondaryColor: const Color.fromARGB(255, 233, 195, 255),
          likedIcon: Icons.messenger,
          unlikedIcon: Icons.messenger_outline,
          likedColor: Colors.purpleAccent,
          likeCount: data['reply'],
          onTap: (isLiked) async {
            List<int> changeUserReplyMemoryBankIndex =
                userPersonalInformationManagement.userReplyMemoryBankIndex;
            if (!isLiked) {
              if (!changeUserReplyMemoryBankIndex.contains(data['id'])) {
                changeUserReplyMemoryBankIndex.add(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserReplyMemoryBankIndex,
                  'reply_list',
                  data['id'],
                  1,
                  'reply');
            } else {
              if (changeUserReplyMemoryBankIndex.contains(data['id'])) {
                changeUserReplyMemoryBankIndex.remove(data['id']);
              }
              synchronizeMemoryBankData(
                  changeUserReplyMemoryBankIndex,
                  'reply_list',
                  data['id'],
                  -1,
                  'reply');
            }
            return !isLiked;
          },
          memoryBankIds:
              userPersonalInformationManagement.userReplyMemoryBankIndex,
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget buildLikeButtonContainer({
    required Color startColor,
    required Color endColor,
    required Color dotPrimaryColor,
    required Color dotSecondaryColor,
    required IconData likedIcon,
    required IconData unlikedIcon,
    required Color likedColor,
    required int likeCount,
    required Future<bool> Function(bool) onTap,
    required List<int> memoryBankIds,
  }) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildLikeButton(
            startColor: startColor,
            endColor: endColor,
            dotPrimaryColor: dotPrimaryColor,
            dotSecondaryColor: dotSecondaryColor,
            likedIcon: likedIcon,
            unlikedIcon: unlikedIcon,
            likedColor: likedColor,
            likeCount: likeCount,
            onTap: onTap,
            memoryBankIds: memoryBankIds,
          ),
        ],
      ),
    );
  }
}
