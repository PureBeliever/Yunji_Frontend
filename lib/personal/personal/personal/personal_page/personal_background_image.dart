import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/main/app/app_global_variable.dart';
import 'package:yunji/main/app_module/show_toast.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/home/login/login_init.dart';

// 背景图管理
class BackgroundImageChangeManagement extends GetxController {
  static BackgroundImageChangeManagement get to => Get.find();
  File? backgroundImageValue;
  File? changedBackgroundImageValue;

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
  State<PersonalBackgroundImage> createState() => _PersonalBackgroundImageState();
}

class _PersonalBackgroundImageState extends State<PersonalBackgroundImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.more_vert, size: 25, color: Colors.white),
          ),
        ],
      ),
      body: Center(
        child: Expanded(
          child: GetBuilder<BackgroundImageChangeManagement>(
            init: backgroundImageChangeManagement,
            builder: (controller) {
              final imageProvider = controller.backgroundImageValue != null
                  ? FileImage(controller.backgroundImageValue!)
                  : FileImage(File('assets/personal/gray_back_head.png'));
              return PhotoView(
                imageProvider: imageProvider,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Center(
          child: OutlinedButton(
            onPressed: () {
              if (!loginStatus) {
                soginDependencySettings(context);
                 showToast(context, "未登录", "未登录", toast.ToastificationType.success, const Color(0xff047aff), const Color(0xFFEDF7FF));
              } else {
                Navigator.pop(context);
                switchPage(context, const EditPersonalPage());
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              side: const BorderSide(width: 0.5, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
              minimumSize: Size.zero,
            ),
            child: const Text('编辑', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
          ),
        ),
      ),
    );
  }
}
