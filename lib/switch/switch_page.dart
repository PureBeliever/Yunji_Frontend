import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void switchPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => page,
      // 设置滑动时间
    ),
  );
}