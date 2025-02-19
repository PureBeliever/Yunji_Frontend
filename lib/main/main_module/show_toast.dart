import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(
  BuildContext context,
  String title,
  String message,
) {
  toastification.show(
    context: context,
    type: ToastificationType.success,
    style: ToastificationStyle.flat,
    title: Text(
      title,
      style: TextStyle(fontSize: 17),
    ),
    description: Text(
      message,
      style: TextStyle(fontSize: 16),
    ),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    primaryColor: Colors.blue,
    foregroundColor: Colors.blue, // 修改前景色为白色
    backgroundColor: Color.fromARGB(255, 225, 240, 255), // 设置背景色
    borderRadius: BorderRadius.circular(12.0),
    closeButtonShowType: CloseButtonShowType.none,
    showProgressBar: false,
    boxShadow: lowModeShadow,
  );
}

void showWarnToast(BuildContext context, String title, String message,
    [Function? onTap]) {
  toastification.show(
    context: context,
    type: ToastificationType.warning,
    style: ToastificationStyle.flat,
    title: Text(
      title,
      style: TextStyle(fontSize: 17),
    ),
    description: Text(
      message,
      style: TextStyle(fontSize: 16),
    ),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    primaryColor: Colors.orange,
    foregroundColor: Colors.orange, // 修改前景色为白色
    backgroundColor: Color.fromARGB(255, 255, 246, 225), // 设置背景色
    borderRadius: BorderRadius.circular(12.0),
    closeButtonShowType: CloseButtonShowType.none,
    showProgressBar: false,
    boxShadow: lowModeShadow,
    callbacks: onTap != null
        ? ToastificationCallbacks(
            onTap: (toastItem) => onTap(),
          )
        : ToastificationCallbacks(),
  );
}

void showErrorToast(
  BuildContext context,
  String title,
  String message,
) {
  toastification.show(
    context: context,
    type: ToastificationType.error,
    style: ToastificationStyle.flat,
    title: Text(
      title,
      style: TextStyle(fontSize: 17),
    ),
    description: Text(
      message,
      style: TextStyle(fontSize: 16),
    ),
    alignment: Alignment.topCenter,
    autoCloseDuration: const Duration(seconds: 4),
    primaryColor: Colors.red,
    foregroundColor: Colors.red, // 修改前景色为白色
    backgroundColor: Color.fromARGB(255, 255, 225, 225), // 设置背景色
    borderRadius: BorderRadius.circular(12.0),
    closeButtonShowType: CloseButtonShowType.none,
    showProgressBar: false,
    boxShadow: lowModeShadow,
  );
}
