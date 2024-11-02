import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class PagerController extends GetxController {
  var appVersion = "".obs;
  var currentPage = "".obs;

  @override
  void onInit() async {
    super.onInit();
    currentPage.value = groupedPage;
    var page = await LocalDb.get("currentPage");
    if (page != null) {
      currentPage.value = page;
    }

    PackageInfo.fromPlatform().then(
      (info) {
        appVersion.value = info.version;
      },
    );
  }

  savePageChanges() async {
    await LocalDb.add("currentPage", currentPage.value);
  }
}
