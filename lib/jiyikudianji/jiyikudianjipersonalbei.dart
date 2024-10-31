import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class JiyikuPersonalBei extends StatefulWidget {
  const JiyikuPersonalBei({super.key});

  @override
  State<JiyikuPersonalBei> createState() => _JiyikuPersonalBeiState();
}

class JiyikuBeicontroller extends GetxController {
  static JiyikuBeicontroller get to => Get.find();
  File? beiimage;

  void cizhi(String ?zhi) {
    beiimage = zhi!=null?File(zhi):null;
  }
}

class _JiyikuPersonalBeiState extends State<JiyikuPersonalBei> {
  final jiyikuBeicontroller = Get.put(JiyikuBeicontroller());

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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GetBuilder<JiyikuBeicontroller>(
              init: jiyikuBeicontroller,
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
    );
  }
}
