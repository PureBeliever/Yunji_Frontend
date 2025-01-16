import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/home/home_module/size_expansion_tile_state.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/setting/setting_page.dart';
import 'package:yunji/global.dart';
import 'package:yunji/main/main_module/switch.dart';

// 主页面抽屉组件
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final _editPersonalDataValueManagement =
      Get.put(EditPersonalDataValueManagement());

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
              _buildHeader(context), // 构建抽屉头部
              _buildMenuList(context), // 构建菜单列表
            ],
          ),
        ),
      ),
    );
  }

  // 构建抽屉头部
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 26, left: 28, top: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileRow(context), // 构建个人资料行
          const SizedBox(height: 3),
          _buildName(), // 构建姓名
          _buildUserName(), // 构建用户名
          const SizedBox(height: 10),
          _buildFollowInfo(), // 构建关注信息
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

  // 构建个人资料行
  Widget _buildProfileRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProfileIcon(context), // 构建头像
            _buildSettingsIcon(), // 构建设置图标
          ],
        ),
      ),
    );
  }

  // 构建头像
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

  // 构建设置图标
  Widget _buildSettingsIcon() {
    return IconButton(
      splashColor: const Color.fromRGBO(145, 145, 145, 1),
      icon: SvgPicture.asset(
        'assets/home/sunny.svg',
        width: 30,
        height: 30,
      ),
      onPressed: () {
        getUserName();
      },
    );
  }

  // 构建姓名
  Widget _buildName() {
    return GetBuilder<EditPersonalDataValueManagement>(
      init: _editPersonalDataValueManagement,
      builder: (_editPersonalDataValueManagement) {
        return Text(
          '${_editPersonalDataValueManagement.nameValue}',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 21,
          ),
        );
      },
    );
  }

  // 构建用户名
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

  // 构建关注信息
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

  // 构建菜单列表
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
                const PersonalPage()), // 构建个人资料菜单项
            _buildMenuItem(context, '会员', 'assets/home/member.svg', null), // 构建会员菜单项
            _buildMenuItem(context, '收藏', 'assets/home/collect.svg', null), // 构建收藏菜单项
            _buildMenuItem(
              context,
              '反馈',
              'assets/home/feedback.svg',
              null,
            ), // 构建反馈菜单项
            _buildMenuItem(
                context, '设置', 'assets/home/setting.svg', const SettingPage()), // 构建设置菜单项
            const Padding(
              padding: EdgeInsets.only(left: 28, right: 26),
              child: Divider(
                color: Color.fromRGBO(201, 201, 201, 1),
                thickness: 0.3,
                height: 50,
              ),
            ),
            const MemoryAnalysis(), // 构建记忆分析组件
          ],
        ),
      ),
    );
  }

  // 构建菜单项
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

// 记忆分析组件
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
