import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/version_model.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class BoxManagementController extends GetxController {
  MqttController mqttController = Get.find();
  HomeController homeController = Get.find();
  var boxes = <Box>[].obs;
  var selectedSortOption = "Cihaz Adı".obs;
  var selectedBox = Box().obs;
  var loadingBox = false.obs;

  var newVersion = VersionModel().obs;

  var espPins = [
    "D0",
    "D1",
    "D2",
    "D3",
    "D4",
    "D5",
    "D6",
    "D7",
    "D8",
  ];

  Future<void> checkNewVersion() async {
    loadingBox.value = true;
    var result = await BoxService.checkNewVersion();
    if (result != null) {
      newVersion.value = result;
    }
    loadingBox.value = false;
  }

  Future<void> getBoxes() async {
    loadingBox.value = true;
    boxes.clear();
    var allBoxes = await BoxService.getAll() ?? <Box>[];
    if (allBoxes.isNotEmpty) {
      if (homeController.selectedOrganisationId > 0) {
        boxes.value = allBoxes
            .where(
              (b) =>
                  b.organisationId ==
                  homeController.selectedOrganisationId.value,
            )
            .toList();
      } else {
        boxes.value = allBoxes;
      }
    }
    loadingBox.value = false;
  }

  int versionControl(String version) {
    int isOld = -2;
    print("nv:" + newVersion.value.version);
    print("cv:" + version);
    var nv = newVersion.value;
    if (nv.version.isNotEmpty) {
      var bv1 = int.tryParse(version.split(".")[0]) ?? 0;
      var nv1 = int.tryParse(nv.version.split(".")[0]) ?? 0;
      if (bv1 < nv1) {
        isOld = -1;
      } else if (bv1 == nv1) {
        var bv2 = int.tryParse(version.split(".")[1]) ?? 0;
        var nv2 = int.tryParse(nv.version.split(".")[1]) ?? 0;
        if (bv2 < nv2) {
          isOld = -1;
        } else if (bv2 == nv2) {
          isOld = 0;
        } else {
          isOld = 1;
        }
      } else {
        isOld = 1;
      }
    }
    return isOld;
  }

  void sortBoxes() {
    boxes.sort((a, b) {
      // int subComparison = a.isSub == b.isSub ? 0 : (a.isSub ? -1 : 1);
      // if (subComparison != 0) return subComparison;

      // int oldComparison = a.isOld == b.isOld ? 0 : (a.isOld == -1 ? -1 : 1);
      // if (oldComparison != 0) return oldComparison;

      return b.name.toLowerCaseTr().compareTo(a.name.toLowerCaseTr());
    });
  }

  Future<Box?> register(Box box) async {
    try {
      var response = await BoxService.add(box);
      if (response != null) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        boxes.add(response);
        sortBoxes();
        selectedBox.value = response;
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

  Future<void> updateBox(Box box) async {
    var response = await BoxService.update(box);
    if (response != null) {
      selectedBox.value = response;
      successSnackbar("Başarılı", "Bilgiler Güncellendi");
      return;
    }
    errorSnackbar("Başarısız", "Bilgiler Güncellenemedi");
  }

  Future<void> delete(int id) async {
    var response = await BoxService.delete(id);
    if (response) {
      boxes.remove(
        boxes.firstWhere(
          (b) => b.id == id,
        ),
      );
      sortBoxes();
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }
}
