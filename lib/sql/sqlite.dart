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
        //dingshi类型与后端不一样
        await db.execute(
          'CREATE TABLE personaljiyikudianji(username  char(20),name char(50), brief  char(170) , place  char(40), year  char(15), beijing char(50), touxiang  char(50), jiaru  char(15) ,id INT  PRIMARY KEY,timu JSON,huida JSON, zhuti char(50),xiabiao JSON,code JSON,shoucang int,laqu int,xihuan int ,tiwen int);',
        );
      },
      version: 1,
    );
    return database;
  }

  Future<void> insertjiyiku(var zhi) async {
    final db = database;

    zhi.forEach((xhi) {
      xhi['timu'] = jsonEncode(xhi['timu']);
      xhi['huida'] = jsonEncode(xhi['huida']);
      xhi['code'] = jsonEncode(xhi['code']);

      db?.insert(
        'jiyiku',
        xhi,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> insertpersonaljiyikudianji(var zhi) async {
    final db = database;

    zhi.forEach((xhi) {
      xhi['timu'] = jsonEncode(xhi['timu']);
      xhi['huida'] = jsonEncode(xhi['huida']);
      xhi['code'] = jsonEncode(xhi['code']);

      db?.insert('personaljiyikudianji', xhi,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> insertpersonaljiyiku(var zhi) async {
    final db = database;

    zhi.forEach((xhi) {
      xhi['timu'] = jsonEncode(xhi['timu']);
      xhi['huida'] = jsonEncode(xhi['huida']);
      xhi['cishu'] = jsonEncode(xhi['cishu']);
      xhi['code'] = jsonEncode(xhi['code']);

      db?.insert('personaljiyiku', xhi,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<List<Map<String, dynamic>>> chaxundianji(List<int> ids) async {
    final db = database;

    String whereClause = ' id IN (${ids.map((id) => '?').join(',')})';

    List<dynamic> whereArgs = ids.reversed.toList();
    final List<Map<String, dynamic>> jiyiku = await db!.query(
      'personaljiyikudianji',
      where: whereClause,
      whereArgs: whereArgs,
    );
    final List<Map<String, dynamic>> sortedResults =
        whereArgs.map((id) => jiyiku.firstWhere((row) => row['id'] == id)).toList();

    return sortedResults;
  }

  Future<List<Map<String, dynamic>>> chaxun(List<int> ids) async {
    final db = database;

    String whereClause = ' id IN (${ids.map((id) => '?').join(',')})';

    List<dynamic> whereArgs = ids.reversed.toList();
    final List<Map<String, dynamic>> jiyiku = await db!.query(
      'personaljiyiku',
      where: whereClause,
      whereArgs: whereArgs,
    );
    final List<Map<String, dynamic>> sortedResults =
        whereArgs.map((id) => jiyiku.firstWhere((row) => row['id'] == id)).toList();

    return sortedResults;
  }

  Future<List<Map<String, dynamic>>> chajiyiku() async {
    final db = database;

    final List<Map<String, dynamic>> jiyiku = await db!.query(
      'jiyiku',
      orderBy: 'NULL',
    );
    return jiyiku;
  }

  Future<void> updatepersonalxihuan(String username, String xihuan, int id,
      int xihuanlength, Map<String, dynamic> zhi) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET xihuan=? WHERE username= ?',
      [xihuan, username],
    );
    db?.insert(
      'personaljiyiku',
      zhi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET xihuan=? WHERE id= ?',
      [xihuanlength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET xihuan=? WHERE id= ?',
      [xihuanlength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET xihuan=? WHERE id= ?',
      [xihuanlength, id],
    );
  }

  Future<void> updatepersonalshoucang(String username, String shoucang, int id,
      int shoucanglength, Map<String, dynamic> zhi) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET shoucang=? WHERE username= ?',
      [shoucang, username],
    );
    db?.insert(
      'personaljiyiku',
      zhi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET shoucang=? WHERE id= ?',
      [shoucanglength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET shoucang=? WHERE id= ?',
      [shoucanglength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET shoucang=? WHERE id= ?',
      [shoucanglength, id],
    );
  }

  Future<void> updatepersonallaqu(String username, String laqu, int id,
      int laqulength, Map<String, dynamic> zhi) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET laqu=? WHERE username= ?',
      [laqu, username],
    );
    db?.insert(
      'personaljiyiku',
      zhi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET laqu=? WHERE id= ?',
      [laqulength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET laqu=? WHERE id= ?',
      [laqulength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET laqu=? WHERE id= ?',
      [laqulength, id],
    );
  }

  Future<void> updatepersonaltiwen(String username, String tiwen, int id,
      int tiwenlength, Map<String, dynamic> zhi) async {
    final db = database;

    await db?.execute(
      'UPDATE personal SET tiwen=? WHERE username= ?',
      [tiwen, username],
    );
    db?.insert(
      'personaljiyiku',
      zhi,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.execute(
      'UPDATE jiyiku SET tiwen=? WHERE id= ?',
      [tiwenlength, id],
    );
    await db?.execute(
      'UPDATE personaljiyiku SET tiwen=? WHERE id= ?',
      [tiwenlength, id],
    );
    await db?.execute(
      'UPDATE personaljiyikudianji SET tiwen=? WHERE id= ?',
      [tiwenlength, id],
    );
  }

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
