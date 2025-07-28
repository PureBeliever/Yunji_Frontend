import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';


class OtherPersonalHeadPortrait extends StatefulWidget {
  const OtherPersonalHeadPortrait({super.key});

  @override
  State<OtherPersonalHeadPortrait> createState() => _OtherPersonalHeadPortraitState();
}

class OtherPeopleHeadPortraitChangeManagement extends GetxController {
  static OtherPeopleHeadPortraitChangeManagement get to => Get.find();
  File? headPortraitValue;

  void initHeadPortrait(String? headPortrait) {
    headPortraitValue = headPortrait != null ? File(headPortrait) : null;
  }
}

class _OtherPersonalHeadPortraitState extends State<OtherPersonalHeadPortrait> {
  final otherPeopleHeadPortraitChangeManagement = Get.put(OtherPeopleHeadPortraitChangeManagement());

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
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GetBuilder<OtherPeopleHeadPortraitChangeManagement>(
                init: otherPeopleHeadPortraitChangeManagement,
                builder: (controller) {
                  return PhotoView(
                    imageProvider: controller.headPortraitValue != null
                        ? FileImage(controller.headPortraitValue!)
                        : const AssetImage('assets/personal/gray_back_head.png'),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
