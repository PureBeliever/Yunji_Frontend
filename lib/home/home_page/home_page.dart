import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/main/app_module/memory_bank_item.dart';
import 'package:yunji/main/app_module/show_toast.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/home_page/home_drawer.dart';
import 'package:yunji/main/app_module/sliver_header_delegate.dart';
import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/home/home_module/ball_indicator.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/review/creat_review/creat_review_page.dart';


// 主页记忆板刷新
class RefreshofHomepageMemoryBankextends extends GetxController {
  static RefreshofHomepageMemoryBankextends get to => Get.find();
  List<Map<String, dynamic>> memoryRefreshValue = [];


  void updateMemoryRefreshValue(List<Map<String, dynamic>>? value) {

    if (value != null) {
      memoryRefreshValue = value.reversed.toList();
      update();
    }
  }
}

// 上下文
BuildContext? contexts;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController tabController;

  Future<void> _refresh() async {
    await refreshHomePageMemoryBank(contexts!);
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
  }

  Widget _buildSpeedDial() {
    return SpeedDial(
      backgroundColor: Colors.blue,
      buttonSize: const Size(60, 60),
      animatedIcon: AnimatedIcons.add_event,
      animatedIconTheme: const IconThemeData(color: Colors.white, size: 28),
      spacing: 12,
      childrenButtonSize: const Size(53, 53),
      shape: const CircleBorder(),
      children: [_buildSpeedDialChild()],
    );
  }

  SpeedDialChild _buildSpeedDialChild() {
    return SpeedDialChild(
      shape: const CircleBorder(),
      child: SvgPicture.asset(
        'assets/home/creat_memory_bank.svg',
        color: Colors.blue,
        width: 25,
        height: 25,
      ),
      backgroundColor: Colors.white,
      label: '创建记忆库',
      labelShadow: List.empty(),
      labelBackgroundColor: Colors.white,
      labelStyle: const TextStyle(
          fontSize: 20.0, fontWeight: FontWeight.w700),
      onTap: _handleSpeedDialChildTap,
    );
  }

  void _handleSpeedDialChildTap() {
    if (loginStatus == false) {
      smsLogin(context);
      showToast(context, "未登录", "未登录", toast.ToastificationType.success, const Color(0xff047aff), const Color(0xFFEDF7FF));
    } else {
      switchPage(context, const CreatReviewPage());
    }
  }

  

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.dark,
    ));
    contexts = context;
    double appBarHeight = MediaQuery.of(context).size.height * 0.05;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegateshijian.fixedHeight(
                height: 23,
                child: Material(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              expandedHeight: 0,
              collapsedHeight: appBarHeight,
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              toolbarHeight: appBarHeight,
              leading: GetBuilder<HeadPortraitChangeManagement>(
                init: headPortraitChangeManagement,
                builder: (headPortraitChangeManagement) {
                  return headPortraitChangeManagement.headPortraitValue != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: IconButton(
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                _scaffoldKey.currentState?.openDrawer();
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
                            // 将此处的icon_name替换为您的SVG图标名称
                            width: 30,
                            height: 30,
                          ),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        );
                },
              ),
              iconTheme: const IconThemeData(color: Colors.black),
        
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate.fixedHeight(
                height: 40,
                child: Material(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: TabBar(
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
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
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
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
                        return MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: SizeCacheWidget(
                            child: MemoryBankList(
                              refreshofMemoryBankextends:
                                  refreshofHomepageMemoryBankextends.memoryRefreshValue,
                              onItemTap: (index) {
                                viewPostDataManagementForMemoryBanks
                                    .initTheMemoryDataForThePost(
                                        refreshofHomepageMemoryBankextends
                                            .memoryRefreshValue[index]);
                                switchPage(context, const OtherMemoryBank());
                              },
                            ),
                          ),
                        );
                      })),
            ),
            ListView(
              children: <Widget>[
                for (int i = 0; i < 20; ++i)
                  Container(
                    height: 50,
                    color: i % 2 == 0 ? Colors.blue : Colors.green,
                    child: Center(
                      child: Text(
                        'Item $i',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSpeedDial(),
    );
  }
}
