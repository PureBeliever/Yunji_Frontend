import 'dart:math';


import 'package:get/get.dart';
import 'package:yunji/review/creat_review/creat_review/creat_review_page.dart';
import 'package:yunji/review/notification_init.dart';
import 'package:yunji/review/creat_review/start_review/review.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/review/review/continue_review.dart';
import 'package:yunji/personal/other_personal/other/other_memory_bank.dart';
import 'package:yunji/personal/other_personal/other/other_personal/other_personal_page.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_page.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_background_image.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_head_portrait.dart';
import 'package:yunji/personal/personal/personal/personal_page/personal_page.dart';
import 'package:yunji/setting/setting_user/setting_user.dart';
import 'package:yunji/main/sqlite_init.dart';
import 'package:dio/dio.dart';

// 数据库管理
final databaseManager = DatabaseManager();

// 用户名管理
final userNameChangeManagement = Get.put(UserNameChangeManagement());

// 背景图管理
final backgroundImageChangeManagement =
    Get.put(BackgroundImageChangeManagement());

// 头像管理
final headPortraitChangeManagement = Get.put(HeadPortraitChangeManagement());

// 主页记忆库刷新
final refreshofHomepageMemoryBankextends =
    Get.put(RefreshofHomepageMemoryBankextends());

// 查看帖子记忆库数据管理
final viewPostDataManagementForMemoryBanks =
    Get.put(ViewPostDataManagementForMemoryBanks());

// 复习数据管理
final reviewDataManagement = Get.put(ReviewDataManagement());

// 继续学习数据管理
final continueLearningAboutDataManagement =
    Get.put(ContinueLearningAboutDataManagement());

// 信息列表滚动数据管理
final otherPeopleInformationListScrollDataManagement =
    Get.put(OtherPeopleInformationListScrollDataManagement());

// 其他用户个人信息管理
final otherPeoplePersonalInformationManagement =
    Get.put(OtherPeoplePersonalInformationManagement());

final userPersonalInformationManagement =
    Get.put(UserPersonalInformationManagement());

// 选择结果更新显示
final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());

// 编辑个人信息数据管理
final editPersonalDataValueManagement =
    Get.put(EditPersonalDataValueManagement());

// 用户信息列表滚动数据管理
final userInformationListScrollDataManagement =
    Get.put(UserInformationListScrollDataManagement());

final creatReviewController = Get.put(CreatReviewController());

final NotificationHelper notificationHelper = NotificationHelper();

// 登录状态
bool loginStatus = false;

final header = {'Content-Type': 'application/json'};

final dio = Dio();

String generateRandomFilename() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  return List.generate(10, (_) => chars[random.nextInt(chars.length)])
          .join('') +
      '.jpg';
}
