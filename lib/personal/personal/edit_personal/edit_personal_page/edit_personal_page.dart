import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_module/address_picker_dialog.dart';

import 'package:yunji/personal/personal/edit_personal/edit_personal_module/default_cupertion.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_api.dart';

import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/show_toast.dart';

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
    if (backgroundImageChangeManagement.backgroundImageValue?.path !=
        backgroundImageChangeManagement.changedBackgroundImageValue?.path) {
      changes++;
    }
    if (headPortraitChangeManagement.changedHeadPortraitValue?.path !=
        headPortraitChangeManagement.headPortraitValue?.path) changes++;

    return changes;
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
  String? name;
  String? profile;
  String? selectResidentialAddress;
  String? selectDateOfBirth;
  bool backspaceValue = true;
  final _editPersonalDataValueManagement =
      Get.put(EditPersonalDataValueManagement());

  // final ImagePicker _picker = ImagePicker();

  // Future<void> _pickVideoAndConvertToGif() async {
  //   final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

  //   if (video != null) {
  //     switchPage(context, EditVideoEditorPage(video: video));
  //   }
  // }

  @override
  void initState() {
    super.initState();
    backspaceValue =
        _editPersonalDataValueManagement.nameValue?.isNotEmpty ?? false;
    name = _editPersonalDataValueManagement.nameValue;
    profile = _editPersonalDataValueManagement.profileValue;
    selectResidentialAddress =
        _editPersonalDataValueManagement.residentialAddressValue;
    selectDateOfBirth = _editPersonalDataValueManagement.dateOfBirthValue;
  }

  final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());
  final backgroundImageChangeManagement =
      Get.put(BackgroundImageChangeManagement());
  final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _selectAndCropImage({
    required ImageSource source,
    required CropStyle cropStyle,
    required List<CropAspectRatioPreset> aspectRatioPresets,
    required Function(File) onImageCropped,
  }) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);

      if (image != null && !image.path.endsWith('.gif')) {
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
      } else if (image != null) {
        onImageCropped(File(image.path));
      }
    } catch (err) {
      // Handle error
    }
  }

  Future<void> _selectImage({
    required ImageSource source,
    required CropStyle cropStyle,
    required List<CropAspectRatioPreset> aspectRatioPresets,
    required Function(File) onImageCropped,
  }) async {
    await _selectAndCropImage(
      source: source,
      cropStyle: cropStyle,
      aspectRatioPresets: aspectRatioPresets,
      onImageCropped: onImageCropped,
    );
  }

  Future<void> headPortraitSelectImage() async {
    await _selectImage(
      source: ImageSource.gallery,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      onImageCropped: (file) {
        headPortraitChangeManagement.selectAndShootImage(file);
      },
    );
  }

  Future<void> headPortraitSelectCamera() async {
    await _selectImage(
      source: ImageSource.camera,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      onImageCropped: (file) {
        headPortraitChangeManagement.selectAndShootImage(file);
      },
    );
  }

  Future<void> backgroundImageSelectImage() async {
    await _selectImage(
      source: ImageSource.gallery,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
      onImageCropped: (file) {
        backgroundImageChangeManagement.selectAndShootTheImage(file);
      },
    );
  }

  Future<void> backgroundImageSelectCamera() async {
    await _selectImage(
      source: ImageSource.camera,
      cropStyle: CropStyle.rectangle,
      aspectRatioPresets: [CropAspectRatioPreset.ratio5x3],
      onImageCropped: (file) {
        backgroundImageChangeManagement.selectAndShootTheImage(file);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_editPersonalDataValueManagement.rollbackTheChangedValue(
              name: name,
              profile: profile,
              residentialAddress: selectResidentialAddress,
              dateOfBirth: selectDateOfBirth,
            ) >
            0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildDialog(context);
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
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context),
          body: ListView(
            children: <Widget>[
              _buildImageSection(context),
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 10.0),
                child: GetBuilder<EditPersonalDataValueManagement>(
                  init: _editPersonalDataValueManagement,
                  builder: (editPersonalDataValueManagement) {
                    return _buildFormFields();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () {
          if (_editPersonalDataValueManagement.rollbackTheChangedValue(
                name: name,
                profile: profile,
                residentialAddress: selectResidentialAddress,
                dateOfBirth: selectDateOfBirth,
              ) >
              0) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return _buildDialog(context);
              },
            );
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Icon(Icons.arrow_back, color: AppColors.Gray),
      ),
      title: Text(
        '编辑个人资料',
        style: AppTextStyle.titleStyle,
      ),
      actions: [
        GetBuilder<SelectorResultsUpdateDisplay>(
          init: selectorResultsUpdateDisplay,
          builder: (pcontroller) {
            return Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: backspaceValue
                  ? GestureDetector(
                      onTap: () {
                        if (_editPersonalDataValueManagement
                                .rollbackTheChangedValue(
                              name: name,
                              profile: profile,
                              residentialAddress: selectResidentialAddress,
                              dateOfBirth: selectDateOfBirth,
                            ) >
                            0) {
                          _editPersonalDataValueManagement
                              .changePersonalInformation(
                            name: name,
                            profile: profile,
                            residentialAddress: selectResidentialAddress,
                            dateOfBirth: selectDateOfBirth,
                            applicationDate: _editPersonalDataValueManagement
                                .applicationDateValue,
                          );

                          editPersonal(
                            name,
                            profile,
                            selectResidentialAddress,
                            selectDateOfBirth,
                            backgroundImageChangeManagement
                                .syncChangedBackgroundImage(),
                            headPortraitChangeManagement
                                .syncChangedHeadPortrait(),
                          );
                          Navigator.pop(context);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        '保存',
                        style: AppTextStyle.textStyle,
                      ),
                    )
                  : Text(
                      '保存',
                      style: AppTextStyle.subsidiaryText,
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25, top: 20),
              child: Text(
                '编辑个人资料',
                style: AppTextStyle.titleStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 25, top: 10, bottom: 20),
              child: Text('放弃更改?', style: AppTextStyle.textStyle),
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
                              _editPersonalDataValueManagement
                                  .dateOfBirthValue);
                      selectorResultsUpdateDisplay
                          .residentialAddressSelectorResultValueChange(
                              _editPersonalDataValueManagement
                                  .residentialAddressValue);
                      backgroundImageChangeManagement.restoreBackgroundImage();
                      headPortraitChangeManagement.restoreHeadPortrait();
                      name = _editPersonalDataValueManagement.nameValue;
                      profile = _editPersonalDataValueManagement.profileValue;
                      selectResidentialAddress = selectorResultsUpdateDisplay
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
  }

  Widget _buildImageSection(BuildContext context) {
    return SizedBox(
      height: 320,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildImageDialog(context, backgroundImageSelectCamera,
                  backgroundImageSelectImage);
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
                        return backgroundImageChangeManagement
                                    .changedBackgroundImageValue !=
                                null
                            ? Image.file(
                                backgroundImageChangeManagement
                                    .changedBackgroundImageValue!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/personal/gray_back_head.png',
                                    fit: BoxFit.cover,
                                  );
                                },
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
                      colorFilter:
                          const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
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
                          return _buildheadDialog(
                              context,
                              headPortraitSelectCamera,
                              headPortraitSelectImage);
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.background,
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
                        radius: 50,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ),
                            ),
                            Positioned(
                              height: 47,
                              child: SvgPicture.asset(
                                'assets/personal/camera.svg',
                                height: 47,
                                width: 47,
                                colorFilter: const ColorFilter.mode(
                                    Colors.grey, BlendMode.srcIn),
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
    );
  }

  Widget _buildImageDialog(
      BuildContext context, Function onCameraTap, Function onGalleryTap) {
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
              if (!status.isGranted) {
                var permissionStatus = await Permission.camera.request();
                if (!permissionStatus.isGranted) {
                  showWarnToast(
                    context,
                    "未授权相机权限",
                    "无法开启相机，点击提示开启权限",
                    () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.settings);
                    },
                  );
                  return;
                }
              }
              onCameraTap();
              Navigator.pop(context);
            },
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '拍摄照片',
                style: AppTextStyle.textStyle,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onGalleryTap();
              Navigator.pop(context);
            },
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '选择相册',
                style: AppTextStyle.textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildheadDialog(
      BuildContext context, Function onCameraTap, Function onGalleryTap) {
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
              if (!status.isGranted) {
                var permissionStatus = await Permission.camera.request();
                if (!permissionStatus.isGranted) {
                  showWarnToast(
                    context,
                    "未授权相机权限",
                    "无法开启相机，点击提示开启权限",
                    () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.settings);
                    },
                  );
                  return;
                }
              }
              onCameraTap();
              Navigator.pop(context);
            },
            child: SizedBox(
              width: double.infinity,
              child: Text(
                '拍摄照片',
                style: AppTextStyle.textStyle,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onGalleryTap();
              Navigator.pop(context);
            },
            child: SizedBox(
              width: double.infinity,
              child: Text(
                // '选择相册(支持动图)',
                '选择相册',
                style: AppTextStyle.textStyle,
              ),
            ),
          ),
          // TextButton(
          //   onPressed: () {
          //     _pickVideoAndConvertToGif();
          //   },
          //   child: const SizedBox(
          //     width: double.infinity,
          //     child: Text(
          //       '选择视频转动图',
          //       style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 17,
          //           fontWeight: FontWeight.w700),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: [
            _buildTextFormField(
              label: '姓名',
              hintText: '姓名不能为空',
              initialValue: name,
              maxLength: 45,
              onChanged: (value) {
                name = value.trim();

                if (name == null || name!.isEmpty) {
                  setState(() {
                    backspaceValue = true;
                  });
                } else {
                  setState(() {
                    backspaceValue = false;
                  });
                }
              },
            ),
            const SizedBox(width: double.infinity, height: 20),
            _buildTextFormField(
              label: '简介',
              initialValue: profile,
              maxLength: 150,
              maxLines: 10,
              minLines: 3,
              onChanged: (value) {
                profile = value.replaceAll('\n', '');
              },
            ),
          ],
        ),
        const SizedBox(width: double.infinity, height: 20),
        GetBuilder<SelectorResultsUpdateDisplay>(
          init: selectorResultsUpdateDisplay,
          builder: (pcontroller) {
            return Column(
              children: [
                _buildTextFormField(
                  label: '位置',
                  initialValue: selectorResultsUpdateDisplay
                      .residentialAddressSelectorResultValue,
                  maxLength: 50,
                  readOnly: true,
                  onTap: () async {
                    // Result? result =
                    //     await CityPickers.showCityPicker(context: context);
                    // selectResidentialAddress = (result != null &&
                    //         result.provinceId != 'null')
                    //     ? '${result.provinceName}.${result.cityName}.${result.areaName}'
                    //     : null;
                    // selectorResultsUpdateDisplay
                    //     .residentialAddressSelectorResultValueChange(
                    //         selectResidentialAddress);
                    showChineseAddressPickerDialog(context);
                  },
                ),
                const SizedBox(width: double.infinity, height: 20),
                _buildTextFormField(
                  label: '出生日期',
                  initialValue: selectorResultsUpdateDisplay
                      .dateOfBirthSelectorResultValue,
                  maxLength: 50,
                  readOnly: true,
                  onTap: () {
                    _buildDatePickerDialog(context);
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? hintText,
    String? initialValue,
    int maxLength = 50,
    int maxLines = 1,
    int minLines = 1,
    bool readOnly = false,
    Function(String)? onChanged,
    Function()? onTap,
  }) {
    return TextFormField(
      cursorColor: AppColors.iconColor,
      style: AppTextStyle.textStyle,
      controller: TextEditingController(text: initialValue),
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.text, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.iconColor, width: 2),
          borderRadius: BorderRadius.circular(25.0),
        ),
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hintText,
        labelStyle: AppTextStyle.subsidiaryText,
        counterText: "",
        hintStyle: AppTextStyle.subsidiaryText,
      ),
    );
  }

  Future _buildDatePickerDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: AppColors.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: SizedBox(
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 250,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: AppTextStyle.titleStyle,
                        ),
                      ),
                      child: Localizations.override(
                        context: context,
                        locale: const Locale('en'),
                        delegates: const [
                          MyDefaultCupertinoLocalizations.delegate
                        ],
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.date,
                          minimumDate: DateTime(1900, 1, 1),
                          maximumDate: DateTime.now(),
                          initialDateTime: DateTime(2000, 1, 1),
                          dateOrder: DatePickerDateOrder.ymd,
                          onDateTimeChanged: (date) {
                            selectDateOfBirth =
                                DateFormat('yyyy年MM月dd日').format(date);
                          },
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              '取消',
                              style: AppTextStyle.textStyle,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              selectorResultsUpdateDisplay
                                  .dateOfBirthSelectorResultValueChange(' ');
                            },
                            child: Text(
                              '移除',
                              style: AppTextStyle.redTextStyle,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          selectorResultsUpdateDisplay
                              .dateOfBirthSelectorResultValueChange(
                                  selectDateOfBirth);
                        },
                        child: Text(
                          '确定',
                          style: AppTextStyle.textStyle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
