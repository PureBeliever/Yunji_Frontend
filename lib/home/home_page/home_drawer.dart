import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:yunji/home/home_module/size_expansion_tile_state.dart';
import 'package:yunji/main/main_module/dialog.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/main/global.dart';

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
        color: AppColors.background,
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
          Divider(
            color: AppColors.Gray,
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
            _buildThemeIcon(), // 构建主题图标
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
            Navigator.popAndPushNamed(context, '/personal');
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
  Widget _buildThemeIcon() {
    return IconButton(
      splashColor: AppColors.Gray,
      icon: SvgPicture.asset(
        AppColors.isNight ? 'assets/home/moon.svg' : 'assets/home/sunny.svg',
        width: 30,
        height: 30,
        colorFilter: ColorFilter.mode(AppColors.Gray, BlendMode.srcIn),
      ),
      onPressed: () {
        dialogTwoButton(
          context: context,
          title: '切换主题',
          message: '是否切换为夜间模式(重启后生效)?',
          buttonLeft: '日间模式',
          buttonRight: '夜间模式',
          onConfirmLifeMode: () {
            saveLoginStatus(false);
            Navigator.pop(context);
          },
          onConfirmRightMode: () {
            saveLoginStatus(true);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // 构建姓名
  Widget _buildName() {
    return GetBuilder<EditPersonalDataValueManagement>(
      init: _editPersonalDataValueManagement,
      builder: (editPersonalDataValueManagement) {
        return Text(
          '${editPersonalDataValueManagement.nameValue}',
          style: AppTextStyle.littleTitleStyle,
        );
      },
    );
  }

  // 构建用户名
  Widget _buildUserName() {
    return Text(
      '@${userNameChangeManagement.userNameValue}',
      style: AppTextStyle.subsidiaryText,
    );
  }

  // 构建关注信息
  Widget _buildFollowInfo() {
    return Row(
      children: [
        Text('0 ', style: AppTextStyle.textStyle),
        Text(
          '正在关注  ',
          style: AppTextStyle.subsidiaryText,
        ),
        Text(
          '0 ',
          style: AppTextStyle.textStyle,
        ),
        Text(
          '关注者  ',
          style: AppTextStyle.subsidiaryText,
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
                '/personal'), // 构建个人资料菜单项
            _buildMenuItem(
              context,
              '会员',
              'assets/home/member.svg',
              '/member',
            ), // 构建会员菜单项
            _buildMenuItem(
              context,
              '收藏',
              'assets/home/collect.svg',
              '/collect',
            ), // 构建收藏菜单项
            _buildMenuItem(
              context,
              '反馈',
              'assets/home/feedback.svg',
              '/feedback',
            ), // 构建反馈菜单项
            _buildMenuItem(context, '设置', 'assets/home/setting.svg',
                '/settings'), // 构建设置菜单项
            Padding(
              padding: const EdgeInsets.only(left: 28, right: 26),
              child: Divider(
                color: AppColors.Gray,
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
      BuildContext context, String title, String assetPath, String route,
      ) {
    return InkWell(
      onTap: () {
        Navigator.popAndPushNamed(context, route);
      
      },
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, right: 5),
          child: SvgPicture.asset(
            assetPath,
            width: 30,
            height: 30,
            colorFilter: ColorFilter.mode(AppColors.Gray, BlendMode.srcIn),
          ),
        ),
        title: Text(
          title,
          style: AppTextStyle.titleStyle,
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
      child: sizeExpansionTile(
        collapsedIconColor: AppColors.text,
        iconColor: AppColors.iconColor,
        trailing: null,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            '记忆分析',
            style: AppTextStyle.littleTitleStyle,
          ),
        ),
        children: [
          ListTile(
              title: Text(
            '示例',
            style: AppTextStyle.textStyle,
          )),
          ListTile(
              title: Text(
            '示例',
            style: AppTextStyle.textStyle,
          )),
          ListTile(
              title: Text(
            '示例',
            style: AppTextStyle.textStyle,
          )),
          ListTile(
              title: Text(
            '示例',
            style: AppTextStyle.textStyle,
          )),
          ListTile(
              title: Text(
            '示例',
            style: AppTextStyle.textStyle,
          )),
        ],
      ),
    );
  }
}
