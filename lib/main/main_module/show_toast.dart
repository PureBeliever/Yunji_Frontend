import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart' as toast;

void showToast(
  BuildContext context,
  String title,
  String message,
  toast.ToastificationType type,
  Color? primaryColor,
  Color? backgroundColor,
) {
  toast.toastification.show(
    context: context,
    type: type,
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
      message,
      style: const TextStyle(
        color: Color.fromARGB(255, 119, 118, 118),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
    alignment: Alignment.topRight,
    autoCloseDuration: const Duration(seconds: 4),
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: toast.lowModeShadow,
    primaryColor: primaryColor,
    backgroundColor: backgroundColor,
    dragToClose: true,
    
  );
}
