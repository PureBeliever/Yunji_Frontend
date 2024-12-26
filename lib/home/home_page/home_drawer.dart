import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yunji/home/home_module/size_expansion_tile_state.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';

import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/setting/setting.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/setting/setting_account_user_name.dart';
import 'package:yunji/main/app_module/switch.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 335,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Container(
        color: Colors.white,
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeader(context),
              _buildMenuList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 26, left: 28, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileRow(context),
          const SizedBox(height: 3),
          _buildName(),
          _buildUserName(),
          const SizedBox(height: 10),
          _buildFollowInfo(),
          const SizedBox(height: 25),
          const Divider(
            color: Color.fromRGBO(201, 201, 201, 1),
            thickness: 0.3,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProfileIcon(context),
            _buildSettingsIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return GetBuilder<HeadPortraitChangeManagement>(
      init: headPortraitChangeManagement,
      builder: (controller) {
        return IconButton(
          onPressed: () {
            Navigator.pop(context);
            switchPage(context, const PersonalPage());
          },
          padding: EdgeInsets.zero,
          icon: CircleAvatar(
            backgroundColor: Colors.grey,
            radius: 23,
            backgroundImage: controller.headPortraitValue != null
                ? FileImage(controller.headPortraitValue!)
                : const AssetImage('assets/personal/gray_back_head.png'),
          ),
        );
      },
    );
  }

  Widget _buildSettingsIcon() {
    return IconButton(
      splashColor: const Color.fromRGBO(145, 145, 145, 1),
      icon: SvgPicture.asset(
        'assets/home/sunny.svg',
        width: 30,
        height: 30,
      ),
      onPressed: () {},
    );
  }

  Widget _buildName() {
    return GetBuilder<EditPersonalDataValueManagement>(
      init: editPersonalDataValueManagement,
      builder: (editPersonalDataValueManagement) {
        return Text(
          '${editPersonalDataValueManagement.nameValue}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        );
      },
    );
  }

  Widget _buildUserName() {

        return Text(
          '@${userNameChangeManagement.userNameValue}',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(84, 87, 105, 1),
            fontSize: 16,
          ),
        );
   
  }

  Widget _buildFollowInfo() {
    return const Row(
      children: [
        Text(
          '0 ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        Text(
          '正在关注  ',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(84, 87, 105, 1),
            fontSize: 16,
          ),
        ),
        Text(
          '0 ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        Text(
          '关注者  ',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(84, 87, 105, 1),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _buildMenuItem(context, '个人资料', 'assets/home/personal_data.svg',
                const PersonalPage()),
            _buildMenuItem(context, '会员', 'assets/home/member.svg', null),
            _buildMenuItem(context, '收藏', 'assets/home/collect.svg', null),
            _buildMenuItem(
              context,
              '反馈',
              'assets/home/feedback.svg',
              null,
            ),
            _buildMenuItem(
                context, '设置', 'assets/home/setting.svg', const Setting()),
            const Padding(
              padding: EdgeInsets.only(left: 28, right: 26),
              child: Divider(
                color: Color.fromRGBO(201, 201, 201, 1),
                thickness: 0.3,
                height: 50,
              ),
            ),
            const MemoryAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String title, String assetPath, Widget? page,
      {VoidCallback? onTap}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (page != null) switchPage(context, page);
        if (onTap != null) onTap();
      },
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: SvgPicture.asset(
            assetPath,
            width: 30,
            height: 30,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 21,
          ),
        ),
      ),
    );
  }
}

class MemoryAnalysis extends StatefulWidget {
  const MemoryAnalysis({super.key});

  @override
  State<MemoryAnalysis> createState() => _MemoryAnalysisState();
}

class _MemoryAnalysisState extends State<MemoryAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: const sizeExpansionTile(
        collapsedIconColor: Colors.black,
        iconColor: Colors.blue,
        trailing: null,
        title: Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            '记忆分析',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        children: [
          ListTile(title: Text('示例')),
          ListTile(title: Text('示例')),
          ListTile(title: Text('示例')),
          ListTile(title: Text('示例')),
          ListTile(title: Text('示例')),
        ],
      ),
    );
  }
}
