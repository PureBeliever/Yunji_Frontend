import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/switch/switch_page.dart';
import 'package:yunji/setting/setting_account_user_name.dart';

class Settingzhanghao extends StatefulWidget {
  const Settingzhanghao({super.key});

  @override
  State<Settingzhanghao> createState() => _Settingzhanghao();
}

class _Settingzhanghao extends State<Settingzhanghao> {
  final settingzhanghaoxiugaicontroller =
      Get.put(UserNameChangeManagement());
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
          switchPage(context, const Settingzhanghaoxiugai());
        },
        child: ListTile(
            title: const Text(
              '用户名',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            subtitle: GetBuilder<UserNameChangeManagement>(
                init: UserNameChangeManagement.to,
                builder: (UserNameChangeManagement) {
                  return Text(
                    '@${UserNameChangeManagement.userNameValue}' ,
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
