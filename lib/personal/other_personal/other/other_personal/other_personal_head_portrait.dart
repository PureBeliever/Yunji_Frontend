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
    headPortraitValue = headPortrait!=null? File(headPortrait):null;
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
            child: GetBuilder<OtherPeopleHeadPortraitChangeManagement>(
              init: otherPeopleHeadPortraitChangeManagement,
              builder: (otherPeopleHeadPortraitChangeManagement) {
                return otherPeopleHeadPortraitChangeManagement.headPortraitValue != null
                    ? PhotoView(
                          imageProvider: FileImage(otherPeopleHeadPortraitChangeManagement.headPortraitValue!),
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
