import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/main/app_module/switch.dart';
import 'package:yunji/home/login/login_init.dart';

// 背景图管理
class BackgroundImageChangeManagement extends GetxController {
  static BackgroundImageChangeManagement get to => Get.find();
  File? backgroundImageValue;
  File? changedBackgroundImageValue;

  // 选择与拍摄图片赐予更改的背景图
  void selectAndShootTheImageToGiveTheChangedBackgroundImage(
      File selectedChangedBackgroundImage) {
    changedBackgroundImageValue = selectedChangedBackgroundImage;
    update();
  }

  // 初始化背景图
  void initBackgroundImage(String? backgroundDiagramInDatabase) {
    if (backgroundDiagramInDatabase != null) {
      changedBackgroundImageValue = File(backgroundDiagramInDatabase);
      backgroundImageValue = File(backgroundDiagramInDatabase);
      update();
    }
  }

  // 恢复未更改的背景图
  void restoreAnUnchangedBackgroundImage() {
    changedBackgroundImageValue = backgroundImageValue;
    update();
  }

  // 返回更改的背景图同步后端
  File? returnsTheChangedBackgroundImageSynchronizationBackend() {
    var backgroundImageOfTheSynchronizationBackend =
        backgroundImageValue == changedBackgroundImageValue
            ? null
            : changedBackgroundImageValue;
    backgroundImageValue = changedBackgroundImageValue;
    update();
    return backgroundImageOfTheSynchronizationBackend;
  }

  // 退出页面判断背景图是否已更改
  bool exitThePageToDetermineWhetherTheBackgroundImageHasChanged() {
    return backgroundImageValue != changedBackgroundImageValue ? true : false;
  }
}

class PersonalBei extends StatefulWidget {
  const PersonalBei({super.key});

  @override
  State<PersonalBei> createState() => _PersonalBeiState();
}

class _PersonalBeiState extends State<PersonalBei> {
  final backgroundImageChangeManagement =
      Get.put(BackgroundImageChangeManagement());

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
            child: GetBuilder<BackgroundImageChangeManagement>(
              init: backgroundImageChangeManagement,
              builder: (backgroundImageChangeManagement) {
                return backgroundImageChangeManagement.backgroundImageValue !=
                        null
                    ? PhotoView(
                        imageProvider: FileImage(backgroundImageChangeManagement
                            .backgroundImageValue!),
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
          ),
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
                switchPage(context, const EditPersonalPage());
              }
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
              side: const BorderSide(width: 0.5, color: Colors.white),
              padding:
                  const EdgeInsets.only(left: 13, right: 13, top: 3, bottom: 3),
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
