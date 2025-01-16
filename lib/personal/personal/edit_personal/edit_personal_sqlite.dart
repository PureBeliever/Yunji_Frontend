import 'package:yunji/global.dart';
import 'package:yunji/personal/personal/edit_personal/edit_personal_api.dart';

Future<void> updatePersonal(EditPersonalData personalData) async {

    try {
      await db.transaction((txn) async {
        await txn.execute(
          'UPDATE personal_data SET name = ?, introduction = ?, residential_address = ?, birth_time = ?, background_image = ?, head_portrait = ? WHERE user_name = ?',
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
      });
    } catch (e) {
      print('Error updating personal data: $e');
    }

}
