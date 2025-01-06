import 'package:flutter/material.dart';
import 'package:flutter_ali_auth/flutter_ali_auth.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/home/login/mobile/mobile_number_api.dart';
import 'package:yunji/home/login/sms/sms_login.dart';
import 'package:yunji/home/algorithm_home_api.dart';
import 'package:yunji/main/app_module/show_toast.dart';

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
    mobileNumberLogin(token);
     showToast(
    context,
    "登录成功",
    "欢迎使用本应用！",
    toast.ToastificationType.success,
    const Color(0xff047aff),
    const Color(0xFFEDF7FF),
  );
  showToast(
    context,
    "右滑查看资料",
    "可以查看个人资料",
    toast.ToastificationType.success,
    const Color(0xff047aff),
    const Color(0xFFEDF7FF),
  );
    await refreshHomePageMemoryBank(context);
    
    _isFirstLoginAttempt = false;
  }
}

// 显示提示信息


// 检查是否为已知错误
bool isKnownError(String resultCode) {
  const knownErrors = ['600024', '600001', '600016', '600015', '600012'];
  return knownErrors.contains(resultCode);
}