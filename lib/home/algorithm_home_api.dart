//试用的推荐算法，随机选择100个记忆库，请求过的记忆库的id，会被intdatabase减去，存储可以被请求的记忆库的id
//请求服务器，获取记忆库信息，更新主页记忆库
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/main/global.dart';
import 'package:yunji/home/home_sqlite.dart';
import 'package:yunji/main/main_module/show_toast.dart';
import 'package:yunji/main/main_init/app_sqlite.dart';
import 'package:yunji/personal/personal/personal/personal_api.dart';

// 刷新主页记忆库
Future<void> refreshHomePageMemoryBank(BuildContext context) async {
  try {
    await databaseManager.initDatabase(); // 确保数据库初始化
    // 获取存储记忆库id的数据库值
    final memoryBankInfo = await queryIdAndLength();
    List<int> number = List<int>.from(jsonDecode(memoryBankInfo["number"]));

    final randomSelection = <int>{};
    final random = Random();
    // 随机选择100个记忆库下标
    while (randomSelection.length < 100 && randomSelection.length < number.length) {
      randomSelection.add(number[random.nextInt(number.length)]);
    }

    final response = await dio.post(
      '$website/getTheHomePageMemoryLibrary',
      data: jsonEncode(randomSelection.toList()),
      options: Options(headers: header),
    );

    final data = response.data;

    final memoryBankResults = List<Map<String, dynamic>>.from(data["memoryBankResults"] ?? []);
    final personalValue = List<Map<String, dynamic>>.from(data["personalValue"] ?? []);

    final requestedValueId = List<int>.empty(growable: true);
    if (memoryBankResults.isEmpty) {
      showToast(
        context,
        "暂无更多记忆库",
        "让我们一起创建新的记忆库吧！",
        toast.ToastificationType.success,
        const Color(0xff047aff),
        const Color(0xFFEDF7FF),
      );
      return;
    }

    await _processPersonalValue(personalValue, memoryBankResults, requestedValueId);
    await insertHomePageMemoryBank(memoryBankResults);

    final memoryBankData = await queryHomePageMemoryBank();
    if (memoryBankData != null) {
      refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(memoryBankData);
    }

    int max = data["length"] + 2;
    int min = memoryBankInfo["length"];
    // 计算未请求的id列表
    final filterIdList = number.where((number) => !requestedValueId.contains(number)).toList();
    // 计算新的id列表
    final numbers = List.generate(max - min, (i) => i + min).cast<int>();

    // 将未请求的id列表和新的id列表合并
    filterIdList.addAll(numbers);
    // 更新intdatabase表
    await updateint(filterIdList.toString(), max);
  } catch (e) {
   
    print('刷新主页记忆库时发生错误: $e');
  }
}

Future<void> _processPersonalValue(List<dynamic> personalValue,
    List<dynamic> memoryBankResults, List<int> requestedValueId) async {
  for (final person in personalValue) {
    if (person['head_portrait'] != null) {
   
        final dir = await getApplicationDocumentsDirectory();
        final filename = generateRandomFilename();
        final imageBytes = base64.decode(person['head_portrait']);
        person['head_portrait'] = '${dir.path}/$filename';
        await File(person['head_portrait']).writeAsBytes(imageBytes);
    
    }

    for (final memory in memoryBankResults) {
      if (memory['user_name'] == person['user_name']) {
        requestedValueId.add(memory['id']);
        memory['name'] = person['name'];
        memory['head_portrait'] = person['head_portrait'];
      }
    }
  }
}

// 获取用户名

void getUserName() async {
  final response = await dio.get(
    '$website/getUserName',
    options: Options(headers: header),
  );
  final data = response.data;
  final userName = data['username'];
  requestTheUsersPersonalData(userName);
}
