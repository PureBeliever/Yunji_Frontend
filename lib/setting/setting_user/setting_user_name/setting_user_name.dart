import 'package:flutter/material.dart';
import 'package:yunji/setting/setting_user/setting_user_name/setting_api.dart';
import 'package:yunji/main/global.dart';

  bool saveState = false;

class SettingUserName extends StatefulWidget {
  const SettingUserName({super.key});
  @override
  State<SettingUserName> createState() => _SettingUserName();
}

class _SettingUserName extends State<SettingUserName> {
  static String? editUserNameValue = userNameChangeManagement.userNameValue;

  final _userNameController = TextEditingController(text: editUserNameValue);
  final _changeUserNameController = TextEditingController(text: editUserNameValue);

  @override
  void dispose() {
    _userNameController.dispose();
    _changeUserNameController.dispose();
    super.dispose();
  }

  String? get _errorText {
    final text = _changeUserNameController.value.text;
    RegExp regex = RegExp(r'^[a-zA-Z0-9_]*$');
    if (text.isEmpty || text.contains(' ')) {
      return '用户名不能包含空格且不能超过15个字符，只能使用字母、数字和下划线';
    } else if (text.length < 5) {
      return '用户名必须多于4个字符';
    } else if (!regex.hasMatch(text)) {
      return '只能使用字母、数字与下划线';
    } else if (saveState) {
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
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          '更改用户名',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: saveState
                ? const Text(
                    '保存',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 119, 118, 118),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      editUserName(editUserNameValue, userNameChangeManagement.userNameValue);
                      await userNameChangeManagement.userNameChanged(editUserNameValue);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '保存',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              controller: _userNameController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: '当前',
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: Color.fromARGB(255, 187, 187, 187),
                ),
              ),
            ),
            const SizedBox(height: 35),
            ValueListenableBuilder(
              valueListenable: _changeUserNameController,
              builder: (context, TextEditingValue value, __) {
                return TextFormField(
                  controller: _changeUserNameController,
                  onChanged: (value) async {
                    editUserNameValue = value.trim();
                    if (value.length > 4) {
                      saveState = await verifyUserName(editUserNameValue);
                    } else {
                      saveState = false;
                    }
                    setState(() {});
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
                    errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
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
                      color: Color.fromARGB(255, 187, 187, 187),
                    ),
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
