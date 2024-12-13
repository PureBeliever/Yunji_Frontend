import 'dart:convert';
import 'dart:io';
import 'dart:math';

// ignore: unused_import
import 'package:dio/dio.dart' as dios;
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yunji/personal/bianpersonal_page.dart';
import 'package:yunji/jiyikudianji/jiyikudianjipersonal.dart';
import 'package:yunji/main/main.dart';
import 'package:yunji/personal/personal_bei.dart';
import 'package:yunji/personal/personal_head.dart';
import 'package:yunji/personal/personal_page.dart';
import 'package:yunji/setting/setting_zhanghao_xiugai.dart';
import 'package:yunji/sql/sqlite.dart';

final dio = dios.Dio();

final bianpersonalController = Get.put(BianpersonalController());
final placecontroller = Get.put(Placecontroller());
final beicontroller = Get.put(Beicontroller());
final headcontroller = Get.put(Headcontroller());
final settingzhanghaoxiugaicontroller =
    Get.put(Settingzhanghaoxiugaicontroller());
final personaljiyikucontroller = Get.put(PersonaljiyikuController());
final personaljiyikudianjiController =
    Get.put(PersonaljiyikudianjiController());

void xiuzhanghao(String xinusername, String username) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'xinusername': xinusername,
    'username': username,
  };

  final response = await dio.put('http://47.92.90.93:36233/xiugai',
      data: jsonEncode(formdata), options: Options(headers: header));
  if (response.statusCode == 200) {
    databaseManager.updateusername(xinusername, username);
  }
}

void baocunjiyiku(
  Map<String, String> timu,
  Map<String, String> huida,
  String zhuti,
  String username,
  List<int> code,
  DateTime dingshi,
  List<int> xiabiao,
  bool duanxin,
  bool naozhong,
  bool zhuangtai,
  Map<String, String> cishu,
  String fanganming,
) async {
  Map<String, dynamic> formdata = {
    'username': username,
    'timu': timu,
    'huida': huida,
    'zhuti': zhuti,
    'code': code,
    'dingshi': dingshi.toString(),
    'xiabiao': xiabiao,
    'duanxin': duanxin,
    'naozhong': naozhong,
    'zhuangtai': zhuangtai,
    'cishu': cishu,
    'fanganming': fanganming
  };
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  String jsonformdata = jsonEncode(formdata);
  final response = await dio.post(
    'http://47.92.90.93:36233/baocunjiyiku',
    data: jsonformdata,
    options: Options(headers: header),
  );
  postpersonalapi(settingzhanghaoxiugaicontroller.username);
}

void xiugaijiyiku(
    Map<String, String> timu,
    Map<String, String> huida,
    int id,
    String zhuti,
    String username,
    List<int> code,
    DateTime dingshi,
    List<int> xiabiao,
    bool duanxin,
    bool naozhong,
    bool zhuangtai,
    Map<String, String> cishu,
    String fanganming) async {
  Map<String, dynamic> formdata = {
    'username': username,
    'timu': timu,
    'id': id,
    'huida': huida,
    'zhuti': zhuti,
    'code': code,
    'dingshi': dingshi.toString(),
    'xiabiao': xiabiao,
    'duanxin': duanxin,
    'naozhong': naozhong,
    'zhuangtai': zhuangtai,
    'cishu': cishu,
    'fanganming': fanganming
  };
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  print('执行');
  print(formdata);
  String jsonformdata = jsonEncode(formdata);
  final response = await dio.post(
    'http://47.92.90.93:36233/xiugaijiyiku',
    data: jsonformdata,
    options: Options(headers: header),
  );
  postpersonalapi(settingzhanghaoxiugaicontroller.username);
}

String _generateRandomFilename() {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  Random random = Random();
  String randomFileName =
      List.generate(10, (_) => chars[random.nextInt(chars.length)]).join('');
  return '$randomFileName.jpg';
}

void shouji(String shouji) async {
  denglu = true;
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'shouji': shouji,
  };

  final response = await dio.post('http://47.92.90.93:36233/shouji',
      data: jsonEncode(formdata), options: Options(headers: header));
  String? bei;
  String? tou;
  final dirqian = await getApplicationDocumentsDirectory();
  final dir = Directory(join(dirqian.path, 'personalimage'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  Map<String, dynamic> serverData = response.data;
  if (serverData['beijing'] != null) {
    final ming = _generateRandomFilename();
    bei = '${dir.path}/$ming';
    List<int> imageBytes = base64.decode(serverData['beijing']);
    await File(bei).writeAsBytes(imageBytes);
  }
  if (serverData['touxiang'] != null) {
    final ming = _generateRandomFilename();
    tou = '${dir.path}/$ming';
    List<int> imageBytes = base64.decode(serverData['touxiang']);
    await File(tou).writeAsBytes(imageBytes);
  }

  serverData.remove('beijing');
  serverData.remove('touxiang');
  var fido = Personaljie(
      tiwen: jsonEncode(serverData['tiwen']),
      laqu: jsonEncode(serverData['laqu']),
      wode: jsonEncode(serverData['wode']),
      shoucang: jsonEncode(serverData['shoucang']),
      xihuan: jsonEncode(serverData['xihuan']),
      username: serverData['username']!,
      name: serverData['name']!,
      brief: serverData['brief']!,
      place: serverData['place']!,
      year: serverData['year']!,
      beijing: bei,
      touxiang: tou,
      jiaru: serverData['jiaru']!);
  databaseManager.insertPersonalzhi(fido);
  placecontroller.riqi(serverData['year']!);
  placecontroller.weizhi(serverData['place']!);
  beicontroller.chushi(bei);
  headcontroller.chushi(tou);
  bianpersonalController.namevalue(
    serverData['name']!,
    serverData['brief']!,
    serverData['place']!,
    serverData['year']!,
  );
  settingzhanghaoxiugaicontroller.xiugaiusername(serverData['username']!);
  bianpersonalController.jiaruvalue(serverData['jiaru']!);
  postpersonalapi(settingzhanghaoxiugaicontroller.username);
}

void zhuce() async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  final response = await dio.get('http://47.92.90.93:36233/zhuce',
      options: Options(headers: header));
  String? bei;
  String? tou;
  final dirqian = await getApplicationDocumentsDirectory();
  final dir = Directory(join(dirqian.path, 'personalimage'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  Map<String, dynamic> serverData = response.data;
  if (serverData['beijing'] != null) {
    final ming = _generateRandomFilename();
    bei = '${dir.path}/$ming';
    List<int> imageBytes = base64.decode(serverData['beijing']);
    await File(bei).writeAsBytes(imageBytes);
  }
  if (serverData['touxiang'] != null) {
    final ming = _generateRandomFilename();
    tou = '${dir.path}/$ming';
    List<int> imageBytes = base64.decode(serverData['touxiang']);
    await File(tou).writeAsBytes(imageBytes);
  }

  serverData.remove('beijing');
  serverData.remove('touxiang');
  var fido = Personaljie(
      tiwen: jsonEncode(serverData['tiwen']),
      laqu: jsonEncode(serverData['laqu']),
      wode: jsonEncode(serverData['wode']),
      shoucang: jsonEncode(serverData['shoucang']),
      xihuan: jsonEncode(serverData['xihuan']),
      username: serverData['username']!,
      name: serverData['name']!,
      brief: serverData['brief']!,
      place: serverData['place']!,
      year: serverData['year']!,
      beijing: bei,
      touxiang: tou,
      jiaru: serverData['jiaru']!);
  databaseManager.insertPersonalzhi(fido);
  placecontroller.riqi(serverData['year']!);
  placecontroller.weizhi(serverData['place']!);
  beicontroller.chushi(bei);
  headcontroller.chushi(tou);
  bianpersonalController.namevalue(
    serverData['name']!,
    serverData['brief']!,
    serverData['place']!,
    serverData['year']!,
  );
  settingzhanghaoxiugaicontroller.xiugaiusername(serverData['username']!);
  bianpersonalController.jiaruvalue(serverData['jiaru']!);
  postpersonalapi(settingzhanghaoxiugaicontroller.username);
}

Future<String> imageFile(File imageFile) async {
  List<int> imageBytes = await imageFile.readAsBytes();
  String base64Image = base64Encode(imageBytes);
  return base64Image;
}

// ignore: non_constant_identifier_names
void PostHttp(String username, String name, String brief, String place,
    String year, File? beijing, File? touxiang) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = ({
    'username': username,
    'name': name,
    'brief': brief,
    'place': place,
    'year': year,
    'beijing': beijing == null ? null : await imageFile(beijing),
    'touxiang': touxiang == null ? null : await imageFile(touxiang)
  });

  final response = await dio.post('http://47.92.90.93:36233/personal',
      data: formdata, options: Options(headers: header));

  if (response.statusCode == 200) {
    String? bei = beicontroller.beiimage?.path;
    String? head = headcontroller.headimage?.path;
    if (beijing != null) {
      bei = beijing.path;
    }
    if (touxiang != null) {
      head = touxiang.path;
    }

    var fido = Personal(
        username: username,
        name: name,
        brief: brief,
        place: place,
        year: year,
        beijing: bei,
        touxiang: head,
        jiaru: null);

    databaseManager.updatePersonal(fido);
    postpersonalapi(settingzhanghaoxiugaicontroller.username);
  }
}

void duanxin(String shoujiyan) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'shouji': shoujiyan,
  };

  final response = await dio.post('http://47.92.90.93:36233/duanxin',
      data: jsonEncode(formdata), options: Options(headers: header));
}

void xihuanapi(String username, String xihuan, int id, int shuzhi) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = {
    'username': username,
    'xihuan': xihuan,
    'id': id,
    'shuzhi': shuzhi,
  };

  final response = await dio.post('http://47.92.90.93:36233/xihuan',
      data: jsonEncode(formdata), options: Options(headers: header));
}

void shoucangapi(String username, String shoucang, int id, int shuzhi) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = {
    'username': username,
    'shoucang': shoucang,
    'id': id,
    'shuzhi': shuzhi,
  };

  final response = await dio.post('http://47.92.90.93:36233/shoucang',
      data: jsonEncode(formdata), options: Options(headers: header));
}

void laquapi(String username, String laqu, int id, int shuzhi) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = {
    'username': username,
    'laqu': laqu,
    'id': id,
    'shuzhi': shuzhi,
  };

  final response = await dio.post('http://47.92.90.93:36233/laqu',
      data: jsonEncode(formdata), options: Options(headers: header));
}

void jiyikupostpersonalapi(String username) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {'username': username};

  final response = await dio.post('http://47.92.90.93:36233/postpersonaldianji',
      data: jsonEncode(formdata), options: Options(headers: header));
  final dirqian = await getApplicationDocumentsDirectory();
  final dir = Directory(join(dirqian.path, 'personaldianjiimage'));
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);

  final zhi = response.data;
  Map<String, dynamic> personalzhi = zhi['personalzhi'];
  if (zhi['results'] != null) {
    var result = zhi["results"];
    var personal = zhi["personal"];
    for (int i = 0; i < personal.length; i++) {
      if (personal[i]['beijing'] != null) {
        final ming = _generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['beijing']);
        personal[i]['beijing'] = '${dir.path}/$ming';
        await File(personal[i]['beijing']).writeAsBytes(imageBytes);
      }
      if (personal[i]['touxiang'] != null) {
        final ming = _generateRandomFilename();
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

    await databaseManager.insertpersonaljiyikudianji(result);

    personaljiyikudianjiController.apiqingqiu(personalzhi);
  }
}

void postpersonalapi(String username) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {'username': username};

  final response = await dio.post('http://47.92.90.93:36233/postpersonal',
      data: jsonEncode(formdata), options: Options(headers: header));
  final dirqian = await getApplicationDocumentsDirectory();
  final dir = Directory(join(dirqian.path, 'personalimage'));
  if (await dir.exists()) {
    await dir.delete(recursive: true);
  }
  await dir.create(recursive: true);

  final zhi = response.data;
  Map<String, dynamic> personalzhi = zhi['personalzhi'];
  var bei;
  var tou;

  if (personalzhi['beijing'] != null) {
    final ming = _generateRandomFilename();
    List<int> imageBytes = base64.decode(personalzhi['beijing']);
    bei = '${dir.path}/$ming';
    await File(bei).writeAsBytes(imageBytes);
  }

  if (personalzhi['touxiang'] != null) {
    final ming = _generateRandomFilename();
    List<int> imageBytes = base64.decode(personalzhi['touxiang']);
    tou = '${dir.path}/$ming';
    await File(tou).writeAsBytes(imageBytes);
  }

  final fido = Personaljie(
      shoucang: jsonEncode(personalzhi['shoucang']),
      laqu: jsonEncode(personalzhi['laqu']),
      tiwen: jsonEncode(personalzhi['tiwen']),
      xihuan: jsonEncode(personalzhi['xihuan']),
      username: personalzhi['username'],
      name: personalzhi['name'],
      brief: personalzhi['brief'],
      place: personalzhi['place'],
      year: personalzhi['year'],
      beijing: bei,
      touxiang: tou,
      jiaru: personalzhi['jiaru'],
      wode: jsonEncode(personalzhi['wode']));

  databaseManager.insertPersonalzhi(fido);
  placecontroller.riqi(personalzhi['year']!);
  placecontroller.weizhi(personalzhi['place']!);
  beicontroller.chushi(bei);
  headcontroller.chushi(tou);
  bianpersonalController.namevalue(
    personalzhi['name']!,
    personalzhi['brief']!,
    personalzhi['place']!,
    personalzhi['year']!,
  );

  settingzhanghaoxiugaicontroller.xiugaiusername(personalzhi['username']!);
  bianpersonalController.jiaruvalue(personalzhi['jiaru']!);

  if (zhi['results'] != null) {
    var result = zhi["results"];
    var personal = zhi["personal"];
    for (int i = 0; i < personal.length; i++) {
      if (personal[i]['beijing'] != null) {
        final ming = _generateRandomFilename();
        List<int> imageBytes = base64.decode(personal[i]['beijing']);
        personal[i]['beijing'] = '${dir.path}/$ming';
        await File(personal[i]['beijing']).writeAsBytes(imageBytes);
      }
      if (personal[i]['touxiang'] != null) {
        final ming = _generateRandomFilename();
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

    await databaseManager.insertpersonaljiyiku(result);
    personaljiyikucontroller.apiqingqiu(personalzhi);
  }
}

void tiwenapi(String username, String tiwen, int id, int shuzhi) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  Map<String, dynamic> formdata = {
    'username': username,
    'tiwen': tiwen,
    'id': id,
    'shuzhi': shuzhi,
  };

  final response = await dio.post('http://47.92.90.93:36233/tiwen',
      data: jsonEncode(formdata), options: Options(headers: header));
}

Future<Map<String, String>> image(String? bei, String? tou) async {
  Map<String, dynamic> formdata = ({
    'beijing': bei,
    'touxiang': tou,
  });
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };

  final response = await dio.post('http://47.92.90.93:36233/image',
      data: jsonEncode(formdata), options: Options(headers: header));
  String beijing = ' ';
  String touxiang = ' ';
  final dirqian = await getApplicationDocumentsDirectory();
  final dir = Directory(join(dirqian.path, 'personalimage'));
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final data = response.data;

  if (data['beijing'] != null) {
    final ming = _generateRandomFilename();
    List<int> imageBytes = base64.decode(data['beijing']);
    beijing = '${dir.path}/$ming';
    await File(beijing).writeAsBytes(imageBytes);
  }

  if (data['touxiang'] != null) {
    final ming = _generateRandomFilename();
    List<int> imageBytes = base64.decode(data['touxiang']);
    touxiang = '${dir.path}/$ming';
    await File(touxiang).writeAsBytes(imageBytes);
  }
  Map<String, String> uio = {'beijing': beijing, 'touxiang': touxiang};

  return uio;
}

Future<bool> yanzheng(String shoujiyan, String code) async {
  Map<String, String> header = {
    'Content-Type': 'application/json',
  };
  Map<String, dynamic> formdata = {
    'shouji': shoujiyan,
    'code': code,
  };

  bool zhi = false;
  final response = await dio.post('http://47.92.90.93:36233/code',
      data: jsonEncode(formdata), options: Options(headers: header));

  if (response.statusCode == 200) {
    zhi = true;
    Map<String, dynamic> serverData = response.data;

    String? bei = serverData['beijing'];
    String? tou = serverData['touxiang'];

    if (bei != null || tou != null) {
      Map<String, String> map = await image(bei, tou);
      bei = map['beijing'];
      tou = map['touxiang'];
    }

    var fido = Personaljie(
        tiwen: jsonEncode(serverData['tiwen']),
        wode: jsonEncode(serverData['wode']),
        laqu: jsonEncode(serverData['laqu']),
        shoucang: jsonEncode(serverData['shoucang']),
        xihuan: jsonEncode(serverData['xihuan']),
        username: serverData['username']!,
        name: serverData['name']!,
        brief: serverData['brief']!,
        place: serverData['place']!,
        year: serverData['year']!,
        beijing: bei,
        touxiang: tou,
        jiaru: serverData['jiaru']!);
    databaseManager.insertPersonalzhi(fido);
    placecontroller.riqi(serverData['year']!);
    placecontroller.weizhi(serverData['place']!);
    beicontroller.chushi(bei);
    headcontroller.chushi(tou);
    bianpersonalController.namevalue(
      serverData['name']!,
      serverData['brief']!,
      serverData['place']!,
      serverData['year']!,
    );
    settingzhanghaoxiugaicontroller.xiugaiusername(serverData['username']!);
    bianpersonalController.jiaruvalue(serverData['jiaru']!);
    postpersonalapi(settingzhanghaoxiugaicontroller.username);
  }
  return zhi;
}
