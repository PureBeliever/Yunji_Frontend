// ignore_for_file: prefer_interpolation_to_compose_strings, avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/cut/cut.dart';
import 'package:yunji/jiyikudianji/jiyikudianji.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonalbei.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonalhead.dart';
import 'package:yunji/main/main.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';

class Jiyikudianjipersonal extends StatefulWidget {
  const Jiyikudianjipersonal({super.key});

  @override
  State<Jiyikudianjipersonal> createState() => _JiyikudianjipersonalPageState();
}

class JiyikudianjipersonalController extends GetxController {
  static JiyikudianjipersonalController get to => Get.find();

  bool beijing = false;
  double filter = 0.0;
  double shadowtitle = 0.0;
  String indexname = '记忆库';
  Map<String, dynamic> zhi = {};

  void cizhi(Map<String, dynamic> cizhi) {
    zhi = cizhi;
  }

  void suoying(int ind) {
    String ji = ind == 0 ? '记忆库' : '';
    String wen = ind == 1 ? '拉取' : '';
    String hui = ind == 2 ? '回复' : '';
    String xi = ind == 3 ? '喜欢' : '';
    indexname = ji + wen + hui + xi;
    update();
  }

  void kong() {
    beijing = false;
    filter = 0.0;
    shadowtitle = 0.0;
    indexname = '记忆库';
  }

  void onebeijing() {
    filter = 3;
    beijing = true;
    update();
  }

  void onenobeijing() {
    filter = 0;
    beijing = false;
    update();
  }

  void onetitle() {
    shadowtitle = 1;
    update();
  }

  void onenotitle() {
    shadowtitle = 0;
    update();
  }
}

final settingzhanghaoxiugaicontroller =
    Get.put(Settingzhanghaoxiugaicontroller());
final personaljiyikudianjiController =
    Get.put(PersonaljiyikudianjiController());

class PersonaljiyikudianjiController extends GetxController {
  static PersonaljiyikudianjiController get to => Get.find();
  List<Map<String, dynamic>>? xihuanzhi = [];
  List<Map<String, dynamic>>? laquzhi = [];
  List<Map<String, dynamic>>? wodezhi = [];
  List<int> xihuan = [];
  List<int> shoucang = [];
  List<int> laqu = [];
  List<int> tiwen = [];
  List<int> wo = [];

  String indexname = ' ';
  void suoying(int ind) {
    String ji = ind == 0 ? '${wo.length}个' : '';
    String wen = ind == 1 ? '${laqu.length}个' : '';
    String hui = ind == 2 ? '' : '';
    String xi = ind == 3 ? '${xihuan.length}个' : '';
    indexname = ji + wen + hui + xi;
    update();
  }

  void shuaxin() async {
    xihuanzhi = await databaseManager.chaxundianji(xihuan);
    laquzhi = await databaseManager.chaxundianji(laqu);

    wodezhi = await databaseManager.chaxundianji(wo);
    wodezhi = wodezhi?.reversed.toList();

    update();
  }

  void apiqingqiu(Map<String, dynamic> zhi) async {
    if (zhi['xihuan'] != null) {
      var xihuancast = zhi['xihuan'].cast<int>();
      xihuan = xihuancast;
      xihuanzhi = await databaseManager.chaxundianji(xihuancast);
      xihuanzhi = xihuanzhi?.reversed.toList();
    }

    if (zhi['shoucang'] != null) {
      var shoucangcast = zhi['shoucang'].cast<int>();
      shoucang = shoucangcast;
    }

    if (zhi['laqu'] != null) {
      var laqucast = zhi['laqu'].cast<int>();
      laqu = laqucast;
      laquzhi = await databaseManager.chaxundianji(laqucast);
      laquzhi = laquzhi?.reversed.toList();
    }

    if (zhi['tiwen'] != null) {
      var tiwencast = zhi['tiwen'].cast<int>();
      tiwen = tiwencast;
    }

    if (zhi['wode'] != null) {
      var wodecast = zhi['wode'].cast<int>();
      indexname = '${wodecast.length}个';
      wo = wodecast;
      wodezhi = await databaseManager.chaxundianji(wodecast);
      wodezhi = wodezhi?.reversed.toList();
    }
    update();
  }

  void shuxinjiemian() {
    update();
  }
}

class _JiyikudianjipersonalPageState extends State<Jiyikudianjipersonal>
    with TickerProviderStateMixin {
  late TabController tabController;
  final maincontroller = Get.put(Maincontroller());
  final jiyikuBeicontroller = Get.put(JiyikuBeicontroller());
  final jiyikudianjipersonalController =
      Get.put(JiyikudianjipersonalController());
  final jiyukupersonalHeadcontroller = Get.put(JiyukupersonalHeadcontroller());
  final jiyikudianjicontroller = Get.put(Jiyikudianjicontroller());
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    jiyikudianjipersonalController.kong();
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
        jiyikudianjipersonalController.suoying(tabController.index);
        personaljiyikudianjiController.suoying(tabController.index);
      });
    tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          scrollController.addListener(() {
            if (scrollController.offset >= 160) {
              jiyikudianjipersonalController.onebeijing();
            } else if (scrollController.offset < 160) {
              jiyikudianjipersonalController.onenobeijing();
            }
            if (scrollController.offset >= 235) {
              jiyikudianjipersonalController.onetitle();
            } else if (scrollController.offset < 235) {
              jiyikudianjipersonalController.onenotitle();
            }
          });
        }));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    jiyikupostpersonalapi(jiyikudianjipersonalController.zhi['username']);
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
                      child: GetBuilder<JiyikudianjipersonalController>(
                          init: jiyikudianjipersonalController,
                          builder: (controller) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jiyikudianjipersonalController.zhi['name'],
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(controller.shadowtitle),
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  personaljiyikudianjiController.indexname +
                                      controller.indexname,
                                  style: TextStyle(
                                    color: Colors.white
                                        .withOpacity(controller.shadowtitle),
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
                              child: GetBuilder<JiyikudianjipersonalController>(
                                init: jiyikudianjipersonalController,
                                builder: (controller) {
                                  return ImageFiltered(
                                    imageFilter: ImageFilter.blur(
                                        sigmaX: controller.filter, sigmaY: 0),
                                    child: GestureDetector(
                                      onTap: () {
                                        jiyikuBeicontroller.cizhi(
                                            jiyikudianjipersonalController
                                                .zhi['beijing']);
                                        handleClick(
                                            context, const JiyikuPersonalBei());
                                      },
                                      child: jiyikudianjipersonalController
                                                  .zhi['beijing'] !=
                                              null
                                          ? Image.file(
                                              File(
                                                  jiyikudianjipersonalController
                                                      .zhi['beijing']),
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
                              child: GetBuilder<JiyikudianjipersonalController>(
                                init: jiyikudianjipersonalController,
                                builder: (controller) {
                                  return AnimatedContainer(
                                    duration: Duration(
                                        seconds: jiyikudianjipersonalController
                                                .beijing
                                            ? 1
                                            : 0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(
                                              jiyikudianjipersonalController
                                                      .beijing
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
                                    jiyukupersonalHeadcontroller.cizhi(
                                        jiyikudianjipersonalController
                                            .zhi['touxiang']);
                                    handleClick(context,
                                        const Jiyikudianjipersonalhead());
                                  },
                                  child: CircleAvatar(
                                    radius: 27,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          jiyikudianjipersonalController
                                                      .zhi['touxiang'] !=
                                                  null
                                              ? FileImage(File(
                                                  jiyikudianjipersonalController
                                                      .zhi['touxiang']))
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
                                      jiyukupersonalHeadcontroller.cizhi(
                                          jiyikudianjipersonalController
                                              .zhi['touxiang']);
                                      handleClick(context,
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
                                jiyikudianjipersonalController.zhi['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 24,
                                  color: Colors.black,
                                  fontFamily: 'Raleway',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              GetBuilder<Settingzhanghaoxiugaicontroller>(
                                  init: settingzhanghaoxiugaicontroller,
                                  builder: (settingcontroller) {
                                    return Text(
                                      '@${settingcontroller.username}',
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
                                child: jiyikudianjipersonalController
                                        .zhi['brief']
                                        .trim()
                                        .isNotEmpty
                                    ? Text(
                                        jiyikudianjipersonalController
                                            .zhi['brief'],
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
                                  jiyikudianjipersonalController.zhi['year']
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
                                                    jiyikudianjipersonalController
                                                        .zhi['year'],
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
                                  jiyikudianjipersonalController.zhi['place']
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
                                                jiyikudianjipersonalController
                                                    .zhi['place'],
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
                                          jiyikudianjipersonalController
                                              .zhi['jiaru'],
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
              body: GetBuilder<PersonaljiyikuController>(
                  init: personaljiyikucontroller,
                  builder: (personaljiyikucontroller) {
                    return GetBuilder<PersonaljiyikudianjiController>(
                        init: personaljiyikudianjiController,
                        builder: (personaljiyikudianjiController) {
                          return TabBarView(
                            controller: tabController,
                            children: [
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: ListView.builder(
                                      physics: physics,
                                      itemCount: personaljiyikudianjiController
                                                  .wodezhi ==
                                              null
                                          ? 0
                                          : personaljiyikudianjiController
                                              .wodezhi?.length,
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
                                                jiyikudianjicontroller.cizhi(
                                                    personaljiyikudianjiController
                                                        .wodezhi![index]);
                                                handleClick(context,
                                                    const jiyikudianji());
                                              },
                                              child: Padding(
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
                                                        onPressed: () {},
                                                        icon: CircleAvatar(
                                                          radius: 21,
                                                          backgroundImage: personaljiyikudianjiController
                                                                              .wodezhi?[
                                                                          index]
                                                                      [
                                                                      'touxiang'] !=
                                                                  null
                                                              ? FileImage(File(
                                                                  personaljiyikudianjiController
                                                                              .wodezhi![
                                                                          index]
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
                                                                          text: personaljiyikudianjiController.wodezhi?[index]
                                                                              [
                                                                              'name'],
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w900,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' @${personaljiyikudianjiController.wodezhi?[index]['username']}',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: Color.fromRGBO(
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
                                                                '${personaljiyikudianjiController.wodezhi?[index]['xiabiao'].length}个记忆项',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
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
                                                            '${personaljiyikudianjiController.wodezhi?[index]['zhuti']}',
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
                                                                personaljiyikudianjiController
                                                                            .wodezhi?[
                                                                        index]
                                                                    ['timu'],
                                                                personaljiyikudianjiController
                                                                            .wodezhi?[
                                                                        index][
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
                                                                personaljiyikudianjiController
                                                                            .wodezhi?[
                                                                        index]
                                                                    ['huida'],
                                                                personaljiyikudianjiController
                                                                            .wodezhi?[
                                                                        index][
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinlaqu(
                                                                              personaljiyikudianjiController.wodezhi?[index]['id'],
                                                                              personaljiyikudianjiController.wodezhi?[index]['laqu'],
                                                                              personaljiyikudianjiController.wodezhi![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushilaqu(
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinshoucang(
                                                                              personaljiyikudianjiController.wodezhi?[index]['id'],
                                                                              personaljiyikudianjiController.wodezhi?[index]['shoucang'],
                                                                              personaljiyikudianjiController.wodezhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushishoucang(
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinxihuan(
                                                                              personaljiyikudianjiController.wodezhi?[index]['id'],
                                                                              personaljiyikudianjiController.wodezhi?[index]['xihuan'],
                                                                              personaljiyikudianjiController.wodezhi![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushixihuan(
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxintiwen(
                                                                              personaljiyikudianjiController.wodezhi?[index]['id'],
                                                                              personaljiyikudianjiController.wodezhi?[index]['tiwen'],
                                                                              personaljiyikudianjiController.wodezhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushitiwen(
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                                                          personaljiyikudianjiController.wodezhi?[index]
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
                                      })),
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: ListView.builder(
                                      physics: physics,
                                      itemCount: personaljiyikudianjiController
                                                  .laquzhi ==
                                              null
                                          ? 0
                                          : personaljiyikudianjiController
                                              .laquzhi?.length,
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
                                                jiyikudianjicontroller.cizhi(
                                                    personaljiyikudianjiController
                                                        .laquzhi![index]);
                                                handleClick(context,
                                                    const jiyikudianji());
                                              },
                                              child: Padding(
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
                                                        onPressed: () {},
                                                        icon: CircleAvatar(
                                                          radius: 21,
                                                          backgroundImage: personaljiyikudianjiController
                                                                              .laquzhi?[
                                                                          index]
                                                                      [
                                                                      'touxiang'] !=
                                                                  null
                                                              ? FileImage(File(
                                                                  personaljiyikudianjiController
                                                                              .laquzhi![
                                                                          index]
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
                                                                          text: personaljiyikudianjiController.laquzhi?[index]
                                                                              [
                                                                              'name'],
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w900,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' @${personaljiyikudianjiController.laquzhi?[index]['username']}',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: Color.fromRGBO(
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
                                                                '${personaljiyikudianjiController.laquzhi?[index]['xiabiao'].length}个记忆项',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
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
                                                            '${personaljiyikudianjiController.laquzhi?[index]['zhuti']}',
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
                                                                personaljiyikudianjiController
                                                                            .laquzhi?[
                                                                        index]
                                                                    ['timu'],
                                                                personaljiyikudianjiController
                                                                            .laquzhi?[
                                                                        index][
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
                                                                personaljiyikudianjiController
                                                                            .laquzhi?[
                                                                        index]
                                                                    ['huida'],
                                                                personaljiyikudianjiController
                                                                            .laquzhi?[
                                                                        index][
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinlaqu(
                                                                              personaljiyikudianjiController.laquzhi?[index]['id'],
                                                                              personaljiyikudianjiController.laquzhi?[index]['laqu'],
                                                                              personaljiyikudianjiController.laquzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushilaqu(
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinshoucang(
                                                                              personaljiyikudianjiController.laquzhi?[index]['id'],
                                                                              personaljiyikudianjiController.laquzhi?[index]['shoucang'],
                                                                              personaljiyikudianjiController.laquzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushishoucang(
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinxihuan(
                                                                              personaljiyikudianjiController.laquzhi?[index]['id'],
                                                                              personaljiyikudianjiController.laquzhi?[index]['xihuan'],
                                                                              personaljiyikudianjiController.laquzhi![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushixihuan(
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxintiwen(
                                                                              personaljiyikudianjiController.laquzhi?[index]['id'],
                                                                              personaljiyikudianjiController.laquzhi?[index]['tiwen'],
                                                                              personaljiyikudianjiController.laquzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushitiwen(
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                                                          personaljiyikudianjiController.laquzhi?[index]
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
                                      })),
                              ListView.builder(itemBuilder: (context, index) {
                                return null;
                              }),
                              MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  removeBottom: true,
                                  child: ListView.builder(
                                      physics: physics,
                                      itemCount: personaljiyikudianjiController
                                                  .xihuanzhi ==
                                              null
                                          ? 0
                                          : personaljiyikudianjiController
                                              .xihuanzhi?.length,
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
                                                jiyikudianjicontroller.cizhi(
                                                    personaljiyikudianjiController
                                                        .xihuanzhi![index]);
                                                handleClick(context,
                                                    const jiyikudianji());
                                              },
                                              child: Padding(
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
                                                        onPressed: () {},
                                                        icon: CircleAvatar(
                                                          radius: 21,
                                                          backgroundImage: personaljiyikudianjiController
                                                                              .xihuanzhi?[
                                                                          index]
                                                                      [
                                                                      'touxiang'] !=
                                                                  null
                                                              ? FileImage(File(
                                                                  personaljiyikudianjiController
                                                                              .xihuanzhi![
                                                                          index]
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
                                                                          text: personaljiyikudianjiController.xihuanzhi?[index]
                                                                              [
                                                                              'name'],
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                17,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w900,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' @${personaljiyikudianjiController.xihuanzhi?[index]['username']}',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontWeight:
                                                                                FontWeight.w400,
                                                                            color: Color.fromRGBO(
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
                                                                '${personaljiyikudianjiController.xihuanzhi?[index]['xiabiao'].length}个记忆项',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 16,
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
                                                            '${personaljiyikudianjiController.xihuanzhi?[index]['zhuti']}',
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
                                                                personaljiyikudianjiController
                                                                            .xihuanzhi?[
                                                                        index]
                                                                    ['timu'],
                                                                personaljiyikudianjiController
                                                                            .xihuanzhi?[
                                                                        index][
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
                                                                personaljiyikudianjiController
                                                                            .xihuanzhi?[
                                                                        index]
                                                                    ['huida'],
                                                                personaljiyikudianjiController
                                                                            .xihuanzhi?[
                                                                        index][
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
                                                                      size: 20,
                                                                      onTap:
                                                                          (isLiked) async {
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinlaqu(
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['id'],
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['laqu'],
                                                                              personaljiyikudianjiController.xihuanzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushilaqu(
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinshoucang(
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['id'],
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['shoucang'],
                                                                              personaljiyikudianjiController.xihuanzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushishoucang(
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxinxihuan(
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['id'],
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['xihuan'],
                                                                              personaljiyikudianjiController.xihuanzhi![index]);

                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushixihuan(
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                        if (denglu ==
                                                                            true) {
                                                                          personaljiyikucontroller.shuaxintiwen(
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['id'],
                                                                              personaljiyikudianjiController.xihuanzhi?[index]['tiwen'],
                                                                              personaljiyikudianjiController.xihuanzhi![index]);
                                                                          return !isLiked;
                                                                        } else {
                                                                          chushi();
                                                                          return isLiked;
                                                                        }
                                                                      },
                                                                      isLiked: personaljiyikucontroller.chushitiwen(
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                                                          personaljiyikudianjiController.xihuanzhi?[index]
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
                                      })),
                            ],
                          );
                        });
                  }),
            );
          }),
    );
  }
}

typedef SliverHeaderBuilder = Widget Function(
    BuildContext context, double shrinkOffset, bool overlapsContent);

class SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  // child 为 header
  SliverHeaderDelegate({
    required this.maxHeight,
    this.minHeight = 0,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        assert(minHeight <= maxHeight && minHeight >= 0);

  //最大和最小高度相同
  SliverHeaderDelegate.fixedHeight({
    required double height,
    required Widget child,
  })  : builder = ((a, b, c) => child),
        maxHeight = height,
        minHeight = height;

  //需要自定义builder时使用
  SliverHeaderDelegate.builder({
    required this.maxHeight,
    this.minHeight = 0,
    required this.builder,
  });

  final double maxHeight;
  final double minHeight;
  final SliverHeaderBuilder builder;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    Widget child = builder(context, shrinkOffset, overlapsContent);

    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            //阴影

            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 0.3),
                blurRadius: 1.8),
          ],
        ),
        child: SizedBox.expand(child: child));
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(SliverHeaderDelegate oldDelegate) {
    return oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
