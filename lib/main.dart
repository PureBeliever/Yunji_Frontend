import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';
import 'package:yunji/main/global.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_background_image.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_head_portrait.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/review/custom_memory_scheme.dart';
import 'package:yunji/review/review/continue_review/continue_review.dart';
import 'package:yunji/review/review/continue_review/continue_review_option.dart';
import 'package:yunji/review/review/creat_review/creat_review_option.dart';
import 'package:yunji/review/review/creat_review/creat_review_page.dart';
import 'package:yunji/review/review/start_review/review.dart';
import 'package:yunji/setting/setting_page.dart';
import 'package:yunji/setting/setting_user/setting_user.dart';
import 'package:yunji/setting/setting_user/setting_user_name/setting_user_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 配置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarBrightness: AppColors.statusBarBrightness,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: AppColors.statusBarBrightness,
    systemNavigationBarDividerColor: AppColors.background,
  ));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
    // 利用映射表简化路由配置，降低重复代码（注意：因为 custom_memory_scheme 需要传参，所以不在这里注册）
    final Map<String, Widget Function()> routes = {
      '/': () => const HomePage(),
      '/personal': () => const PersonalPage(),
      '/personal/personal_head_portrait': () => const PersonalHeadPortrait(),
      '/personal/personal_background_image': () =>
          const PersonalBackgroundImage(),
      '/personal/edit_personal_page': () => const EditPersonalPage(),
      '/personal/review_page': () => const ReviewPage(),
      '/personal/continue_review': () => const ContinueReview(),
      '/personal/continue_review/continue_review_option': () =>
          const ContinueReviewOption(),
      '/settings': () => const SettingPage(),
      '/settings/setting_user': () => const SettingUser(),
      '/settings/setting_user/setting_user_name': () => const SettingUserName(),
      '/creat_review_page': () => const CreatReviewPage(),
      '/creat_review_page/creat_review_option': () => const CreatReviewOption(),
      // 注意：路径 '/creat_review_page/creat_review_option/custom_memory_scheme'
      // 不在此注册，而是在 onGenerateRoute 中单独处理
      '/other_memory_bank': () => const OtherMemoryBank(),
      '/other_memory_bank/other_personal_page': () => const OtherPersonalPage(),
      '/other_memory_bank/other_personal_page/other_personal_background_image':
          () => const OtherPersonalBackgroundImage(),
      '/other_memory_bank/other_personal_page/other_personal_head_portrait':
          () => const OtherPersonalHeadPortrait(),
    };

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '云忆',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        // 单独处理需要传参的页面
        if (settings.name ==
            '/creat_review_page/creat_review_option/custom_memory_scheme') {
          final args = settings.arguments as Map<String, dynamic>;
          return CupertinoPageRoute(
            builder: (context) => CustomMemoryScheme(
              question: (args['question'] as Map).cast<int, String>(),
              answer: (args['answer'] as Map).cast<int, String>(),
              theme: args['theme'] as String,
              message: args['message'] as bool,
              alarmInformation: args['alarmInformation'] as bool,
              continueReview: args['continueReview'] as bool,
              id: args['id'] as int,
            ),
            settings: settings,
          );
        }
        // 其他页面按映射表注册
        final pageBuilder = routes[settings.name];
        if (pageBuilder != null) {
          return CupertinoPageRoute(
            builder: (context) => pageBuilder(),
            settings: settings,
          );
        }
        return CupertinoPageRoute(
          builder: (context) => const UnknownPage(),
          settings: settings,
        );
      },
    );
  }
}

class UnknownPage extends StatelessWidget {
  const UnknownPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: const Center(
        child: Text(
          '页面正在开发中\n敬请期待',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
