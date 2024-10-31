import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/cut/cut.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';

class Settingzhanghao extends StatefulWidget {
  const Settingzhanghao({super.key});

  @override
  State<Settingzhanghao> createState() => _Settingzhanghao();
}

class _Settingzhanghao extends State<Settingzhanghao> {
  final settingzhanghaoxiugaicontroller =
      Get.put(Settingzhanghaoxiugaicontroller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          '账号信息',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: InkWell(
        onTap: () {
          handleClick(context, const Settingzhanghaoxiugai());
        },
        child: ListTile(
            title: const Text(
              '用户名',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            subtitle: GetBuilder<Settingzhanghaoxiugaicontroller>(
                init: settingzhanghaoxiugaicontroller,
                builder: (settingzhanghaoxiugai) {
                  return Text(
                    '@${settingzhanghaoxiugai.username}' ,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(84, 87, 105, 1),
                      fontSize: 14,
                    ),
                  );
                })),
      ),
    );
  }
}
