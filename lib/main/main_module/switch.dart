
import 'package:flutter/cupertino.dart';


void switchPage(BuildContext context, Widget page) {
  Navigator.push(
    context,
    CupertinoPageRoute(
      builder: (context) => page,
      // 设置滑动时间
    ),
  );
}