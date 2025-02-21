import 'dart:core';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/dialog.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/main/main_init/app_sqlite.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_item.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/home/home_page/home_drawer.dart';
import 'package:yunji/home/home_module/ball_indicator.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/review/review/creat_review/creat_review_page.dart';

// 主页记忆板刷新
class RefreshofHomepageMemoryBankextends extends GetxController {
  static RefreshofHomepageMemoryBankextends get to => Get.find();
  List<Map<String, dynamic>> memoryRefreshValue = [];

  void updateMemoryRefreshValue(List<Map<String, dynamic>> value) {
    memoryRefreshValue = value.reversed.toList();
    update();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _viewPostDataManagementForMemoryBanks =
      Get.put(ViewPostDataManagementForMemoryBanks());

  late TabController tabController;

  Future<void> _refresh() async {
    await refreshHomePageMemoryBank(context);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // static const platform = MethodChannel('com.example.yunji/channel');

  // Future<void> _getNativeMessage() async {
  //   try {
  //     final String result = await platform.invokeMethod('getNativeMessage');
  //     print(result);
  //   } on PlatformException catch (e) {
  //     print("Failed to get native message: '${e.message}'.");
  //   }
  // }
  Future<void> _mainInit() async {
    await _initializeApp();
    final homePageMemoryDatabaseData = await queryHomePageMemoryBank();
    final personalData = await queryPersonalData();
    await refreshHomePageMemoryBank(context);

    if (homePageMemoryDatabaseData != null && personalData != null) {
      _initializeUserData(homePageMemoryDatabaseData, personalData);
    } else {
      smsLogin();
      _createIntDatabaseTable();
    }

    Alarm.ringStream.stream.listen((OnData) =>
        OnRingCallback(OnData.notificationSettings.body, OnData.id));
  }

  Future<void> _createIntDatabaseTable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> number = ['1'];
    await prefs.setStringList('intdatabase_number', number);
    await prefs.setInt('intdatabase_length', 1);
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      requestPermission(),
      Alarm.init(),
      databaseManager.initDatabase(),
      _initializeNotification(),
      initializeNightMode(),
    ]);
    tz.initializeTimeZones();
  }

  Future<void> _initializeNotification() async {
    final notificationHelper = NotificationHelper();
    await notificationHelper.initialize();
  }

  void _initializeUserData(
      List<Map<String, dynamic>> homePageMemoryDatabaseData,
      Map<String, dynamic> personalData) async {
    final selectorResultsUpdateDisplay =
        Get.put(SelectorResultsUpdateDisplay());
    final editPersonalDataValueManagement =
        Get.put(EditPersonalDataValueManagement());

    refreshofHomepageMemoryBankextends
        .updateMemoryRefreshValue(homePageMemoryDatabaseData);

    loginStatus = true;

    // 初始化背景图和头像
    backgroundImageChangeManagement
        .initBackgroundImage(personalData['background_image']);
    headPortraitChangeManagement
        .initHeadPortrait(personalData['head_portrait']);

    // 更新选择器结果
    selectorResultsUpdateDisplay
        .dateOfBirthSelectorResultValueChange(personalData['birth_time']);
    selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
        personalData['residential_address']);

    // 更新个人信息
    editPersonalDataValueManagement.changePersonalInformation(
      name: personalData['name'],
      profile: personalData['introduction'],
      residentialAddress: personalData['residential_address'],
      dateOfBirth: personalData['birth_time'],
      applicationDate: personalData['join_date'],
    );

    userPersonalInformationManagement
        .requestUserPersonalInformationDataOnTheBackEnd(personalData);

    userNameChangeManagement.userNameChanged(personalData['user_name']);
  }

  Future<void> requestPermission() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  void OnRingCallback(String body, int id) {
    buildDialog(
      context: context,
      title: '闹钟',
      content: body,
      onConfirm: () {
        Alarm.stop(id);
        Navigator.of(context).pop();
      },
      buttonRight: '停止闹钟',
    );
  }

  @override
  void initState() {
    _mainInit();
    // _getNativeMessage();
    super.initState();
    tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    );
  }

  void _handleSpeedDialChildTap() {
    if (loginStatus == false) {
      smsLogin();
      showToast(context, "未登录", "未登录");
    } else {
      switchPage(context, const CreatReviewPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    double appBarHeight = MediaQuery.of(context).size.height * 0.05;
    return Scaffold(
      backgroundColor: AppColors.background,
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: TabBarView(controller: tabController, children: [
        GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 5) {
                _scaffoldKey.currentState?.openDrawer();
              } else if (details.primaryVelocity! < -5) {
                tabController.animateTo(1);
              }
            },
            child: BallIndicator(
                onRefresh: _refresh,
                ballColors: const [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.amber,
                  Colors.pink,
                  Colors.purple,
                  Colors.cyan,
                  Colors.orange,
                  Colors.yellow,
                ],
                child: GetBuilder<RefreshofHomepageMemoryBankextends>(
                    init: refreshofHomepageMemoryBankextends,
                    builder: (refreshofHomepageMemoryBankextends) {
                      return CustomScrollView(
                        slivers: <Widget>[
                          SliverAppBar(
                            floating: true,
                            pinned: false,
                            snap: true,
                            expandedHeight: appBarHeight + 40,
                            surfaceTintColor: AppColors.background,
                            backgroundColor: AppColors.background,
                            toolbarHeight: appBarHeight,
                            leading: GetBuilder<HeadPortraitChangeManagement>(
                              init: headPortraitChangeManagement,
                              builder: (headPortraitChangeManagement) {
                                return headPortraitChangeManagement
                                            .headPortraitValue !=
                                        null
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: IconButton(
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () {
                                              _scaffoldKey.currentState
                                                  ?.openDrawer();
                                            },
                                            icon: CircleAvatar(
                                                radius: 30,
                                                backgroundImage: FileImage(
                                                    headPortraitChangeManagement
                                                        .headPortraitValue!))),
                                      )
                                    : IconButton(
                                        icon: SvgPicture.asset(
                                          'assets/home/personal_add.svg',
                                          width: 30,
                                          height: 30,
                                          colorFilter: ColorFilter.mode(
                                              AppColors.Gray, BlendMode.srcIn),
                                        ),
                                        onPressed: () {
                                          _scaffoldKey.currentState
                                              ?.openDrawer();
                                        },
                                      );
                              },
                            ),
                            iconTheme: const IconThemeData(color: Colors.black),
                            flexibleSpace: _buildTabBar(),
                          ),
                          SliverList.builder(
                            itemCount: refreshofHomepageMemoryBankextends
                                .memoryRefreshValue.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MemoryBankItem(
                                data: refreshofHomepageMemoryBankextends
                                    .memoryRefreshValue[index],
                                onTap: () {
                                  _viewPostDataManagementForMemoryBanks
                                      .initMemoryData(
                                          refreshofHomepageMemoryBankextends
                                              .memoryRefreshValue[index]);
                                  switchPage(context, const OtherMemoryBank());
                                },
                              );
                            },
                          )
                        ],
                      );
                    }))),
        GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 5) {
                tabController.animateTo(0);
              }
            },
            child: BallIndicator(
                onRefresh: _refresh,
                ballColors: const [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.amber,
                  Colors.pink,
                  Colors.purple,
                  Colors.cyan,
                  Colors.orange,
                  Colors.yellow,
                ],
                child: GetBuilder<RefreshofHomepageMemoryBankextends>(
                    init: refreshofHomepageMemoryBankextends,
                    builder: (refreshofHomepageMemoryBankextends) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                        ),
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverAppBar(
                              floating: true,
                              pinned: false,
                              snap: true,
                              expandedHeight: appBarHeight + 40,
                              surfaceTintColor: AppColors.background,
                              backgroundColor: AppColors.background,
                              toolbarHeight: appBarHeight,
                              leading: GetBuilder<HeadPortraitChangeManagement>(
                                init: headPortraitChangeManagement,
                                builder: (headPortraitChangeManagement) {
                                  return headPortraitChangeManagement
                                              .headPortraitValue !=
                                          null
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: IconButton(
                                              padding: const EdgeInsets.all(0),
                                              onPressed: () {
                                                _scaffoldKey.currentState
                                                    ?.openDrawer();
                                              },
                                              icon: CircleAvatar(
                                                  radius: 30,
                                                  backgroundImage: FileImage(
                                                      headPortraitChangeManagement
                                                          .headPortraitValue!))),
                                        )
                                      : IconButton(
                                          icon: SvgPicture.asset(
                                            'assets/home/personal_add.svg',
                                            width: 30,
                                            height: 30,
                                          ),
                                          onPressed: () {
                                            _scaffoldKey.currentState
                                                ?.openDrawer();
                                          },
                                        );
                                },
                              ),
                              iconTheme:
                                  const IconThemeData(color: Colors.black),
                              flexibleSpace: _buildTabBar(),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return Container(
                                    color: index.isOdd
                                        ? Colors.white
                                        : Colors.black12,
                                    height: 100.0,
                                    child: Center(
                                      child: Text('$index',
                                          textScaler:
                                              const TextScaler.linear(5)),
                                    ),
                                  );
                                },
                                childCount: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    }))),
      ]),
      floatingActionButton: _buildSpeedDial(),
    );
  }

  SpeedDialChild _buildSpeedDialChild() {
    return SpeedDialChild(
      shape: const CircleBorder(),
      child: SvgPicture.asset(
        'assets/home/creat_memory_bank.svg',
        colorFilter: ColorFilter.mode(AppColors.Gray, BlendMode.srcIn),
        width: 25,
        height: 25,
      ),
      backgroundColor: AppColors.background,
      label: '创建记忆库',
      labelShadow: List.empty(),
      labelBackgroundColor: AppColors.background,
      labelStyle: AppTextStyle.littleTitleStyle,
      onTap: _handleSpeedDialChildTap,
    );
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      backgroundColor: AppColors.iconColor,
      buttonSize: const Size(60, 60),
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: IconThemeData(color: AppColors.background, size: 28),
      spacing: 12,
      childrenButtonSize: const Size(53, 53),
      shape: const CircleBorder(),
      children: [_buildSpeedDialChild()],
    );
  }

  Widget? _buildTabBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 30),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
          ),
          child: TabBar(
            labelStyle: AppTextStyle.coarseTextStyle,
            indicatorColor: AppColors.iconColor,
            unselectedLabelStyle: AppTextStyle.subsidiaryText,
            controller: tabController,
            tabs: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: Center(
                  child: Text(
                    '推荐',
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    '正在关注',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
