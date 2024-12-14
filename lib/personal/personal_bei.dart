import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/main/home_page.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/cut/cut.dart';
import 'package:yunji/main/login/login_settings.dart';
class PersonalBei extends StatefulWidget {
  const PersonalBei({super.key});

  @override
  State<PersonalBei> createState() => _PersonalBeiState();
}

class Beicontroller extends GetxController {
  static Beicontroller get to => Get.find();
  File? beiimage;
  File? bianbeiimage;

  void chushi(String? uio) {
    if (uio != null) {
      bianbeiimage = File(uio);
      beiimage = bianbeiimage;
      update();
    }
  }

  void hanbianbeiimage(File bei) {
    bianbeiimage = bei;
    update();
  }

  void hanyuan() {
    bianbeiimage = beiimage;
    update();
  }

  File? baocun() {
    var ty = beiimage == bianbeiimage ? null : bianbeiimage;
    beiimage = bianbeiimage;
    update();
    return ty;
  }

  int tuichu() {
    return beiimage != bianbeiimage ? 1 : 0;
  }
}

class _PersonalBeiState extends State<PersonalBei> {
  final beicontroller = Get.put(Beicontroller());

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
            child: GetBuilder<Beicontroller>(
              init: beicontroller,
              builder: (controller) {
                return controller.beiimage != null
                    ? PhotoView(
                        imageProvider: FileImage(controller.beiimage!),
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
              if (denglu == false) {
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
                handleClick(context, const BianpersonalPage());
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
