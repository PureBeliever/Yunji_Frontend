import 'package:alarm/alarm.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/dialog.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/main/main_init/app_sqlite.dart';
import 'package:yunji/main/main_module/memory_bank/memory_bank_item.dart';
import 'package:yunji/home/home_page/home_drawer.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';

// 主页记忆板刷新 (优化后名称)
class HomepageMemoryBankRefreshController extends GetxController {
  static HomepageMemoryBankRefreshController get to => Get.find();
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
  // 控制器和状态管理
  final homePageMemoryBankRefreshController =
      Get.put(HomepageMemoryBankRefreshController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _viewPostDataManagementForMemoryBanks =
      Get.put(ViewPostDataManagementForMemoryBanks());

  // Tab控制器
  late TabController tabController;

  // 刷新主页记忆库
  Future<void> _refresh() async {
    await refreshHomePageMemoryBank(context);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // 初始化主应用
  Future<void> _mainInit() async {
    await _initializeApp();
    final results =
        await Future.wait([queryHomePageMemoryBank(), queryPersonalData()]);
    final homePageMemoryDatabaseData =
        results[0] as List<Map<String, dynamic>>?;
    final personalData = results[1] as Map<String, dynamic>?;

    await refreshHomePageMemoryBank(context);

    if (homePageMemoryDatabaseData != null && personalData != null) {
      await _initializeUserData(homePageMemoryDatabaseData, personalData);
    } else {
      smsLogin();
      await _createIntDatabaseTable();
    }

    Alarm.ringStream.stream.listen((onData) =>
        _onRingCallback(onData.notificationSettings.body, onData.id));
  }

  // 创建内部数据库表
  Future<void> _createIntDatabaseTable() async {
    final prefs = await SharedPreferences.getInstance();
    final number = ['1'];
    await prefs.setStringList('intdatabase_number', number);
    await prefs.setInt('intdatabase_length', 1);
  }

  // 初始化应用
  Future<void> _initializeApp() async {
    await Future.wait([
      Alarm.init(),
      databaseManager.initDatabase(),
      _initializeNotification(),
      initializeNightMode(),
    ]);
    tz.initializeTimeZones();
  }

  // 初始化通知
  Future<void> _initializeNotification() async {
    final notificationHelper = NotificationHelper();
    await notificationHelper.initialize();
  }

  // 初始化用户数据
  Future<void> _initializeUserData(
      List<Map<String, dynamic>> homePageMemoryDatabaseData,
      Map<String, dynamic> personalData) async {
    final selectorResultsUpdateDisplay =
        Get.put(SelectorResultsUpdateDisplay());
    final editPersonalDataValueManagement =
        Get.put(EditPersonalDataValueManagement());

    homePageMemoryBankRefreshController
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

  // 处理闹钟响铃回调
  void _onRingCallback(String body, int id) {
    buildDialog(
      context: context,
      title: '闹钟',
      content: body,
      onConfirm: () {
        Alarm.stop(id);
        Navigator.pop(context);
      },
      buttonRight: '停止闹钟',
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    );
    _mainInit();
  }

  // 构建经典头部
  ClassicHeader _buildClassicHeader() {
    return ClassicHeader(
        iconTheme: const IconThemeData(color: Colors.black, size: 20),
        showMessage: false,
        showText: false);
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.05;
    return Scaffold(
      backgroundColor: AppColors.background,
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: GetBuilder<HomepageMemoryBankRefreshController>(
        init: homePageMemoryBankRefreshController,
        builder: (controller) {
          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  pinned: false,
                  snap: true,
                  expandedHeight: appBarHeight + 72,
                  surfaceTintColor: AppColors.background,
                  backgroundColor: AppColors.background,
                  toolbarHeight: appBarHeight,
                  leading: GetBuilder<HeadPortraitChangeManagement>(
                    init: headPortraitChangeManagement,
                    builder: (portraitController) {
                      return portraitController.headPortraitValue != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 15.0),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                                icon: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: FileImage(
                                      portraitController.headPortraitValue!),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: SvgPicture.asset(
                                'assets/home/personal_add.svg',
                                width: 30,
                                height: 30,
                                colorFilter: ColorFilter.mode(
                                    AppColors.Gray, BlendMode.srcIn),
                              ),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            );
                    },
                  ),
                  iconTheme: const IconThemeData(color: Colors.black),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                      ),
                      alignment: Alignment.bottomCenter,
                      child: TabBar(
                        labelStyle: AppTextStyle.coarseTextStyle,
                        indicatorColor: AppColors.iconColor,
                        unselectedLabelStyle: AppTextStyle.subsidiaryText,
                        controller: tabController,
                        tabs: const [
                          Tab(text: '推荐'),
                          Tab(text: '正在关注'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: tabController,
              children: [
                EasyRefresh(
                  callRefreshOverOffset: 5,
                  header: _buildClassicHeader(),
                  onRefresh: _refresh,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 5) {
                        _scaffoldKey.currentState?.openDrawer();
                      } else if (details.primaryVelocity! < -5) {
                        tabController.animateTo(1);
                      }
                    },
                    child: ListView.builder(
                      itemCount: controller.memoryRefreshValue.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MemoryBankItem(
                          data: controller.memoryRefreshValue[index],
                          onTap: () {
                            _viewPostDataManagementForMemoryBanks
                                .initMemoryData(
                                    controller.memoryRefreshValue[index]);
                            Navigator.pushNamed(context, '/other_memory_bank');
                          },
                        );
                      },
                    ),
                  ),
                ),
                EasyRefresh(
                  callRefreshOverOffset: 5,
                  header: _buildClassicHeader(),
                  onRefresh: _refresh,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 5) {
                        tabController.animateTo(0);
                      }
                    },
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          color: index.isOdd ? Colors.white : Colors.black12,
                          height: 100.0,
                          child: Center(
                            child: Text(
                              '$index',
                              textScaler: const TextScaler.linear(5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
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
      labelShadow: const [],
      labelBackgroundColor: AppColors.background,
      labelStyle: AppTextStyle.littleTitleStyle,
      onTap: () => Navigator.pushNamed(context, '/creat_review_page'),
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
}
