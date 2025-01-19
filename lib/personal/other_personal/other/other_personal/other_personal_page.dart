// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:keframe/keframe.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_item.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_background_image.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_head_portrait.dart';
import 'package:yunji/personal/sliver_header_delegate.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/personal/other_personal/other_personal_sqlite.dart';

class OtherPersonalPage extends StatefulWidget {
  const OtherPersonalPage({super.key});

  @override
  State<OtherPersonalPage> createState() => _OtherPersonalPageState();
}

//信息列表滚动数据管理

final _otherPeopleInformationListScrollDataManagement =
    Get.put(OtherPeopleInformationListScrollDataManagement());
class OtherPeopleInformationListScrollDataManagement extends GetxController {
  static OtherPeopleInformationListScrollDataManagement get to => Get.find();


  bool backgroundState = false;
  double filter = 0.0;
  double opacity = 0.0;
  Map<String, dynamic> scrollDataValue = {};
  String displayText = ' ';

  void calculateTheNumberOfMemoryBanksPerPage(
      int currentPageSubscript,
      int otherPeopleReviewMemoryBankIndex,
      int otherPeoplePulledMemoryBankIndex,
      int otherPeopleReplyMemoryBankIndex,
      int otherPeopleLikedMemoryBankIndex) {
    List<String> memoryBankStrings = [
      '$otherPeopleReviewMemoryBankIndex个记忆库',
      '$otherPeoplePulledMemoryBankIndex个拉取',
      '$otherPeopleReplyMemoryBankIndex个回复',
      '$otherPeopleLikedMemoryBankIndex个喜欢'
    ];

    displayText = currentPageSubscript >= 0 &&
            currentPageSubscript < memoryBankStrings.length
        ? memoryBankStrings[currentPageSubscript]
        : '';
    update();
  }

  void initialScrollData(Map<String, dynamic> scrollData) {
    scrollDataValue = scrollData;
    update();
  }

  void clearData() {
    backgroundState = false;
    filter = 0.0;
    opacity = 0.0;
  }

  void setBackgroundColor(bool isTrue) {
    filter = isTrue ? 3 : 0;
    backgroundState = isTrue;
    update();
  }

  void setTransparency(bool isVisible) {
    opacity = isVisible ? 1 : 0;
    update();
  }
}

class OtherPeoplePersonalInformationManagement extends GetxController {
  static OtherPeoplePersonalInformationManagement get to => Get.find();

  List<Map<String, dynamic>>? otherPeopleLikedMemoryBank = [];
  List<Map<String, dynamic>>? otherPeoplePulledMemoryBank = [];
  List<Map<String, dynamic>>? otherPeopleReviewMemoryBank = [];

  List<int> otherPeopleLikedMemoryBankIndex = [];
  List<int> otherPeopleCollectedMemoryBankIndex = [];
  List<int> otherPeoplePulledMemoryBankIndex = [];
  List<int> otherPeopleReplyMemoryBankIndex = [];
  List<int> otherPeopleReviewMemoryBankIndex = [];

  void refreshDisplayText(int tabControllerIndex) {
    _otherPeopleInformationListScrollDataManagement
        .calculateTheNumberOfMemoryBanksPerPage(
      tabControllerIndex,
      otherPeopleReviewMemoryBankIndex.length,
      otherPeoplePulledMemoryBankIndex.length,
      otherPeopleReplyMemoryBankIndex.length,
      otherPeopleLikedMemoryBankIndex.length,
    );
  }

  Future<void> requestOtherPeoplePersonalInformationDataOnTheBackEnd(
      Map<String, dynamic> otherPeoplePersonalInformationData) async {
    await _updateMemoryBankIndices(
      otherPeoplePersonalInformationData,
      'like_list',
      otherPeopleLikedMemoryBankIndex,
      (indices) async => otherPeopleLikedMemoryBank =
          await queryOtherPeoplePersonalMemoryBank(indices),
    );

    _updateMemoryBankIndices(
      otherPeoplePersonalInformationData,
      'collect_list',
      otherPeopleCollectedMemoryBankIndex,
    );

    await _updateMemoryBankIndices(
      otherPeoplePersonalInformationData,
      'pull_list',
      otherPeoplePulledMemoryBankIndex,
      (indices) async => otherPeoplePulledMemoryBank =
          await queryOtherPeoplePersonalMemoryBank(indices),
    );

    await _updateMemoryBankIndices(
      otherPeoplePersonalInformationData,
      'review_list',
      otherPeopleReviewMemoryBankIndex,
      (indices) async => otherPeopleReviewMemoryBank =
          await queryOtherPeoplePersonalMemoryBank(indices),
    );
    refreshDisplayText(0);
    update();
  }

// 更新记忆库下标
  Future<void> _updateMemoryBankIndices(
    Map<String, dynamic> data,
    String key,
    List<int> indexList, [
    Future<void> Function(List<int>)? updateMemoryBank,
  ]) async {
    if (data[key] != null) {
      indexList.clear();
      indexList.addAll(data[key].cast<int>());
      if (updateMemoryBank != null) {
        await updateMemoryBank(indexList);
      }
    }
  }
}

class _OtherPersonalPageState extends State<OtherPersonalPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  final _otherPeopleBackgroundImageChangeManagement =
      Get.put(OtherPeopleBackgroundImageChangeManagement());
  final _otherPeopleHeadPortraitChangeManagement =
      Get.put(OtherPeopleHeadPortraitChangeManagement());
        final _viewPostDataManagementForMemoryBanks =
    Get.put(ViewPostDataManagementForMemoryBanks());
  final _otherPeoplePersonalInformationManagement =
      Get.put(OtherPeoplePersonalInformationManagement());

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    _otherPeopleInformationListScrollDataManagement.clearData();
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
        _otherPeoplePersonalInformationManagement
            .refreshDisplayText(tabController.index);
      });
    tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        scrollController.addListener(_scrollListener);
      });
    });
  }

  void _scrollListener() {
    final offset = scrollController.offset;
    _otherPeopleInformationListScrollDataManagement
        .setBackgroundColor(offset >= 160);
    _otherPeopleInformationListScrollDataManagement
        .setTransparency(offset >= 235);
  }

  Future<void> _refresh() async {
    requestTheOtherPersonalData(
        _otherPeopleInformationListScrollDataManagement
            .scrollDataValue['user_name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: EasyRefresh(
        callRefreshOverOffset: 5,
        header: ClassicHeader(
          processedText: '刷新完成',
          armedText: '松手刷新',
          processingText: '正在刷新',
          dragText: '下拉可刷新',
          readyText: '正在刷新',
          iconDimension: 100,
          textDimension: 190,
          iconTheme: const IconThemeData(color: Colors.white, size: 28),
          textStyle: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          messageBuilder: (context, state, text, dateTime) {
            TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
            return Text(
              '更新于${timeOfDay.hour}:${timeOfDay.minute}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            );
          },
          messageStyle: const TextStyle(color: Colors.white),
        ),
        onRefresh: _refresh,
        child: GetBuilder<OtherPeoplePersonalInformationManagement>(
          init: _otherPeoplePersonalInformationManagement,
          builder: (otherPeoplePersonalInformationManagement) {
            return NestedScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  GetBuilder<OtherPeopleInformationListScrollDataManagement>(
                    init: _otherPeopleInformationListScrollDataManagement,
                    builder: (otherPeopleInformationListScrollDataManagement) {
                      return SliverAppBar(
                        title: Padding(
                          padding: const EdgeInsets.only(left: 48.0),
                          child: Column(
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
                          ),
                        ),
                        pinned: true,
                        leading: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
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
                            ),
                          ),
                        ),
                        actions: [
                          _buildActionIcon('assets/search.svg'),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 13.0, right: 16.0),
                            child: _buildActionIcon(Icons.more_vert),
                          ),
                        ],
                        expandedHeight: 215,
                        flexibleSpace: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            double percent =
                                ((constraints.maxHeight - kToolbarHeight) *
                                    40 /
                                    (200 - kToolbarHeight));
                            double dx = 68 - percent * 1.20;
                            double size = (80 + percent * 2) / 100;

                            return Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Positioned.fill(
                                  child: ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaX:
                                            otherPeopleInformationListScrollDataManagement
                                                .filter,
                                        sigmaY: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        _otherPeopleBackgroundImageChangeManagement
                                            .initBackgroundImage(
                                                otherPeopleInformationListScrollDataManagement
                                                        .scrollDataValue[
                                                    'background_image']);
                                        switchPage(context,
                                            const OtherPersonalBackgroundImage());
                                      },
                                      child: _buildBackgroundImage(
                                          otherPeopleInformationListScrollDataManagement),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  height: 90,
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: AnimatedContainer(
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
                                        _otherPeopleHeadPortraitChangeManagement
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
                                          backgroundImage: _buildHeadPortraitImage(
                                              otherPeopleInformationListScrollDataManagement),
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
                      );
                    },
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
                            _buildHeaderRow(),
                            _buildNameText(),
                            _buildUserNameText(),
                            _buildIntroductionText(),
                            const SizedBox(height: 13),
                            _buildInfoWrap(),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 13.0, bottom: 13.0),
                              child: _buildFollowInfoRow(),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                  child: Text('记忆库'),
                                ),
                              ),
                              Text('拉取'),
                              Text('回复'),
                              Text('喜欢'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: tabController,
                children: [
                  _buildMemoryBankList(otherPeoplePersonalInformationManagement
                      .otherPeopleReviewMemoryBank),
                  _buildMemoryBankList(otherPeoplePersonalInformationManagement
                      .otherPeoplePulledMemoryBank),
                  _buildEmptyListView(),
                  _buildMemoryBankList(otherPeoplePersonalInformationManagement
                      .otherPeopleLikedMemoryBank),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionIcon(dynamic icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: icon is String
          ? SvgPicture.asset(icon, width: 25, height: 25, color: Colors.white)
          : Icon(icon, size: 25, color: Colors.white),
    );
  }

  Widget _buildBackgroundImage(
      OtherPeopleInformationListScrollDataManagement dataManagement) {
    return dataManagement.scrollDataValue['background_image'] != null
        ? Image.file(
            File(dataManagement.scrollDataValue['background_image']),
            fit: BoxFit.cover,
          )
        : Image.asset(
            'assets/personal/gray_back_head.png',
            fit: BoxFit.cover,
          );
  }

  ImageProvider _buildHeadPortraitImage(
      OtherPeopleInformationListScrollDataManagement dataManagement) {
    return dataManagement.scrollDataValue['head_portrait'] != null
        ? FileImage(File(dataManagement.scrollDataValue['head_portrait']))
        : const AssetImage('assets/personal/gray_back_head.png');
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _otherPeopleHeadPortraitChangeManagement.initHeadPortrait(
                _otherPeopleInformationListScrollDataManagement
                    .scrollDataValue['head_portrait']);
            switchPage(context, const OtherPersonalHeadPortrait());
          },
          child: Container(
            width: 90,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10.0, top: 8),
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
    );
  }

  Widget _buildNameText() {
    return Text(
      '${_otherPeopleInformationListScrollDataManagement.scrollDataValue['name']}',
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 24,
        color: Colors.black,
        fontFamily: 'Raleway',
        decoration: TextDecoration.none,
      ),
    );
  }

  Widget _buildUserNameText() {
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
  }

  Widget _buildIntroductionText() {
    return Padding(
      padding: const EdgeInsets.only(top: 13.0),
      child: _otherPeopleInformationListScrollDataManagement
                  .scrollDataValue['introduction']?.isNotEmpty ??
              false
          ? Text(
              _otherPeopleInformationListScrollDataManagement
                  .scrollDataValue['introduction'],
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
                color: Colors.black,
                fontFamily: 'Raleway',
                decoration: TextDecoration.none,
              ),
            )
          : const SizedBox(),
    );
  }

  Widget _buildInfoWrap() {
    return Wrap(
      direction: Axis.horizontal,
      textDirection: TextDirection.ltr,
      children: [
        _buildInfoRow(
            'assets/personal/birth_time.svg',
            '出生于 ${_otherPeopleInformationListScrollDataManagement.scrollDataValue['birth_time']}',
            _otherPeopleInformationListScrollDataManagement
                    .scrollDataValue['birth_time'] !=
                null),
        _buildInfoRow(
            'assets/personal/residential_address.svg',
            '${_otherPeopleInformationListScrollDataManagement.scrollDataValue['residential_address']}',
            _otherPeopleInformationListScrollDataManagement
                    .scrollDataValue['residential_address'] !=
                null),
        _buildInfoRow(
            'assets/personal/join_date.svg',
            '${_otherPeopleInformationListScrollDataManagement.scrollDataValue['join_date']}',
            _otherPeopleInformationListScrollDataManagement
                    .scrollDataValue['join_date'] !=
                null),
      ],
    );
  }

  Widget _buildInfoRow(String iconPath, String text, bool isNotEmpty) {
    return isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(iconPath, width: 20, height: 20),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Color.fromRGBO(84, 87, 105, 1),
                    fontFamily: 'Raleway',
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
              const SizedBox(width: 13),
            ],
          )
        : const SizedBox();
  }

  Widget _buildFollowInfoRow() {
    return const Row(
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
    );
  }

  Widget _buildMemoryBankList(List<Map<String, dynamic>>? memoryBank) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: SizeCacheWidget(
        child: MemoryBankList(
          refreshofMemoryBankextends: memoryBank,
          onItemTap: (index) {
            _viewPostDataManagementForMemoryBanks.initMemoryData(memoryBank![index]);
            switchPage(context, const OtherMemoryBank());
          },
        ),
      ),
    );
  }

  Widget _buildEmptyListView() {
    return SizeCacheWidget(
      child: ListView.builder(
        cacheExtent: 500,
        itemBuilder: (context, index) {
          return null;
        },
      ),
    );
  }
}
