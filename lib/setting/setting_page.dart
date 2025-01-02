import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/setting/setting_user/setting_user.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '设置',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListTile(
        onTap: () => switchPage(context, const SettingUser()),
        leading: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SvgPicture.asset(
            'assets/setting/personal_setting.svg',
            width: 30,
            height: 30,
          ),
        ),
        title: const Text(
          '你的账号',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        subtitle: const Text(
          '查看和修改你的账号相关信息，了解添加账号或切换账号的选项',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(84, 87, 105, 1),
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
