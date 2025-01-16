import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/global.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/main/main_module/switch.dart';
import 'package:yunji/home/login/login_init.dart';

class PersonalHeadPortrait extends StatefulWidget {
  const PersonalHeadPortrait({super.key});

  @override
  State<PersonalHeadPortrait> createState() => _PersonalHeadPortrait();
}

class HeadPortraitChangeManagement extends GetxController {
  static HeadPortraitChangeManagement get to => Get.find();
  File? headPortraitValue;
  File? changedHeadPortraitValue;

  // 选择与拍摄图片更改头像
  void selectAndShootImage(File selectedImage) {
    changedHeadPortraitValue = selectedImage;
    update();
  }

  // 初始化头像
  void initHeadPortrait(String? databasePath) {
    if (databasePath != null) {
      headPortraitValue = File(databasePath);
      changedHeadPortraitValue = headPortraitValue;
      update();
    }
  }

  // 恢复头像为未更改状态
  void restoreHeadPortrait() {
    changedHeadPortraitValue = headPortraitValue;
    update();
  }

  // 同步更改的头像到后端
  File? syncChangedHeadPortrait() {
    headPortraitValue = changedHeadPortraitValue;
    update();
    return headPortraitValue;
  }
}

class _PersonalHeadPortrait extends State<PersonalHeadPortrait> {
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
          child: GetBuilder<HeadPortraitChangeManagement>(
            init: headPortraitChangeManagement,
            builder: (controller) {
              final imageProvider = controller.headPortraitValue != null
                  ? FileImage(controller.headPortraitValue!)
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
                showToast(
                    context,
                    "未登录",
                    "未登录",
                    toast.ToastificationType.success,
                    const Color(0xff047aff),
                    const Color(0xFFEDF7FF));
              } else {
                Navigator.pop(context);
                switchPage(context, const EditPersonalPage());
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              side: const BorderSide(width: 0.5, color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 3),
              minimumSize: Size.zero,
            ),
            child: const Text(
              '编辑',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
