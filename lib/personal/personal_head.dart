import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/switch/switch_page.dart';
import 'package:yunji/home/login/login_init.dart';

class PersonalHead extends StatefulWidget {
  const PersonalHead({super.key});

  @override
  State<PersonalHead> createState() => _PersonalHeadState();
}

class HeadPortraitChangeManagement extends GetxController {
  static HeadPortraitChangeManagement get to => Get.find();
  File? headPortraitValue;
  File? changedHeadPortraitValue;

  // 选择与拍摄图片赐予更改的头像
  void selectAndShootTheImageToGiveTheChangedHeadPortraitImage(File selectedChangedHeadPortrait) {
    changedHeadPortraitValue = selectedChangedHeadPortrait;
    update();
  }

  // 初始化头像
  void initHeadPortrait(String? headPortraitInDatabase) {
    if (headPortraitInDatabase != null) {
      headPortraitValue = File(headPortraitInDatabase);
      changedHeadPortraitValue = File(headPortraitInDatabase);
      update();
    }
  }

  // 恢复未更改的头像
  void restoreAnUnchangedHeadPortraitImage() {
    changedHeadPortraitValue = headPortraitValue;
    update();
  }

  // 返回更改的头像同步后端
  File? returnsTheChangedHeadPortraitImageSynchronizationBackend() {
    var headPortraitOfTheSynchronizationBackend = headPortraitValue == changedHeadPortraitValue ? null : changedHeadPortraitValue;
    headPortraitValue = changedHeadPortraitValue;
    update();
    return headPortraitOfTheSynchronizationBackend;
  }

  // 退出页面判断头像是否已更改
  int exitThePageToDetermineWhetherTheHeadPortraitHasChanged() {
    return headPortraitValue != changedHeadPortraitValue ? 1 : 0;
  }

}

class _PersonalHeadState extends State<PersonalHead> {
  final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            size: 25,
            color: Colors.white,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.more_vert,
              size: 25,
              color: Colors.white,
            ),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GetBuilder<HeadPortraitChangeManagement>(
              init: headPortraitChangeManagement,
              builder: (headPortraitChangeManagement) {
                return headPortraitChangeManagement.headPortraitValue != null
                    ? PhotoView(
                        imageProvider: FileImage(headPortraitChangeManagement.headPortraitValue!),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      )
                    : PhotoView(
                        imageProvider: const AssetImage('assets/chuhui.png'),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                      );
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 100,
        child: Center(
          child: OutlinedButton(
            onPressed: () {
              if (loginStatus == false) {
                soginDependencySettings(context);
                toast.toastification.show(
                    context: contexts,
                    type: toast.ToastificationType.success,
                    style: toast.ToastificationStyle.flatColored,
                    title: const Text("未登录",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 17)),
                    description: const Text(
                      "未登录",
                      style: TextStyle(
                          color: Color.fromARGB(255, 119, 118, 118),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                    alignment: Alignment.topRight,
                    autoCloseDuration: const Duration(seconds: 4),
                    primaryColor: const Color(0xff047aff),
                    backgroundColor: const Color(0xffedf7ff),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: toast.lowModeShadow,
                    dragToClose: true);
              } else {
                Navigator.pop(context);
                switchPage(context, const BianpersonalPage());
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              side: const BorderSide(width: 0.5, color: Colors.white),
              padding: const EdgeInsets.only(left: 13, right: 13, top: 3, bottom: 3),
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
