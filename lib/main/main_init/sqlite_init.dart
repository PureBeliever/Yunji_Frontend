import 'dart:io';

import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseManager {
  late Database database;
  DatabaseManager() {
    initDatabase().then((db) {
      database = db;
    });
  }
  Future<Database> initDatabase() async {
    // 根据平台选择合适的数据库工厂
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isAndroid || Platform.isIOS) {
      // 移动平台使用默认的 sqflite 实现，不使用 FFI
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    } else {
      // 桌面平台（例如 Windows、macOS、Linux）使用 FFI 实现
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    }
    final database = await databaseFactory.openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      options: OpenDatabaseOptions(
        version: 1, // 添加版本号
        onCreate: (db, version) async {
          await _createPersonalTable(db);
          await _createJiyikuTable(db);
          await _createPersonalJiyikuTable(db);
          await _createPersonalJiyikudianjiTable(db);
        },
      ),
    );
    return database;
  }

  Future<void> _createPersonalTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE personal_data( user_name  char(20)   PRIMARY KEY , name  char(50), introduction  char(170) ,residential_address  char(40), birth_time  char(15), background_image char(50), head_portrait char(50),join_date  char(15) ,like_list JSON,collect_list JSON,pull_list JSON,review_list JSON,reply_list JSON);',
    );
  }

  Future<void> _createJiyikuTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE  memory_bank ('
      'user_name CHAR(20), '
      'name CHAR(50), '
      'head_portrait CHAR(50), '
      'id BIGINT PRIMARY KEY, '
      'question JSON, '
      'answer JSON, '
      'theme CHAR(50), '
      'subscript  JSON, '
      'collect  INT, '
      'pull INT, '
      'like INT, '
      'reply INT);',
    );
  }

  Future<void> _createPersonalJiyikuTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE personal_memory_bank ('
      'user_name CHAR(20), '
      'name CHAR(50), '
      'head_portrait CHAR(50), '
      'id BIGINT PRIMARY KEY, '
      'question JSON, '
      'answer JSON, '
      'theme CHAR(50), '
      'subscript  JSON, '
      'memory_time JSON, '
      'set_time CHAR(30), '
      'collect  INT, '
      'pull INT, '
      'like INT, '
      'reply INT, '
      'information_notification BOOL, '
      'alarm_notification BOOL, '
      'complete_state BOOL, '
      'review_record JSON, '
      'review_scheme_name CHAR(10));',
    );
  }

  Future<void> _createPersonalJiyikudianjiTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE  other_personal_memory_bank ('
      'user_name CHAR(20), '
      'name CHAR(50), '
      'head_portrait CHAR(50), '
      'id BIGINT PRIMARY KEY, '
      'question JSON, '
      'answer JSON, '
      'theme CHAR(50), '
      'subscript  JSON, '
      'collect  INT, '
      'pull INT, '
      'like INT, '
      'reply INT);',
    );
  }
}
