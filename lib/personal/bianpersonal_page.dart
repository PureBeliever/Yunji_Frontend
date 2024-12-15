import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yunji/modified_component/mydefaultcupertion.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/personal/personal_bei.dart';
import 'package:yunji/personal/personal_head.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:toastification/toastification.dart' as toast;

class EditPersonalDataValueManagement extends GetxController {
  static EditPersonalDataValueManagement get to => Get.find();

  // 姓名
  String nameValue = '';
  // 简介
  String profileValue = ' ';
  // 出生日期
  String dateOfBirthValue = ' ';
  // 居住地址
  String residentialAddressValue = ' ';
  // 加入日期
  String applicationDateValue = ' ';

  // 加入日期更改
  void applicationDateChange(String applicationDateValueChange) {
    applicationDateValue = applicationDateValueChange;
    update();
  }

  // 个人信息更改
  void changePersonalInformation(String nameValueChange, String profileValueChange, String residentialAddressValueChange, String dateOfBirthValueChange) {
    nameValue = nameValueChange;
    profileValue = profileValueChange;
    residentialAddressValue = residentialAddressValueChange;
    dateOfBirthValue = dateOfBirthValueChange;
    update();
  }

  // 个人信息回滚
  int rollbackTheChangedValue(String nameValueChange, String profileValueChange, String residentialAddressValueChange, String dateOfBirthValueChange) {
    int nameChangeStatus = nameValue != nameValueChange ? 1 : 0;
    int profileChangeStatus = profileValue != profileValueChange ? 1 : 0;
    int residentialAddressChangeStatus = residentialAddressValue != residentialAddressValueChange ? 1 : 0;
    int dateOfBirthChangeStatus = dateOfBirthValue != dateOfBirthValueChange ? 1 : 0;
    return nameChangeStatus + profileChangeStatus + residentialAddressChangeStatus + dateOfBirthChangeStatus;
  }
}

class Baocuncontroller extends GetxController {
  static Baocuncontroller get to => Get.find();

  String name = ' ';

  void namess(String na) {
    name = na;
    update();
  }
}
//更新选择器结果显示
class SelectorResultsUpdateDisplay extends GetxController {
  static SelectorResultsUpdateDisplay get to => Get.find();
  String residentialAddressSelectorResultValue = ' ';
  String dateOfBirthSelectorResultValue = ' ';
// 日期选择器结果值更改
  void dateOfBirthSelectorResultValueChange(String dateOfBirthSelectorResultValueChange) {
    dateOfBirthSelectorResultValue = dateOfBirthSelectorResultValueChange;
    update();
  }
// 地址选择器结果值更改
  void residentialAddressSelectorResultValueChange(String residentialAddressSelectorResultValueChange) {
    residentialAddressSelectorResultValue = residentialAddressSelectorResultValueChange;
    update();
  }
}

class BianpersonalPage extends StatefulWidget {
  const BianpersonalPage({super.key});

  @override
  State<BianpersonalPage> createState() => _BiannpersonalPage();
}

class _BiannpersonalPage extends State<BianpersonalPage> {
  static String name = EditPersonalDataValueManagement.to.nameValue;
  static String brief = EditPersonalDataValueManagement.to.profileValue;
  static String formatteplace = EditPersonalDataValueManagement.to.residentialAddressValue;
  static String formattedDate = EditPersonalDataValueManagement.to.dateOfBirthValue;
final editPersonalDataValueManagement = Get.put(EditPersonalDataValueManagement());
  final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());
  final baocuncontroller = Get.put(Baocuncontroller());
  final backgroundImageChangeManagement = Get.put(BackgroundImageChangeManagement());
  final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());
  final ImagePicker _imagePicker = ImagePicker();
  final userNameChangeManagement = Get.put(UserNameChangeManagement());
  static String username = UserNameChangeManagement.to.userNameValue;

  selectImage() async {
    try {
      XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            uiSettings: [
              AndroidUiSettings(
                  cropFrameColor: Colors.transparent,
                  toolbarTitle: '',
                  showCropGrid: false,
                  toolbarColor: Colors.black,
                  hideBottomControls: true,
                  statusBarColor: Colors.black,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.square,
                  lockAspectRatio: true),
              IOSUiSettings(
                title: '',
              ),
            ]);
        headPortraitChangeManagement.selectAndShootTheImageToGiveTheChangedHeadPortraitImage(File(croppedFile!.path));
      }
   
    } catch (err) {}
  }

  selectCamera() async {
    try {
      XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: photo.path,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            uiSettings: [
              AndroidUiSettings(
                  cropFrameColor: Colors.transparent,
                  toolbarTitle: '',
                  showCropGrid: false,
                  toolbarColor: Colors.black,
                  hideBottomControls: true,
                  statusBarColor: Colors.black,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.square,
                  lockAspectRatio: true),
              IOSUiSettings(
                title: '',
              ),
            ]);
        headPortraitChangeManagement.selectAndShootTheImageToGiveTheChangedHeadPortraitImage(File(croppedFile!.path));
      }
      // ignore: empty_catches
    } catch (err) {}
  }

  beiselectImage() async {
    XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: image.path, aspectRatioPresets: [
        CropAspectRatioPreset.ratio5x3,
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '',
            showCropGrid: false,
            toolbarColor: Colors.black,
            hideBottomControls: true,
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: true),
        IOSUiSettings(
          title: '',
        ),
      ]);
      backgroundImageChangeManagement.selectAndShootTheImageToGiveTheChangedBackgroundImage(File(croppedFile!.path));
    }
  }

  beiselectCamera() async {
    XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (photo != null) {
      CroppedFile? croppedFile = await ImageCropper()
          .cropImage(sourcePath: photo.path, aspectRatioPresets: [
        CropAspectRatioPreset.ratio5x3,
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: '',
            showCropGrid: false,
            toolbarColor: Colors.black,
            hideBottomControls: true,
            statusBarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio5x3,
            lockAspectRatio: true),
        IOSUiSettings(
          title: '',
        ),
      ]);
      backgroundImageChangeManagement.selectAndShootTheImageToGiveTheChangedBackgroundImage(File(croppedFile!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (editPersonalDataValueManagement.rollbackTheChangedValue(
                    name, brief, formatteplace, formattedDate) >
                0 ||
            backgroundImageChangeManagement.exitThePageToDetermineWhetherTheBackgroundImageHasChanged() == 1 ||
            headPortraitChangeManagement.exitThePageToDetermineWhetherTheHeadPortraitHasChanged() == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // 返回一个构建好的弹窗
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SizedBox(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 25, top: 20),
                        child: Text(
                          '编辑个人资料',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 25, top: 10, bottom: 20),
                        child: Text('放弃更改?', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                '取消',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                selectorResultsUpdateDisplay
                                    .dateOfBirthSelectorResultValueChange(editPersonalDataValueManagement.dateOfBirthValue);
                                selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(editPersonalDataValueManagement.residentialAddressValue);
                                backgroundImageChangeManagement.restoreAnUnchangedBackgroundImage();
                                headPortraitChangeManagement.restoreAnUnchangedHeadPortraitImage();
                                name = editPersonalDataValueManagement.nameValue;
                                brief = editPersonalDataValueManagement.profileValue;
                                formatteplace = selectorResultsUpdateDisplay.residentialAddressSelectorResultValue;
                                formattedDate = selectorResultsUpdateDisplay.dateOfBirthSelectorResultValue;
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                '放弃',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          Navigator.of(context).pop();
        }
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                if (editPersonalDataValueManagement.rollbackTheChangedValue(
                            name, brief, formatteplace, formattedDate) >
                        0 ||
                      backgroundImageChangeManagement.exitThePageToDetermineWhetherTheBackgroundImageHasChanged() == 1 ||
                    headPortraitChangeManagement.exitThePageToDetermineWhetherTheHeadPortraitHasChanged() == 1) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // 返回一个构建好的弹窗
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: SizedBox(
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 25, top: 20),
                                child: Text(
                                  '编辑个人资料',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    left: 25, top: 10, bottom: 20),
                                child: Text('放弃更改?',
                                    style: TextStyle(fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        '取消',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        selectorResultsUpdateDisplay
                                            .dateOfBirthSelectorResultValueChange(editPersonalDataValueManagement.dateOfBirthValue);  
                                        selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(
                                            editPersonalDataValueManagement.residentialAddressValue);
                                        backgroundImageChangeManagement.restoreAnUnchangedBackgroundImage();
                                        headPortraitChangeManagement.restoreAnUnchangedHeadPortraitImage();
                                        name = editPersonalDataValueManagement.nameValue;
                                        brief = editPersonalDataValueManagement.profileValue;
                                        formatteplace =
                                            selectorResultsUpdateDisplay.residentialAddressSelectorResultValue;
                                        formattedDate =
                                            selectorResultsUpdateDisplay.dateOfBirthSelectorResultValue;
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        '放弃',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(
                Icons.arrow_back,
              ),
            ),
            title: const Text(
              '编辑个人资料',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GetBuilder<Baocuncontroller>(
                    init: baocuncontroller,
                    builder: (dcontroller) {
                      return dcontroller.name.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                if (editPersonalDataValueManagement.rollbackTheChangedValue(name, brief,
                                            formatteplace, formattedDate) >
                                        0 ||
                                    backgroundImageChangeManagement.exitThePageToDetermineWhetherTheBackgroundImageHasChanged() == 1 ||
                                    headPortraitChangeManagement.exitThePageToDetermineWhetherTheHeadPortraitHasChanged() == 1) {
                                  editPersonalDataValueManagement.rollbackTheChangedValue(name, brief,          
                                      formatteplace, formattedDate);

                                  Navigator.pop(context);

                                  PostHttp(
                                      username,
                                      name,
                                      brief,
                                      formatteplace,
                                      formattedDate,
                                      backgroundImageChangeManagement.returnsTheChangedBackgroundImageSynchronizationBackend(),
                                      headPortraitChangeManagement.returnsTheChangedHeadPortraitImageSynchronizationBackend());
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                '保存',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w900),
                              ),
                            )
                          : const Text(
                              '保存',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 119, 118, 118),
                              ),
                            );
                    }),
              )
            ],
          ),
          body: ListView(
            children: <Widget>[
              SizedBox(
                height: 320,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    var status = await Permission.camera.status;

                                    if (status.isGranted) {
                                      beiselectCamera();
                                      Navigator.pop(context);
                                    } else {
                                      var permissionStatus =
                                          await Permission.camera.request();
                                      if (permissionStatus.isGranted) {
                                        beiselectCamera();
                                        Navigator.pop(context);
                                      } else {
                                        toast.toastification.show(
                                            context: context,
                                            callbacks:
                                                toast.ToastificationCallbacks(
                                              onTap: (toastItem) =>
                                                  AppSettings.openAppSettings(
                                                      type: AppSettingsType
                                                          .settings),
                                            ),
                                            type: toast
                                                .ToastificationType.warning,
                                            style: toast.ToastificationStyle
                                                .flatColored,
                                            title: const Text("未授权相机权限",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 17)),
                                            description: const Text(
                                              "无法开启相机，点击提示开启权限",
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 119, 118, 118),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            alignment: Alignment.topLeft,
                                            autoCloseDuration:
                                                const Duration(seconds: 4),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            boxShadow: toast.lowModeShadow,
                                            dragToClose: true);
                                      }
                                    }
                                  },
                                  child: const SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '拍摄照片',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    beiselectImage();
                                    Navigator.pop(context);
                                  },
                                  child: const SizedBox(
                                    width: double.infinity,
                                    child: Text(
                                      '选择相册',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ))
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      SizedBox(
                        height: 245,
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Positioned.fill(
                              child: GetBuilder<BackgroundImageChangeManagement>(
                                init: backgroundImageChangeManagement,
                                builder: (backgroundImageChangeManagement) {
                                  return backgroundImageChangeManagement.changedBackgroundImageValue != null
                                      ? Image.file(
                                          backgroundImageChangeManagement.changedBackgroundImageValue!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/chuhui.png',
                                          fit: BoxFit.cover,
                                        );
                                },
                              ),
                            ),
                            Positioned.fill(
                                child: Container(
                              color: Colors.black.withOpacity(0.5),
                            )),
                            Positioned(
                                height: 47,
                                child: SvgPicture.asset(
                                  'assets/xiangji.svg',
                                  height: 47,
                                  width: 47,
                                )),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 197,
                        left: 10,
                        child: GetBuilder<HeadPortraitChangeManagement>(
                            init: headPortraitChangeManagement,
                            builder: (headPortraitChangeManagement) {
                              return GestureDetector(
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextButton(
                                                onPressed: () async {
                                                  var status = await Permission
                                                      .camera.status;

                                                  if (status.isGranted) {
                                                    selectCamera();
                                                    Navigator.pop(context);
                                                  } else {
                                                    var permissionStatus =
                                                        await Permission.camera
                                                            .request();
                                                    if (permissionStatus
                                                        .isGranted) {
                                                      selectCamera();
                                                      Navigator.pop(context);
                                                    } else {
                                                      toast.toastification.show(
                                                          context: context,
                                                          callbacks: toast
                                                              .ToastificationCallbacks(
                                                            onTap: (toastItem) =>
                                                                AppSettings.openAppSettings(
                                                                    type: AppSettingsType
                                                                        .settings),
                                                          ),
                                                          type: toast
                                                              .ToastificationType
                                                              .warning,
                                                          style: toast
                                                              .ToastificationStyle
                                                              .flatColored,
                                                          title: const Text(
                                                              "未授权相机权限",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  fontSize:
                                                                      17)),
                                                          description:
                                                              const Text(
                                                            "无法开启相机",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        119,
                                                                        118,
                                                                        118),
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          alignment:
                                                              Alignment.topLeft,
                                                          autoCloseDuration:
                                                              const Duration(
                                                                  seconds: 4),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12.0),
                                                          boxShadow: toast
                                                              .lowModeShadow,
                                                          dragToClose: true);
                                                    }
                                                  }
                                                },
                                                child: const SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    '拍摄照片',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  selectImage();
                                                  Navigator.pop(context);
                                                },
                                                child: const SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    '选择相册',
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 51,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.grey,
                                    backgroundImage: headPortraitChangeManagement
                                                .changedHeadPortraitValue !=
                                            null
                                        ? FileImage(
                                            headPortraitChangeManagement.changedHeadPortraitValue!)
                                        : const AssetImage('assets/chuhui.png'),
                                    radius: 47.5,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned.fill(
                                            child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        )),
                                        Positioned(
                                            height: 47,
                                            child: SvgPicture.asset(
                                              'assets/xiangji.svg',
                                              height: 47,
                                              width: 47,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GetBuilder<EditPersonalDataValueManagement>(
                      init: editPersonalDataValueManagement,
                      builder: (editPersonalDataValueManagement) {
                        return Column(
                          children: [
                            TextFormField(
                              cursorColor: Colors.blue,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              controller: TextEditingController(
                                  text: editPersonalDataValueManagement.nameValue == ' '
                                      ? null
                                      : editPersonalDataValueManagement.nameValue),
                              onChanged: (value) {
                                name = value.trim();
                                baocuncontroller.namess(name);
                              },
                              maxLines: 1,
                              maxLength: 45,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: '姓名',
                                hintText: '姓名不能为空',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 119, 118, 118),
                                ),
                                counterText: "",
                              ),
                            ),
                            const SizedBox(width: double.infinity, height: 20),
                            TextFormField(
                              cursorColor: Colors.blue,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              controller: TextEditingController(
                                  text: editPersonalDataValueManagement.profileValue == ' '
                                      ? null
                                      : editPersonalDataValueManagement.profileValue),
                              onChanged: (value) {
                                brief = value.replaceAll('\n', '');
                              },
                              maxLines: 10,
                              minLines: 3,
                              maxLength: 150,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: '简介',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 119, 118, 118),
                                ),
                                counterText: "",
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: double.infinity, height: 20),
                    GetBuilder<SelectorResultsUpdateDisplay>(
                      init: selectorResultsUpdateDisplay,
                      builder: (pcontroller) {
                        return Column(
                          children: [
                            TextFormField(
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              onTap: () async {
                                Result? result =
                                    await CityPickers.showCityPicker(
                                  context: context,
                                );
                                if (result != null &&
                                    result.provinceId != 'kong') {
                                  formatteplace =
                                      '${result.provinceName!}.${result.cityName!}.${result.areaName!}';
                                  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(formatteplace);
                                } else if (result?.provinceId == 'kong') {
                                  formatteplace = ' ';
                                  selectorResultsUpdateDisplay.residentialAddressSelectorResultValueChange(formatteplace);
                                }
                              },
                              controller: TextEditingController(
                                  text: selectorResultsUpdateDisplay.residentialAddressSelectorResultValue == ' '
                                      ? null
                                      : selectorResultsUpdateDisplay.residentialAddressSelectorResultValue),
                              maxLines: 1,
                              maxLength: 50,
                              readOnly: true,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: '位置',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 119, 118, 118),
                                ),
                                counterText: "",
                              ),
                            ),
                            const SizedBox(width: double.infinity, height: 20),
                            TextFormField(
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: SizedBox(
                                        height: 300,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 250,
                                              child: Localizations.override(
                                                context: context,
                                                locale: const Locale('en'),
                                                delegates: const [
                                                  MyDefaultCupertinoLocalizations
                                                      .delegate,
                                                ],
                                                child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode
                                                      .date,
                                                  minimumDate:
                                                      DateTime(1900, 1, 1),
                                                  maximumDate: DateTime.now(),
                                                  initialDateTime:
                                                      DateTime(2000, 1, 1),
                                                  dateOrder:
                                                      DatePickerDateOrder.ymd,
                                                  onDateTimeChanged: (date) {
                                                    formattedDate = DateFormat(
                                                            'yyyy年MM月dd日')
                                                        .format(date);
                                                  },
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: const Text(
                                                        '取消',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        selectorResultsUpdateDisplay
                                                            .dateOfBirthSelectorResultValueChange(' ');
                                                      },
                                                      child: const Text(
                                                        '移除',
                                                        style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    selectorResultsUpdateDisplay
                                                        .dateOfBirthSelectorResultValueChange(formattedDate);
                                                  },
                                                  child: const Text(
                                                    '确定',
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              controller: TextEditingController(
                                  text: selectorResultsUpdateDisplay.dateOfBirthSelectorResultValue == ' '
                                      ? null
                                      : selectorResultsUpdateDisplay.dateOfBirthSelectorResultValue),
                              maxLines: 1,
                              maxLength: 50,
                              readOnly: true,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.black, width: 2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                border: const OutlineInputBorder(),
                                labelText: '出生日期',
                                labelStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 119, 118, 118),
                                ),
                                counterText: "",
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
