import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:get/get.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/home_controller.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';
import 'package:akilli_anahtar/controllers/admin/box_management_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<NotificationFilterController>(NotificationFilterController(),
        permanent: true);
    Get.put<MqttController>(MqttController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<LoginController>(LoginController(), permanent: true);

    Get.put<BoxManagementController>(BoxManagementController(),
        permanent: true);
  }
}
