import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class UserManagementController extends GetxController {
  var users = <User>[].obs;
  var selectedSortOption = "Ad Soyad".obs;
  var selectedUser = User().obs;
  var searchQuery = "".obs;
  var loadingUser = false.obs;

  var operationClaims = <OperationClaim>[].obs;
  var userOperationClaims = <UserOperationClaim>[].obs;

  var boxes = <Box>[].obs;
  var filteredBoxes = <Box>[].obs;
  var selectedBoxId = 0.obs;
  var devices = <Device>[].obs;
  var filteredDevices = <Device>[].obs;
  var userDevices = <UserDevice>[].obs;

  var organisations = <Organisation>[].obs;
  var selectedOrganisationId = 0.obs;
  var userOrganisations = <UserOrganisation>[].obs;

  Future<void> getUsers() async {
    loadingUser.value = true;
    users.value = await UserService.getAll() ?? <User>[];
    loadingUser.value = false;
  }

  void sortUsers() {
    if (selectedSortOption.value == 'Sıra No') {
      users.sort((a, b) => a.id.compareTo(b.id));
    } else if (selectedSortOption.value == 'Ad Soyad') {
      users.sort((a, b) =>
          a.fullName.toLowerCaseTr().compareTo(b.fullName.toLowerCaseTr()));
    } else if (selectedSortOption.value == 'Kullanıcı Adı') {
      users.sort((a, b) =>
          a.userName.toLowerCaseTr().compareTo(b.userName.toLowerCaseTr()));
    }
  }

  Future<User?> register(User user) async {
    try {
      var response = await UserService.register(user);
      if (response != null) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        users.add(response);
        sortUsers();
        selectedUser.value = users.firstWhere((u) => u.id == response.id);
        return response;
      } else {
        errorSnackbar("Başarısız", "Kayıt yapılamadı");
        return null;
      }
    } catch (e) {
      errorSnackbar('Error', 'Bir hata oldu. Tekrar deneyin.');
      return null;
    }
  }

  Future<User?> saveAs(User user) async {
    try {
      var response = await UserService.saveAs(user);
      if (response != null) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        users.add(response);
        sortUsers();
        selectedUser.value = users.firstWhere((u) => u.id == response.id);
        getUserClaims();
        getUserOrganisations();
        getUserDevices();
        return response;
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
    if (response != null) {
      selectedUser.value = response;
      successSnackbar("Başarılı", "Bilgiler Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Bilgiler Güncellenemedi");
  }

  Future<void> delete(int id) async {
    var response = await UserService.delete(id);
    if (response) {
      users.remove(selectedUser.value);
      sortUsers();
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }

  Future<void> passUpdate(int id, String password) async {
    var response = await UserService.passwordUpdate(id, password);
    if (response) {
      successSnackbar("Başarılı", " Şifre Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Şifre Güncellenemedi");
  }

  Future<void> getOperationClaims() async {
    operationClaims.value =
        await HomeService.getAllOperationClaim() ?? <OperationClaim>[];
  }

  Future<void> getUserClaims() async {
    userOperationClaims.value =
        await UserService.getUserClaims(selectedUser.value.id) ??
            <UserOperationClaim>[];
  }

  Future<void> addUserClaim(int claimId) async {
    var result = await UserService.addUserClaim(selectedUser.value.id, claimId);
    if (result != null) {
      userOperationClaims.add(result);
    }
  }

  Future<void> deleteUserClaim(int userClaimId) async {
    var result = await UserService.deleteUserClaim(userClaimId);
    if (result) {
      userOperationClaims
          .remove(userOperationClaims.firstWhere((uc) => uc.id == userClaimId));
    }
  }

  Future<void> getBoxes() async {
    boxes.value = await BoxService.getAll() ?? <Box>[];
  }

  void filterBoxes() {
    selectedBoxId.value = 0;
    filteredBoxes.value = selectedOrganisationId.value == 0
        ? boxes
        : boxes
            .where((b) => b.organisationId == selectedOrganisationId.value)
            .toList();
    filteredDevices.value = devices
        .where((d) => filteredBoxes.any((b) => b.id == d.boxId))
        .toList();
  }

  Future<void> getDevices() async {
    devices.value = await DeviceService.getAll() ?? <Device>[];
  }

  void filterDevices() {
    filteredDevices.value = selectedBoxId.value == 0
        ? devices
            .where((d) => filteredBoxes.any((b) => b.id == d.boxId))
            .toList()
        : devices.where((d) => d.boxId == selectedBoxId.value).toList();
  }

  Future<void> getUserDevices() async {
    userDevices.value =
        await UserService.getUserDevices(selectedUser.value.id) ??
            <UserDevice>[];
  }

  Future<void> addUserDevice(int deviceId) async {
    var result =
        await UserService.addUserDevice(selectedUser.value.id, deviceId);
    print(result);
    if (result != null) {
      userDevices.add(result);
      filterDevices();
    }
  }

  Future<void> deleteUserDevice(int userDeviceId) async {
    var result = await UserService.deleteUserDevice(userDeviceId);
    print(result);
    if (result) {
      userDevices.remove(userDevices.firstWhere((ud) => ud.id == userDeviceId));
      filterDevices();
    }
  }

  Future<void> getOrganisations() async {
    organisations.value =
        await HomeService.getAllOrganisation() ?? <Organisation>[];
  }

  Future<void> getUserOrganisations() async {
    userOrganisations.value =
        await UserService.getUserOrganisations(selectedUser.value.id) ??
            <UserOrganisation>[];
  }

  Future<void> addUserOrganisation(int deviceId) async {
    var result =
        await UserService.addUserOrganisation(selectedUser.value.id, deviceId);
    if (result != null) {
      userOrganisations.add(result);
    }
  }

  Future<void> deleteUserOrganisation(int userOrganisationId) async {
    var result = await UserService.deleteUserOrganisation(userOrganisationId);
    if (result) {
      userOrganisations.remove(
          userOrganisations.firstWhere((uo) => uo.id == userOrganisationId));
    }
  }
}
