import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:keframe/keframe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:like_button/like_button.dart';

import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_api.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_item.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_sqlite.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
import 'package:yunji/personal/other_personal/other_personal_api.dart';
import 'package:yunji/review/review/continue_review.dart';
import 'package:yunji/personal/sliver_header_delegate.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/review/creat_review/start_review/review.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/personal/personal/personal/personal_sqlite.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

final _userInformationListScrollDataManagement =
    Get.put(UserInformationListScrollDataManagement());

class UserInformationListScrollDataManagement extends GetxController {
  static UserInformationListScrollDataManagement get to => Get.find();

  bool backgroundState = false;
  double filter = 0.0;
  double opacity = 0.0;
  String displayText = ' ';

  void calculateTheNumberOfMemoryBanksPerPage(int currentPageSubscript,
      int reviewIndex, int pulledIndex, int replyIndex, int likedIndex) {
    List<String> memoryBankStrings = [
      '$reviewIndex个记忆库',
      '$pulledIndex个拉取',
      '$replyIndex个回复',
      '$likedIndex个喜欢'
    ];

    displayText = (currentPageSubscript >= 0 &&
            currentPageSubscript < memoryBankStrings.length)
        ? memoryBankStrings[currentPageSubscript]
        : '';
    update();
  }

  void clearData() {
    backgroundState = false;
    filter = 0.0;
    opacity = 0.0;
  }

  void setBackgroundColor(bool isActive) {
    filter = isActive ? 3 : 0;
    backgroundState = isActive;
    update();
  }

  void setTransparency(bool isVisible) {
    opacity = isVisible ? 1 : 0;
    update();
  }
}

class MemoryBankCompletionStatus extends GetxController {
  static MemoryBankCompletionStatus get to => Get.find();
  final _continueLearningAboutDataManagement =
      Get.put(ContinueLearningAboutDataManagement());

  final _reviewDataManagement = Get.put(ReviewDataManagement());

  bool displayIconStatus(int? status) => status == 1;

  Widget memoryLibraryStatusDisplayWidget(
      Map<String, dynamic> widgetsDisplayValues, BuildContext context) {
    DateTime setTimeValueDateTime =
        DateTime.parse(widgetsDisplayValues['set_time']);
    Duration setTimeValueDuration =
        setTimeValueDateTime.difference(DateTime.now());

    final int numberOfDays = setTimeValueDuration.inDays;
    final int numberOfHours = setTimeValueDuration.inHours % 24;
    final int numberOfMinutes = setTimeValueDuration.inMinutes % 60;

    Map<String, dynamic> reviewRecord =
        jsonDecode(widgetsDisplayValues['review_record']);
    List<String> statusRecord = reviewRecord.entries.map((entry) {
      return entry.value != '方案1'
          ? '已完成${entry.key}次${entry.value}的复习'
          : '未选择复习';
    }).toList();

    String displayStatusRecord =
        "距离下一次复习还剩$numberOfDays天$numberOfHours小时$numberOfMinutes分钟";

    Widget statusDisplayWidget =
        _buildStatusDisplayWidget(statusRecord, widgetsDisplayValues, context);

    if (setTimeValueDuration.inMinutes <= 0 &&
        widgetsDisplayValues['complete_state'] == 0) {
      statusDisplayWidget = _buildReviewButton(widgetsDisplayValues, context);
    } else if (setTimeValueDuration.inMinutes > 0 &&
        widgetsDisplayValues['complete_state'] == 0) {
      statusDisplayWidget = Text(
        displayStatusRecord,
        style: AppTextStyle.subsidiaryText,
      );
    }

    return statusDisplayWidget;
  }

  Widget _buildStatusDisplayWidget(List<String> statusRecord,
      Map<String, dynamic> widgetsDisplayValues, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ListView(
        children: [
          SizedBox(
            width: double.infinity,
            height: statusRecord.length * 23.0,
            child: ListView.builder(
              cacheExtent: 500,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statusRecord.length,
              itemBuilder: (context, index) {
                return Text(statusRecord[index],
                    style: AppTextStyle.subsidiaryText);
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              _continueLearningAboutDataManagement
                  .initMemoryData(widgetsDisplayValues);
              switchPage(context, const ContinueReview());
            },
            child: Text(
              '继续学习',
              style: AppTextStyle.greenTextStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(
      Map<String, dynamic> widgetsDisplayValues, BuildContext context) {
    return GestureDetector(
      onTap: () {
        _reviewDataManagement.initMemoryData(widgetsDisplayValues);
        switchPage(context, const ReviewPage());
      },
      child: Text(
        '开始复习',
        style: AppTextStyle.greenTextStyle,
      ),
    );
  }

  void refreshDisplay() {
    update();
  }
}

class UserPersonalInformationManagement extends GetxController {
  static UserPersonalInformationManagement get to => Get.find();

  List<Map<String, dynamic>>? userLikedMemoryBank = [];
  List<Map<String, dynamic>>? userPulledMemoryBank = [];
  List<Map<String, dynamic>>? userReviewMemoryBank = [];

  List<int> userLikedMemoryBankIndex = [];
  List<int> userCollectedMemoryBankIndex = [];
  List<int> userReplyMemoryBankIndex = [];
  List<int> userPulledMemoryBankIndex = [];
  List<int> userReviewMemoryBankIndex = [];

  void refreshDisplayText(int tabControllerIndex) {
    _userInformationListScrollDataManagement
        .calculateTheNumberOfMemoryBanksPerPage(
      tabControllerIndex,
      userReviewMemoryBankIndex.length,
      userPulledMemoryBankIndex.length,
      userReplyMemoryBankIndex.length,
      userLikedMemoryBankIndex.length,
    );
  }

  Future<void> requestUserPersonalInformationDataOnTheBackEnd(
      Map<String, dynamic> userPersonalInformationData) async {
    await _updateMemoryBankData(
        userPersonalInformationData,
        'like_list',
        userLikedMemoryBankIndex,
        (indices) async =>
            userLikedMemoryBank = await queryUserPersonalMemoryBank(indices));

    await _updateMemoryBankData(userPersonalInformationData, 'collect_list',
        userCollectedMemoryBankIndex);

    await _updateMemoryBankData(
        userPersonalInformationData, 'reply_list', userReplyMemoryBankIndex);

    await _updateMemoryBankData(
        userPersonalInformationData,
        'pull_list',
        userPulledMemoryBankIndex,
        (indices) async =>
            userPulledMemoryBank = await queryUserPersonalMemoryBank(indices));

    await _updateMemoryBankData(
        userPersonalInformationData,
        'review_list',
        userReviewMemoryBankIndex,
        (indices) async =>
            userReviewMemoryBank = await queryUserPersonalMemoryBank(indices));

    refreshDisplayText(0);
    update();
  }

  Future<void> _updateMemoryBankData(
    Map<String, dynamic> data,
    String key,
    List<int> indexList, [
    Future<void> Function(List<int>)? updateMemoryBank,
  ]) async {
    if (data[key] != null) {
      indexList.clear();

      if (data[key] is List) {
        indexList.addAll(data[key].cast<int>());
      } else if (jsonDecode(data[key]) != null) {
        indexList.addAll(jsonDecode(data[key]).cast<int>());
      }

      if (updateMemoryBank != null) {
        await updateMemoryBank(indexList);
      }
    }
  }
}

class _PersonalPageState extends State<PersonalPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  final memoryBankCompletionStatus = Get.put(MemoryBankCompletionStatus());
  final _viewPostDataManagementForMemoryBanks =
      Get.put(ViewPostDataManagementForMemoryBanks());
  final _editPersonalDataValueManagement =
      Get.put(EditPersonalDataValueManagement());
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    tabController.index = 0;
    _userInformationListScrollDataManagement.clearData();
    scrollController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeTabController();
    _initializeScrollController();
    _initializePeriodicTimer();
  }

  void _initializeTabController() {
    tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    )..addListener(() {
        userPersonalInformationManagement
            .refreshDisplayText(tabController.index);
      });
  }

  void _initializeScrollController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        final offset = scrollController.offset;
        _userInformationListScrollDataManagement
            .setBackgroundColor(offset >= 160);
        _userInformationListScrollDataManagement.setTransparency(offset >= 235);
      });
    });
  }

  void _initializePeriodicTimer() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      memoryBankCompletionStatus.refreshDisplay();
    });
  }

  Future<void> _refresh() async {
    requestTheUsersPersonalData(userNameChangeManagement.userNameValue ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GetBuilder<EditPersonalDataValueManagement>(
        init: _editPersonalDataValueManagement,
        builder: (editPersonalDataValueManagement) {
          return EasyRefresh(
            callRefreshOverOffset: 5,
            header: _buildClassicHeader(),
            onRefresh: _refresh,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  _buildSliverAppBar(context, editPersonalDataValueManagement),
                  _buildSliverToBoxAdapter(editPersonalDataValueManagement),
                  _buildSliverPersistentHeader(),
                ];
              },
              body: _buildTabBarView(),
            ),
          );
        },
      ),
    );
  }

  ClassicHeader _buildClassicHeader() {
    return ClassicHeader(
      processedText: '刷新完成',
      armedText: '松手刷新',
      processingText: '正在刷新',
      dragText: '下拉可刷新',
      readyText: '正在刷新',
      iconDimension: 100,
      textDimension: 190,
      iconTheme: const IconThemeData(color: Colors.white, size: 28),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      messageBuilder: (context, state, text, dateTime) {
        TimeOfDay timeOfDay = TimeOfDay.fromDateTime(dateTime);
        return Text(
          '更新于${timeOfDay.hour}:${timeOfDay.minute}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        );
      },
      messageStyle: const TextStyle(color: Colors.white),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context,
      EditPersonalDataValueManagement editPersonalDataValueManagement) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 48.0),
        child: GetBuilder<UserInformationListScrollDataManagement>(
          init: _userInformationListScrollDataManagement,
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editPersonalDataValueManagement.nameValue ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                        _userInformationListScrollDataManagement.opacity),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _userInformationListScrollDataManagement.displayText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(
                        _userInformationListScrollDataManagement.opacity),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      pinned: true,
      leading: _buildLeadingIcon(context),
      actions: _buildAppBarActions(),
      expandedHeight: 215,
      flexibleSpace: _buildFlexibleSpaceBar(),
    );
  }

  Padding _buildLeadingIcon(BuildContext context) {
    return Padding(
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
            size: 26,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _buildActionIcon('assets/search.svg'),
      Padding(
        padding: const EdgeInsets.only(left: 13.0, right: 16.0),
        child: _buildActionIcon(Icons.more_vert),
      ),
    ];
  }

  LayoutBuilder _buildFlexibleSpaceBar() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double percent = ((constraints.maxHeight - kToolbarHeight) *
            40 /
            (200 - kToolbarHeight));
        double dx = 68 - percent * 1.20;
        double size = (80 + percent * 2) / 100;

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: GetBuilder<UserInformationListScrollDataManagement>(
                init: _userInformationListScrollDataManagement,
                builder: (userInformationListScrollDataManagement) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: userInformationListScrollDataManagement.filter,
                      sigmaY: 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        switchPage(context, const PersonalBackgroundImage());
                      },
                      child: GetBuilder<BackgroundImageChangeManagement>(
                        init: backgroundImageChangeManagement,
                        builder: (backgroundImageChangeManagement) {
                          return _buildBackgroundImage(
                              backgroundImageChangeManagement);
                        },
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
              child: GetBuilder<UserInformationListScrollDataManagement>(
                init: _userInformationListScrollDataManagement,
                builder: (userInformationListScrollDataManagement) {
                  return AnimatedContainer(
                    duration: Duration(
                        seconds: userInformationListScrollDataManagement
                                .backgroundState
                            ? 1
                            : 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(
                              userInformationListScrollDataManagement
                                      .backgroundState
                                  ? 0.5
                                  : 0),
                          Colors.black.withOpacity(0.8),
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
                      dx, constraints.maxHeight / 2.3 - 0.06 * kToolbarHeight),
                child: GestureDetector(
                  onTap: () {
                    switchPage(context, const PersonalHeadPortrait());
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: AppColors.background,
                    child: GetBuilder<HeadPortraitChangeManagement>(
                      init: headPortraitChangeManagement,
                      builder: (headPortraitChangeManagement) {
                        return CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              headPortraitChangeManagement.headPortraitValue !=
                                      null
                                  ? FileImage(headPortraitChangeManagement
                                      .headPortraitValue!)
                                  : const AssetImage(
                                      'assets/personal/gray_back_head.png'),
                          radius: 25,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  SliverToBoxAdapter _buildSliverToBoxAdapter(
      EditPersonalDataValueManagement editPersonalDataValueManagement) {
    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              Text(
                '${editPersonalDataValueManagement.nameValue}',
                style: AppTextStyle.titleStyle,
              ),
              Text(
                '@${userNameChangeManagement.userNameValue}',
                style: AppTextStyle.subsidiaryText,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: editPersonalDataValueManagement.profileValue != null
                    ? Text(
                        '${editPersonalDataValueManagement.profileValue}',
                        style: AppTextStyle.subsidiaryText,
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 13),
              Wrap(
                direction: Axis.horizontal,
                textDirection: TextDirection.ltr,
                children: [
                  _buildInfoRow(
                      'assets/personal/birth_time.svg',
                      '出生于 ${editPersonalDataValueManagement.dateOfBirthValue}',
                      editPersonalDataValueManagement.dateOfBirthValue != null),
                  _buildInfoRow(
                      'assets/personal/residential_address.svg',
                      '${editPersonalDataValueManagement.residentialAddressValue}',
                      editPersonalDataValueManagement.residentialAddressValue !=
                          null),
                  _buildInfoRow(
                      'assets/personal/join_date.svg',
                      '${editPersonalDataValueManagement.applicationDateValue}',
                      editPersonalDataValueManagement.applicationDateValue !=
                          null),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 13.0, bottom: 13.0),
                child: Row(
                  children: [
                    Text(
                      '0',
                      style: AppTextStyle.textStyle,
                    ),
                    Text(
                      ' 正在关注    ',
                      style: AppTextStyle.subsidiaryText,
                    ),
                    Text(
                      '0',
                      style: AppTextStyle.textStyle,
                    ),
                    Text(
                      ' 关注者',
                      style: AppTextStyle.subsidiaryText,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildProfileHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            switchPage(context, const PersonalHeadPortrait());
          },
          child: Container(
            width: 90,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.iconColor),
            elevation: WidgetStateProperty.all(4.0),
          ),
          child: Text(
            "编辑个人资料",
            style: AppTextStyle.whiteTextStyle,
          ),
          onPressed: () async {
            if (loginStatus == false) {
              smsLogin();
              showWarnToast(context, "未登录", "未登录");
            } else {
              switchPage(context, const EditPersonalPage());
            }
          },
        ),
      ],
    );
  }

  SliverPersistentHeader _buildSliverPersistentHeader() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverHeaderDelegate.fixedHeight(
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
          ),
          child: TabBar(
            labelStyle: AppTextStyle.coarseTextStyle,
            indicatorColor: AppColors.iconColor,
            unselectedLabelStyle: AppTextStyle.subsidiaryText,
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
    );
  }

  GetBuilder<UserPersonalInformationManagement> _buildTabBarView() {
    return GetBuilder<UserPersonalInformationManagement>(
      init: userPersonalInformationManagement,
      builder: (userPersonalInformationManagement) {
        return TabBarView(
          controller: tabController,
          children: [
            _buildTabView(context, _reviewMemoryBank()),
            _buildTabView(
              context,
              MemoryBankList(
                refreshofMemoryBankextends:
                    userPersonalInformationManagement.userPulledMemoryBank,
                onItemTap: (index) {
                  _viewPostDataManagementForMemoryBanks.initMemoryData(
                    userPersonalInformationManagement
                        .userPulledMemoryBank![index],
                  );
                  switchPage(context, const OtherMemoryBank());
                },
              ),
            ),
            _buildTabView(
              context,
              ListView.builder(
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  return null;
                },
              ),
            ),
            _buildTabView(
              context,
              MemoryBankList(
                refreshofMemoryBankextends:
                    userPersonalInformationManagement.userLikedMemoryBank,
                onItemTap: (index) {
                  _viewPostDataManagementForMemoryBanks.initMemoryData(
                    userPersonalInformationManagement
                        .userLikedMemoryBank![index],
                  );
                  switchPage(context, const OtherMemoryBank());
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String parseJson(String? jsonString, List<dynamic> subscript) {
    if (jsonString == null) return ' ';
    var value = jsonDecode(jsonString);
    return value['${subscript[0]}'] ?? '';
  }

  Widget _reviewMemoryBank() {
    return ListView.builder(
      cacheExtent: 500,
      physics: const NeverScrollableScrollPhysics(),
      itemCount:
          userPersonalInformationManagement.userReviewMemoryBank?.length ?? 0,
      itemBuilder: (context, index) {
        final memoryBank =
            userPersonalInformationManagement.userReviewMemoryBank![index];
        final completeState = memoryBank['complete_state'];
        final subscriptLength = memoryBank['subscript'].length;
        final question =
            parseJson(memoryBank['question'], memoryBank['subscript']);
        final answer = parseJson(memoryBank['answer'], memoryBank['subscript']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: AppColors.Gray,
              thickness: 0.3,
              height: 0.9,
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () {
                _viewPostDataManagementForMemoryBanks
                    .initMemoryData(memoryBank);
                switchPage(context, const OtherMemoryBank());
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
                child: Column(
                  children: [
                    GetBuilder<MemoryBankCompletionStatus>(
                      init: memoryBankCompletionStatus,
                      builder: (memoryBankCompletionStatus) {
                        return Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: memoryBankCompletionStatus
                                        .displayIconStatus(completeState)
                                    ? 21
                                    : 28,
                                right: 10,
                                top: 3,
                              ),
                              child: SvgPicture.asset(
                                memoryBankCompletionStatus
                                        .displayIconStatus(completeState)
                                    ? 'assets/personal/review_medal.svg'
                                    : 'assets/personal/set_time.svg',
                                width: memoryBankCompletionStatus
                                        .displayIconStatus(completeState)
                                    ? 30
                                    : 20,
                                height: memoryBankCompletionStatus
                                        .displayIconStatus(completeState)
                                    ? 30
                                    : 20,
                                colorFilter: ColorFilter.mode(
                                    AppColors.Gray, BlendMode.srcIn),
                              ),
                            ),
                            Expanded(
                              child: memoryBankCompletionStatus
                                  .memoryLibraryStatusDisplayWidget(
                                      memoryBank, context),
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                switchPage(context, const OtherPersonalPage());
                                await requestTheOtherPersonalData(
                                    memoryBank['user_name']);
                              },
                              icon: CircleAvatar(
                                radius: 21,
                                backgroundImage: memoryBank['head_portrait'] !=
                                        null
                                    ? FileImage(
                                        File(memoryBank['head_portrait']))
                                    : const AssetImage(
                                        'assets/personal/gray_back_head.png'),
                              ),
                            ),
                          ],
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
                                            text: memoryBank['name'],
                                            style: AppTextStyle.textStyle,
                                          ),
                                          TextSpan(
                                            text:
                                                ' @${memoryBank['user_name']}',
                                            style: AppTextStyle.subsidiaryText,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' ·',
                                    style: AppTextStyle.subsidiaryText,
                                  ),
                                  Text(
                                    '$subscriptLength个记忆项',
                                    style: AppTextStyle.subsidiaryText,
                                  ),
                                ],
                              ),
                              Text(
                                memoryBank['theme'],
                                style: AppTextStyle.textStyle,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                question,
                                style: AppTextStyle.textStyle,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                answer,
                                style: AppTextStyle.subsidiaryText,
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _buildLikeButton(
                                    likeIcon: Icons.swap_calls,
                                    unLikeIcon: Icons.swap_calls,
                                    color: Colors.blue,
                                    count: memoryBank['pull'],
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 42, 91, 255),
                                      end: Color.fromARGB(255, 142, 204, 255),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor:
                                          Color.fromARGB(255, 0, 153, 255),
                                      dotSecondaryColor:
                                          Color.fromARGB(255, 195, 238, 255),
                                    ),
                                    onTap: (isLiked) async {
                                      final List<int>
                                          changeUserPulledMemoryBankIndex =
                                          userPersonalInformationManagement
                                              .userPulledMemoryBankIndex;
                                      if (isLiked == false) {
                                        addPersonalMemoryBankData(memoryBank);
                                        changeUserPulledMemoryBankIndex
                                            .add(memoryBank['id']);
                                        await synchronizeMemoryBankData(
                                            changeUserPulledMemoryBankIndex,
                                            'pull_list',
                                            memoryBank['id'],
                                            1,
                                            'pull');
                                      } else {
                                        changeUserPulledMemoryBankIndex
                                            .remove(memoryBank['id']);
                                        await synchronizeMemoryBankData(
                                            changeUserPulledMemoryBankIndex,
                                            'pull_list',
                                            memoryBank['id'],
                                            -1,
                                            'pull');
                                        if (!userPersonalInformationManagement
                                                .userPulledMemoryBankIndex
                                                .contains(memoryBank['id']) &&
                                            !userPersonalInformationManagement
                                                .userLikedMemoryBankIndex
                                                .contains(memoryBank['id']) &&
                                            !userPersonalInformationManagement
                                                .userReviewMemoryBankIndex
                                                .contains(memoryBank['id'])) {
                                          deletePersonalMemoryBankData(
                                              memoryBank['id']);
                                        }
                                      }
                                      return !isLiked;
                                    },
                                    memoryBankIds:
                                        userPersonalInformationManagement
                                            .userPulledMemoryBankIndex,
                                    memoryBank: memoryBank,
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    likeIcon: Icons.folder,
                                    unLikeIcon: Icons.folder_open,
                                    color: Colors.orange,
                                    count: memoryBank['collect'],
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 253, 156, 46),
                                      end: Color.fromARGB(255, 255, 174, 120),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor:
                                          Color.fromARGB(255, 255, 102, 0),
                                      dotSecondaryColor:
                                          Color.fromARGB(255, 255, 212, 163),
                                    ),
                                    onTap: (isLiked) async {
                                      List<int>
                                          changeUserCollectedMemoryBankIndex =
                                          userPersonalInformationManagement
                                              .userCollectedMemoryBankIndex;
                                      if (isLiked == false) {
                                        changeUserCollectedMemoryBankIndex
                                            .add(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserCollectedMemoryBankIndex,
                                            'collect_list',
                                            memoryBank['id'],
                                            1,
                                            'collect');
                                      } else {
                                        changeUserCollectedMemoryBankIndex
                                            .remove(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserCollectedMemoryBankIndex,
                                            'collect_list',
                                            memoryBank['id'],
                                            -1,
                                            'collect');
                                      }
                                      return !isLiked;
                                    },
                                    memoryBankIds:
                                        userPersonalInformationManagement
                                            .userCollectedMemoryBankIndex,
                                    memoryBank: memoryBank,
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    likeIcon: Icons.favorite,
                                    unLikeIcon: Icons.favorite_border,
                                    color: Colors.red,
                                    count: memoryBank['like'],
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 255, 64, 64),
                                      end: Color.fromARGB(255, 255, 206, 206),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor:
                                          Color.fromARGB(255, 255, 0, 0),
                                      dotSecondaryColor:
                                          Color.fromARGB(255, 255, 186, 186),
                                    ),
                                    onTap: (isLiked) async {
                                      List<int> changeUserLikedMemoryBankIndex =
                                          userPersonalInformationManagement
                                              .userLikedMemoryBankIndex;
                                      if (isLiked == false) {
                                        addPersonalMemoryBankData(memoryBank);
                                        changeUserLikedMemoryBankIndex
                                            .add(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserLikedMemoryBankIndex,
                                            'like_list',
                                            memoryBank['id'],
                                            1,
                                            '`like`');
                                      } else {
                                        changeUserLikedMemoryBankIndex
                                            .remove(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserLikedMemoryBankIndex,
                                            'like_list',
                                            memoryBank['id'],
                                            -1,
                                            '`like`');
                                        if (!userPersonalInformationManagement
                                                .userPulledMemoryBankIndex
                                                .contains(memoryBank['id']) &&
                                            !userPersonalInformationManagement
                                                .userLikedMemoryBankIndex
                                                .contains(memoryBank['id']) &&
                                            !userPersonalInformationManagement
                                                .userReviewMemoryBankIndex
                                                .contains(memoryBank['id'])) {
                                          deletePersonalMemoryBankData(
                                              memoryBank['id']);
                                        }
                                      }
                                      return !isLiked;
                                    },
                                    memoryBankIds:
                                        userPersonalInformationManagement
                                            .userLikedMemoryBankIndex,
                                    memoryBank: memoryBank,
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    likeIcon: Icons.messenger,
                                    unLikeIcon: Icons.messenger_outline,
                                    color: Colors.purpleAccent,
                                    count: memoryBank['reply'],
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 237, 42, 255),
                                      end: Color.fromARGB(255, 185, 142, 255),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor:
                                          Color.fromARGB(255, 225, 0, 255),
                                      dotSecondaryColor:
                                          Color.fromARGB(255, 233, 195, 255),
                                    ),
                                    onTap: (isLiked) async {
                                      List<int> changeUserReplyMemoryBankIndex =
                                          userPersonalInformationManagement
                                              .userReplyMemoryBankIndex;
                                      if (isLiked == false) {
                                        changeUserReplyMemoryBankIndex
                                            .add(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserReplyMemoryBankIndex,
                                            'reply_list',
                                            memoryBank['id'],
                                            1,
                                            'reply');
                                      } else {
                                        changeUserReplyMemoryBankIndex
                                            .remove(memoryBank['id']);
                                        synchronizeMemoryBankData(
                                            changeUserReplyMemoryBankIndex,
                                            'reply_list',
                                            memoryBank['id'],
                                            -1,
                                            'reply');
                                      }
                                      return !isLiked;
                                    },
                                    memoryBankIds:
                                        userPersonalInformationManagement
                                            .userReplyMemoryBankIndex,
                                    memoryBank: memoryBank,
                                  ),
                                  const Spacer(flex: 1),
                                  const Spacer(flex: 1),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
          ],
        );
      },
    );
  }

  Widget _buildLikeButton({
    required IconData likeIcon,
    required IconData unLikeIcon,
    required Color color,
    required int count,
    required CircleColor circleColor,
    required BubblesColor bubblesColor,
    required Future<bool> Function(bool) onTap,
    required List<int> memoryBankIds,
    required dynamic memoryBank,
  }) {
    return SizedBox(
      width: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LikeButton(
            size: 20,
            circleColor: circleColor,
            bubblesColor: bubblesColor,
            onTap: onTap,
            likeBuilder: (bool isLiked) {
              return Icon(
                isLiked ? likeIcon : unLikeIcon,
                color: isLiked ? color : AppColors.Gray,
                size: 20,
              );
            },
            likeCount: count,
            isLiked: memoryBankIds.contains(memoryBank['id']),
            countBuilder: (int? count, bool isLiked, String text) {
              var colorValue = isLiked ? color : AppColors.Gray;
              return Text(
                text,
                style:
                    TextStyle(color: colorValue, fontWeight: FontWeight.w700),
              );
            },
          ),
        ],
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
          ? SvgPicture.asset(
              icon,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            )
          : Icon(icon, size: 26, color: Colors.white),
    );
  }

  Widget _buildBackgroundImage(
      BackgroundImageChangeManagement backgroundImageChangeManagement) {
    return backgroundImageChangeManagement.backgroundImageValue != null
        ? Image.file(
            backgroundImageChangeManagement.changedBackgroundImageValue!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/personal/gray_back_head.png',
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            'assets/personal/gray_back_head.png',
            fit: BoxFit.cover,
          );
  }

  Widget _buildInfoRow(String assetPath, String text, bool isNotEmpty) {
    return isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(AppColors.Gray, BlendMode.srcIn),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyle.subsidiaryText,
                ),
              ),
              const SizedBox(width: 13),
            ],
          )
        : const SizedBox();
  }

  Widget _buildTabView(BuildContext context, Widget child) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: SizeCacheWidget(child: child),
    );
  }
}
