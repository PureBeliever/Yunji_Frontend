import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yunji/home/login/sms/sms_api.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/main/main_module/show_toast.dart';

// 短信登录功能
void smsLogin() {
  // 获取全局的 context（若无法获取则直接返回）
  final BuildContext? context = navigatorKey.currentContext;
  if (context == null) {
    return;
  }

  // 输入框控制器
  final phoneController = TextEditingController();
  final codeController = TextEditingController();

  // 状态管理：验证码发送状态、倒计时、手机号校验状态与验证尝试状态
  final sendingState = ValueNotifier<bool>(true);
  final seconds = ValueNotifier<int>(60);
  final phoneNumberStatus = ValueNotifier<bool>(false);
  final verifyAttempt = ValueNotifier<bool>(true);

  // 倒计时，每秒递减，结束后重置状态
  void countdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds.value <= 0) {
        timer.cancel();
        sendingState.value = true;
        seconds.value = 60;
      } else {
        seconds.value--;
      }
    });
  }

  // 发送验证码逻辑
  void handleSendCode() {
    final phone = phoneController.text;
    if (!_isValidPhoneNumber(phone)) {
      showWarnToast(
        context,
        "手机号格式错误",
        "请输入正确的手机号码",
      );
      return;
    }

    if (sendingState.value) {
      phoneNumberStatus.value = true;
      smsVerificationCode(phone); // 发送短信验证码
      showToast(
        context,
        "验证码已发送",
        "请注意查收验证码",
      );
      sendingState.value = false;
      countdown();
    } else {
      showWarnToast(
        context,
        "请稍后重试",
        "需等待${seconds.value}秒",
      );
    }
  }

  // 验证验证码逻辑
  void handleVerifyCode() async {
    if (!phoneNumberStatus.value || sendingState.value || !verifyAttempt.value) {
      showWarnToast(
        context,
        "验证码已过期",
        "请重新获取验证码",
      );
      return;
    }

    verifyAttempt.value = false;
    final verified = await verification(phoneController.text, codeController.text);
    if (verified) {
      _onLoginSuccess(context);
      Navigator.pop(context);
    } else {
      showErrorToast(
        context,
        "验证失败",
        "验证码错误",
      );
    }
    verifyAttempt.value = true;
  }

  // 显示登录对话框
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: LoginDialogContent(
          phoneController: phoneController,
          codeController: codeController,
          sendingState: sendingState,
          seconds: seconds,
          onSendCode: handleSendCode,
          onVerify: handleVerifyCode,
        ),
      );
    },
  );
}

// 登录对话框内容
class LoginDialogContent extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController codeController;
  final ValueNotifier<bool> sendingState;
  final ValueNotifier<int> seconds;
  final VoidCallback onSendCode;
  final VoidCallback onVerify;

  const LoginDialogContent({
    Key? key,
    required this.phoneController,
    required this.codeController,
    required this.sendingState,
    required this.seconds,
    required this.onSendCode,
    required this.onVerify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: 200,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildPhoneInput(),
            const SizedBox(height: 10),
            _buildCodeInput(),
            _buildAgreement(),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  // 构建对话框头部（标题与关闭按钮）
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 8),
        const Text(
          '注册登录',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.clear, color: Colors.black),
        ),
      ],
    );
  }

  // 构建手机号输入框
  Widget _buildPhoneInput() {
    return TextFormField(
      controller: phoneController,
      cursorColor: Colors.blue,
      style: const TextStyle(fontWeight: FontWeight.w600),
      maxLines: 1,
      maxLength: 11,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        border: const OutlineInputBorder(),
        labelText: '手机号',
        labelStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color.fromARGB(255, 119, 118, 118),
        ),
        counterText: "",
      ),
    );
  }

  // 构建验证码输入框及“获取验证码”按钮
  Widget _buildCodeInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: TextFormField(
            controller: codeController,
            cursorColor: Colors.blue,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            maxLength: 4,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2),
              ),
              border: const OutlineInputBorder(),
              labelText: '验证码',
              labelStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 119, 118, 118),
              ),
              counterText: "",
            ),
          ),
        ),
        const SizedBox(width: 5),
        TextButton(
          onPressed: onSendCode,
          child: const Text(
            "获取验证码",
            style: TextStyle(fontSize: 17, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // 构建用户协议说明
  Widget _buildAgreement() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: Checkbox(
            value: true,
            activeColor: Colors.blue,
            onChanged: (_) {},
          ),
        ),
         Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Color.fromARGB(255, 119, 118, 118),
                fontSize: 14,
              ),
              children: [
                TextSpan(text: '我已阅读并同意'),
                TextSpan(
                  text: '使用协议',
                  style: TextStyle(color: Colors.blue),
                ),
                TextSpan(text: '和'),
                TextSpan(
                  text: '隐私协议,',
                  style: TextStyle(color: Colors.blue),
                ),
                TextSpan(text: '未注册绑定的手机号验证成功后将自动注册'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 构建登录按钮
  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 90),
        backgroundColor: Colors.blue,
      ),
      onPressed: onVerify,
      child: const Text(
        "验证登录",
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
  }
}

// 验证手机号格式是否合法
bool _isValidPhoneNumber(String phone) {
  return phone.length == 11 && RegExp(r'^\d+$').hasMatch(phone);
}

// 登录成功后的处理逻辑
void _onLoginSuccess(BuildContext context) {
  loginStatus = true;
  showToast(
    context,
    "登录成功",
    "欢迎使用本应用！",
  );
  showToast(
    context,
    "右滑查看资料",
    "可以查看个人资料",
  );
}
