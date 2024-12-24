//试用的推荐算法，随机选择100个记忆库，请求过的记忆库的id，会被intdatabase减去，存储可以被请求的记忆库的id
//请求服务器，获取记忆库信息，更新主页记忆库
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart' as toast;

import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/home/home_sqlite.dart';

// 刷新主页记忆库
Future<void> refreshHomePageMemoryBank(BuildContext context) async {
  await databaseManager.initDatabase(); // 确保数据库初始化
  await Future.delayed(const Duration(seconds: 1));
//获取存储记忆库id的数据库值

  Map<String, dynamic> theIdOfTheMemoryBankThatWasObtained =
      await queryIdAndLength();
//上一次请求的记忆库中的最后一个记忆库的id值
print(theIdOfTheMemoryBankThatWasObtained);
  String lastId = theIdOfTheMemoryBankThatWasObtained["number"];
//这次请求记忆库的id值
  int thisTimeTheIdValueOfTheMemoryIsRequested =
      theIdOfTheMemoryBankThatWasObtained["length"] + 1;
  lastId = "[$thisTimeTheIdValueOfTheMemoryIsRequested]";

  List<int> numberAsList = lastId
      .replaceAll('[', '')
      .replaceAll(']', '')
      .split(',')
      .map((String num) => int.parse(num.trim()))
      .toList();

  Random random = Random();
  Set<int> randomSelection = {};

  while (randomSelection.length < 100 &&
      randomSelection.length < numberAsList.length) {
    int index = random.nextInt(numberAsList.length);
    randomSelection.add(numberAsList[index]);
  }

  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  List<int> idList = randomSelection.toList();
  final response = await dio.post(
      'http://47.92.98.170:36233/getTheHomePageMemoryLibrary',
      data: jsonEncode(idList),
      options: Options(headers: header));

  var data = response.data;
  var memoryBankResults = data["memoryBankResults"];
  var personalValue = data["personalValue"];

  if (memoryBankResults == null) {
    toast.toastification.show(
        context: context,
        type: toast.ToastificationType.success,
        style: toast.ToastificationStyle.flatColored,
        title: const Text("暂无更多记忆库",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17)),
        description: const Text(
          "让我们一起创建新的记忆库吧！",
          style: TextStyle(
              color: Color.fromARGB(255, 119, 118, 118),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 4),
        primaryColor: const Color(0xff047aff),
        backgroundColor: const Color(0xffedf7ff),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: toast.lowModeShadow,
        dragToClose: true);
  } else {
    for (int i = 0; i < personalValue.length; i++) {
      if (personalValue[i]['head_portrait'] != null) {
        final dir = await getApplicationDocumentsDirectory();
        final filename = generateRandomFilename();
        List<int> imageBytes = base64.decode(personalValue[i]['head_portrait']);
        personalValue[i]['head_portrait'] = '${dir.path}/$filename';
        await File(personalValue[i]['head_portrait']).writeAsBytes(imageBytes);
      }

      for (int y = 0; y < memoryBankResults.length; y++) {
        if (memoryBankResults[y]['user_name'] ==
            personalValue[i]['user_name']) {
          memoryBankResults[y]['name'] = personalValue[i]['name'];
          memoryBankResults[y]['head_portrait'] =
              personalValue[i]['head_portrait'];
        }
      }
    }

    await insertHomePageMemoryBank(memoryBankResults);
    List<Map<String, dynamic>>? memoryBankData =
        await queryHomePageMemoryBank();

    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(memoryBankData);

    var count = data["length"];
    List<int> filterIdList = numberAsList
        .where((number) => !randomSelection.contains(number))
        .toList();

    int memoryBankLength = theIdOfTheMemoryBankThatWasObtained["length"];
    final differenceValue = count - memoryBankLength;
    List<int> numbers =
        List.generate(differenceValue, (i) => i + memoryBankLength + 1);
    filterIdList.addAll(numbers);

    await updateint(filterIdList.toString(), count);
  }
}
