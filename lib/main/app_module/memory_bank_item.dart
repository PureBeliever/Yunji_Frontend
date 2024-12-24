import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/home/home_page/home_page.dart';

// 记忆库帖子的页面设置

class MemoryBankList extends StatelessWidget {
  List<Map<String, dynamic>>?  refreshofMemoryBankextends;
  final Function(int) onItemTap;

  MemoryBankList({
    required this.refreshofMemoryBankextends,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      cacheExtent: 500,
      itemCount:
          refreshofMemoryBankextends?.length ?? 0,
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
  String _typeConversion(String? data, var index) {
    if (data != null) {
      var decodedData = jsonDecode(data);
      var indexValue = index;
      return decodedData.containsKey('${indexValue[0]}')
          ? decodedData['${indexValue[0]}']
          : '';
    } else {
      return ' ';
    }
  }

  MemoryBankItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          const Divider(
            color: Color.fromRGBO(223, 223, 223, 1),
            thickness: 0.9,
            height: 0.9,
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 3.0, bottom: 3.0, right: 15, left: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头像按钮
                IconButton(
                  onPressed: () {
                    // 处理头像按钮点击事件
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
                      // 名称和用户名
                      Row(
                        children: [
                          Flexible(
                            child: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: data['name'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' @${data['user_name']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(84, 87, 105, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Text(
                            '·',
                            style: TextStyle(
                                fontSize: 17,
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${data['subscript'].length}个记忆项',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(84, 87, 105, 1),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                      // 主题
                      Text(
                        '${data['theme']}',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      // 问题
                      Text(
                        _typeConversion(data['question'], data['subscript']),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      // 回复
                      Text(
                        _typeConversion(data['reply'], data['subscript']),
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      // 点赞按钮行
                      LikeButtonRow(),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }
}

// LikeButtonRow.dart
class LikeButtonRow extends StatelessWidget {

  Widget buildLikeButton({
    required Color startColor,
    required Color endColor,
    required Color dotPrimaryColor,
    required Color dotSecondaryColor,
    required IconData likedIcon,
    required IconData unlikedIcon,
    required Color likedColor,
    required Color unlikedColor,
    required Future<bool> Function(bool) onTap,
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
          color: isLiked ? likedColor : unlikedColor,
          size: 20,
        );
      },
      countBuilder: (int? count, bool isLiked, String text) {
        var color = isLiked ? likedColor : unlikedColor;
        Widget result;
        if (count == 0) {
          result = Text(
            "love",
            style: TextStyle(color: color),
          );
        }
        result = Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        );
        return result;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildLikeButton(
                startColor: Color.fromARGB(255, 42, 91, 255),
                endColor: Color.fromARGB(255, 142, 204, 255),
                dotPrimaryColor: Color.fromARGB(255, 0, 153, 255),
                dotSecondaryColor: Color.fromARGB(255, 195, 238, 255),
                likedIcon: Icons.swap_calls,
                unlikedIcon: Icons.swap_calls,
                likedColor: Colors.blue,
                unlikedColor: Color.fromRGBO(84, 87, 105, 1),
                onTap: (isLiked) async {
                  return !isLiked;
                },
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
        SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildLikeButton(
                startColor: Color.fromARGB(255, 253, 156, 46),
                endColor: Color.fromARGB(255, 255, 174, 120),
                dotPrimaryColor: Color.fromARGB(255, 255, 102, 0),
                dotSecondaryColor: Color.fromARGB(255, 255, 212, 163),
                likedIcon: Icons.folder,
                unlikedIcon: Icons.folder_open,
                likedColor: Colors.orange,
                unlikedColor: Color.fromRGBO(84, 87, 105, 1),
                onTap: (isLiked) async {
                  return !isLiked;
                },
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
        SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildLikeButton(
                startColor: Color.fromARGB(255, 255, 64, 64),
                endColor: Color.fromARGB(255, 255, 206, 206),
                dotPrimaryColor: Color.fromARGB(255, 255, 0, 0),
                dotSecondaryColor: Color.fromARGB(255, 255, 186, 186),
                likedIcon: Icons.favorite,
                unlikedIcon: Icons.favorite_border,
                likedColor: Colors.red,
                unlikedColor: Color.fromRGBO(84, 87, 105, 1),
                onTap: (isLiked) async {
                  return !isLiked;
                },
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),
        SizedBox(
          width: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildLikeButton(
                startColor: Color.fromARGB(255, 237, 42, 255),
                endColor: Color.fromARGB(255, 185, 142, 255),
                dotPrimaryColor: Color.fromARGB(255, 225, 0, 255),
                dotSecondaryColor: Color.fromARGB(255, 233, 195, 255),
                likedIcon: Icons.messenger,
                unlikedIcon: Icons.messenger_outline,
                likedColor: Colors.purpleAccent,
                unlikedColor: Color.fromRGBO(84, 87, 105, 1),
                onTap: (isLiked) async {
                  return !isLiked;
                },
              ),
            ],
          ),
        ),
        const Spacer(flex: 2),

      ],
    );
  }
}
