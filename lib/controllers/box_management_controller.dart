import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/version_model.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class BoxManagementController extends GetxController {
  var boxes = <Box>[].obs;
  var selectedSortOption = "Name".obs;
  var selectedBox = Box().obs;
  var searchQuery = "".obs;
  var loadingBox = false.obs;

  var checkingNewVersion = false.obs;
  var newVersion = VersionModel().obs;

  Future<void> checkNewVersion() async {
    checkingNewVersion.value = true;
    newVersion.value = await BoxService.checkNewVersion();
    checkingNewVersion.value = false;
  }

  Future<void> getBoxes() async {
    loadingBox.value = true;
    boxes.value = await BoxService.getAll() ?? <Box>[];
    loadingBox.value = false;
  }

  void sortBoxes() {
    boxes.sort((a, b) {
      // First sort by isSub (true first)
      int subComparison = a.isSub == b.isSub ? 0 : (a.isSub ? -1 : 1);
      if (subComparison != 0) return subComparison;

      // If both isSub and box.name are the same, sort by isOld
      int oldComparison = a.isOld == b.isOld ? 0 : (a.isOld ? -1 : 1);
      if (oldComparison != 0) return oldComparison;

      // If isSub is the same, sort by box.name
      //int nameComparison =
      return b.name.toLowerCaseTr().compareTo(a.name.toLowerCaseTr());
      //if (nameComparison != 0) return nameComparison;
    });
  }

  Future<Box?> register(Box box) async {
    try {
      var response = await BoxService.add(box);
      if (response != null) {
        successSnackbar("Başarılı", "Kayıt yapıldı.");
        boxes.add(response);
        sortBoxes();
        selectedBox.value = boxes.firstWhere((u) => u.id == response.id);
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
      boxes.remove(selectedBox.value);
      sortBoxes();
      successSnackbar("Başarılı", "Silindi");
      return;
    }
    errorSnackbar("Başarısız", "Silinemedi");
  }
}
