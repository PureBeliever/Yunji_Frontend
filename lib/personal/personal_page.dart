import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:keframe/keframe.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:like_button/like_button.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/jixv_fuxi/jixvfuxi_page.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/modified_component/sliver_header_delegate.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/switch/switch_page.dart';
import 'package:yunji/jiyikudianji/jiyikudianji.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/fuxi/fuxi_page.dart';
import 'package:yunji/personal/personal_bei.dart';
import 'package:yunji/personal/personal_head.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/sql/sqlite.dart';




class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class RollingeffectController extends GetxController {
  static RollingeffectController get to => Get.find();

  bool beijing = false;
  double filter = 0.0;
  double shadowtitle = 0.0;
  String indexname = '记忆库';

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
// 记忆库完成状态
class MemoryBankCompletionStatus extends GetxController {
  static MemoryBankCompletionStatus get to => Get.find();
// 是否显示其它图标
  bool displayIconStatus(int? status) {
    bool displayIconStatusValue = status == 1 ? true : false;
    return displayIconStatusValue;
  }

  Widget memoryLibraryStatusDisplayWidget(
      Map<String, dynamic> widgetsDisplayValues, BuildContext context) {
        
    var setTimeValueDynamic = widgetsDisplayValues['dingshi'];
    DateTime setTimeValueDateTime = DateTime.parse(setTimeValueDynamic);
    DateTime presentTimeDateTime = DateTime.now();

    Duration setTimeValueDuration = setTimeValueDateTime.difference(presentTimeDateTime);
    final int numberOfDays = setTimeValueDuration.inDays;
    final int numberOfHours = setTimeValueDuration.inHours % 24;
    final int numberOfMinutes = setTimeValueDuration.inMinutes % 60;

    Map<String, dynamic> theWidgetDisplaysTheValue = jsonDecode(widgetsDisplayValues['cishu']);

    int displaysTheNumberOfValues = theWidgetDisplaysTheValue.length;
    List<String> statusRecord = [];

    theWidgetDisplaysTheValue.forEach(
      (key, value) {
        if (key != '方案1') {
          statusRecord.add('已完成${key}次${value}的复习');
        } else {
          Text(
            '未选择复习',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color.fromRGBO(84, 87, 105, 1),
            ),
          );
        }
      },
    );
    String displayStatusRecord = "距离下一次复习还剩${numberOfDays}天${numberOfHours}小时${numberOfMinutes}分钟";

    double height = displaysTheNumberOfValues * 23;

    Widget statusDisplayWidget = SizedBox(
      width: double.infinity,
      height: 46,
      child: ListView(
        children: [
          SizedBox(
            width: double.infinity,
            height: height,
            child: ListView.builder(
                cacheExtent: 500,
                physics: NeverScrollableScrollPhysics(),
                itemCount: displaysTheNumberOfValues,   
                itemBuilder: (context, index) {
                  return Text(
                    statusRecord[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Color.fromRGBO(84, 87, 105, 1),
                    ),
                  );
                }),
          ),
          GestureDetector(
            onTap: () {
              continueLearningAboutDataManagement.initTheMemoryData(widgetsDisplayValues);
              switchPage(context, JixvfuxiPage());
            },
            child: Text(
              '继续学习',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
                fontSize: 16,
                decoration: TextDecoration.underline,
                decorationColor: Colors.green,
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ),
        ],
      ),
    );

    if (setTimeValueDuration.inMinutes <= 0 && widgetsDisplayValues['zhuangtai'] == 0) {
      statusDisplayWidget = GestureDetector(
        onTap: () {
          reviewTheDataManagementOfMemoryBank.initTheMemoryData(widgetsDisplayValues);
          switchPage(context, FuxiPage());
        },
        child: Text(
          '开始复习',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.green,
            fontSize: 16,
            decoration: TextDecoration.underline,
            decorationColor: Colors.green,
            decorationStyle: TextDecorationStyle.solid,
          ),
        ),
      );
    }
    if (setTimeValueDuration.inMinutes > 0 && widgetsDisplayValues['zhuangtai'] == 0) {
      statusDisplayWidget = Text(
        displayStatusRecord,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: Color.fromRGBO(84, 87, 105, 1),
        ),
      );
    }

    return statusDisplayWidget;
  }

  void refreshDisplay() {
    update();
  }
}

class PersonaljiyikuController extends GetxController {
  static PersonaljiyikuController get to => Get.find();
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

  void apiqingqiu(Map<String, dynamic> zhi) async {
    if (zhi['xihuan'] != null) {
      var xihuancast = zhi['xihuan'].cast<int>();
      xihuan = xihuancast;
      xihuanzhi = await databaseManager.queryUserPersonalMemoryBank(xihuancast);
    }

    if (zhi['shoucang'] != null) {
      var shoucangcast = zhi['shoucang'].cast<int>();
      shoucang = shoucangcast;
    }

    if (zhi['laqu'] != null) {
      var laqucast = zhi['laqu'].cast<int>();
      laqu = laqucast;
      laquzhi = await databaseManager.queryUserPersonalMemoryBank(laqucast);
    }

    if (zhi['tiwen'] != null) {
      var tiwencast = zhi['tiwen'].cast<int>();
      tiwen = tiwencast;
    }

    if (zhi['wode'] != null) {
      var wodecast = zhi['wode'].cast<int>();
      indexname = '${wodecast.length}个';
      wo = wodecast;
      wodezhi = await databaseManager.queryUserPersonalMemoryBank(wodecast);
    }
    update();
  }

  void shuaxin(Map<String, dynamic>? zhi) async {
    var laqujson = zhi?['laqu'] == null ? null : jsonDecode(zhi?['laqu']);
    var tiwenjson = zhi?['tiwen'] == null ? null : jsonDecode(zhi?['tiwen']);
    var wodejson = zhi?['wode'] == null ? null : jsonDecode(zhi?['wode']);
    var shoucangjson =
        zhi?['shoucang'] == null ? null : jsonDecode(zhi?['shoucang']);
    var xihuanjson = zhi?['xihuan'] == null ? null : jsonDecode(zhi?['xihuan']);

    if (xihuanjson != null) {
      var xihuancast = xihuanjson.cast<int>();
      xihuan = xihuancast;
      xihuanzhi = await databaseManager.queryUserPersonalMemoryBank(xihuancast);
    }

    if (shoucangjson != null) {
      var shoucangcast = shoucangjson.cast<int>();
      shoucang = shoucangcast;
    }

    if (laqujson != null) {
      var laqucast = laqujson.cast<int>();
      laqu = laqucast;
      laquzhi = await databaseManager.queryUserPersonalMemoryBank(laqucast);
    }

    if (tiwenjson != null) {
      var tiwencast = tiwenjson.cast<int>();
      tiwen = tiwencast;
    }

    if (wodejson != null) {
      var wodecast = wodejson.cast<int>();
      wo = wodecast;
      wodezhi = await databaseManager.queryUserPersonalMemoryBank(wodecast);
    }
    update();
  }

  void shuaxinxihuan(int id, int shuzhi, Map<String, dynamic> xizhi) async {
    if (xihuan.contains(id)) {
      xihuan.remove(id);
      shuzhi -= 1;
    } else {
      xihuan.add(id);
      shuzhi += 1;
    }

    xihuanapi(userNameChangeManagement.userNameValue, jsonEncode(xihuan), id,
        shuzhi);

    await databaseManager.updateMemoryBankLikes(
        userNameChangeManagement.userNameValue,
        jsonEncode(xihuan),
        id,
        shuzhi,
        xizhi);

    Map<String, dynamic>? zhi = await databaseManager.chapersonal();
    List<Map<String, dynamic>>? mainzhi = await databaseManager.queryHomePageMemoryBank();
    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(mainzhi);
    otherPeoplePersonalInformationManagement.readDatabaseRefreshData();
    personaljiyikucontroller.shuaxin(zhi);
  }

  void shuaxinshoucang(int id, int shuzhi, Map<String, dynamic> xizhi) async {
    if (shoucang.contains(id)) {
      shoucang.remove(id);
      shuzhi -= 1;
    } else {
      shoucang.add(id);
      shuzhi += 1;
    }

    shoucangapi(userNameChangeManagement.userNameValue, jsonEncode(shoucang),
        id, shuzhi);

    await databaseManager.updateMemoryBankCollects(
        userNameChangeManagement.userNameValue,
        jsonEncode(shoucang),
        id,
        shuzhi,
        xizhi);

    Map<String, dynamic>? zhi = await databaseManager.chapersonal();
    List<Map<String, dynamic>>? mainzhi = await databaseManager.queryHomePageMemoryBank();
    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(mainzhi);
    otherPeoplePersonalInformationManagement.readDatabaseRefreshData();
    personaljiyikucontroller.shuaxin(zhi);
  }

  void shuaxinlaqu(int id, int shuzhi, Map<String, dynamic> xizhi) async {
    if (laqu.contains(id)) {
      laqu.remove(id);
      shuzhi -= 1;
    } else {
      laqu.add(id);
      shuzhi += 1;
    }
    laquapi(
        userNameChangeManagement.userNameValue, jsonEncode(laqu), id, shuzhi);

    await databaseManager.updateMemoryBankLags(
        userNameChangeManagement.userNameValue,
        jsonEncode(laqu),
        id,
        shuzhi,
        xizhi);

    Map<String, dynamic>? zhi = await databaseManager.chapersonal();
    List<Map<String, dynamic>>? mainzhi = await databaseManager.queryHomePageMemoryBank();
    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(mainzhi);
    otherPeoplePersonalInformationManagement.readDatabaseRefreshData();
    personaljiyikucontroller.shuaxin(zhi);
  }

  void shuaxintiwen(int id, int shuzhi, Map<String, dynamic> xizhi) async {
    if (tiwen.contains(id)) {
      shuzhi -= 1;
      tiwen.remove(id);
    } else {
      tiwen.add(id);
      shuzhi += 1;
    }

    tiwenapi(userNameChangeManagement.userNameValue, jsonEncode(tiwen), id,
        shuzhi);

    await databaseManager.updateMemoryBankQuestions(
        userNameChangeManagement.userNameValue,
        jsonEncode(tiwen),
        id,
        shuzhi,
        xizhi);

    Map<String, dynamic>? zhi = await databaseManager.chapersonal();
    List<Map<String, dynamic>>? mainzhi = await databaseManager.queryHomePageMemoryBank();
    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(mainzhi);
    otherPeoplePersonalInformationManagement.readDatabaseRefreshData();
    personaljiyikucontroller.shuaxin(zhi);
  }

  bool chushilaqu(int id) {
    if (laqu.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  int chushilaquint(int id) {
    if (laqu.contains(id)) {
      return 1;
    } else {
      return 0;
    }
  }

  bool chushitiwen(int id) {
    if (tiwen.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  int chushitiwenint(int id) {
    if (tiwen.contains(id)) {
      return 1;
    } else {
      return 0;
    }
  }

  bool chushixihuan(int id) {
    if (xihuan.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  int chushixihuanint(int id) {
    if (xihuan.contains(id)) {
      return 1;
    } else {
      return 0;
    }
  }

  bool chushishoucang(int id) {
    if (shoucang.contains(id)) {
      return true;
    } else {
      return false;
    }
  }

  int chushishoucangint(int id) {
    if (shoucang.contains(id)) {
      return 1;
    } else {
      return 0;
    }
  }
}

class _PersonalPageState extends State<PersonalPage>
    with TickerProviderStateMixin {
  late TabController tabController;
  // 记忆板完成状态
  final memoryBankCompletionStatus = Get.put(MemoryBankCompletionStatus());
  final personaljiyikucontroller = Get.put(PersonaljiyikuController());
  final editPersonalDataValueManagement = Get.put(EditPersonalDataValueManagement());
  final backgroundImageChangeManagement = Get.put(BackgroundImageChangeManagement());
  final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());
  final rollingeffectController = Get.put(RollingeffectController());

  ScrollController scrollController = ScrollController();
  @override
  void dispose() {
    rollingeffectController.kong();
    scrollController.dispose();
    tabController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(minutes: 1), (timer) {
      memoryBankCompletionStatus.refreshDisplay();
    });
    tabController = TabController(
      length: 4,
      initialIndex: 0,
      vsync: this,
      animationDuration: const Duration(milliseconds: 100),
    )..addListener(() {
        rollingeffectController.suoying(tabController.index);
        personaljiyikucontroller.suoying(tabController.index);
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
          scrollController.addListener(() {
            if (scrollController.offset >= 160) {
              rollingeffectController.onebeijing();
            } else if (scrollController.offset < 160) {
              rollingeffectController.onenobeijing();
            }
            if (scrollController.offset >= 235) {
              rollingeffectController.onetitle();
            } else if (scrollController.offset < 235) {
              rollingeffectController.onenotitle();
            }
          });
        }));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    postpersonalapi(userNameChangeManagement.userNameValue);
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
      body: GetBuilder<EditPersonalDataValueManagement>(
        init: editPersonalDataValueManagement,
        builder: (editPersonalDataValueManagement) {
          return EasyRefresh.builder(
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
                          child: GetBuilder<RollingeffectController>(
                              init: rollingeffectController,
                              builder: (controller) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      editPersonalDataValueManagement.nameValue,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(
                                            controller.shadowtitle),
                                        fontSize: 21,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      personaljiyikucontroller.indexname +
                                          controller.indexname,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(
                                            controller.shadowtitle),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
                              color: Colors.black
                                  .withOpacity(0.5), // 设置Container的背景颜色
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
                            padding:
                                const EdgeInsets.only(left: 13.0, right: 16.0),
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
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
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
                                  child: GetBuilder<RollingeffectController>(
                                    init: rollingeffectController,
                                    builder: (controller) {
                                      return ImageFiltered(
                                        imageFilter: ImageFilter.blur(
                                            sigmaX: controller.filter,
                                            sigmaY: 0),
                                        child: GestureDetector(
                                          onTap: () {
                                            switchPage(
                                                context, const PersonalBei());
                                          },
                                          child: GetBuilder<BackgroundImageChangeManagement>(
                                            init: backgroundImageChangeManagement,
                                            builder: (backgroundImageChangeManagement) {
                                              return backgroundImageChangeManagement.backgroundImageValue !=
                                                      null
                                                  ? Image.file(
                                                      backgroundImageChangeManagement.backgroundImageValue!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/chuhui.png',
                                                      fit: BoxFit.cover,
                                                    );
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
                                  child: GetBuilder<RollingeffectController>(
                                    init: rollingeffectController,
                                    builder: (controller) {
                                      return AnimatedContainer(
                                        duration: Duration(
                                            seconds:
                                                rollingeffectController.beijing
                                                    ? 1
                                                    : 0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(
                                                  rollingeffectController
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
                                        switchPage(
                                            context, const PersonalHead());
                                      },
                                      child: CircleAvatar(
                                          radius: 27,
                                          backgroundColor: Colors.white,
                                          child: GetBuilder<HeadPortraitChangeManagement>(
                                              init: headPortraitChangeManagement,
                                              builder: (headPortraitChangeManagement) {
                                                return CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: headPortraitChangeManagement
                                                              .headPortraitValue !=
                                                          null
                                                      ? FileImage(headPortraitChangeManagement
                                                          .headPortraitValue!)
                                                      : const AssetImage(
                                                          'assets/chuhui.png'),
                                                  radius: 25,
                                                );
                                              })),
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
                                          switchPage(
                                              context, const PersonalHead());
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
                                      ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    const Color.fromARGB(
                                                        255, 119, 118, 118)),
                                            elevation:
                                                WidgetStateProperty.all(4.0)),
                                        child: const Text(
                                          "编辑个人资料",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          if (loginStatus == false) {
                                            smsLogin(context);
                                            toast.toastification.show(
                                                context: contexts,
                                                type: toast
                                                    .ToastificationType.success,
                                                style: toast.ToastificationStyle
                                                    .flatColored,
                                                title: const Text("未登录",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 17)),
                                                description: const Text(
                                                  "未登录",
                                                  style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 119, 118, 118),
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                alignment: Alignment.topRight,
                                                autoCloseDuration:
                                                    const Duration(seconds: 4),
                                                primaryColor:
                                                    const Color(0xff047aff),
                                                backgroundColor:
                                                    const Color(0xffedf7ff),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                                boxShadow: toast.lowModeShadow,
                                                dragToClose: true);
                                          } else {
                                            switchPage(context,
                                                const BianpersonalPage());
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    editPersonalDataValueManagement.nameValue,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      color: Colors.black,
                                      fontFamily: 'Raleway',
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  GetBuilder<UserNameChangeManagement>(
                                      init: UserNameChangeManagement.to,
                                      builder: (UserNameChangeManagement) {
                                        return Text(
                                          '@${UserNameChangeManagement.userNameValue}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                            color:
                                                Color.fromRGBO(84, 87, 105, 1),
                                            fontFamily: 'Raleway',
                                            decoration: TextDecoration.none,
                                          ),
                                        );
                                      }),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 13.0),
                                    child: editPersonalDataValueManagement.profileValue
                                            .trim()
                                            .isNotEmpty
                                        ? Text(
                                                editPersonalDataValueManagement.profileValue,
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
                                      editPersonalDataValueManagement.dateOfBirthValue.trim().isNotEmpty
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
                                                    '出生于 ${editPersonalDataValueManagement.dateOfBirthValue}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                      editPersonalDataValueManagement.residentialAddressValue.trim().isNotEmpty
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
                                                    editPersonalDataValueManagement.residentialAddressValue,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                              'assets/jiaruriqi.svg',
                                              width: 20,
                                              height: 20),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Expanded(
                                            child: Text(
                                                editPersonalDataValueManagement.dateOfBirthValue,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16,
                                                color: Color.fromRGBO(
                                                    84, 87, 105, 1),
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
                                    padding: EdgeInsets.only(
                                        top: 13.0, bottom: 13.0),
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
                                            color:
                                                Color.fromRGBO(84, 87, 105, 1),
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
                                            color:
                                                Color.fromRGBO(84, 87, 105, 1),
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
                      builder: (personaljiyikuController) {
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
                                      itemCount:
                                          personaljiyikucontroller.wodezhi ==
                                                  null
                                              ? 0
                                              : personaljiyikucontroller
                                                  .wodezhi?.length,
                                      itemBuilder: (context, index) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(
                                              color: Color.fromRGBO(
                                                  223, 223, 223, 1),
                                              thickness: 0.9,
                                              height: 0.9,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(
                                                    personaljiyikuController
                                                        .wodezhi![index]);
                                                switchPage(context,
                                                    const jiyikudianji());
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 3.0,
                                                    bottom: 3.0,
                                                    right: 15,
                                                    left: 2),
                                                child: Column(
                                                  children: [
                                                    GetBuilder<
                                                            MemoryBankCompletionStatus>(
                                                        init:
                                                            memoryBankCompletionStatus,
                                                        builder:
                                                            (memoryBankCompletionStatus) {
                                                          return Row(children: [
                                                            memoryBankCompletionStatus!.displayIconStatus(
                                                                        personaljiyikucontroller.wodezhi?[index]
                                                                            [
                                                                            'zhuangtai']) ==
                                                                    false
                                                                ? Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            28,
                                                                        right:
                                                                            10,
                                                                        top: 3),
                                                                    child: SvgPicture.asset(
                                                                        'assets/shijian.svg',
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20))
                                                                : Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left:
                                                                            21,
                                                                        right:
                                                                            10,
                                                                        top: 3),
                                                                    child: SvgPicture.asset(
                                                                        'assets/jiangzhuang.svg',
                                                                        width:
                                                                            27,
                                                                        height: 27)),
                                                            Expanded(
                                                              child: memoryBankCompletionStatus
                                                                  .memoryLibraryStatusDisplayWidget(
                                                                      personaljiyikucontroller
                                                                              .wodezhi![
                                                                          index],
                                                                      context),
                                                            ),
                                                          ]);
                                                        }),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Column(
                                                          children: [
                                                            IconButton(
                                                                onPressed:
                                                                    () {},
                                                                icon:
                                                                    CircleAvatar(
                                                                  radius: 21,
                                                                  backgroundImage: personaljiyikucontroller.wodezhi?[index]
                                                                              [
                                                                              'touxiang'] !=
                                                                          null
                                                                      ? FileImage(
                                                                          File(personaljiyikucontroller.wodezhi![index]
                                                                              [
                                                                              'touxiang']))
                                                                      : const AssetImage(
                                                                          'assets/chuhui.png'),
                                                                )),
                                                          ],
                                                        ),
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
                                                                        RichText(
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      text:
                                                                          TextSpan(
                                                                        children: [
                                                                          TextSpan(
                                                                            text:
                                                                                personaljiyikucontroller.wodezhi?[index]['name'],
                                                                            style:
                                                                                const TextStyle(
                                                                              fontSize: 17,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w900,
                                                                            ),
                                                                          ),
                                                                          TextSpan(
                                                                            text:
                                                                                ' @${personaljiyikucontroller.wodezhi?[index]['username']}',
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
                                                                  const Text(
                                                                    ' ·',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            17,
                                                                        color: Color.fromRGBO(
                                                                            84,
                                                                            87,
                                                                            105,
                                                                            1),
                                                                        fontWeight:
                                                                            FontWeight.w900),
                                                                  ),
                                                                  Text(
                                                                    '${personaljiyikucontroller.wodezhi?[index]['xiabiao'].length}个记忆项',
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
                                                                '${personaljiyikucontroller.wodezhi?[index]['zhuti']}',
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
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
                                                                    personaljiyikucontroller
                                                                            .wodezhi?[index]
                                                                        [
                                                                        'timu'],
                                                                    personaljiyikucontroller
                                                                            .wodezhi?[index]
                                                                        [
                                                                        'xiabiao']),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
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
                                                                    personaljiyikucontroller
                                                                            .wodezhi?[index]
                                                                        [
                                                                        'huida'],
                                                                    personaljiyikucontroller
                                                                            .wodezhi?[index]
                                                                        [
                                                                        'xiabiao']),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        17,
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
                                                              SizedBox(
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
                                                                              start: Color.fromARGB(255, 42, 91, 255),
                                                                              end: Color.fromARGB(255, 142, 204, 255)),
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
                                                                            personaljiyikuController.shuaxinlaqu(
                                                                                personaljiyikucontroller.wodezhi?[index]['id'],
                                                                                personaljiyikucontroller.wodezhi?[index]['laqu'],
                                                                                personaljiyikuController.wodezhi![index]);
                                                                            return !isLiked;
                                                                          },
                                                                          isLiked:
                                                                              personaljiyikuController.chushilaqu(personaljiyikucontroller.wodezhi?[index]['id']),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              isLiked ? Icons.swap_calls : Icons.swap_calls,
                                                                              color: isLiked ? Colors.blue : const Color.fromRGBO(84, 87, 105, 1),
                                                                              size: 20,
                                                                            );
                                                                          },
                                                                          likeCount:
                                                                              personaljiyikucontroller.wodezhi?[index]['laqu'],
                                                                          countBuilder: (int? count,
                                                                              bool isLiked,
                                                                              String text) {
                                                                            var color = isLiked
                                                                                ? Colors.blue
                                                                                : const Color.fromRGBO(84, 87, 105, 1);
                                                                            Widget
                                                                                result;
                                                                            if (count ==
                                                                                0) {
                                                                              result = Text(
                                                                                "love",
                                                                                style: TextStyle(color: color),
                                                                              );
                                                                            }
                                                                            result =
                                                                                Text(
                                                                              text,
                                                                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
                                                                              start: Color.fromARGB(255, 253, 156, 46),
                                                                              end: Color.fromARGB(255, 255, 174, 120)),
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
                                                                            personaljiyikuController.shuaxinshoucang(
                                                                                personaljiyikucontroller.wodezhi?[index]['id'],
                                                                                personaljiyikucontroller.wodezhi?[index]['shoucang'],
                                                                                personaljiyikuController.wodezhi![index]);
                                                                            return !isLiked;
                                                                          },
                                                                          isLiked:
                                                                              personaljiyikuController.chushishoucang(personaljiyikucontroller.wodezhi?[index]['id']),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              isLiked ? Icons.folder : Icons.folder_open,
                                                                              color: isLiked ? Colors.orange : const Color.fromRGBO(84, 87, 105, 1),
                                                                              size: 20,
                                                                            );
                                                                          },
                                                                          likeCount:
                                                                              personaljiyikucontroller.wodezhi?[index]['shoucang'],
                                                                          countBuilder: (int? count,
                                                                              bool isLiked,
                                                                              String text) {
                                                                            var color = isLiked
                                                                                ? Colors.orange
                                                                                : const Color.fromRGBO(84, 87, 105, 1);
                                                                            Widget
                                                                                result;
                                                                            if (count ==
                                                                                0) {
                                                                              result = Text(
                                                                                "love",
                                                                                style: TextStyle(color: color),
                                                                              );
                                                                            }
                                                                            result =
                                                                                Text(
                                                                              text,
                                                                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
                                                                              start: Color.fromARGB(255, 255, 64, 64),
                                                                              end: Color.fromARGB(255, 255, 206, 206)),
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
                                                                            personaljiyikucontroller.shuaxinxihuan(
                                                                                personaljiyikucontroller.wodezhi?[index]['id'],
                                                                                personaljiyikucontroller.wodezhi?[index]['xihuan'],
                                                                                personaljiyikuController.wodezhi![index]);

                                                                            return !isLiked;
                                                                          },
                                                                          isLiked:
                                                                              personaljiyikuController.chushixihuan(personaljiyikucontroller.wodezhi?[index]['id']),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              isLiked ? Icons.favorite : Icons.favorite_border,
                                                                              color: isLiked ? Colors.red : const Color.fromRGBO(84, 87, 105, 1),
                                                                              size: 20,
                                                                            );
                                                                          },
                                                                          likeCount:
                                                                              personaljiyikucontroller.wodezhi?[index]['xihuan'],
                                                                          countBuilder: (int? count,
                                                                              bool isLiked,
                                                                              String text) {
                                                                            var color = isLiked
                                                                                ? Colors.red
                                                                                : const Color.fromRGBO(84, 87, 105, 1);
                                                                            Widget
                                                                                result;
                                                                            if (count ==
                                                                                0) {
                                                                              result = Text(
                                                                                "love",
                                                                                style: TextStyle(color: color),
                                                                              );
                                                                            }
                                                                            result =
                                                                                Text(
                                                                              text,
                                                                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
                                                                              start: Color.fromARGB(255, 237, 42, 255),
                                                                              end: Color.fromARGB(255, 185, 142, 255)),
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
                                                                            personaljiyikuController.shuaxintiwen(
                                                                                personaljiyikuController.wodezhi?[index]['id'],
                                                                                personaljiyikuController.wodezhi?[index]['tiwen'],
                                                                                personaljiyikuController.wodezhi![index]);
                                                                            return !isLiked;
                                                                          },
                                                                          isLiked:
                                                                              personaljiyikuController.chushitiwen(personaljiyikuController.wodezhi?[index]['id']),
                                                                          likeBuilder:
                                                                              (bool isLiked) {
                                                                            return Icon(
                                                                              isLiked ? Icons.messenger : Icons.messenger_outline,
                                                                              color: isLiked ? Colors.purpleAccent : const Color.fromRGBO(84, 87, 105, 1),
                                                                              size: 20,
                                                                            );
                                                                          },
                                                                          likeCount:
                                                                              personaljiyikuController.wodezhi?[index]['tiwen'],
                                                                          countBuilder: (int? count,
                                                                              bool isLiked,
                                                                              String text) {
                                                                            var color = isLiked
                                                                                ? Colors.purple
                                                                                : const Color.fromRGBO(84, 87, 105, 1);
                                                                            Widget
                                                                                result;
                                                                            if (count ==
                                                                                0) {
                                                                              result = Text(
                                                                                "love",
                                                                                style: TextStyle(color: color),
                                                                              );
                                                                            }
                                                                            result =
                                                                                Text(
                                                                              text,
                                                                              style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
                                      itemCount:
                                          personaljiyikucontroller.laquzhi ==
                                                  null
                                              ? 0
                                              : personaljiyikucontroller
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
                                                viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(
                                                    personaljiyikuController
                                                        .laquzhi![index]);
                                                switchPage(context,
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
                                                          backgroundImage: personaljiyikucontroller
                                                                              .laquzhi?[
                                                                          index]
                                                                      [
                                                                      'touxiang'] !=
                                                                  null
                                                              ? FileImage(File(
                                                                  personaljiyikucontroller
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
                                                                child: RichText(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: personaljiyikucontroller.laquzhi?[index]
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
                                                                            ' @${personaljiyikucontroller.laquzhi?[index]['username']}',
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
                                                                '${personaljiyikucontroller.laquzhi?[index]['xiabiao'].length}个记忆项',
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
                                                            '${personaljiyikucontroller.laquzhi?[index]['zhuti']}',
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
                                                                personaljiyikucontroller
                                                                            .laquzhi?[
                                                                        index]
                                                                    ['timu'],
                                                                personaljiyikucontroller
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
                                                                personaljiyikucontroller
                                                                            .laquzhi?[
                                                                        index]
                                                                    ['huida'],
                                                                personaljiyikucontroller
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
                                                                        personaljiyikuController.shuaxinlaqu(
                                                                            personaljiyikucontroller.laquzhi?[index]['id'],
                                                                            personaljiyikucontroller.laquzhi?[index]['laqu'],
                                                                            personaljiyikuController.laquzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushilaqu(
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                        personaljiyikuController.shuaxinshoucang(
                                                                            personaljiyikucontroller.laquzhi?[index]['id'],
                                                                            personaljiyikucontroller.laquzhi?[index]['shoucang'],
                                                                            personaljiyikuController.laquzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushishoucang(
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                        personaljiyikuController.shuaxinxihuan(
                                                                            personaljiyikucontroller.laquzhi?[index]['id'],
                                                                            personaljiyikucontroller.laquzhi?[index]['xihuan'],
                                                                            personaljiyikuController.laquzhi![index]);

                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushixihuan(
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                        personaljiyikuController.shuaxintiwen(
                                                                            personaljiyikucontroller.laquzhi?[index]['id'],
                                                                            personaljiyikucontroller.laquzhi?[index]['tiwen'],
                                                                            personaljiyikuController.laquzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushitiwen(
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                                          personaljiyikucontroller.laquzhi?[index]
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
                                                          )
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
                                      itemCount:
                                          personaljiyikucontroller.xihuanzhi ==
                                                  null
                                              ? 0
                                              : personaljiyikucontroller
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
                                                viewPostDataManagementForMemoryBanks.initTheMemoryDataForThePost(
                                                    personaljiyikuController
                                                        .xihuanzhi![index]);
                                                switchPage(context,
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
                                                          backgroundImage: personaljiyikucontroller
                                                                              .xihuanzhi?[
                                                                          index]
                                                                      [
                                                                      'touxiang'] !=
                                                                  null
                                                              ? FileImage(File(
                                                                  personaljiyikucontroller
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
                                                                child: RichText(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: personaljiyikucontroller.xihuanzhi?[index]
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
                                                                            ' @${personaljiyikucontroller.xihuanzhi?[index]['username']}',
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
                                                                '${personaljiyikucontroller.xihuanzhi?[index]['xiabiao'].length}个记忆项',
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
                                                            '${personaljiyikucontroller.xihuanzhi?[index]['zhuti']}',
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
                                                                personaljiyikucontroller
                                                                            .xihuanzhi?[
                                                                        index]
                                                                    ['timu'],
                                                                personaljiyikucontroller
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
                                                                personaljiyikucontroller
                                                                            .xihuanzhi?[
                                                                        index]
                                                                    ['huida'],
                                                                personaljiyikucontroller
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
                                                                        personaljiyikuController.shuaxinlaqu(
                                                                            personaljiyikucontroller.xihuanzhi?[index]['id'],
                                                                            personaljiyikucontroller.xihuanzhi?[index]['laqu'],
                                                                            personaljiyikuController.xihuanzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushilaqu(
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                        personaljiyikuController.shuaxinshoucang(
                                                                            personaljiyikucontroller.xihuanzhi?[index]['id'],
                                                                            personaljiyikucontroller.xihuanzhi?[index]['shoucang'],
                                                                            personaljiyikuController.xihuanzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushishoucang(
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                        personaljiyikuController.shuaxinxihuan(
                                                                            personaljiyikucontroller.xihuanzhi?[index]['id'],
                                                                            personaljiyikucontroller.xihuanzhi?[index]['xihuan'],
                                                                            personaljiyikuController.xihuanzhi![index]);

                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushixihuan(
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                        personaljiyikuController.shuaxintiwen(
                                                                            personaljiyikucontroller.xihuanzhi?[index]['id'],
                                                                            personaljiyikucontroller.xihuanzhi?[index]['tiwen'],
                                                                            personaljiyikuController.xihuanzhi![index]);
                                                                        return !isLiked;
                                                                      },
                                                                      isLiked: personaljiyikuController.chushitiwen(
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                                          personaljiyikucontroller.xihuanzhi?[index]
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
                                                          )
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
                      }),
                );
              });
        },
      ),
    );
  }
}
