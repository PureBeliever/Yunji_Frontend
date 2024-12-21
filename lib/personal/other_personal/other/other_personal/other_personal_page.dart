// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:keframe/keframe.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/switch/switch_page.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_background_image.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_head_portrait.dart';
import 'package:yunji/modified_component/sliver_header_delegate.dart';
import 'package:yunji/personal/personal/personal/personal_page.dart';
import 'package:yunji/setting/setting_account_user_name.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/other_personal/other_personal_sqlite.dart';


class Jiyikudianjipersonal extends StatefulWidget {
  const Jiyikudianjipersonal({super.key});

  @override
  State<Jiyikudianjipersonal> createState() => _JiyikudianjipersonalPageState();
}

//信息列表滚动数据管理
class OtherPeopleInformationListScrollDataManagement extends GetxController {
  static OtherPeopleInformationListScrollDataManagement get to => Get.find();
//背景状态
  bool backgroundState = false;
  //模糊度
  double filter = 0.0;

  //透明度
  double opacity = 0.0;
  //显示文本
  String displayText = '记忆库';
  //滚动数据
  Map<String, dynamic> scrollDataValue = {};

//初始化滚动数据
  void initialScrollData(Map<String, dynamic> scrollData) {
    scrollDataValue = scrollData;
  }

//计算显示的列表名
  void calculateTheListName(int ind) {
    //其他人创建的记忆库列表名
    String createdMemoryBankListName = ind == 0 ? '记忆库' : '';
    //其他人拉取的记忆库列表名
    String pulledMemoryBankListName = ind == 1 ? '拉取' : '';
    //其他人回复的记忆库列表名
    String replyMemoryBankListName = ind == 2 ? '回复' : '';
    //其他人喜欢的记忆库列表名
    String likedMemoryBankListName = ind == 3 ? '喜欢' : '';
    //计算显示的列表名
    displayText = createdMemoryBankListName +
        pulledMemoryBankListName +
        replyMemoryBankListName +
        likedMemoryBankListName;
    update();
  }

//退出页面时清空数据
  void clearData() {
    backgroundState = false;
    filter = 0.0;
    opacity = 0.0;
    displayText = '记忆库';
  }

//设置滚动变化时的背景颜色
  void setBackgroundColortrue() {
    filter = 3;
    backgroundState = true;
    update();
  }

//设置滚动变化时的背景颜色
  void setBackgroundColorfalse() {
    filter = 0;
    backgroundState = false;
    update();
  }

//设置透明度显示文本
  void setTransparencyToDisplayText() {
    opacity = 1;
    update();
  }

//设置透明度隐藏文本
  void setTransparencyToHideText() {
    opacity = 0;
    update();
  }
}


// 其他人的个人信息管理
class OtherPeoplePersonalInformationManagement extends GetxController {
  static OtherPeoplePersonalInformationManagement get to => Get.find();

  //其他人喜欢的记忆库
  List<Map<String, dynamic>>? otherPeopleLikedMemoryBank = [];

  //其他人拉取的记忆库
  List<Map<String, dynamic>>? otherPeoplePulledMemoryBank = [];

  //其他人创建的记忆库
  List<Map<String, dynamic>>? otherPeopleCreatedMemoryBank = [];

  //用户喜欢的记忆库下标
  List<int> otherPeopleLikedMemoryBankIndex = [];
  //用户收藏的记忆库下标
  List<int> otherPeopleCollectedMemoryBankIndex = [];
  //用户拉取的记忆库下标
  List<int> otherPeoplePulledMemoryBankIndex = [];
  //用户回复的记忆库下标
  List<int> otherPeopleReplyMemoryBankIndex = [];
  //用户创建的记忆库下标
  List<int> otherPeopleCreatedMemoryBankIndex = [];
//显示文本
  String displayText = ' ';
//计算每个页面的记忆库数量
  void calculateTheNumberOfMemoryBanksPerPage(int currentPageSubscript) {
    //创建的记忆库数量String类型
    String otherPeopleCollectedMemoryBankIndexString = currentPageSubscript == 0
        ? '${otherPeopleCreatedMemoryBankIndex!.length}个'
        : '';
    //拉取的记忆库数量String类型
    String otherPeoplePulledMemoryBankIndexString = currentPageSubscript == 1
        ? '${otherPeoplePulledMemoryBankIndex!.length}个'
        : '';
    //回复的记忆库数量String类型
    String otherPeopleReplyMemoryBankIndexString = currentPageSubscript == 2
        ? '${otherPeopleReplyMemoryBankIndex!.length}个'
        : '';
    //喜欢的记忆库数量String类型
    String otherPeopleLikedMemoryBankIndexString = currentPageSubscript == 3
        ? '${otherPeopleLikedMemoryBankIndex!.length}个'
        : '';
    displayText = otherPeopleCollectedMemoryBankIndexString +
        otherPeoplePulledMemoryBankIndexString +
        otherPeopleReplyMemoryBankIndexString +
        otherPeopleLikedMemoryBankIndexString;
    update();
  }

//读取用户数据库个人信息刷新数据
  void readDatabaseRefreshData() async {
    otherPeopleLikedMemoryBank =
        await queryOtherPeoplePersonalMemoryBank(otherPeopleLikedMemoryBankIndex);

    otherPeoplePulledMemoryBank =
        await queryOtherPeoplePersonalMemoryBank(otherPeoplePulledMemoryBankIndex);

    otherPeopleCreatedMemoryBank =
        await queryOtherPeoplePersonalMemoryBank(otherPeopleCreatedMemoryBankIndex);

    update();
  }

//请求后端其他人的个人信息数据
  void requestOtherPeoplePersonalInformationDataOnTheBackEnd(
      Map<String, dynamic> otherPeoplePersonalInformationData) async {
    if (otherPeoplePersonalInformationData['xihuan'] != null) {
      var otherPeopleLikedMemoryBankIndexint =
          otherPeoplePersonalInformationData['xihuan'].cast<int>();
      otherPeopleLikedMemoryBankIndex = otherPeopleLikedMemoryBankIndexint;
      otherPeopleLikedMemoryBank = await queryOtherPeoplePersonalMemoryBank(otherPeopleLikedMemoryBankIndexint);
    }

    if (otherPeoplePersonalInformationData['shoucang'] != null) {
      var otherPeopleCollectedMemoryBankIndexint =
          otherPeoplePersonalInformationData['shoucang'].cast<int>();
      otherPeopleCollectedMemoryBankIndex =
          otherPeopleCollectedMemoryBankIndexint;
    }

    if (otherPeoplePersonalInformationData['laqu'] != null) {
      var otherPeoplePulledMemoryBankIndexint =
          otherPeoplePersonalInformationData['laqu'].cast<int>();
      otherPeoplePulledMemoryBankIndex = otherPeoplePulledMemoryBankIndexint;
      otherPeoplePulledMemoryBank = await queryOtherPeoplePersonalMemoryBank(otherPeoplePulledMemoryBankIndexint);
    }

    if (otherPeoplePersonalInformationData['tiwen'] != null) {
      var otherPeopleReplyMemoryBankIndexint =
          otherPeoplePersonalInformationData['tiwen'].cast<int>();
      otherPeopleReplyMemoryBankIndex = otherPeopleReplyMemoryBankIndexint;
    }

    if (otherPeoplePersonalInformationData['wode'] != null) {
      var otherPeopleCreatedMemoryBankIndexint =
          otherPeoplePersonalInformationData['wode'].cast<int>();
      otherPeopleCreatedMemoryBankIndex = otherPeopleCreatedMemoryBankIndexint;
      otherPeopleCreatedMemoryBank = await queryOtherPeoplePersonalMemoryBank(otherPeopleCreatedMemoryBankIndexint);
    }
    update();
  }

}

class _JiyikudianjipersonalPageState extends State<Jiyikudianjipersonal>
    with TickerProviderStateMixin {
  late TabController tabController;
  final otherPeopleBackgroundImageChangeManagement = Get.put(OtherPeopleBackgroundImageChangeManagement());
  final otherPeopleHeadPortraitChangeManagement = Get.put(OtherPeopleHeadPortraitChangeManagement());

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    otherPeopleInformationListScrollDataManagement.clearData();
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    )..addListener(() {
        otherPeopleInformationListScrollDataManagement.calculateTheListName(tabController.index);
        otherPeoplePersonalInformationManagement
            .calculateTheNumberOfMemoryBanksPerPage(tabController.index);
      });
    tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          scrollController.addListener(() {
            if (scrollController.offset >= 160) {
                otherPeopleInformationListScrollDataManagement.setBackgroundColortrue();
            } else if (scrollController.offset < 160) {
              otherPeopleInformationListScrollDataManagement.setBackgroundColorfalse();
            }
            if (scrollController.offset >= 235) {
                otherPeopleInformationListScrollDataManagement.setTransparencyToDisplayText();
            } else if (scrollController.offset < 235) {
                otherPeopleInformationListScrollDataManagement.setTransparencyToHideText();
            }
          });
        }));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
      requestTheOtherPersonalData(otherPeopleInformationListScrollDataManagement.scrollDataValue['username']);
  }

  String timuzhi(String? timu, var xiabiao) {
    if (timu != null) {
      var zhi = jsonDecode(timu);
      var index = xiabiao;

      return zhi.containsKey('${index[0]}') ? zhi['${index[0]}'] : '';
    } else {
      return ' ';
    }
  }

  String huida(String? huida, var xiabiao) {
    if (huida != null) {
      var zhi = jsonDecode(huida);
      var index = xiabiao;

      return zhi.containsKey('${index[0]}') ? zhi['${index[0]}'] : '';
    } else {
      return ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: EasyRefresh.builder(
          callRefreshOverOffset: 5,
          header: ClassicHeader(
              processedText: '刷新完成',
              armedText: '松手以刷新',
              processingText: '正在刷新',
              dragText: '下拉可刷新',
              readyText: '正在刷新',
              iconDimension: 100,
              textDimension: 190,
              iconTheme: const IconThemeData(color: Colors.white, size: 28),
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
              messageBuilder: (context, state, text, dateTime) {
                TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);

                int hour = timeOfDay.hour;
                int minute = timeOfDay.minute;

                return Text(
                  '更新于$hour:$minute',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                );
              },
              messageStyle: const TextStyle(color: Colors.white)),
          onRefresh: _refresh,
          childBuilder: (context, physics) {
            return NestedScrollView(
              physics: physics,
              controller: scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: GetBuilder<OtherPeopleInformationListScrollDataManagement>(
                          init: otherPeopleInformationListScrollDataManagement,
                          builder: (otherPeopleInformationListScrollDataManagement) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  otherPeopleInformationListScrollDataManagement.scrollDataValue['name'],
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                        otherPeopleInformationListScrollDataManagement
                                            .opacity),
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  otherPeoplePersonalInformationManagement
                                          .displayText +
                                        otherPeopleInformationListScrollDataManagement
                                          .displayText,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(
                                        otherPeopleInformationListScrollDataManagement
                                            .opacity),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            );
                          }),
                    ),
                    pinned: true,
                    leading: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // 设置Container的形状为圆形
                            color: Colors.black
                                .withOpacity(0.5), // 设置Container的背景颜色
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 25,
                              color: Colors.white,
                            ),
                          )),
                    ),
                    actions: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // 设置Container的形状为圆形
                          color:
                              Colors.black.withOpacity(0.5), // 设置Container的背景颜色
                        ),
                        child: SvgPicture.asset(
                          'assets/sousuo.svg',
                          width: 25,
                          height: 25,
                          // ignore: deprecated_member_use
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 13.0, right: 16.0),
                        child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // 设置Container的形状为圆形
                              color: Colors.black
                                  .withOpacity(0.5), // 设置Container的背景颜色
                            ),
                            child: const Icon(Icons.more_vert,
                                size: 25, color: Colors.white)),
                      ),
                    ],
                    expandedHeight: 215,
                    flexibleSpace: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        double percent =
                            ((constraints.maxHeight - kToolbarHeight) *
                                40 /
                                (200 - kToolbarHeight));

                        double dx = 0;
                        double size = 0;

                        dx = 68 - percent * 1.20;
                        size = (80 + percent * 2) / 100;

                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Positioned.fill(
                              child: GetBuilder<
                                  OtherPeopleInformationListScrollDataManagement>(
                                init: otherPeopleInformationListScrollDataManagement,
                                builder: (otherPeopleInformationListScrollDataManagement) {
                                  return ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaX:
                                            otherPeopleInformationListScrollDataManagement
                                                .filter,
                                        sigmaY: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        otherPeopleBackgroundImageChangeManagement.initBackgroundImage(
                                            otherPeopleInformationListScrollDataManagement
                                                .scrollDataValue['beijing']);
                                        switchPage(
                                            context, const JiyikuPersonalBei());
                                      },
                                      child: otherPeopleInformationListScrollDataManagement
                                                  .scrollDataValue['beijing'] !=
                                              null
                                          ? Image.file(
                                              File(
                                                  otherPeopleInformationListScrollDataManagement
                                                      .scrollDataValue['beijing']),
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/chuhui.png',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              height: 90,
                              top: 0,
                              left: 0,
                              right: 0,
                              child: GetBuilder<
                                  OtherPeopleInformationListScrollDataManagement>(
                                init: otherPeopleInformationListScrollDataManagement,
                                builder: (otherPeopleInformationListScrollDataManagement) {
                                  return AnimatedContainer(
                                    duration: Duration(
                                        seconds:
                                            otherPeopleInformationListScrollDataManagement
                                                    .backgroundState
                                                ? 1
                                                : 0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(
                                              otherPeopleInformationListScrollDataManagement
                                                      .backgroundState
                                                  ? 0.5
                                                  : 0),
                                          Colors.black.withOpacity(0.8)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..scale(size)
                                  ..translate(
                                      dx,
                                      constraints.maxHeight / 2.3 -
                                          0.06 * kToolbarHeight),
                                child: GestureDetector(
                                  onTap: () {
                                    otherPeopleHeadPortraitChangeManagement.initHeadPortrait(
                                        otherPeopleInformationListScrollDataManagement
                                            .scrollDataValue['touxiang']);
                                    switchPage(context,
                                        const Jiyikudianjipersonalhead());
                                  },
                                  child: CircleAvatar(
                                    radius: 27,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          otherPeopleInformationListScrollDataManagement
                                                      .scrollDataValue['touxiang'] !=
                                                  null
                                              ? FileImage(File(
                                                  otherPeopleInformationListScrollDataManagement
                                                      .scrollDataValue['touxiang']))
                                              : const AssetImage(
                                                  'assets/chuhui.png'),
                                      radius: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 14.0, right: 8.0, top: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      otherPeopleHeadPortraitChangeManagement.initHeadPortrait(
                                          otherPeopleInformationListScrollDataManagement
                                              .scrollDataValue['touxiang']);
                                      switchPage(context,
                                          const Jiyikudianjipersonalhead());
                                    },
                                    child: Container(
                                      width: 90,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft:
                                              Radius.circular(60), // 左下角圆角
                                          bottomRight:
                                              Radius.circular(60), // 右下角圆角
                                        ),
                                      ), // 设置颜色
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, top: 8),
                                    child: SizedBox(
                                      height: 35,
                                      width: 70,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(0),
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: const Text(
                                          "关注",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white),
                                        ),
                                        onPressed: () {},
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                otherPeopleInformationListScrollDataManagement.scrollDataValue['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontFamily: 'Raleway',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              GetBuilder<UserNameChangeManagement>(
                                  init: userNameChangeManagement,
                                  builder: (userNameChangeManagement) {
                                    return Text(
                                      '@${userNameChangeManagement.userNameValue}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Color.fromRGBO(84, 87, 105, 1),
                                        fontFamily: 'Raleway',
                                        decoration: TextDecoration.none,
                                      ),
                                    );
                                  }),
                              Padding(
                                padding: const EdgeInsets.only(top: 13.0),
                                  child: otherPeopleInformationListScrollDataManagement
                                        .scrollDataValue['brief']
                                        .trim()
                                        .isNotEmpty
                                    ? Text(
                                          otherPeopleInformationListScrollDataManagement
                                            .scrollDataValue['brief'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                          color: Colors.black,
                                          fontFamily: 'Raleway',
                                          decoration: TextDecoration.none,
                                        ),
                                      )
                                    : const SizedBox(), // 如果biancontroller.brief为空，则显示一个空的SBox
                              ),
                              const SizedBox(
                                height: 13,
                              ),
                              Wrap(
                                direction: Axis.horizontal,
                                textDirection: TextDirection.ltr,
                                children: [
                                    otherPeopleInformationListScrollDataManagement
                                          .scrollDataValue['year']
                                          .trim()
                                          .isNotEmpty
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/chusheng.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '出生于 ' +
                                                    otherPeopleInformationListScrollDataManagement
                                                        .scrollDataValue['year'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      84, 87, 105, 1),
                                                  fontFamily: 'Raleway',
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 13)
                                          ],
                                        )
                                      : const SizedBox(),
                                    otherPeopleInformationListScrollDataManagement
                                          .scrollDataValue['place']
                                          .trim()
                                          .isNotEmpty
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/place.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Expanded(
                                              child: Text(
                                                otherPeopleInformationListScrollDataManagement
                                                    .scrollDataValue['place'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      84, 87, 105, 1),
                                                  fontFamily: 'Raleway',
                                                  decoration:
                                                      TextDecoration.none,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 13)
                                          ],
                                        )
                                      : const SizedBox(),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SvgPicture.asset('assets/jiaruriqi.svg',
                                          width: 20, height: 20),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(
                                        child: Text(
                                          otherPeopleInformationListScrollDataManagement
                                              .scrollDataValue['jiaru'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color:
                                                Color.fromRGBO(84, 87, 105, 1),
                                            fontFamily: 'Raleway',
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.only(top: 13.0, bottom: 13.0),
                                child: Row(
                                  children: [
                                    Text(
                                      '0',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: 'Raleway',
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      ' 正在关注    ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Color.fromRGBO(84, 87, 105, 1),
                                        fontFamily: 'Raleway',
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      '0',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontFamily: 'Raleway',
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    Text(
                                      ' 关注者',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: Color.fromRGBO(84, 87, 105, 1),
                                        fontFamily: 'Raleway',
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: SliverHeaderDelegate.fixedHeight(
                      height: 45,
                      child: Material(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: TabBar(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17.5,
                              color: Colors.black,
                              fontFamily: 'Raleway',
                              decoration: TextDecoration.none,
                            ),
                            indicatorColor: Colors.blue,
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 17,
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontFamily: 'Raleway',
                              decoration: TextDecoration.none,
                            ),
                            controller: tabController,
                            tabs: const [
                              SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    '记忆库',
                                  ),
                                ),
                              ),
                              Text(
                                '拉取',
                              ),
                              Text(
                                '回复',
                              ),
                              Text(
                                '喜欢',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: GetBuilder<UserPersonalInformationManagement>(
                  init: userPersonalInformationManagement,
                  builder: (userPersonalInformationManagement) {
                    return GetBuilder<OtherPeoplePersonalInformationManagement>(
                        init: otherPeoplePersonalInformationManagement,
                        builder: (otherPeoplePersonalInformationManagement) {
                          return TabBarView(
                            controller: tabController,
                            children: [
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: SizeCacheWidget(
                                    child: ListView.builder(
                                        cacheExtent: 500,
                                        physics: physics,
                                        itemCount: otherPeoplePersonalInformationManagement
                                                    .otherPeopleCreatedMemoryBank ==
                                                null
                                            ? 0
                                            : otherPeoplePersonalInformationManagement
                                                .otherPeopleCreatedMemoryBank
                                                ?.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              const Divider(
                                                color: Color.fromRGBO(
                                                    223, 223, 223, 1),
                                                thickness: 0.9,
                                                height: 0.9,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  viewPostDataManagementForMemoryBanks
                                                      .initTheMemoryDataForThePost(
                                                          otherPeoplePersonalInformationManagement
                                                                  .otherPeopleCreatedMemoryBank![
                                                              index]);
                                                  switchPage(context,
                                                      const jiyikudianji());
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom: 3.0,
                                                          right: 15,
                                                          left: 2),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: CircleAvatar(
                                                            radius: 21,
                                                            backgroundImage: otherPeoplePersonalInformationManagement
                                                                            .otherPeopleCreatedMemoryBank?[index]
                                                                        [
                                                                        'touxiang'] !=
                                                                    null
                                                                ? FileImage(File(
                                                                    otherPeoplePersonalInformationManagement
                                                                            .otherPeopleCreatedMemoryBank![index]
                                                                        [
                                                                        'touxiang']))
                                                                : const AssetImage(
                                                                    'assets/chuhui.png'),
                                                          )),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                                height: 5),
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        RichText(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['name'],
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ' @${otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['username']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Color.fromRGBO(84, 87, 105, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  ' ·',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              84,
                                                                              87,
                                                                              105,
                                                                              1),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900),
                                                                ),
                                                                Text(
                                                                  '${otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['xiabiao'].length}个记忆项',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Text(
                                                              '${otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['zhuti']}',
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleCreatedMemoryBank?[
                                                                          index]
                                                                      ['timu'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleCreatedMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleCreatedMemoryBank?[
                                                                          index]
                                                                      ['huida'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleCreatedMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 7,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                42,
                                                                                91,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                142,
                                                                                204,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              0,
                                                                              153,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              195,
                                                                              238,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                               
                                                                        },
                                                                 
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.swap_calls
                                                                                : Icons.swap_calls,
                                                                            color: isLiked
                                                                                ? Colors.blue
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['laqu'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.blue
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                253,
                                                                                156,
                                                                                46),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                174,
                                                                                120)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              102,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              212,
                                                                              163),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                     
                                                                        },
                                                                      
                                                                 
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.folder
                                                                                : Icons.folder_open,
                                                                            color: isLiked
                                                                                ? Colors.orange
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['shoucang'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.orange
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        size:
                                                                            20,
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                64,
                                                                                64),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                206,
                                                                                206)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              0,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              186,
                                                                              186),
                                                                        ),
                                                                        onTap:
                                                                            (isLiked) async {
                                                                       
                                                                        },
                                                                       
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: isLiked
                                                                                ? Colors.red
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['xihuan'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.red
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                237,
                                                                                42,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                185,
                                                                                142,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              225,
                                                                              0,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              233,
                                                                              195,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                     
                                                                        },
                                                          
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.messenger
                                                                                : Icons.messenger_outline,
                                                                            color: isLiked
                                                                                ? Colors.purpleAccent
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleCreatedMemoryBank?[index]['tiwen'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.purple
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                const Spacer(
                                                                    flex: 1),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          );
                                        }),
                                  )),
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: SizeCacheWidget(
                                    child: ListView.builder(
                                        cacheExtent: 500,
                                        physics: physics,
                                        itemCount: otherPeoplePersonalInformationManagement
                                                    .otherPeoplePulledMemoryBank ==
                                                null
                                            ? 0
                                            : otherPeoplePersonalInformationManagement
                                                .otherPeoplePulledMemoryBank
                                                ?.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              const Divider(
                                                color: Color.fromRGBO(
                                                    223, 223, 223, 1),
                                                thickness: 0.9,
                                                height: 0.9,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  viewPostDataManagementForMemoryBanks
                                                      .initTheMemoryDataForThePost(
                                                          otherPeoplePersonalInformationManagement
                                                                  .otherPeoplePulledMemoryBank![
                                                              index]);
                                                  switchPage(context,
                                                      const jiyikudianji());
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom: 3.0,
                                                          right: 15,
                                                          left: 2),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: CircleAvatar(
                                                            radius: 21,
                                                            backgroundImage: otherPeoplePersonalInformationManagement
                                                                            .otherPeoplePulledMemoryBank?[index]
                                                                        [
                                                                        'touxiang'] !=
                                                                    null
                                                                ? FileImage(File(
                                                                    otherPeoplePersonalInformationManagement
                                                                            .otherPeoplePulledMemoryBank![index]
                                                                        [
                                                                        'touxiang']))
                                                                : const AssetImage(
                                                                    'assets/chuhui.png'),
                                                          )),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                                height: 5),
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        RichText(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['name'],
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ' @${otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['username']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Color.fromRGBO(84, 87, 105, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  ' ·',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              84,
                                                                              87,
                                                                              105,
                                                                              1),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900),
                                                                ),
                                                                Text(
                                                                  '${otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['xiabiao'].length}个记忆项',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Text(
                                                              '${otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['zhuti']}',
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeoplePulledMemoryBank?[
                                                                          index]
                                                                      ['timu'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeoplePulledMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeoplePulledMemoryBank?[
                                                                          index]
                                                                      ['huida'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeoplePulledMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 7,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                42,
                                                                                91,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                142,
                                                                                204,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              0,
                                                                              153,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              195,
                                                                              238,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                          
                                                                        },
                                                                     
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.swap_calls
                                                                                : Icons.swap_calls,
                                                                            color: isLiked
                                                                                ? Colors.blue
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['laqu'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.blue
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                253,
                                                                                156,
                                                                                46),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                174,
                                                                                120)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              102,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              212,
                                                                              163),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                        
                                                                        },
                                                                     
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.folder
                                                                                : Icons.folder_open,
                                                                            color: isLiked
                                                                                ? Colors.orange
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['shoucang'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.orange
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        size:
                                                                            20,
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                64,
                                                                                64),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                206,
                                                                                206)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              0,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              186,
                                                                              186),
                                                                        ),
                                                                        onTap:
                                                                            (isLiked) async {
                                                                       
                                                                        },
                                                                    
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: isLiked
                                                                                ? Colors.red
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['xihuan'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.red
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                237,
                                                                                42,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                185,
                                                                                142,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              225,
                                                                              0,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              233,
                                                                              195,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                        
                                                                        },
                                                            
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.messenger
                                                                                : Icons.messenger_outline,
                                                                            color: isLiked
                                                                                ? Colors.purpleAccent
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeoplePulledMemoryBank?[index]['tiwen'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.purple
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                const Spacer(
                                                                    flex: 1),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          );
                                        }),
                                  )),
                              SizeCacheWidget(
                                child: ListView.builder(
                                    cacheExtent: 500,
                                    itemBuilder: (context, index) {
                                      return null;
                                    }),
                              ),
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: SizeCacheWidget(
                                    child: ListView.builder(
                                        cacheExtent: 500,
                                        physics: physics,
                                        itemCount: otherPeoplePersonalInformationManagement
                                                    .otherPeopleLikedMemoryBank ==
                                                null
                                            ? 0
                                            : otherPeoplePersonalInformationManagement
                                                .otherPeopleLikedMemoryBank
                                                ?.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            children: [
                                              const Divider(
                                                color: Color.fromRGBO(
                                                    223, 223, 223, 1),
                                                thickness: 0.9,
                                                height: 0.9,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  viewPostDataManagementForMemoryBanks
                                                      .initTheMemoryDataForThePost(
                                                          otherPeoplePersonalInformationManagement
                                                                  .otherPeopleLikedMemoryBank![
                                                              index]);
                                                  switchPage(context,
                                                      const jiyikudianji());
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom: 3.0,
                                                          right: 15,
                                                          left: 2),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {},
                                                          icon: CircleAvatar(
                                                            radius: 21,
                                                            backgroundImage: otherPeoplePersonalInformationManagement
                                                                            .otherPeopleLikedMemoryBank?[index]
                                                                        [
                                                                        'touxiang'] !=
                                                                    null
                                                                ? FileImage(File(
                                                                    otherPeoplePersonalInformationManagement
                                                                            .otherPeopleLikedMemoryBank![index]
                                                                        [
                                                                        'touxiang']))
                                                                : const AssetImage(
                                                                    'assets/chuhui.png'),
                                                          )),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                                height: 5),
                                                            Row(
                                                              children: [
                                                                Flexible(
                                                                  child:
                                                                      Container(
                                                                    child:
                                                                        RichText(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['name'],
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ' @${otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['username']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              color: Color.fromRGBO(84, 87, 105, 1),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Text(
                                                                  ' ·',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          17,
                                                                      color: Color
                                                                          .fromRGBO(
                                                                              84,
                                                                              87,
                                                                              105,
                                                                              1),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900),
                                                                ),
                                                                Text(
                                                                  '${otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['xiabiao'].length}个记忆项',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Text(
                                                              '${otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['zhuti']}',
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleLikedMemoryBank?[
                                                                          index]
                                                                      ['timu'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleLikedMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 4,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Text(
                                                              timuzhi(
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleLikedMemoryBank?[
                                                                          index]
                                                                      ['huida'],
                                                                  otherPeoplePersonalInformationManagement
                                                                              .otherPeopleLikedMemoryBank?[
                                                                          index]
                                                                      [
                                                                      'xiabiao']),
                                                              style: const TextStyle(
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .black),
                                                              maxLines: 7,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                42,
                                                                                91,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                142,
                                                                                204,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              0,
                                                                              153,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              195,
                                                                              238,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {

                                                                        },
                                                                     
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.swap_calls
                                                                                : Icons.swap_calls,
                                                                            color: isLiked
                                                                                ? Colors.blue
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['laqu'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.blue
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                253,
                                                                                156,
                                                                                46),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                174,
                                                                                120)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              102,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              212,
                                                                              163),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                      
                                                                        },
                                                                        
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.folder
                                                                                : Icons.folder_open,
                                                                            color: isLiked
                                                                                ? Colors.orange
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['shoucang'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.orange
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        size:
                                                                            20,
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                64,
                                                                                64),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                255,
                                                                                206,
                                                                                206)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              0,
                                                                              0),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              255,
                                                                              186,
                                                                              186),
                                                                        ),
                                                                        onTap:
                                                                            (isLiked) async {
                                                                      
                                                                        },
                                                                      
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.favorite
                                                                                : Icons.favorite_border,
                                                                            color: isLiked
                                                                                ? Colors.red
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['xihuan'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.red
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                SizedBox(
                                                                  width: 70,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      LikeButton(
                                                                        circleColor: const CircleColor(
                                                                            start: Color.fromARGB(
                                                                                255,
                                                                                237,
                                                                                42,
                                                                                255),
                                                                            end: Color.fromARGB(
                                                                                255,
                                                                                185,
                                                                                142,
                                                                                255)),
                                                                        bubblesColor:
                                                                            const BubblesColor(
                                                                          dotPrimaryColor: Color.fromARGB(
                                                                              255,
                                                                              225,
                                                                              0,
                                                                              255),
                                                                          dotSecondaryColor: Color.fromARGB(
                                                                              255,
                                                                              233,
                                                                              195,
                                                                              255),
                                                                        ),
                                                                        size:
                                                                            20,
                                                                        onTap:
                                                                            (isLiked) async {
                                                                     
                                                                        },
                                                               
                                                                        likeBuilder:
                                                                            (bool
                                                                                isLiked) {
                                                                          return Icon(
                                                                            isLiked
                                                                                ? Icons.messenger
                                                                                : Icons.messenger_outline,
                                                                            color: isLiked
                                                                                ? Colors.purpleAccent
                                                                                : const Color.fromRGBO(84, 87, 105, 1),
                                                                            size:
                                                                                20,
                                                                          );
                                                                        },
                                                                        likeCount:
                                                                            otherPeoplePersonalInformationManagement.otherPeopleLikedMemoryBank?[index]['tiwen'],
                                                                        countBuilder: (int? count,
                                                                            bool
                                                                                isLiked,
                                                                            String
                                                                                text) {
                                                                          var color = isLiked
                                                                              ? Colors.purple
                                                                              : const Color.fromRGBO(84, 87, 105, 1);
                                                                          Widget
                                                                              result;
                                                                          if (count ==
                                                                              0) {
                                                                            result =
                                                                                Text(
                                                                              "love",
                                                                              style: TextStyle(color: color),
                                                                            );
                                                                          }
                                                                          result =
                                                                              Text(
                                                                            text,
                                                                            style:
                                                                                TextStyle(color: color, fontWeight: FontWeight.w700),
                                                                          );
                                                                          return result;
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const Spacer(
                                                                    flex: 1),
                                                                const Spacer(
                                                                    flex: 1),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                            ],
                                          );
                                        }),
                                  )),
                            ],
                          );
                        });
                  }),
            );
          }),
    );
  }
}

