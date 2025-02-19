import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 导入系统服务包
import 'package:toastification/toastification.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/main/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: AppColors.statusBarBrightness,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: AppColors.statusBarBrightness,
    systemNavigationBarDividerColor: AppColors.background,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ToastificationWrapper(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '云忆',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
