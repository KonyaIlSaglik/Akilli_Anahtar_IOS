// import 'package:akilli_anahtar/models/page_model.dart';
// import 'package:akilli_anahtar/services/local/shared_prefences.dart';
// import 'package:get/get.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class PagerController extends GetxController {
//   var appVersion = "".obs;
//   var currentPage = "".obs;

//   @override
//   void onInit() async {
//     super.onInit();
//     currentPage.value = PageModel.groupedPage;
//     var page = await LocalDb.get("currentPage");
//     if (page != null && page == "1") {
//       currentPage.value = PageModel.groupedPage;
//       savePageChanges();
//     } else {
//       currentPage.value = PageModel.favoritePage;
//       savePageChanges();
//     }

//     PackageInfo.fromPlatform().then(
//       (info) {
//         appVersion.value = info.version;
//       },
//     );
//   }

//   savePageChanges() async {
//     await LocalDb.add(
//         "currentPage", currentPage.value == PageModel.favoritePage ? "0" : "1");
//   }
// }
