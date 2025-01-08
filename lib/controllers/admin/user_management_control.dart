import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
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
  HomeController homeController = Get.find();
  var users = <UserDto>[].obs;
  var filteredUsers = <UserDto>[].obs;
  var selectedSortOption = "Ad Soyad".obs;
  var selectedUser = UserDto().obs;
  var userSearchQuery = "".obs;
  var loadingUser = false.obs;

  var operationClaims = <OperationClaim>[].obs;
  var userOperationClaims = <UserOperationClaim>[].obs;

  var boxes = <Box>[].obs;
  var filteredBoxes = <Box>[].obs;
  var selectedBoxId = 0.obs;
  var devices = <Device>[].obs;
  var deviceSearchQuery = "".obs;
  var filteredDevices = <Device>[].obs;
  var userDevices = <UserDevice>[].obs;

  var userOrganisations = <UserOrganisation>[].obs;

  var organisationUsers = <UserOrganisation>[].obs;

  Future<void> getUsers() async {
    loadingUser.value = true;
    var allUsers = await UserService.getAll() ?? <UserDto>[];
    if (allUsers.isNotEmpty) {
      if (homeController.selectedOrganisationId > 0) {
        var result = await HomeService.getUserOrganisationsByOrganisationId(
            homeController.selectedOrganisationId.value);
        if (result != null) {
          organisationUsers.value = result;

          users.value = allUsers
              .where(
                (u) => organisationUsers.any(
                  (ou) => ou.userId == u.id,
                ),
              )
              .toList();
          filterUsers();
          loadingUser.value = false;
          return;
        }
      }
      users.value = allUsers;
    }
    filterUsers();
    loadingUser.value = false;
  }

  void sortUsers() {
    if (selectedSortOption.value == userOrderItems[0]) {
      users.sort((a, b) => a.id.compareTo(b.id));
    } else if (selectedSortOption.value == userOrderItems[1]) {
      users.sort((a, b) =>
          a.fullName.toLowerCaseTr().compareTo(b.fullName.toLowerCaseTr()));
    } else if (selectedSortOption.value == userOrderItems[2]) {
      users.sort((a, b) =>
          a.userName.toLowerCaseTr().compareTo(b.userName.toLowerCaseTr()));
    }
  }

  void filterUsers() {
    filteredUsers.value = userSearchQuery.value.isEmpty
        ? users
        : users
            .where((u) =>
                u.fullName
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()) ||
                u.userName
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()) ||
                u.id
                    .toString()
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()))
            .toList();
  }

  Future<UserDto?> register(UserDto user) async {
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

  Future<UserDto?> saveAs(UserDto user) async {
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

  Future<void> updateUser(UserDto user) async {
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

  Future<void> getDevices() async {
    devices.value = await DeviceService.getAll() ?? <Device>[];
    for (var device in devices) {
      device.boxName = boxes
          .singleWhere(
            (b) => b.id == device.boxId,
          )
          .name;
    }
  }

  void filterDevices() {
    var list = devices
        .where(
          (d) => userOrganisations.any(
            (uo) => uo.organisationId == d.organisationId,
          ),
        )
        .toList();

    var value = deviceSearchQuery.value.toLowerCaseTr();
    filteredDevices.value = deviceSearchQuery.value.isEmpty
        ? list
        : list
            .where((d) =>
                d.name.toLowerCaseTr().contains(value) ||
                d.boxName!.toLowerCaseTr().contains(value))
            .toList();
  }

  Future<void> getUserDevices() async {
    userDevices.value =
        await UserService.getUserDevices(selectedUser.value.id) ??
            <UserDevice>[];
  }

  Future<void> addUserDevice(int deviceId) async {
    var result =
        await UserService.addUserDevice(selectedUser.value.id, deviceId);
    if (result != null) {
      userDevices.add(result);
    }
  }

  Future<void> deleteUserDevice(int userDeviceId) async {
    var result = await UserService.deleteUserDevice(userDeviceId);
    if (result) {
      userDevices.remove(userDevices.firstWhere((ud) => ud.id == userDeviceId));
    }
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

const userOrderItems = <String>['Sıra No', 'Ad Soyad', 'Kullanıcı Adı'];
