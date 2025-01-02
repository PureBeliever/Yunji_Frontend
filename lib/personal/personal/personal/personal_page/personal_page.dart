import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:keframe/keframe.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/main/app_module/memory_bank/memory_bank_item.dart';
import 'package:yunji/main/app_module/show_toast.dart';
import 'package:yunji/review/review/continue_review/continue_review.dart';
import 'package:yunji/main/app_module/sliver_header_delegate.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/review/review/start_review/review.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/setting/setting_user/setting_user_name/setting_user_name.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/personal/personal/personal/personal_sqlite.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

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

  // 是否显示其它图标
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
        "距离下一次复习还剩${numberOfDays}天${numberOfHours}小时${numberOfMinutes}分钟";

    Widget statusDisplayWidget =
        _buildStatusDisplayWidget(statusRecord, widgetsDisplayValues, context);

    if (setTimeValueDuration.inMinutes <= 0 &&
        widgetsDisplayValues['complete_state'] == 0) {
      statusDisplayWidget = _buildReviewButton(widgetsDisplayValues, context);
    } else if (setTimeValueDuration.inMinutes > 0 &&
        widgetsDisplayValues['complete_state'] == 0) {
      statusDisplayWidget = Text(
        displayStatusRecord,
        style: _statusTextStyle(),
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
              physics: const BouncingScrollPhysics(),
              itemCount: statusRecord.length,
              itemBuilder: (context, index) {
                return Text(
                  statusRecord[index],
                  style: _statusTextStyle(),
                );
              },
            ),
          ),
          GestureDetector(
            onTap: () {
              continueLearningAboutDataManagement
                  .initMemoryData(widgetsDisplayValues);
              switchPage(context, ContinueReview());
            },
            child: Text(
              '继续学习',
              style: _linkTextStyle(),
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
        reviewDataManagement
            .initMemoryData(widgetsDisplayValues);
        switchPage(context, ReviewPage());
      },
      child: Text(
        '开始复习',
        style: _linkTextStyle(),
      ),
    );
  }

  TextStyle _statusTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: 16,
      color: Color.fromRGBO(84, 87, 105, 1),
    );
  }

  TextStyle _linkTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.w500,
      color: Colors.green,
      fontSize: 16,
      decoration: TextDecoration.underline,
      decorationColor: Colors.green,
      decorationStyle: TextDecorationStyle.solid,
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
    userInformationListScrollDataManagement
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

    _updateMemoryBankData(
        userPersonalInformationData, 'collect_list', userReplyMemoryBankIndex);

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
      indexList.addAll(data[key].cast<int>());
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
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    userInformationListScrollDataManagement.clearData();
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
        userPersonalInformationManagement.refreshDisplayText(tabController.index);
      });
  }

  void _initializeScrollController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.addListener(() {
        final offset = scrollController.offset;
        userInformationListScrollDataManagement.setBackgroundColor(offset >= 160);
        userInformationListScrollDataManagement.setTransparency(offset >= 235);
      });
    });
  }

  void _initializePeriodicTimer() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      memoryBankCompletionStatus.refreshDisplay();
    });
  }

  Future<void> _refresh() async {
    requestTheUsersPersonalData(userNameChangeManagement.userNameValue ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<EditPersonalDataValueManagement>(
        init: editPersonalDataValueManagement,
        builder: (editPersonalDataValueManagement) {
          return EasyRefresh(
                       callRefreshOverOffset: 5,
            header: _buildClassicHeader(),
            onRefresh: _refresh,
            child: NestedScrollView(
              physics: const BouncingScrollPhysics(),
              controller: scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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

  SliverAppBar _buildSliverAppBar(BuildContext context, EditPersonalDataValueManagement editPersonalDataValueManagement) {
    return SliverAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 48.0),
        child: GetBuilder<UserInformationListScrollDataManagement>(
          init: userInformationListScrollDataManagement,
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  editPersonalDataValueManagement.nameValue ?? '',
                  style: TextStyle(
                    color: Colors.white.withOpacity(userInformationListScrollDataManagement.opacity),
                    fontSize: 21,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userInformationListScrollDataManagement.displayText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(userInformationListScrollDataManagement.opacity),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
            size: 25,
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
        double percent = ((constraints.maxHeight - kToolbarHeight) * 40 / (200 - kToolbarHeight));
        double dx = 68 - percent * 1.20;
        double size = (80 + percent * 2) / 100;

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned.fill(
              child: GetBuilder<UserInformationListScrollDataManagement>(
                init: userInformationListScrollDataManagement,
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
                          return _buildBackgroundImage(backgroundImageChangeManagement);
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
                init: userInformationListScrollDataManagement,
                builder: (userInformationListScrollDataManagement) {
                  return AnimatedContainer(
                    duration: Duration(seconds: userInformationListScrollDataManagement.backgroundState ? 1 : 0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(userInformationListScrollDataManagement.backgroundState ? 0.5 : 0),
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
                  ..translate(dx, constraints.maxHeight / 2.3 - 0.06 * kToolbarHeight),
                child: GestureDetector(
                  onTap: () {
                    switchPage(context, const PersonalHeadPortrait());
                  },
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.white,
                    child: GetBuilder<HeadPortraitChangeManagement>(
                      init: headPortraitChangeManagement,
                      builder: (headPortraitChangeManagement) {
                        return CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: headPortraitChangeManagement.headPortraitValue != null
                              ? FileImage(headPortraitChangeManagement.headPortraitValue!)
                              : const AssetImage('assets/personal/gray_back_head.png'),
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

  SliverToBoxAdapter _buildSliverToBoxAdapter(EditPersonalDataValueManagement editPersonalDataValueManagement) {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 8.0, top: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context),
              Text(
                '${editPersonalDataValueManagement.nameValue}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: Colors.black,
                  fontFamily: 'Raleway',
                  decoration: TextDecoration.none,
                ),
              ),
             
                 Text(
                    '@${userNameChangeManagement.userNameValue}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Color.fromRGBO(84, 87, 105, 1),
                      fontFamily: 'Raleway',
                      decoration: TextDecoration.none,
                    ),
                  ),
           
              Padding(
                padding: const EdgeInsets.only(top: 13.0),
                child: editPersonalDataValueManagement.profileValue?.isNotEmpty ?? false
                    ? Text(
                        '${editPersonalDataValueManagement.profileValue}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                          color: Colors.black,
                          fontFamily: 'Raleway',
                          decoration: TextDecoration.none,
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(height: 13),
              Wrap(
                direction: Axis.horizontal,
                textDirection: TextDirection.ltr,
                children: [
                  _buildInfoRow('assets/personal/birth_time.svg', '出生于 ${editPersonalDataValueManagement.dateOfBirthValue}'),
                  _buildInfoRow('assets/personal/residential_address.svg', '${editPersonalDataValueManagement.residentialAddressValue}'),
                  _buildInfoRow('assets/personal/join_date.svg', '${editPersonalDataValueManagement.applicationDateValue}'),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 13.0, bottom: 13.0),
                child: Row(
                  children: [
                    Text(
                      '0',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
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
                        fontWeight: FontWeight.w500,
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 119, 118, 118)),
            elevation: WidgetStateProperty.all(4.0),
          ),
          child: const Text(
            "编辑个人资料",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          onPressed: () async {
            if (loginStatus == false) {
              smsLogin(context);
              showToast(
                context,
                "未登录",
                "未登录",
                toast.ToastificationType.success,
                const Color(0xff047aff),
                const Color(0xFFEDF7FF),
              );
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
        child: Material(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: TabBar(
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: Colors.black,
                fontFamily: 'Raleway',
                decoration: TextDecoration.none,
              ),
              indicatorColor: Colors.blue,
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
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
                refreshofMemoryBankextends: userPersonalInformationManagement.userPulledMemoryBank,
                onItemTap: (index) {
                  viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(
                    userPersonalInformationManagement.userPulledMemoryBank![index],
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
                refreshofMemoryBankextends: userPersonalInformationManagement.userLikedMemoryBank,
                onItemTap: (index) {
                  viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(
                    userPersonalInformationManagement.userLikedMemoryBank![index],
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
      itemCount: userPersonalInformationManagement.userReviewMemoryBank?.length ?? 0,
      itemBuilder: (context, index) {
        final memoryBank = userPersonalInformationManagement.userReviewMemoryBank![index];
        final completeState = memoryBank['complete_state'];
        final headPortrait = memoryBank['head_portrait'];
        final name = memoryBank['name'];
        final userName = memoryBank['user_name'];
        final subscriptLength = memoryBank['subscript'].length;
        final theme = memoryBank['theme'];
        final question = parseJson(memoryBank['question'], memoryBank['subscript']);
        final reply = parseJson(memoryBank['reply'], memoryBank['subscript']);
        final pull = memoryBank['pull'];
        final collect = memoryBank['collect'];
        final like = memoryBank['like'];
        final review = memoryBank['review'];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Color.fromRGBO(223, 223, 223, 1),
              thickness: 0.9,
              height: 0.9,
            ),
            const SizedBox(height: 5),
            InkWell(
              onTap: () {
                viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(memoryBank);
                switchPage(context, const OtherMemoryBank());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 2.0),
                child: Column(
                  children: [
                    GetBuilder<MemoryBankCompletionStatus>(
                      init: memoryBankCompletionStatus,
                      builder: (memoryBankCompletionStatus) {
                        return Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: memoryBankCompletionStatus.displayIconStatus(completeState) ? 21 : 28,
                                right: 10,
                                top: 3,
                              ),
                              child: SvgPicture.asset(
                                memoryBankCompletionStatus.displayIconStatus(completeState)
                                    ? 'assets/personal/review_medal.svg'
                                    : 'assets/personal/set_time.svg',
                                width: memoryBankCompletionStatus.displayIconStatus(completeState) ? 27 : 20,
                                height: memoryBankCompletionStatus.displayIconStatus(completeState) ? 27 : 20,
                              ),
                            ),
                            Expanded(
                              child: memoryBankCompletionStatus.memoryLibraryStatusDisplayWidget(memoryBank, context),
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
                              onPressed: () {},
                              icon: CircleAvatar(
                                radius: 21,
                                backgroundImage: headPortrait != null
                                    ? FileImage(File(headPortrait))
                                    : const AssetImage('assets/personal/gray_back_head.png'),
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
                                            text: name,
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' @$userName',
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
                                    ' ·',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color.fromRGBO(84, 87, 105, 1),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '$subscriptLength个记忆项',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color.fromRGBO(84, 87, 105, 1),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                theme,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                question,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                reply,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _buildLikeButton(
                                    icon: Icons.swap_calls,
                                    color: Colors.blue,
                                    count: pull,
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 42, 91, 255),
                                      end: Color.fromARGB(255, 142, 204, 255),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor: Color.fromARGB(255, 0, 153, 255),
                                      dotSecondaryColor: Color.fromARGB(255, 195, 238, 255),
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    icon: Icons.folder_open,
                                    color: Colors.orange,
                                    count: collect,
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 253, 156, 46),
                                      end: Color.fromARGB(255, 255, 174, 120),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor: Color.fromARGB(255, 255, 102, 0),
                                      dotSecondaryColor: Color.fromARGB(255, 255, 212, 163),
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    icon: Icons.favorite_border,
                                    color: Colors.red,
                                    count: like,
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 255, 64, 64),
                                      end: Color.fromARGB(255, 255, 206, 206),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor: Color.fromARGB(255, 255, 0, 0),
                                      dotSecondaryColor: Color.fromARGB(255, 255, 186, 186),
                                    ),
                                  ),
                                  const Spacer(flex: 1),
                                  _buildLikeButton(
                                    icon: Icons.messenger_outline,
                                    color: Colors.purpleAccent,
                                    count: review,
                                    circleColor: const CircleColor(
                                      start: Color.fromARGB(255, 237, 42, 255),
                                      end: Color.fromARGB(255, 185, 142, 255),
                                    ),
                                    bubblesColor: const BubblesColor(
                                      dotPrimaryColor: Color.fromARGB(255, 225, 0, 255),
                                      dotSecondaryColor: Color.fromARGB(255, 233, 195, 255),
                                    ),
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
    required IconData icon,
    required Color color,
    required int count,
    required CircleColor circleColor,
    required BubblesColor bubblesColor,
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
            onTap: (isLiked) async {
              return !isLiked;
            },
            likeBuilder: (bool isLiked) {
              return Icon(
                icon,
                color: isLiked ? color : const Color.fromRGBO(84, 87, 105, 1),
                size: 20,
              );
            },
            likeCount: count,
            countBuilder: (int? count, bool isLiked, String text) {
              var colorValue = isLiked ? color : const Color.fromRGBO(84, 87, 105, 1);
              return Text(
                text,
                style: TextStyle(color: colorValue, fontWeight: FontWeight.w700),
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
              width: 25,
              height: 25,
              color: Colors.white,
            )
          : Icon(icon, size: 25, color: Colors.white),
    );
  }

  Widget _buildBackgroundImage(BackgroundImageChangeManagement backgroundImageChangeManagement) {
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

  Widget _buildInfoRow(String assetPath, String text) {
    return text.isNotEmpty
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                assetPath,
                width: 20,
                height: 20,
              ),
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

  Widget _buildTabView(BuildContext context, Widget child) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      child: SizeCacheWidget(child: child),
    );
  }
}
