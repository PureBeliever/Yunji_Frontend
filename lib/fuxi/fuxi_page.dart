import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/main.dart';

class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = true,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems, List<int> xiabiao,
    Map<String, dynamic> timu, Map<String, dynamic> huida) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: timu['${xiabiao[index]}'] ?? '',
      expandedValue: huida['${xiabiao[index]}'] ?? '',
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
  void cizhi(Map<String, dynamic> cizhi) {
    zhi = cizhi;
    zhuti = cizhi['zhuti'];
    length = cizhi['xiabiao'].length;
    lengthxiabiao = cizhi['xiabiao'];
    timu = jsonDecode(cizhi['timu']);
    huida = jsonDecode(cizhi['huida']);
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
  final List<Item> _data = generateItems(fuxiController.length,
      fuxiController.lengthxiabiao, fuxiController.timu, fuxiController.huida);
  final _controller = TextEditingController(text: fuxiController.zhuti);
  String zhuti = ' ';
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
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
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
                onPressed: () {},
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
                  padding: const EdgeInsets.only(left: 5, right: 15, top: 50,bottom: 0),
                  child: TextField(
                    onChanged: (value) {
                      zhuti = value;
                    },
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
                            controller:
                                TextEditingController(text: item.headerValue),
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
                        contentPadding: EdgeInsets.all(5),
                        title: TextField(
                          controller:
                              TextEditingController(text: item.expandedValue),
                          maxLength: 1500,
                          maxLines: 30,
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
    );
  }
}
