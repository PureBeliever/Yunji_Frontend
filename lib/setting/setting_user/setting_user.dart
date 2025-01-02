import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/setting/setting_user/setting_user_name/setting_user_name.dart';
import 'package:yunji/main/app/app_global_variable.dart';

class SettingUser extends StatefulWidget {
  const SettingUser({super.key});

  @override
  State<SettingUser> createState() => _SettingUser();
}

class UserNameChangeManagement extends GetxController {
  static UserNameChangeManagement get to => Get.find();
  String? userNameValue;

  Future<void> userNameChanged(String? userNameValueChanged) async {
    userNameValue = userNameValueChanged;
  }
}

class _SettingUser extends State<SettingUser> {
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
          switchPage(context, const SettingUserName());
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
                init: userNameChangeManagement,
                builder: (userNameChangeManagement) {
                  return Text(
                    '@${userNameChangeManagement.userNameValue}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(84, 87, 105, 1),
                      fontSize: 15,
                    ),
                  );
                })),
      ),
    );
  }
}
