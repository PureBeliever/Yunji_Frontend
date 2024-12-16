import 'package:flutter/material.dart';
import 'package:flutter_ali_auth/flutter_ali_auth.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/main/home_page.dart';
import 'package:yunji/main/login/sms_login.dart';
import 'package:yunji/api/personal_api.dart';

bool _isFirstLoginAttempt = true;

// 处理认证事件
Future<void> onEvent(AuthResponseModel event, BuildContext context) async {
  if (event.resultCode == "600024") {
    await AliAuthClient.login();
  }

  if (_isFirstLoginAttempt && event.resultCode == "600000") {
    await handleSuccessfulLogin(event.token, context);
  } else if (_isFirstLoginAttempt && !isKnownError(event.resultCode ?? '')) {
    smsLogin(contexts!);
    _isFirstLoginAttempt = false;
  }
}

// 处理成功登录
Future<void> handleSuccessfulLogin(String? token, BuildContext context) async {
  if (token != null) {
    shouji(token);
    showToast("右滑可查看个人资料", "右滑可查看个人资料", context);
    showToast("登录成功,欢迎您使用本应用！", "这是一款帮助学习和记忆的应用,希望对您产生帮助", context);
    await refreshHomePageMemoryBank();
    _isFirstLoginAttempt = false;
  }
}

// 显示提示信息
void showToast(String title, String description, BuildContext context) {
  toast.toastification.show(
    context: context,
    type: toast.ToastificationType.success,
    style: toast.ToastificationStyle.flatColored,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w800,
        fontSize: 17,
      ),
    ),
    description: Text(
      description,
      style: const TextStyle(
        color: Color.fromARGB(255, 119, 118, 118),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    alignment: Alignment.topRight,
    autoCloseDuration: const Duration(seconds: 10),
    primaryColor: const Color(0xff047aff),
    backgroundColor: const Color(0xffedf7ff),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: toast.lowModeShadow,
    dragToClose: true,
  );
}

// 检查是否为已知错误
bool isKnownError(String resultCode) {
  const knownErrors = ['600024', '600001', '600016', '600015', '600012'];
  return knownErrors.contains(resultCode);
}