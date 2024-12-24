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
import 'package:yunji/main/app_module/memory_bank_item.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_background_image.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_head_portrait.dart';
import 'package:yunji/main/app_module/sliver_header_delegate.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/setting/setting_account_user_name.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/other_personal/other_personal_sqlite.dart';

class OtherPersonalPage extends StatefulWidget {
  const OtherPersonalPage({super.key});

  @override
  State<OtherPersonalPage> createState() => _OtherPersonalPageState();
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
    update();
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
  List<Map<String, dynamic>>? otherPeopleReviewMemoryBank = [];

  //用户喜欢的记忆库下标
  List<int> otherPeopleLikedMemoryBankIndex = [];
  //用户收藏的记忆库下标
  List<int> otherPeopleCollectedMemoryBankIndex = [];
  //用户拉取的记忆库下标
  List<int> otherPeoplePulledMemoryBankIndex = [];
  //用户回复的记忆库下标
  List<int> otherPeopleReplyMemoryBankIndex = [];
  //用户创建的记忆库下标
  List<int> otherPeopleReviewMemoryBankIndex = [];
//显示文本
  String displayText = ' ';
//计算每个页面的记忆库数量
  void calculateTheNumberOfMemoryBanksPerPage(int currentPageSubscript) {
    //创建的记忆库数量String类型
    String otherPeopleCollectedMemoryBankIndexString = currentPageSubscript == 0
        ? '${otherPeopleReviewMemoryBankIndex!.length}个'
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
    otherPeopleLikedMemoryBank = await queryOtherPeoplePersonalMemoryBank(
        otherPeopleLikedMemoryBankIndex);

    otherPeoplePulledMemoryBank = await queryOtherPeoplePersonalMemoryBank(
        otherPeoplePulledMemoryBankIndex);

    otherPeopleReviewMemoryBank = await queryOtherPeoplePersonalMemoryBank(
        otherPeopleReviewMemoryBankIndex);

    update();
  }

//请求后端其他人的个人信息数据
  void requestOtherPeoplePersonalInformationDataOnTheBackEnd(
      Map<String, dynamic> otherPeoplePersonalInformationData) async {
    if (otherPeoplePersonalInformationData['like_list'] != null) {
      var otherPeopleLikedMemoryBankIndexint =
          otherPeoplePersonalInformationData['like_list'].cast<int>();
      otherPeopleLikedMemoryBankIndex = otherPeopleLikedMemoryBankIndexint;
      otherPeopleLikedMemoryBank = await queryOtherPeoplePersonalMemoryBank(
          otherPeopleLikedMemoryBankIndexint);
    }

    if (otherPeoplePersonalInformationData['collect_list'] != null) {
      var otherPeopleCollectedMemoryBankIndexint =
          otherPeoplePersonalInformationData['collect_list'].cast<int>();
      otherPeopleCollectedMemoryBankIndex =
          otherPeopleCollectedMemoryBankIndexint;
    }

    if (otherPeoplePersonalInformationData['pull_list'] != null) {
      var otherPeoplePulledMemoryBankIndexint =
          otherPeoplePersonalInformationData['pull_list'].cast<int>();
      otherPeoplePulledMemoryBankIndex = otherPeoplePulledMemoryBankIndexint;
      otherPeoplePulledMemoryBank = await queryOtherPeoplePersonalMemoryBank(
          otherPeoplePulledMemoryBankIndexint);
    }

    if (otherPeoplePersonalInformationData['review_list'] != null) {
      var otherPeopleReviewMemoryBankIndexint =
          otherPeoplePersonalInformationData['review_list'].cast<int>();
      otherPeopleReviewMemoryBankIndex = otherPeopleReviewMemoryBankIndexint;
      otherPeopleReviewMemoryBank = await queryOtherPeoplePersonalMemoryBank(
          otherPeopleReviewMemoryBankIndexint);
    }

    update();
  }
}

class _OtherPersonalPageState extends State<OtherPersonalPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  final otherPeopleBackgroundImageChangeManagement =
      Get.put(OtherPeopleBackgroundImageChangeManagement());
  final otherPeopleHeadPortraitChangeManagement =
      Get.put(OtherPeopleHeadPortraitChangeManagement());

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
        otherPeopleInformationListScrollDataManagement
            .calculateTheListName(tabController.index);
        otherPeoplePersonalInformationManagement
            .calculateTheNumberOfMemoryBanksPerPage(tabController.index);
      });
    tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          scrollController.addListener(() {
            if (scrollController.offset >= 160) {
              otherPeopleInformationListScrollDataManagement
                  .setBackgroundColortrue();
            } else if (scrollController.offset < 160) {
              otherPeopleInformationListScrollDataManagement
                  .setBackgroundColorfalse();
            }
            if (scrollController.offset >= 235) {
              otherPeopleInformationListScrollDataManagement
                  .setTransparencyToDisplayText();
            } else if (scrollController.offset < 235) {
              otherPeopleInformationListScrollDataManagement
                  .setTransparencyToHideText();
            }
          });
        }));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    requestTheOtherPersonalData(otherPeopleInformationListScrollDataManagement
        .scrollDataValue['user_name']);
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
                      child: GetBuilder<
                              OtherPeopleInformationListScrollDataManagement>(
                          init: otherPeopleInformationListScrollDataManagement,
                          builder:
                              (otherPeopleInformationListScrollDataManagement) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${otherPeopleInformationListScrollDataManagement.scrollDataValue['name']}',
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
                          'assets/search.svg',
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
                                init:
                                    otherPeopleInformationListScrollDataManagement,
                                builder:
                                    (otherPeopleInformationListScrollDataManagement) {
                                  return ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaX:
                                            otherPeopleInformationListScrollDataManagement
                                                .filter,
                                        sigmaY: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        otherPeopleBackgroundImageChangeManagement
                                            .initBackgroundImage(
                                                otherPeopleInformationListScrollDataManagement
                                                        .scrollDataValue[
                                                    'background_image']);
                                        switchPage(
                                            context, const OtherPersonalBackgroundImage());
                                      },
                                      child:
                                          otherPeopleInformationListScrollDataManagement
                                                          .scrollDataValue[
                                                      'background_image'] !=
                                                  null
                                              ? Image.file(
                                                  File(
                                                      otherPeopleInformationListScrollDataManagement
                                                              .scrollDataValue[
                                                          'background_image']),
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/personal/gray_back_head.png',
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
                                init:
                                    otherPeopleInformationListScrollDataManagement,
                                builder:
                                    (otherPeopleInformationListScrollDataManagement) {
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
                                    otherPeopleHeadPortraitChangeManagement
                                        .initHeadPortrait(
                                            otherPeopleInformationListScrollDataManagement
                                                    .scrollDataValue[
                                                'head_portrait']);
                                    switchPage(context,
                                        const OtherPersonalHeadPortrait());
                                  },
                                  child: CircleAvatar(
                                    radius: 27,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          otherPeopleInformationListScrollDataManagement
                                                          .scrollDataValue[
                                                      'head_portrait'] !=
                                                  null
                                              ? FileImage(File(
                                                  otherPeopleInformationListScrollDataManagement
                                                          .scrollDataValue[
                                                      'head_portrait']))
                                              : const AssetImage(
                                                  'assets/personal/gray_back_head.png'),
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
                                      otherPeopleHeadPortraitChangeManagement
                                          .initHeadPortrait(
                                              otherPeopleInformationListScrollDataManagement
                                                      .scrollDataValue[
                                                  'head_portrait']);
                                      switchPage(context,
                                          const OtherPersonalHeadPortrait());
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
                                '${otherPeopleInformationListScrollDataManagement.scrollDataValue['name']}',
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
                                            .scrollDataValue['introduction']
                                            ?.isNotEmpty ??
                                        false
                                    ? Text(
                                        otherPeopleInformationListScrollDataManagement
                                            .scrollDataValue['introduction'],
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
                                              .scrollDataValue['birth_time']
                                              ?.isNotEmpty ??
                                          false
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/personal/birth_time.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '出生于 ${otherPeopleInformationListScrollDataManagement.scrollDataValue['birth_time']}',
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
                                              .scrollDataValue[
                                                  'residential_address']
                                              ?.isNotEmpty ??
                                          false
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/personal/residential_address.svg',
                                              width: 20,
                                              height: 20,
                                            ),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Expanded(
                                              child: Text(
                                                otherPeopleInformationListScrollDataManagement
                                                        .scrollDataValue[
                                                    'residential_address'],
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
                                      SvgPicture.asset(
                                          'assets/personal/join_date.svg',
                                          width: 20,
                                          height: 20),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${otherPeopleInformationListScrollDataManagement.scrollDataValue['join_date']}',
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
                                    child: MemoryBankList(
                                      refreshofMemoryBankextends:
                                          otherPeoplePersonalInformationManagement
                                              .otherPeopleReviewMemoryBank,
                                      onItemTap: (index) {
                                        viewPostDataManagementForMemoryBanks
                                            .initTheMemoryDataForThePost(
                                                otherPeoplePersonalInformationManagement
                                                        .otherPeopleReviewMemoryBank![
                                                    index]);
                                        switchPage(
                                            context, const OtherMemoryBank());
                                      },
                                    ),
                                  )),
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: SizeCacheWidget(
                                    child: MemoryBankList(
                                      refreshofMemoryBankextends:
                                          otherPeoplePersonalInformationManagement
                                              .otherPeoplePulledMemoryBank,
                                      onItemTap: (index) {
                                        viewPostDataManagementForMemoryBanks
                                            .initTheMemoryDataForThePost(
                                                otherPeoplePersonalInformationManagement
                                                        .otherPeoplePulledMemoryBank![
                                                    index]);
                                        switchPage(
                                            context, const OtherMemoryBank());
                                      },
                                    ),
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
                                      child: MemoryBankList(
                                      refreshofMemoryBankextends:
                                          otherPeoplePersonalInformationManagement
                                              .otherPeopleLikedMemoryBank,
                                      onItemTap: (index) {
                                        viewPostDataManagementForMemoryBanks
                                            .initTheMemoryDataForThePost(
                                                otherPeoplePersonalInformationManagement
                                                        .otherPeopleLikedMemoryBank![
                                                    index]);
                                        switchPage(
                                            context, const OtherMemoryBank());
                                      },
                                    ),
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
