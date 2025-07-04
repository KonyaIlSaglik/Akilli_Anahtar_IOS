import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.put(NotificationFilterController(), permanent: true);
  }
}
