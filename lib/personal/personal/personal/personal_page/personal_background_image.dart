import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/home/login/login_init.dart';

// 背景图管理
class BackgroundImageChangeManagement extends GetxController {
  static BackgroundImageChangeManagement get to => Get.find();
  File? backgroundImageValue = null;
  File? changedBackgroundImageValue = null;

  // 选择与拍摄图片赐予更改的背景图
  void selectAndShootTheImage(File selectedImage) {
    changedBackgroundImageValue = selectedImage;
    update();
  }

  // 初始化背景图
  void initBackgroundImage(String? backgroundPath) {
    if (backgroundPath != null) {
      final file = File(backgroundPath);
      changedBackgroundImageValue = file;
      backgroundImageValue = file;
      update();
    } else {
      backgroundImageValue = null;
      changedBackgroundImageValue = null;
      update();
    }
  }

  // 恢复未更改的背景图
  void restoreBackgroundImage() {
    changedBackgroundImageValue = backgroundImageValue;
    update();
  }

  // 返回更改的背景图并同步到后端
  File? syncChangedBackgroundImage() {
    backgroundImageValue = changedBackgroundImageValue;
    update();
    return backgroundImageValue;
  }
}

class PersonalBackgroundImage extends StatefulWidget {
  const PersonalBackgroundImage({super.key});

  @override
  State<PersonalBackgroundImage> createState() =>
      _PersonalBackgroundImageState();
}

class _PersonalBackgroundImageState extends State<PersonalBackgroundImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, size: 26, color: Colors.white),
          ),
        ],
      ),
      body: GetBuilder<BackgroundImageChangeManagement>(
        init: backgroundImageChangeManagement,
        builder: (controller) {
          return Center(
              child: Column(
            children: [
              Expanded(
                child: PhotoView(
                  imageProvider: controller.backgroundImageValue != null
                      ? FileImage(controller.backgroundImageValue!)
                      : const AssetImage('assets/personal/gray_back_head.png'),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
            ],
          ));
        },
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Center(
          child: OutlinedButton(
            onPressed: () {
              if (!loginStatus) {
               smsLogin(context);
                showWarnToast(context, "未登录", "未登录");
              } else {
                Navigator.pop(context);
                switchPage(context, const EditPersonalPage());
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0)),
              side: const BorderSide(width: 0.5, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
              minimumSize: Size.zero,
            ),
            child: const Text('编辑',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}
