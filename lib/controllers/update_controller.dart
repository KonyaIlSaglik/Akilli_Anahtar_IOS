import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:get/get.dart';

class UpdateController extends GetxController {
  var newVersion = "".obs;

  @override
  void onInit() async {
    super.onInit();
    await checkNewVersion();
  }

  Future<void> checkNewVersion() async {
    newVersion.value = await BoxService.checkNewVersion();
  }
}
