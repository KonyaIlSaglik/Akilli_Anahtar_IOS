import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/dtos/um_device_dto.dart';
import 'package:akilli_anahtar/dtos/um_organisation_dto.dart';
import 'package:akilli_anahtar/dtos/user_dto.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/services/api/user_management_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class UserManagementController extends GetxController {
  HomeController homeController = Get.find();

  ///

  var loadingUser = false.obs;
  var users = <UserDto>[].obs;
  var loadingOrganisations = false.obs;
  var organisationList = <Organisation>[].obs;
  var umOrganisations = <UmOrganisationDto>[].obs;
  var umListSelectedOrganisationId = 0.obs;
  var userSearchQuery = "".obs;
  var selectedSortOption = "Ad Soyad".obs;
  var filteredUsers = <UserDto>[].obs;
  var umSelectedUser = UserDto().obs;
  var umDevices = <UmDeviceDto>[].obs;

  Future<void> getUsers() async {
    loadingUser.value = true;
    users.value = await UserService.getAll() ?? <UserDto>[];
    filterUsers();
    loadingUser.value = false;
  }

  Future<void> getAllOrganisations() async {
    loadingOrganisations.value = true;
    organisationList.value =
        await HomeService.getAllOrganisation() ?? <Organisation>[];
    loadingOrganisations.value = false;
  }

  void filterUsers() {
    var list = umListSelectedOrganisationId.value == 0
        ? users
        : users
            .where(
              (u) => u.organisationId == umListSelectedOrganisationId.value,
            )
            .toList();
    filteredUsers.value = userSearchQuery.value.isEmpty
        ? list
        : list
            .where((u) =>
                u.fullName!
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()) ||
                u.userName!
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()) ||
                u.id
                    .toString()
                    .toLowerCaseTr()
                    .contains(userSearchQuery.value.toLowerCase()))
            .toList();
    sortUsers();
  }

  void sortUsers() {
    if (selectedSortOption.value == userOrderItems[0]) {
      filteredUsers.sort((a, b) => a.id!.compareTo(b.id!));
    } else if (selectedSortOption.value == userOrderItems[1]) {
      filteredUsers.sort((a, b) =>
          a.fullName!.toLowerCaseTr().compareTo(b.fullName!.toLowerCaseTr()));
    } else if (selectedSortOption.value == userOrderItems[2]) {
      filteredUsers.sort((a, b) =>
          a.userName!.toLowerCaseTr().compareTo(b.userName!.toLowerCaseTr()));
    }
  }

  Future<void> getAllDevices() async {
    umDevices.value =
        await UserManagementService.getAllDevices(umSelectedUser.value.id!) ??
            <UmDeviceDto>[];
    sortUmDevices();
  }

  Future<void> sortUmDevices() async {
    umDevices.sort((a, b) {
      // userAdded durumuna göre sıralama
      if (a.userAdded == true && b.userAdded != true) {
        return -1; // a üstte gelsin
      } else if (a.userAdded != true && b.userAdded == true) {
        return 1; // b üstte gelsin
      }

      // BoxName göre sıralama
      final boxNameComparison =
          a.boxName!.toLowerCase().compareTo(b.boxName!.toLowerCase());
      if (boxNameComparison != 0) {
        return boxNameComparison; // BoxName farklıysa, sıralamayı burada yap
      }

      // userAdded'lar arasında alfabetik sıralama
      return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
    });
  }

  Future<void> addUserDevice(int deviceId) async {
    var result = await UserManagementService.addUserDevice(
        umSelectedUser.value.id!, deviceId);
    if (result) {
      umDevices.singleWhere((o) => o.id == deviceId).userAdded = true;
      sortUmDevices();
    }
  }

  Future<void> deleteUserDevice(int deviceId) async {
    var result = await UserManagementService.deleteUserDevice(
        umSelectedUser.value.id!, deviceId);
    if (result) {
      umDevices.singleWhere((o) => o.id == deviceId).userAdded = false;
      sortUmDevices();
    }
  }

  Future<void> getAllOrganisationsWithUserAdded() async {
    umOrganisations.value = await UserManagementService.getAllOrganisations(
            umSelectedUser.value.id!) ??
        <UmOrganisationDto>[];
    sortUmOrganisations();
  }

  void sortUmOrganisations() {
    umOrganisations.sort((a, b) {
      if (a.userAdded! && !b.userAdded!) {
        return -1; // a üstte gelsin
      } else if (!a.userAdded! && b.userAdded!) {
        return 1; // b üstte gelsin
      } else {
        // userAdded'lar arasında alfabetik sıralama
        return a.name!.toLowerCaseTr().compareTo(b.name!.toLowerCaseTr());
      }
    });
  }

  Future<void> addUserOrganisation(int organisationId) async {
    var result = await UserManagementService.addUserOrganisation(
        umSelectedUser.value.id!, organisationId);
    if (result) {
      umOrganisations.singleWhere((o) => o.id == organisationId).userAdded =
          true;
      umOrganisations.refresh();
    }
  }

  Future<void> deleteUserOrganisation(int organisationId) async {
    var result = await UserManagementService.deleteUserOrganisation(
        umSelectedUser.value.id!, organisationId);
    if (result) {
      for (var d in umDevices) {
        if (d.organisationId == organisationId && (d.userAdded ?? false)) {
          await deleteUserDevice(d.id!);
        }
      }
      umOrganisations.singleWhere((o) => o.id == organisationId).userAdded =
          false;
      umOrganisations.refresh();
    }
  }

  Future<int?> register(UserDto user) async {
    try {
      user.id = 0;
      var response = await UserService.register(user);
      if (response != null) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        users.add(response);
        filterUsers();
        return response.id;
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
      successSnackbar("Başarılı", "Bilgiler Güncellendi");
      filterUsers();
      return;
    }
    errorSnackbar("Başarısız", "Bilgiler Güncellenemedi");
  }

  Future<void> delete(int id) async {
    var response = await UserService.delete(id);
    if (response) {
      users.remove(users.singleWhere((u) => u.id == id));
      filterUsers();
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }
}

const userOrderItems = <String>['Sıra No', 'Ad Soyad', 'Kullanıcı Adı'];
