// dart包
import 'dart:convert';
import 'dart:core';
import 'dart:io';

//依赖包
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keframe/keframe.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/switch/switch_page.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/home_page/home_drawer.dart';
import 'package:yunji/modified_component/sliver_header_delegate.dart';
import 'package:yunji/home/trial_recommendation_algorithm.dart';
import 'package:yunji/home/home_module/ball_indicator.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/jiyikudianji/jiyikudianji.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonal.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/personal/personal_head.dart';
import 'package:yunji/chuangjianjiyiku/jiyiku.dart';
import 'package:toastification/toastification.dart' as toast;

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

  String _typeConversion(String? data, var index) {
    if (data != null) {
      var decodedData = jsonDecode(data);
      var indexValue = index;
      return decodedData.containsKey('${indexValue[0]}') ? decodedData['${indexValue[0]}'] : '';
    } else {
      return ' ';
    }
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
                            'assets/person.svg',
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
              actions: [],
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
                            child: ListView.builder(
                                cacheExtent: 500,
                                itemCount: refreshofHomepageMemoryBankextends
                                        .memoryRefreshValue?.length ??
                                    0,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      viewPostDataManagementForMemoryBanks
                                          .initTheMemoryDataForThePost(
                                              refreshofHomepageMemoryBankextends
                                                  .memoryRefreshValue[index]);
                                      switchPage(context, const jiyikudianji());
                                    },
                                    child: Column(
                                      children: [
                                        const Divider(
                                          color:
                                              Color.fromRGBO(223, 223, 223, 1),
                                          thickness: 0.9,
                                          height: 0.9,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 3.0,
                                              bottom: 3.0,
                                              right: 15,
                                              left: 2),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    informationListScrollDataManagement
                                                        .initialScrollData(
                                                            refreshofHomepageMemoryBankextends
                                                                    .memoryRefreshValue[
                                                                index]);
                                                    jiyikupostpersonalapi(
                                                        refreshofHomepageMemoryBankextends
                                                                .memoryRefreshValue[
                                                            index]['username']);
                                                    switchPage(context,
                                                        const Jiyikudianjipersonal());
                                                  },
                                                  icon: CircleAvatar(
                                                    radius: 21,
                                                    backgroundImage: refreshofHomepageMemoryBankextends
                                                                        .memoryRefreshValue[
                                                                    index]
                                                                ['touxiang'] !=
                                                            null
                                                        ? FileImage(File(
                                                            refreshofHomepageMemoryBankextends
                                                                        .memoryRefreshValue[
                                                                    index]
                                                                ['touxiang']))
                                                        : const AssetImage(
                                                            'assets/chuhui.png'),
                                                  )),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(height: 5),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: RichText(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: refreshofHomepageMemoryBankextends
                                                                              .memoryRefreshValue?[
                                                                          index]
                                                                      ['name'],
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      ' @${refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['username']}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
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
                                                          '${refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['xiabiao'].length}个记忆项',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Color.fromRGBO(
                                                                    84,
                                                                    87,
                                                                    105,
                                                                    1),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Text(
                                                      '${refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['zhuti']}',
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      _typeConversion(
                                                          refreshofHomepageMemoryBankextends
                                                                  .memoryRefreshValue?[
                                                              index]['timu'],
                                                          refreshofHomepageMemoryBankextends
                                                                  .memoryRefreshValue?[
                                                              index]['xiabiao']),
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                      maxLines: 4,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Text(
                                                      _typeConversion(
                                                          refreshofHomepageMemoryBankextends
                                                                  .memoryRefreshValue?[
                                                              index]['huida'],
                                                          refreshofHomepageMemoryBankextends
                                                                  .memoryRefreshValue?[
                                                              index]['xiabiao']),
                                                      style: const TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black),
                                                      maxLines: 7,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 20),
                                                    GetBuilder<
                                                            PersonaljiyikuController>(
                                                        init:
                                                            personaljiyikucontroller,
                                                        builder:
                                                            (personaljiyikuController) {
                                                          return Row(
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (loginStatus ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinlaqu(
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['id'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['laqu'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          smsLogin(
                                                                              context);
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushilaqu(
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'id']),
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
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'laqu'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .blue
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (loginStatus ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinshoucang(
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['id'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['shoucang'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          smsLogin(
                                                                              context);
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushishoucang(
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'id']),
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
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'shoucang'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .orange
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
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
                                                                      size: 20,
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
                                                                        if (loginStatus ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxinxihuan(
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['id'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['xihuan'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          smsLogin(
                                                                              context);
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushixihuan(
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'id']),
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
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'xihuan'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .red
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (loginStatus ==
                                                                            true) {
                                                                          personaljiyikuController.shuaxintiwen(
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['id'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]['tiwen'],
                                                                              refreshofHomepageMemoryBankextends.memoryRefreshValue![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          smsLogin(
                                                                              context);
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikuController.chushitiwen(
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'id']),
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
                                                                          refreshofHomepageMemoryBankextends.memoryRefreshValue?[index]
                                                                              [
                                                                              'tiwen'],
                                                                      countBuilder: (int?
                                                                              count,
                                                                          bool
                                                                              isLiked,
                                                                          String
                                                                              text) {
                                                                        var color = isLiked
                                                                            ? Colors
                                                                                .purple
                                                                            : const Color.fromRGBO(
                                                                                84,
                                                                                87,
                                                                                105,
                                                                                1);
                                                                        Widget
                                                                            result;
                                                                        if (count ==
                                                                            0) {
                                                                          result =
                                                                              Text(
                                                                            "love",
                                                                            style:
                                                                                TextStyle(color: color),
                                                                          );
                                                                        }
                                                                        result =
                                                                            Text(
                                                                          text,
                                                                          style: TextStyle(
                                                                              color: color,
                                                                              fontWeight: FontWeight.w700),
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
                                                          );
                                                        })
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
                                }),
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
      floatingActionButton: SpeedDial(
          backgroundColor: Colors.blue,
          buttonSize: const Size(60, 60),
          animatedIcon: AnimatedIcons.add_event,
          animatedIconTheme: const IconThemeData(color: Colors.white, size: 28),
          spacing: 12,
          childrenButtonSize: const Size(53, 53),
          shape: const CircleBorder(),
          children: [
            SpeedDialChild(
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/jiyiku.svg',
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
                onTap: () {
                  if (loginStatus == false) {
                    smsLogin(context);
                    toast.toastification.show(
                        context: contexts,
                        type: toast.ToastificationType.success,
                        style: toast.ToastificationStyle.flatColored,
                        title: const Text("未登录",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        description: const Text(
                          "未登录",
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.topRight,
                        autoCloseDuration: const Duration(seconds: 4),
                        primaryColor: const Color(0xff047aff),
                        backgroundColor: const Color(0xffedf7ff),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: toast.lowModeShadow,
                        dragToClose: true);
                  } else {
                    switchPage(context, const Jiyiku());
                  }
                }),
          ]),
    );
  }
}



