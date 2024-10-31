import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class Jiyikudianjipersonalhead extends StatefulWidget {
  const Jiyikudianjipersonalhead({super.key});

  @override
  State<Jiyikudianjipersonalhead> createState() => _JiyikudianjipersonalPageState();
}

class JiyukupersonalHeadcontroller extends GetxController {
  static JiyukupersonalHeadcontroller get to => Get.find();
  File? headimage;

  void cizhi(String? zhi) {
    headimage =zhi!=null? File(zhi):null;
  }
}

class _JiyikudianjipersonalPageState extends State<Jiyikudianjipersonalhead> {
  final jiyukupersonalHeadcontroller = Get.put(JiyukupersonalHeadcontroller());

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
            child: GetBuilder<JiyukupersonalHeadcontroller>(
              init: jiyukupersonalHeadcontroller,
              builder: (controller) {
                return controller.headimage != null
                    ? PhotoView(
                        imageProvider: FileImage(controller.headimage!),
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
    );
  }
}
