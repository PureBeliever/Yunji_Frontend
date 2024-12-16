import 'package:get/get.dart';
import 'package:yunji/fuxi/fuxi_page.dart';
import 'package:yunji/home/home_page/home_page.dart';
import 'package:yunji/jixv_fuxi/jixvfuxi_page.dart';
import 'package:yunji/jiyikudianji/jiyikudianji.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonal.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/personal/personal_bei.dart';
import 'package:yunji/personal/personal_head.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/sql/sqlite.dart';

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
final reviewTheDataManagementOfMemoryBank =
    Get.put(ReviewTheDataManagementOfMemoryBank());

// 继续学习数据管理
final continueLearningAboutDataManagement =
    Get.put(ContinueLearningAboutDataManagement());

// 信息列表滚动数据管理
final informationListScrollDataManagement =
    Get.put(InformationListScrollDataManagement());

final otherPeoplePersonalInformationManagement =
    Get.put(OtherPeoplePersonalInformationManagement());

final personaljiyikucontroller = Get.put(PersonaljiyikuController());

final selectorResultsUpdateDisplay = Get.put(SelectorResultsUpdateDisplay());

final editPersonalDataValueManagement = Get.put(EditPersonalDataValueManagement());



// 登录状态
bool loginStatus = false;
