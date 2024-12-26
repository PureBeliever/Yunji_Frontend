import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class OtherPersonalBackgroundImage extends StatelessWidget {
  const OtherPersonalBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    final otherPeopleBackgroundImageChangeManagement = Get.put(OtherPeopleBackgroundImageChangeManagement());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 25, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GetBuilder<OtherPeopleBackgroundImageChangeManagement>(
        init: otherPeopleBackgroundImageChangeManagement,
        builder: (controller) {
          return Center(
            child: Expanded(
              child: PhotoView(
                imageProvider: controller.backgroundImageValue != null
                    ? FileImage(controller.backgroundImageValue!)
                    : const AssetImage('assets/personal/gray_back_head.png'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtherPeopleBackgroundImageChangeManagement extends GetxController {
  static OtherPeopleBackgroundImageChangeManagement get to => Get.find();
  File? backgroundImageValue;

  void initBackgroundImage(String? backgroundImage) {
    backgroundImageValue = backgroundImage != null ? File(backgroundImage) : null;
  }
}
