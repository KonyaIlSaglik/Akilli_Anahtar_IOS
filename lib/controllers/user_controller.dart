import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/models/register_model.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class UserController extends GetxController {
  var loadingUser = false.obs;
  var users = <User>[].obs;
  var selectedUser = User().obs;
  var searchQuery = "".obs;
  var selectedUserClaims = <UserOperationClaim>[].obs;
  var selectedUserDevices = <UserDevice>[].obs;

  Future<void> getAll() async {
    loadingUser.value = true;
    var result = await UserService.getAll();
    if (result != null) {
      users.value = result;
      sort();
      loadingUser.value = false;
    }
  }

  void sort() {
    users.sort((a, b) =>
        a.fullName.toLowerCaseTr().compareToTr(b.fullName.toLowerCaseTr()));
  }

  Future<User?> register(RegisterModel registerModel) async {
    try {
      var response = await UserService.register(registerModel);
      if (response.success) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        users.add(response.data!);
        sort();
        selectedUser.value = users.firstWhere((u) => u.id == response.data!.id);
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
      selectedUser.value = response.data!;
      successSnackbar("Başarılı", "Bilgiler Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Bilgiler Güncellenemedi");
  }

  Future<void> delete(int id) async {
    var response = await UserService.delete(id);
    if (response.success) {
      users.remove(selectedUser.value);
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }

  Future<void> passUpdate(int id, String password) async {
    var response = await UserService.passUpdate(id, password);
    if (response.success) {
      successSnackbar("Başarılı", " Şifre Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Şifre Güncellenemedi");
  }
}
