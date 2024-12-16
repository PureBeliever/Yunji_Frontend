import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Personal {
  final String? username;
  final String? name;
  final String? brief;
  final String? place;
  final String? year;
  final String? beijing;
  final String? touxiang;
  final String? jiaru;

  const Personal(
      {required this.username,
      required this.name,
      required this.brief,
      required this.place,
      required this.year,
      required this.beijing,
      required this.touxiang,
      required this.jiaru});

  Map<String, String?> toMap() {
    return {
      'username': username,
      'name': name,
      'brief': brief,
      'place': place,
      'year': year,
      'beijing': beijing,
      'touxiang': touxiang,
      'jiaru': jiaru,
    };
  }
}

class Personaljie {
  final String? username;
  final String? name;
  final String? brief;
  final String? place;
  final String? year;
  final String? beijing;
  final String? touxiang;
  final String? jiaru;
  final String? xihuan;
  final String? shoucang;
  final String? laqu;
  final String? tiwen;
  final String? wode;
  const Personaljie(
      {required this.shoucang,
      required this.laqu,
      required this.tiwen,
      required this.xihuan,
      required this.username,
      required this.name,
      required this.brief,
      required this.place,
      required this.year,
      required this.beijing,
      required this.touxiang,
      required this.jiaru,
      required this.wode});

  Map<String, String?> toMap() {
    return {
      'username': username,
      'name': name,
      'brief': brief,
      'place': place,
      'year': year,
      'beijing': beijing,
      'touxiang': touxiang,
      'jiaru': jiaru,
      'xihuan': xihuan,
      'shoucang': shoucang,
      'laqu': laqu,
      'tiwen': tiwen,
      'wode': wode
    };
  }
}

class DatabaseManager {
  Database? database;

  DatabaseManager() {
    initDatabase().then((db) {
      database = db;
    });
  }

  Future<Database> initDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'personal_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          ' CREATE TABLE personal(  shouji  char(15)  ,username  char(20)   PRIMARY KEY , name  char(50), brief  char(170) ,place  char(40), year  char(15), beijing char(50), touxiang  char(50), jiaru  char(15),xihuan JSON,shoucang JSON,laqu JSON,tiwen JSON,wode JSON);',
        );
        await db.execute(
          ' CREATE TABLE intdatabase ( id INTEGER PRIMARY KEY, number LONGTEXT,length INT);',
        );

        List<int> number = [1, 2, 3];
        await db.insert(
          'intdatabase',
          {'id': 0, 'number': number.toString(), 'length': 3},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        await db.execute(
          'CREATE TABLE jiyiku(username  char(20),name char(50), brief  char(170) , place  char(40), year  char(15), beijing char(50), touxiang  char(50), jiaru  char(15) ,id INT  PRIMARY KEY,timu JSON,huida JSON, zhuti char(50),xiabiao JSON,code JSON,shoucang int,laqu int,xihuan int ,tiwen int);',
        );
        await db.execute(
          'CREATE TABLE personaljiyiku(username  char(20),name char(50), brief  char(170) , place  char(40), year  char(15), beijing char(50), touxiang  char(50), jiaru  char(15) ,id INT  PRIMARY KEY,timu JSON,huida JSON, zhuti char(50),xiabiao JSON,code JSON,dingshi char(30),jindu int,shoucang int,laqu int,xihuan int ,tiwen int,duanxin bool,naozhong bool,zhuangtai bool ,cishu JSON,fanganming char(10));',
        );

        await db.execute(
          'CREATE TABLE personaljiyikudianji(username  char(20),name char(50), brief  char(170) , place  char(40), year  char(15), beijing char(50), touxiang  char(50), jiaru  char(15) ,id INT  PRIMARY KEY,timu JSON,huida JSON, zhuti char(50),xiabiao JSON,code JSON,shoucang int,laqu int,xihuan int ,tiwen int);',
        );
      },
      version: 1,
    );
    return database;
  }

  // 插入记忆库
  Future<void> insertHomePageMemoryBank(var memoryBankData) async {
    final db = database;

    memoryBankData.forEach((memoryBank) {
      memoryBank['timu'] = jsonEncode(memoryBank['timu']);
      memoryBank['huida'] = jsonEncode(memoryBank['huida']);
      memoryBank['code'] = jsonEncode(memoryBank['code']);

      db?.insert(
        'jiyiku',
        memoryBank,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // 插入其他人的个人记忆库
  Future<void> insertOtherPeoplePersonalMemoryBank(var memoryBankData) async {
    final db = database;

    memoryBankData.forEach((memoryBank) {
      memoryBank['timu'] = jsonEncode(memoryBank['timu']);
      memoryBank['huida'] = jsonEncode(memoryBank['huida']);
      memoryBank['code'] = jsonEncode(memoryBank['code']);

      db?.insert('personaljiyikudianji', memoryBank,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  // 插入用户个人记忆库
  Future<void> insertUserPersonalMemoryBank(var memoryBankData) async {
    final db = database;

    memoryBankData.forEach((memoryBank) {
      memoryBank['timu'] = jsonEncode(memoryBank['timu']);
      memoryBank['huida'] = jsonEncode(memoryBank['huida']);
      memoryBank['cishu'] = jsonEncode(memoryBank['cishu']);
      memoryBank['code'] = jsonEncode(memoryBank['code']);

      db?.insert('personaljiyiku', memoryBank,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  // 查询其他人的个人记忆库
  Future<List<Map<String, dynamic>>> queryOtherPeoplePersonalMemoryBank(
      List<int> ids) async {
    final db = database;
    //mysql查询语句
    String mysqlQueryStatement = ' id IN (${ids.map((id) => '?').join(',')})';

    List<dynamic> idList = ids.reversed.toList();
    final List<Map<String, dynamic>> memoryBank = await db!.query(
      'personaljiyikudianji',
      where: mysqlQueryStatement,
      whereArgs: idList,
    );
    //根据id排序
    final List<Map<String, dynamic>> sortedResults = idList
        .map((id) => memoryBank.firstWhere((row) => row['id'] == id))
        .toList();

    return sortedResults;
  }

  // 查询用户个人记忆库
  Future<List<Map<String, dynamic>>> queryUserPersonalMemoryBank(
      List<int> ids) async {
    final db = database;

    String mysqlQueryStatement = ' id IN (${ids.map((id) => '?').join(',')})';

    List<dynamic> idList = ids.reversed.toList();
    final List<Map<String, dynamic>> memoryBank = await db!.query(
      'personaljiyiku',
      where: mysqlQueryStatement,
      whereArgs: idList,
    );
    //根据id排序
    final List<Map<String, dynamic>> sortedResults = idList
        .map((id) => memoryBank.firstWhere((row) => row['id'] == id))
        .toList();

    return sortedResults;
  }

  // 查询主页记忆库
  Future<List<Map<String, dynamic>>> queryHomePageMemoryBank() async {
    final db = database;

    final List<Map<String, dynamic>> memoryBank = await db!.query(
      'jiyiku',
      orderBy: 'NULL',
    );
    return memoryBank;
  }

//更新记忆库被喜欢的数量
  Future<void> updateMemoryBankLikes(String username, String likes, int id,
      int likeslength, Map<String, dynamic> memoryBank) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET xihuan=? WHERE username= ?',
      [likes, username],
    );
    db?.insert(
      'personaljiyiku',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET xihuan=? WHERE id= ?',
      [likeslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET xihuan=? WHERE id= ?',
      [likeslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET xihuan=? WHERE id= ?',
      [likeslength, id],
    );
  }

//更新记忆库被收藏的数量
  Future<void> updateMemoryBankCollects(String username, String collects,
      int id, int collectslength, Map<String, dynamic> memoryBank) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET shoucang=? WHERE username= ?',
      [collects, username],
    );
    db?.insert(
      'personaljiyiku',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET shoucang=? WHERE id= ?',
      [collectslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET shoucang=? WHERE id= ?',
      [collectslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET shoucang=? WHERE id= ?',
      [collectslength, id],
    );
  }

//更新记忆库被拉取的数量
  Future<void> updateMemoryBankLags(String username, String lags, int id,
      int lagslength, Map<String, dynamic> memoryBank) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET laqu=? WHERE username= ?',
      [lags, username],
    );
    db?.insert(
      'personaljiyiku',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET laqu=? WHERE id= ?',
      [lagslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET laqu=? WHERE id= ?',
      [lagslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET laqu=? WHERE id= ?',
      [lagslength, id],
    );
  }

//更新记忆库被提问的数量
  Future<void> updateMemoryBankQuestions(String username, String questions,
      int id, int questionslength, Map<String, dynamic> memoryBank) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET tiwen=? WHERE username= ?',
      [questions, username],
    );
    db?.insert(
      'personaljiyiku',
      memoryBank,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET tiwen=? WHERE id= ?',
      [questionslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET tiwen=? WHERE id= ?',
      [questionslength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET tiwen=? WHERE id= ?',
      [questionslength, id],
    );
  }

//查询已经显示记忆库的id和数量
  Future<Map<String, dynamic>> chaint() async {
    final db = database;

    final List<Map<String, dynamic>> personalMaps =
        await db!.query('intdatabase');

    return personalMaps[0];
  }


  Future<void> updateint(String zhi, int length) async {
    final db = database;

    await db?.update(
      'intdatabase',
      {'number': zhi, 'length': length},
      where: 'id = ?',
      whereArgs: [0],
    );
  }


  Future<void> insertPersonalzhi(Personaljie personal) async {
    final db = database;
    await db?.insert(
      'personal',
      personal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updatePersonal(Personal personal) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET name = ?, brief = ?, place = ?, year = ?, beijing = ?, touxiang = ? WHERE username = ?',
      [
        personal.name,
        personal.brief,
        personal.place,
        personal.year,
        personal.beijing,
        personal.touxiang,
        personal.username,
      ],
    );
  }

  Future<void> updateusername(String username, String oldusername) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET username=? WHERE username = ?',
      [username, oldusername],
    );
  }

  Future<Map<String, dynamic>?> chapersonal() async {
    final db = database;

    final List<Map<String, dynamic>> personalMaps = await db!.query('personal');

    return personalMaps.isEmpty ? null : personalMaps[0];
  }
}
