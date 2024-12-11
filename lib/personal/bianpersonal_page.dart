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

class BianpersonalController extends GetxController {
  static BianpersonalController get to => Get.find();

  String name = '';
  String brief = ' ';
  String year = ' ';
  String place = ' ';
  String jiaru = ' ';
  void jiaruvalue(String jia) {
    jiaru = jia;
    update();
  }

  void namevalue(String na, String bri, String pla, String ye) {
    name = na;
    brief = bri;
    place = pla;
    year = ye;
    update();
  }

  int tuichu(String na, String bri, String pla, String ye) {
    int nametui = name != na ? 1 : 0;
    int brieftui = brief != bri ? 1 : 0;
    int placetui = place != pla ? 1 : 0;
    int yeartui = year != ye ? 1 : 0;
    return nametui + brieftui + placetui + yeartui;
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

class Placecontroller extends GetxController {
  static Placecontroller get to => Get.find();
  String formattedDate = ' ';
  String formatteplace = ' ';

  void riqi(String qi) {
    formattedDate = qi;
    update();
  }

  void weizhi(String pl) {
    formatteplace = pl;
    update();
  }
}

class BianpersonalPage extends StatefulWidget {
  const BianpersonalPage({super.key});

  @override
  State<BianpersonalPage> createState() => _BiannpersonalPage();
}

class _BiannpersonalPage extends State<BianpersonalPage> {
  static String name = BianpersonalController.to.name;
  static String brief = BianpersonalController.to.brief;
  static String formatteplace = BianpersonalController.to.place;
  static String formattedDate = BianpersonalController.to.year;

  final headcontroller = Get.put(Headcontroller());
  final bianpersonalController = Get.put(BianpersonalController());
  final baocuncontroller = Get.put(Baocuncontroller());
  final beicontroller = Get.put(Beicontroller());
  final placecontroller = Get.put(Placecontroller());
  final ImagePicker _imagePicker = ImagePicker();
  final settingzhanghaoxiugaicontroller =
      Get.put(Settingzhanghaoxiugaicontroller());
  static String username = Settingzhanghaoxiugaicontroller.to.username;

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
        headcontroller.hanbianheadimage(File(croppedFile!.path));
      }
      // ignore: empty_catches
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
        headcontroller.hanbianheadimage(File(croppedFile!.path));
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
      beicontroller.hanbianbeiimage(File(croppedFile!.path));
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
      beicontroller.hanbianbeiimage(File(croppedFile!.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (bianpersonalController.tuichu(
                    name, brief, formatteplace, formattedDate) >
                0 ||
            beicontroller.tuichu() == 1 ||
            headcontroller.tuichu() == 1) {
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
                                placecontroller
                                    .riqi(bianpersonalController.year);
                                placecontroller
                                    .weizhi(bianpersonalController.place);
                                beicontroller.hanyuan();
                                headcontroller.hanyuan();
                                name = bianpersonalController.name;
                                brief = bianpersonalController.brief;
                                formatteplace = placecontroller.formatteplace;
                                formattedDate = placecontroller.formattedDate;
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
                if (bianpersonalController.tuichu(
                            name, brief, formatteplace, formattedDate) >
                        0 ||
                    beicontroller.tuichu() == 1 ||
                    headcontroller.tuichu() == 1) {
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
                                        placecontroller
                                            .riqi(bianpersonalController.year);
                                        placecontroller.weizhi(
                                            bianpersonalController.place);
                                        beicontroller.hanyuan();
                                        headcontroller.hanyuan();
                                        name = bianpersonalController.name;
                                        brief = bianpersonalController.brief;
                                        formatteplace =
                                            placecontroller.formatteplace;
                                        formattedDate =
                                            placecontroller.formattedDate;
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
                                if (bianpersonalController.tuichu(name, brief,
                                            formatteplace, formattedDate) >
                                        0 ||
                                    beicontroller.tuichu() == 1 ||
                                    headcontroller.tuichu() == 1) {
                                  bianpersonalController.namevalue(name, brief,
                                      formatteplace, formattedDate);

                                  Navigator.pop(context);

                                  PostHttp(
                                      username,
                                      name,
                                      brief,
                                      formatteplace,
                                      formattedDate,
                                      beicontroller.baocun(),
                                      headcontroller.baocun());
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
                              child: GetBuilder<Beicontroller>(
                                init: beicontroller,
                                builder: (beicontroller) {
                                  return beicontroller.bianbeiimage != null
                                      ? Image.file(
                                          beicontroller.bianbeiimage!,
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
                        child: GetBuilder<Headcontroller>(
                            init: headcontroller,
                            builder: (hcontroller) {
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
                                    backgroundImage: headcontroller
                                                .bianheadimage !=
                                            null
                                        ? FileImage(
                                            headcontroller.bianheadimage!)
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
                    GetBuilder<BianpersonalController>(
                      init: bianpersonalController,
                      builder: (bcontroller) {
                        return Column(
                          children: [
                            TextFormField(
                              cursorColor: Colors.blue,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                              controller: TextEditingController(
                                  text: bcontroller.name == ' '
                                      ? null
                                      : bcontroller.name),
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
                                  text: bcontroller.brief == ' '
                                      ? null
                                      : bcontroller.brief),
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
                    GetBuilder<Placecontroller>(
                      init: placecontroller,
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
                                  pcontroller.weizhi(formatteplace);
                                } else if (result?.provinceId == 'kong') {
                                  formatteplace = ' ';
                                  pcontroller.weizhi(formatteplace);
                                }
                              },
                              controller: TextEditingController(
                                  text: pcontroller.formatteplace == ' '
                                      ? null
                                      : pcontroller.formatteplace),
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
                                                        placecontroller
                                                            .riqi(' ');
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
                                                    placecontroller
                                                        .riqi(formattedDate);
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
                                  text: pcontroller.formattedDate == ' '
                                      ? null
                                      : pcontroller.formattedDate),
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
