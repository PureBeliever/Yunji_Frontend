import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class OtherPersonalBackgroundImage extends StatefulWidget {
  const OtherPersonalBackgroundImage({super.key});

  @override
  State<OtherPersonalBackgroundImage> createState() => _OtherPersonalBackgroundImageState();
}

class OtherPeopleBackgroundImageChangeManagement  extends GetxController {
  static OtherPeopleBackgroundImageChangeManagement get to => Get.find();
  File? backgroundImageValue;

  void initBackgroundImage(String ?backgroundImage) {
    backgroundImageValue = backgroundImage!=null?File(backgroundImage):null;
  }
}

class _OtherPersonalBackgroundImageState extends State<OtherPersonalBackgroundImage> {

  final otherPeopleBackgroundImageChangeManagement = Get.put(OtherPeopleBackgroundImageChangeManagement());
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
            child: GetBuilder<OtherPeopleBackgroundImageChangeManagement>(
              init: otherPeopleBackgroundImageChangeManagement,
              builder: (controller) {
                return controller.backgroundImageValue != null
                    ? PhotoView(
                          imageProvider: FileImage(controller.backgroundImageValue!),
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
