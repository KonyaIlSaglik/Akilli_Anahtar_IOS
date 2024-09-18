import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class UserController extends GetxController {
  var loadingUser = false.obs;
  var users = <User>[].obs;
  var selectedUser = User().obs;

  Future<void> getAll() async {
    loadingUser.value = true;
    var result = await UserService.getAll();
    if (result != null) {
      result.sort((a, b) =>
          a.fullName.toLowerCaseTr().compareToTr(b.fullName.toLowerCaseTr()));
      users.value = result;
      loadingUser.value = false;
    }
  }

  Future<User?> register(RegisterModel registerModel) async {
    try {
      var response = await UserService.register(registerModel);
      if (response.success) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        return response.data;
      } else {
        errorSnackbar("Başarısız", "Kayıt yapılamadı");
        return null;
      }
    } catch (e) {
      errorSnackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
      return null;
    }
  }

  Future<void> updateUser(User user) async {
    var response = await UserService.update(user);
    if (response.success) {
      successSnackbar("Başarılı", "Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Güncellenemedi");
  }

  Future<void> delete(User user) async {
    var response = await UserService.delete(user);
    if (response.success) {
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }
}
