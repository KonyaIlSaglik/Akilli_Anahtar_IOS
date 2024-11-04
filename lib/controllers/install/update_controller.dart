import 'package:akilli_anahtar/models/box_update_model.dart';
import 'package:akilli_anahtar/models/version_model.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class UpdateController extends GetxController {
  var checkingNewVersion = false.obs;
  var loadingBoxList = false.obs;
  var newVersion = VersionModel().obs;
  var boxList = <BoxUpdateModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await checkNewVersion();
    await getBoxList();
  }

  Future<void> checkNewVersion() async {
    checkingNewVersion.value = true;
    //newVersion.value = await BoxService.checkNewVersion();
    checkingNewVersion.value = false;
  }

  Future<void> getBoxList() async {
    loadingBoxList.value = true;
    var result = await BoxService.getAll();
    if (result != null) {
      boxList.value = result.map((e) => BoxUpdateModel(box: e)).toList();
    }
    loadingBoxList.value = false;
  }

  void sortBoxList() {
    boxList.sort((a, b) {
      int subComparison = a.isSub == b.isSub ? 0 : (a.isSub ? -1 : 1);
      if (subComparison != 0) return subComparison;

      int oldComparison = a.isOld == b.isOld ? 0 : (a.isOld ? -1 : 1);
      if (oldComparison != 0) return oldComparison;

      return b.box.name.toLowerCaseTr().compareTo(a.box.name.toLowerCaseTr());
    });
  }
}
