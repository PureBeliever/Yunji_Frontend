import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yunji/setting/setting_api.dart';
import 'package:yunji/main/app_global_variable.dart';

// 用户名更改管理器
class UserNameChangeManagement extends GetxController {
  static UserNameChangeManagement get to => Get.find();
  String? userNameValue;
  bool theUserNameChangedStatus = false;
  void userNameChangedStatusTrue() {
    theUserNameChangedStatus = true; 
    update();
  }

  void userNameChangedStatusFalse() {
    theUserNameChangedStatus = false;
    update();
  }

  void userNameChanged(String? userNameValueChanged) {
    userNameValue = userNameValueChanged;
    update();
  }
}

class Settingzhanghaoxiugai extends StatefulWidget {
  const Settingzhanghaoxiugai({super.key});
  @override
  State<Settingzhanghaoxiugai> createState() => _Settingzhanghaoxiugai();
}

class _Settingzhanghaoxiugai extends State<Settingzhanghaoxiugai> {
  final userNameChangeManagement = Get.put(UserNameChangeManagement());
  static String? username = UserNameChangeManagement.to.userNameValue;

  bool cunzai = false;

  final _controller = TextEditingController(text: username);
  final _yonghucontroller = TextEditingController();
  @override
  void initState() {
    _controller.text = username??'';
    _yonghucontroller.text = username??'';
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void chazhanghao(String? username) async {
    Map<String, String> header = {
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> formdata = {
      'username': username??'',
    };

    final response = await dio.post('http://47.92.90.93:36233/verifyUserName',
        data: jsonEncode(formdata), options: Options(headers: header));
    if (response.statusCode == 200) {
      cunzai = true;
      _controller.text = username??'';
      userNameChangeManagement.userNameChangedStatusTrue();
    } else {
      cunzai = false;
      _controller.text = username??'';
      userNameChangeManagement.userNameChangedStatusFalse();
    }
  }

  String? get _errorText {
    final text = _controller.value.text;

    RegExp regex = RegExp(r'^[a-zA-Z0-9_\s]*$');
    RegExp regexkong = RegExp(r'\s');
    if (text.isEmpty || regexkong.hasMatch(text)) {
      return '你的用户名不能超过15个字符,并且只能使用字母，数字和下划线,不能包含空格';
    } else if (text.length < 5) {
      return '用户名必须多于4个字符';
    } else if (!regex.hasMatch(text)) {
      return '只能使用字母，数字与下划线';
    } else if (cunzai == true) {
      return '用户名已被占用';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          '更改用户名',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GetBuilder<UserNameChangeManagement>(
                  init: userNameChangeManagement,
                  builder: (userNameChangeManagement) {
                    return userNameChangeManagement.theUserNameChangedStatus == true
                        ? const Text(
                            '保存',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 119, 118, 118),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              editUserName(
                                  username, userNameChangeManagement.userNameValue);
                              userNameChangeManagement
                                  .userNameChanged(username);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              '保存',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          );
                  }))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              controller: _yonghucontroller,
              enabled: false,
              decoration: const InputDecoration(
                labelText: '当前',
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Color.fromARGB(255, 187, 187, 187)),
              ),
            ),
            const SizedBox(
              height: 35,
            ),
            ValueListenableBuilder(
              // Note: pass _controller to the animation argument
              valueListenable: _controller,
              builder: (context, TextEditingValue value, __) {
                return TextFormField(
                  controller: _controller,
                  onChanged: (value) {
                    username = value.trim();
                    if (value.length > 4) {
                      chazhanghao(username);
                    } else {
                      userNameChangeManagement.userNameChangedStatusTrue();
                    }
                  },
                  maxLength: 17,
                  cursorColor: Colors.blue,
                  autofocus: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    decoration: TextDecoration.none,
                    decorationThickness: 0,
                  ),
                  decoration: InputDecoration(
                    errorText: _errorText,
                    counterText: "",
                    errorMaxLines: 5,
                    errorStyle:
                        const TextStyle(color: Colors.red, fontSize: 16),
                    labelText: '新',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      color: Color.fromRGBO(84, 87, 105, 1),
                    ),
                    prefixText: '@',
                    prefixStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 19,
                        color: Color.fromARGB(255, 187, 187, 187)),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    border: const UnderlineInputBorder(),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
