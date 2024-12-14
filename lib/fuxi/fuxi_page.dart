import 'dart:convert';
import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/api/personal_api.dart';
import 'package:yunji/main/home_page.dart';
import 'package:yunji/chuangjianjiyiku/jiyiku.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/main/notification_settings.dart';

class Item {
  Item({
    required this.huida,
    required this.tiwen,
    this.isExpanded = true,
  });

  String huida;
  String tiwen;

  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> xiabiao,
    Map<String, dynamic> timu, Map<String, dynamic> huida) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      tiwen: timu['${xiabiao[index]}'] ?? '',
      huida: huida['${xiabiao[index]}'] ?? '',
    );
  });
}

class FuxiController extends GetxController {
  static FuxiController get to => Get.find();
  Map<String, dynamic> zhi = {};
  int length = 0;
  List<int> lengthxiabiao = List.empty();
  Map<String, dynamic> timu = {};
  Map<String, dynamic> huida = {};
  String zhuti = '';
  List<dynamic> code = [];
  Map<String, dynamic> cishu = {};
  bool duanxin = false;
  bool naozhong = false;
  bool zhuangtai = false;
  String fanganming = ' ';
  int id = -1;

  void cizhi(Map<String, dynamic> cizhi) {
    id = cizhi['id'];
    zhi = cizhi;
    zhuti = cizhi['zhuti'];
    length = cizhi['xiabiao'].length;
    lengthxiabiao = cizhi['xiabiao'];
    timu = jsonDecode(cizhi['timu']);
    huida = jsonDecode(cizhi['huida']);
    code = jsonDecode(cizhi['code']);
    cishu = jsonDecode(cizhi['cishu']);
    duanxin = cizhi['duanxin'] == 1 ? true : false;
    naozhong = cizhi['naozhong'] == 1 ? true : false;
    zhuangtai = cizhi['zhuangtai'] == 1 ? true : false;
    fanganming = cizhi['fanganming'];
  }

  void zhankai() {
    update();
  }
}

class FuxiPage extends StatefulWidget {
  const FuxiPage({super.key});

  @override
  State<FuxiPage> createState() => _FuxiPage();
}

class _FuxiPage extends State<FuxiPage> {
  final NotificationHelper _notificationHelper = NotificationHelper();


  final FocusNode _focusNode = FocusNode();
  final List<Item> _data = generateItems(fuxiController.length,
      fuxiController.lengthxiabiao, fuxiController.timu, fuxiController.huida);
  final _controller = TextEditingController(text: fuxiController.zhuti);
  String zhuti = fuxiController.zhuti;
  bool message = fuxiController.duanxin;
  bool alarm_information = fuxiController.naozhong;
  final jiyikucontroller = Get.put(Jiyikucontroller());

  final settingzhanghaoxiugaicontroller =
      Get.put(Settingzhanghaoxiugaicontroller());
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(Icons.close, size: 30)),
        actions: [
          SizedBox(
            height: 30,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 0, bottom: 0),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "清空讲解",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: SizedBox(
                        height: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 25, top: 20),
                              child: Text(
                                '复习',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                  left: 25, top: 10, bottom: 20),
                              child: Text('是否清空所有讲解?',
                                  style: TextStyle(fontSize: 16)),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '取消',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _data.forEach((item) {
                                          item.huida = ' ';
                                        });
                                      });

                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '确定',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 0, bottom: 0),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "完成",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white),
                ),
                onPressed: () async {
                  if (zhuti.length == 0) {
                    toast.toastification.show(
                        context: context,
                        type: toast.ToastificationType.success,
                        style: toast.ToastificationStyle.flatColored,
                        title: const Text("请填写主题",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                fontSize: 17)),
                        description: const Text(
                          "主题为空",
                          style: TextStyle(
                              color: Color.fromARGB(255, 119, 118, 118),
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        alignment: Alignment.topCenter,
                        autoCloseDuration: const Duration(seconds: 4),
                        primaryColor: const Color(0xff047aff),
                        backgroundColor: const Color(0xffedf7ff),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: toast.lowModeShadow,
                        dragToClose: true);
                    FocusScope.of(context).requestFocus(_focusNode);
                  } else {
                    
                    int zhi = 0;
                    Map<int, String> stringTimu = {};
                    Map<int, String> stringHuida = {};
                    DateTime dingshi = DateTime.now();
                    List<int> code = List.from(fuxiController.code);
                    code.removeAt(0);
                    Map<String, String> cishu = fuxiController.cishu
                        .map((key, value) => MapEntry(key.toString(), value));

                    List<int> sortedList = [];

                    _data.forEach((uio) {
                      sortedList.add(zhi);
                      stringTimu[zhi] = uio.tiwen;
                      stringHuida[zhi] = uio.huida;
                      zhi++;
                    });
                    Map<String, String> stringtimu = stringTimu
                        .map((key, value) => MapEntry(key.toString(), value));
                    Map<String, String> stringhuida = stringHuida
                        .map((key, value) => MapEntry(key.toString(), value));
            
                    bool zhuangtai = fuxiController.zhuangtai;

                    if (code.isNotEmpty) {
                      // dingshi = dingshi.add(Duration(hours: code[0]));
                      dingshi = dingshi.add(Duration(minutes: code[0]));
                      if (alarm_information == true) {
                        final alarmSettings = AlarmSettings(
                          id: 42,
                          dateTime: dingshi,
                          assetAudioPath: 'assets/alarm.mp3',
                          loopAudio: true,
                          vibrate: true,
                          volume: 0.6,
                          fadeDuration: 3.0,
                          warningNotificationOnKill: Platform.isIOS,
                          androidFullScreenIntent: true,
                          notificationSettings: NotificationSettings(
                            title: '开始复习 !',
                            body: '记忆库${zhuti}到达预定的复习时间',
                            stopButton: '停止闹钟',
                            icon: 'notification_icon',
                          ),
                        );
                        await Alarm.set(alarmSettings: alarmSettings);
                      }
                      if (message == true) {
                        _notificationHelper.zonedScheduleNotification(
                            id: 888,
                            title: '开始复习 !',
                            body: '记忆库${zhuti}到达预定的复习时间',
                            scheduledDateTime: dingshi);
                      }
                    } else {
                      zhuangtai = true;
                      String fanganming = fuxiController.fanganming;
                      String? stringci;
                      for (final entry in cishu.entries) {
                        if (entry.value == fanganming) {
                          stringci = entry.key;
                          break;
                        }
                      }
                      if (stringci != null) {
                        int ci = int.parse(stringci);
                        int key = ci + 1;
                        String value = cishu[stringci] ?? ' s';
                        Map<String, String> newEntries = {'${key}': value};
                        cishu.remove(stringci);
                        cishu.addEntries(newEntries.entries);
                      }
                    }

                    xiugaijiyiku(
                        stringtimu,
                        stringhuida,
                        fuxiController.id,
                        zhuti,
                        settingzhanghaoxiugaicontroller.username,
                        code,
                        dingshi,
                        sortedList,
                        message,
                        alarm_information,
                        zhuangtai,
                        cishu,
                        fuxiController.fanganming);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: GetBuilder<FuxiController>(
          init: fuxiController,
          builder: (jiyikudianjicontroller) {
            return ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          child: Transform.scale(
                            scale: 0.7,
                            child: CupertinoSwitch(
                              value: message,
                              onChanged: (value) {
                                setState(() {
                                  message = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text('信息通知',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontSize: 17)),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 5),
                        SizedBox(
                          height: 30,
                          child: Transform.scale(
                            scale: 0.7,
                            child: CupertinoSwitch(
                              value: alarm_information,
                              onChanged: (value) {
                                setState(() {
                                  alarm_information = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Text('闹钟信息通知',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(84, 87, 105, 1),
                                fontSize: 17)),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
                  child: Text(
                    '复读回顾 >> 清空讲解 >> 更加清晰简洁讲解 >> 完成复习',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 15, top: 50, bottom: 0),
                  child: TextField(
                    onChanged: (value) {
                      zhuti = value;
                    },
                    focusNode: _focusNode,
                    controller: _controller,
                    maxLength: 50,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 17),
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00FF0000)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0x00000000)),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                ExpansionPanelList(
                  materialGapSize: 15,
                  elevation: 0,
                  dividerColor: Colors.white,
                  expansionCallback: (int index, bool isExpanded) {
                    _data[index].isExpanded = isExpanded;
                    jiyikudianjicontroller.zhankai();
                  },
                  children: _data.map<ExpansionPanel>((Item item) {
                    return ExpansionPanel(
                      backgroundColor: Colors.white,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: TextField(
                            onChanged: (value) {
                              item.tiwen = value;
                            },
                            controller: TextEditingController(text: item.tiwen),
                            maxLength: 150,
                            maxLines: 10,
                            minLines: 1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontSize: 17),
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x00FF0000)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0x00000000)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              contentPadding: EdgeInsets.all(0),
                            ),
                          ),
                        );
                      },
                      body: ListTile(
                        contentPadding: EdgeInsets.only(left: 5, right: 10),
                        title: TextField(
                          onChanged: (value) {
                            item.huida = value;
                          },
                          controller: TextEditingController(text: item.huida),
                          maxLength: 1500,
                          maxLines: 30,
                          minLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 17),
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: SizedBox(
                                          height: 150,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 25, top: 20),
                                                child: Text(
                                                  '复习',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w900),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 25,
                                                    top: 10,
                                                    bottom: 20),
                                                child: Text('是否清空选择讲解?',
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 7),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        '取消',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          item.huida = '';
                                                        });

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                        '确定',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Icon(
                                  color: Color.fromRGBO(134, 134, 134, 1),
                                  Icons.remove,
                                  size: 26,
                                )),
                            border: InputBorder.none,
                            counterText: "",
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00FF0000)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0x00000000)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                      isExpanded: item.isExpanded,
                    );
                  }).toList(),
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        elevation: 5.0,
        highlightElevation: 20.0,
        backgroundColor: Colors.blue,
        child: const Text(
          '退出\n键盘',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
