
//试用的推荐算法，随机选择100个记忆库，请求过的记忆库的id，会被intdatabase减去，存储可以被请求的记忆库的id
//请求服务器，获取记忆库信息，更新主页记忆库
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart' as toast;
import 'package:yunji/api/personal_api.dart';
import 'package:yunji/main/app_global_variable.dart';




// 刷新主页记忆库
Future<void> refreshHomePageMemoryBank(BuildContext context) async {
  await databaseManager.initDatabase(); // 确保数据库初始化
  await Future.delayed(const Duration(seconds: 1));
//获取存储记忆库id的数据库值
  Map<String, dynamic> theIdOfTheMemoryBankThatWasObtained =
      await databaseManager.chaint();
//上一次请求的记忆库中的最后一个记忆库的id值
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
  List<int> zhiList = randomSelection.toList();
  final response = await dio.post('http://47.92.90.93:36233/getjiyiku',
      data: jsonEncode(zhiList), options: Options(headers: header));

  var data = response.data;
  var result = data["results"];
  var personal = data["personal"];

  if (result.isEmpty) {
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
    String generateRandomFilename() {
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      Random random = Random();
      String randomFileName =
          List.generate(10, (_) => chars[random.nextInt(chars.length)])
              .join('');
      return '$randomFileName.jpg';
    }

    for (int i = 0; i < personal.length; i++) {
      if (personal[i]['beijing'] != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ming = generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['beijing']);
        personal[i]['beijing'] = '${dir.path}/$ming';
        await File(personal[i]['beijing']).writeAsBytes(imageBytes);
      }
      if (personal[i]['touxiang'] != null) {
        final dir = await getApplicationDocumentsDirectory();
        final ming = generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['touxiang']);
        personal[i]['touxiang'] = '${dir.path}/$ming';
        await File(personal[i]['touxiang']).writeAsBytes(imageBytes);
      }

      for (int y = 0; y < result.length; y++) {
        if (result[y]['username'] == personal[i]['username']) {
          result[y]['name'] = personal[i]['name'];
          result[y]['brief'] = personal[i]['brief'];
          result[y]['place'] = personal[i]['place'];
          result[y]['year'] = personal[i]['year'];
          result[y]['beijing'] = personal[i]['beijing'];
          result[y]['touxiang'] = personal[i]['touxiang'];
          result[y]['jiaru'] = personal[i]['jiaru'];
        }
      }
    }

    await databaseManager.insertHomePageMemoryBank(result);
    List<Map<String, dynamic>>? mainzhi =
        await databaseManager.queryHomePageMemoryBank();

    refreshofHomepageMemoryBankextends.updateMemoryRefreshValue(mainzhi);
  }

  var count = data["count"];
  List<int> filterweizhi = numberAsList
      .where((number) => !randomSelection.contains(number))
      .toList();

  int lengthjiyi = theIdOfTheMemoryBankThatWasObtained["length"];
  final zuidazhi = count - theIdOfTheMemoryBankThatWasObtained["length"];
  List<int> numbers = List.generate(zuidazhi, (i) => i + lengthjiyi + 1);
  filterweizhi.addAll(numbers);

  await databaseManager.updateint(filterweizhi.toString(), count);
}
