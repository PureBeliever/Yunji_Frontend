import 'package:yunji/main/app_global_variable.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_page/edit_personal_api.dart';


Future<void> updatePersonal(EditPersonalData personalData) async {
    final db = databaseManager.database;

    await db?.execute(
      'UPDATE personal_data SET name = ?, introduction= ?, residential_address = ?, birth_time = ?, background_image = ?, head_portrait = ? WHERE user_name = ?',
      [
        personalData.name,
        personalData.introduction,
        personalData.residentialAddress,
        personalData.birthTime,
        personalData.backgroundImage,
        personalData.headPortrait,
        personalData.userName,
      ],
    );
  }
