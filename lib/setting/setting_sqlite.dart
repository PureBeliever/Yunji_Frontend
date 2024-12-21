import 'package:yunji/main/app_global_variable.dart';
 
 Future<void> updateUserName(String username, String oldusername) async {
    final db = databaseManager.database;

    await db?.execute(
      'UPDATE personal SET user_name=? WHERE user_name = ?',
      [username, oldusername],
    );
  }