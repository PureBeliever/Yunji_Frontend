import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  Database? database;
  DatabaseManager() {
    initDatabase().then((db) {
      database = db;
    });
  }
  Future<Database> initDatabase() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) async {
        await db.transaction((txn) async {
          await _createPersonalTable(db);
          await _createIntDatabaseTable(db);
          await _createJiyikuTable(db);
          await _createPersonalJiyikuTable(db);
          await _createPersonalJiyikudianjiTable(db);
        });
      },
      version: 1,
    );
    return database;
  }

  Future<void> _createPersonalTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE personal_data( user_name  char(20)   PRIMARY KEY , name  char(50), introduction  char(170) ,residential_address  char(40), birth_time  char(15), background_image char(50), head_portrait char(50),join_date  char(15) ,like_list JSON,collect_list JSON,pull_list JSON,review_list JSON,reply_list JSON);',
    );
  }

  Future<void> _createIntDatabaseTable(Database txn) async {
    await txn.execute(
      'CREATE TABLE intdatabase (id BIGINT PRIMARY KEY, number LONGTEXT, length INT);',
    );
    List<int> number = [1];
    await txn.insert(
      'intdatabase',
      {'id': 0, 'number': number.toString(), 'length': 1},
      conflictAlgorithm: ConflictAlgorithm.replace,
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
      'Information_notification BOOL, '
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
