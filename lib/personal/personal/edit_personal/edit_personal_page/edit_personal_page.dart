import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:city_pickers/city_pickers.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/personal/personal/edit_personal/edit_personal_module/default_cupertion.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_api.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/setting/setting_account_user_name.dart';
import 'package:yunji/main/app_global_variable.dart';

class EditPersonalDataValueManagement extends GetxController {
  static EditPersonalDataValueManagement get to => Get.find();

  String? nameValue;
  String? profileValue;
  String? dateOfBirthValue;
  String? residentialAddressValue;
  String? applicationDateValue;

  void changePersonalInformation({
    String? name,
    String? profile,
    String? residentialAddress,
    String? dateOfBirth,
    String? applicationDate,
  }) {
    nameValue = name;
    profileValue = profile;
    residentialAddressValue = residentialAddress;
    dateOfBirthValue = dateOfBirth;
    applicationDateValue = applicationDate;
    update();
  }

  int rollbackTheChangedValue({
    String? name,
    String? profile,
    String? residentialAddress,
    String? dateOfBirth,
  }) {
    int changes = 0;
    if (nameValue != name) changes++;
    if (profileValue != profile) changes++;
    if (residentialAddressValue != residentialAddress) changes++;
    if (dateOfBirthValue != dateOfBirth) changes++;
    if (backgroundImageChangeManagement
        .exitThePageToDetermineWhetherTheBackgroundImageHasChanged()) changes++;
    if (headPortraitChangeManagement
        .exitThePageToDetermineWhetherTheHeadPortraitHasChanged()) changes++;
    return changes;
  }
}

class SaveBackSpace extends GetxController {
  static SaveBackSpace get to => Get.find();
  bool backspaceValue = true;

  void backspaceValueChange(bool value) {
    backspaceValue = value;
    update();
  }
}

//更新选择器结果显示
class SelectorResultsUpdateDisplay extends GetxController {
  static SelectorResultsUpdateDisplay get to => Get.find();
  String? residentialAddressSelectorResultValue;
  String? dateOfBirthSelectorResultValue;

// 日期选择器结果值更改
  void dateOfBirthSelectorResultValueChange(
      String? dateOfBirthSelectorResultValueChange) {
    dateOfBirthSelectorResultValue = dateOfBirthSelectorResultValueChange;
    update();
  }

// 地址选择器结果值更改
  void residentialAddressSelectorResultValueChange(
      String? residentialAddressSelectorResultValueChange) {
    residentialAddressSelectorResultValue =
        residentialAddressSelectorResultValueChange;
    update();
  }
}

class EditPersonalPage extends StatefulWidget {
  const EditPersonalPage({super.key});

  @override
  State<EditPersonalPage> createState() => _EditPersonalPageState();
}

class _EditPersonalPageState extends State<EditPersonalPage> {
  // 在构造函数中初始化
  String? name;
  String? profile;
  String? selectResidentialAddress;
  String? selectDateOfBirth;

  @override
  void initState() {
    super.initState();
    name = editPersonalDataValueManagement.nameValue;
    profile = editPersonalDataValueManagement.profileValue;
    selectResidentialAddress =
        editPersonalDataValueManagement.residentialAddressValue;
    selectDateOfBirth = editPersonalDataValueManagement.dateOfBirthValue;
  }

  final saveBackSpace = Get.put(SaveBackSpace());
  final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());
  final backgroundImageChangeManagement =
      Get.put(BackgroundImageChangeManagement());
  final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());
  final ImagePicker _imagePicker = ImagePicker();
  static String? username = UserNameChangeManagement.to.userNameValue;

  Future<void> _selectAndCropImage({
    required ImageSource source,
    required CropStyle cropStyle,
    required List<CropAspectRatioPreset> aspectRatioPresets,
    required Function(File) onImageCropped,
  }) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          cropStyle: cropStyle,
          aspectRatioPresets: aspectRatioPresets,
          uiSettings: [
            AndroidUiSettings(
              cropFrameColor: Colors.transparent,
              toolbarTitle: '',
              showCropGrid: false,
              toolbarColor: Colors.black,
              hideBottomControls: true,
              statusBarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: aspectRatioPresets.first,
              lockAspectRatio: true,
            ),
            IOSUiSettings(title: ''),
          ],
        );
        if (croppedFile != null) {
          onImageCropped(File(croppedFile.path));
        }
      }
    } catch (err) {
      // Handle error
    }
  }

  Future<void> headPortraitSelectImage() async {
    await _selectAndCropImage(
      source: ImageSource.gallery,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      onImageCropped: (file) {
        headPortraitChangeManagement
            .selectAndShootTheImageToGiveTheChangedHeadPortraitImage(file);
      },
    );
  }

  Future<void> headPortraitSelectCamera() async {
    await _selectAndCropImage(
      source: ImageSource.camera,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      onImageCropped: (file) {
        headPortraitChangeManagement
            .selectAndShootTheImageToGiveTheChangedHeadPortraitImage(file);
      },
    );
  }

  Future<void> backgroundImageSelectImage() async {
    await _selectAndCropImage(
      source: ImageSource.gallery,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
      onImageCropped: (file) {
        backgroundImageChangeManagement
            .selectAndShootTheImageToGiveTheChangedBackgroundImage(file);
      },
    );
  }

  Future<void> backgroundImageSelectCamera() async {
    await _selectAndCropImage(
      source: ImageSource.camera,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
      onImageCropped: (file) {
        backgroundImageChangeManagement
            .selectAndShootTheImageToGiveTheChangedBackgroundImage(file);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (editPersonalDataValueManagement.rollbackTheChangedValue(
              name: name,
              profile: profile,
              residentialAddress: selectResidentialAddress,
              dateOfBirth: selectDateOfBirth,
            ) >
            0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
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
                                    .dateOfBirthSelectorResultValueChange(
                                        editPersonalDataValueManagement
                                            .dateOfBirthValue);
                                selectorResultsUpdateDisplay
                                    .residentialAddressSelectorResultValueChange(
                                        editPersonalDataValueManagement
                                            .residentialAddressValue);
                                backgroundImageChangeManagement
                                    .restoreAnUnchangedBackgroundImage();
                                headPortraitChangeManagement
                                    .restoreAnUnchangedHeadPortraitImage();
                                name =
                                    editPersonalDataValueManagement.nameValue;
                                profile = editPersonalDataValueManagement
                                    .profileValue;
                                selectResidentialAddress =
                                    selectorResultsUpdateDisplay
                                        .residentialAddressSelectorResultValue;
                                selectDateOfBirth = selectorResultsUpdateDisplay
                                    .dateOfBirthSelectorResultValue;
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
                            ),
                          ],
                        ),
                      ),
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
                      name: name,
                      profile: profile,
                      residentialAddress: selectResidentialAddress,
                      dateOfBirth: selectDateOfBirth,
                    ) >
                    0) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
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
                                            .dateOfBirthSelectorResultValueChange(
                                                editPersonalDataValueManagement
                                                    .dateOfBirthValue);
                                        selectorResultsUpdateDisplay
                                            .residentialAddressSelectorResultValueChange(
                                                editPersonalDataValueManagement
                                                    .residentialAddressValue);
                                        backgroundImageChangeManagement
                                            .restoreAnUnchangedBackgroundImage();
                                        headPortraitChangeManagement
                                            .restoreAnUnchangedHeadPortraitImage();
                                        name = editPersonalDataValueManagement
                                            .nameValue;
                                        profile =
                                            editPersonalDataValueManagement
                                                .profileValue;
                                        selectResidentialAddress =
                                            selectorResultsUpdateDisplay
                                                .residentialAddressSelectorResultValue;
                                        selectDateOfBirth =
                                            selectorResultsUpdateDisplay
                                                .dateOfBirthSelectorResultValue;
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
                                    ),
                                  ],
                                ),
                              ),
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
              child: const Icon(Icons.arrow_back),
            ),
            title: const Text(
              '编辑个人资料',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            actions: [
              GetBuilder<SelectorResultsUpdateDisplay>(
                init: selectorResultsUpdateDisplay,
                builder: (pcontroller) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: saveBackSpace.backspaceValue
                        ? GestureDetector(
                            onTap: () {
                              if (editPersonalDataValueManagement
                                      .rollbackTheChangedValue(
                                    name: name,
                                    profile: profile,
                                    residentialAddress:
                                        selectResidentialAddress,
                                    dateOfBirth: selectDateOfBirth,
                                  ) >
                                  0) {
                                editPersonalDataValueManagement
                                    .changePersonalInformation(
                                  name: name,
                                  profile: profile,
                                  residentialAddress: selectResidentialAddress,
                                  dateOfBirth: selectDateOfBirth,
                                  applicationDate:
                                      editPersonalDataValueManagement
                                          .applicationDateValue,
                                );

                                Navigator.pop(context);

                                editPersonal(
                                  username,
                                  name,
                                  profile,
                                  selectResidentialAddress,
                                  selectDateOfBirth,
                                  backgroundImageChangeManagement
                                      .returnsTheChangedBackgroundImageSynchronizationBackend(),
                                  headPortraitChangeManagement
                                      .returnsTheChangedHeadPortraitImageSynchronizationBackend(),
                                );
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
                                color: Color.fromARGB(255, 119, 118, 118)),
                          ),
                  );
                },
              ),
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
                                    backgroundImageSelectCamera();
                                    Navigator.pop(context);
                                  } else {
                                    var permissionStatus =
                                        await Permission.camera.request();
                                    if (permissionStatus.isGranted) {
                                      backgroundImageSelectCamera();
                                      Navigator.pop(context);
                                    } else {
                                      toast.toastification.show(
                                        context: context,
                                        callbacks:
                                            toast.ToastificationCallbacks(
                                          onTap: (toastItem) =>
                                              AppSettings.openAppSettings(
                                                  type:
                                                      AppSettingsType.settings),
                                        ),
                                        type: toast.ToastificationType.warning,
                                        style: toast
                                            .ToastificationStyle.flatColored,
                                        title: const Text(
                                          "未授权相机权限",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17),
                                        ),
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
                                        dragToClose: true,
                                      );
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
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  backgroundImageSelectImage();
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
                                ),
                              ),
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
                              child:
                                  GetBuilder<BackgroundImageChangeManagement>(
                                init: backgroundImageChangeManagement,
                                builder: (backgroundImageChangeManagement) {
                                  return backgroundImageChangeManagement
                                              .changedBackgroundImageValue !=
                                          null
                                      ? Image.file(
                                          backgroundImageChangeManagement
                                              .changedBackgroundImageValue!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/personal/gray_back_head.png',
                                          fit: BoxFit.cover,
                                        );
                                },
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            Positioned(
                              height: 47,
                              child: SvgPicture.asset(
                                'assets/personal/camera.svg',
                                height: 47,
                                width: 47,
                              ),
                            ),
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
                                                headPortraitSelectCamera();
                                                Navigator.pop(context);
                                              } else {
                                                var permissionStatus =
                                                    await Permission.camera
                                                        .request();
                                                if (permissionStatus
                                                    .isGranted) {
                                                  headPortraitSelectCamera();
                                                  Navigator.pop(context);
                                                } else {
                                                  toast.toastification.show(
                                                    context: context,
                                                    callbacks: toast
                                                        .ToastificationCallbacks(
                                                      onTap: (toastItem) =>
                                                          AppSettings.openAppSettings(
                                                              type:
                                                                  AppSettingsType
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
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          fontSize: 17),
                                                    ),
                                                    description: const Text(
                                                      "无法开启相机",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              119,
                                                              118,
                                                              118),
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    alignment:
                                                        Alignment.topLeft,
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                    boxShadow:
                                                        toast.lowModeShadow,
                                                    dragToClose: true,
                                                  );
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
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              headPortraitSelectImage();
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
                                            ),
                                          ),
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
                                      ? FileImage(headPortraitChangeManagement
                                          .changedHeadPortraitValue!)
                                      : const AssetImage(
                                              'assets/personal/gray_back_head.png')
                                          as ImageProvider,
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
                                        ),
                                      ),
                                      Positioned(
                                        height: 47,
                                        child: SvgPicture.asset(
                                          'assets/personal/camera.svg',
                                          height: 47,
                                          width: 47,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                  child: GetBuilder<EditPersonalDataValueManagement>(
                      init: editPersonalDataValueManagement,
                      builder: (editPersonalDataValueManagement) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: [
                                TextFormField(
                                  cursorColor: Colors.blue,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                  controller: TextEditingController(text: name),
                                  onChanged: (value) {
                                    name = value.trim();
                                    saveBackSpace
                                        .backspaceValueChange(value.isNotEmpty);
                                  },
                                  maxLines: 1,
                                  maxLength: 45,
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
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
                                const SizedBox(
                                    width: double.infinity, height: 20),
                                TextFormField(
                                  cursorColor: Colors.blue,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                  controller:
                                      TextEditingController(text: profile),
                                  onChanged: (value) {
                                    profile = value.replaceAll('\n', '');
                                  },
                                  maxLines: 10,
                                  minLines: 3,
                                  maxLength: 150,
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
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
                            ),
                            const SizedBox(width: double.infinity, height: 20),
                            GetBuilder<SelectorResultsUpdateDisplay>(
                              init: selectorResultsUpdateDisplay,
                              builder: (pcontroller) {
                                return Column(
                                  children: [
                                    TextFormField(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                      onTap: () async {
                                        Result? result =
                                            await CityPickers.showCityPicker(
                                                context: context);
                                        selectResidentialAddress = (result !=
                                                    null &&
                                                result.provinceId != 'null')
                                            ? '${result.provinceName}.${result.cityName}.${result.areaName}'
                                            : ' ';
                                        selectorResultsUpdateDisplay
                                            .residentialAddressSelectorResultValueChange(
                                                selectResidentialAddress);
                                      },
                                      controller: TextEditingController(
                                          text: selectorResultsUpdateDisplay
                                              .residentialAddressSelectorResultValue),
                                      maxLines: 1,
                                      maxLength: 50,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        border: const OutlineInputBorder(),
                                        labelText: '位置',
                                        labelStyle: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                              255, 119, 118, 118),
                                        ),
                                        counterText: "",
                                      ),
                                    ),
                                    const SizedBox(
                                        width: double.infinity, height: 20),
                                    TextFormField(
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
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
                                                      child: Localizations
                                                          .override(
                                                        context: context,
                                                        locale:
                                                            const Locale('en'),
                                                        delegates: const [
                                                          MyDefaultCupertinoLocalizations
                                                              .delegate
                                                        ],
                                                        child:
                                                            CupertinoDatePicker(
                                                          mode:
                                                              CupertinoDatePickerMode
                                                                  .date,
                                                          minimumDate: DateTime(
                                                              1900, 1, 1),
                                                          maximumDate:
                                                              DateTime.now(),
                                                          initialDateTime:
                                                              DateTime(
                                                                  2000, 1, 1),
                                                          dateOrder:
                                                              DatePickerDateOrder
                                                                  .ymd,
                                                          onDateTimeChanged:
                                                              (date) {
                                                            selectDateOfBirth =
                                                                DateFormat(
                                                                        'yyyy年MM月dd日')
                                                                    .format(
                                                                        date);
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                '取消',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                selectorResultsUpdateDisplay
                                                                    .dateOfBirthSelectorResultValueChange(
                                                                        ' ');
                                                              },
                                                              child: const Text(
                                                                '移除',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        17,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w900,
                                                                    color: Colors
                                                                        .red),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            selectorResultsUpdateDisplay
                                                                .dateOfBirthSelectorResultValueChange(
                                                                    selectDateOfBirth);
                                                          },
                                                          child: const Text(
                                                            '确定',
                                                            style: TextStyle(
                                                                fontSize: 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      controller: TextEditingController(
                                          text: selectorResultsUpdateDisplay
                                              .dateOfBirthSelectorResultValue),
                                      maxLines: 1,
                                      maxLength: 50,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.blue, width: 2),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        border: const OutlineInputBorder(),
                                        labelText: '出生日期',
                                        labelStyle: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromARGB(
                                              255, 119, 118, 118),
                                        ),
                                        counterText: "",
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      })),
            ],
          ),
        ),
      ),
    );
  }
}
