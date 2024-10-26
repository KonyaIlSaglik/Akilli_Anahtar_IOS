import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find();

  var currentPage = homePage.obs;
  var selectedOrganisationId = 0.obs;

  List<Device> get controlDevices {
    var cd = _authController.devices
        .where(
          (d) =>
              d.typeId == 4 || d.typeId == 5 || d.typeId == 6 || d.typeId == 9,
        )
        .toList();
    return selectedOrganisationId.value == 0 ? cd : cd;
  }

  List<Device> get sensorDevices {
    return _authController.devices
        .where(
          (d) => d.typeId == 1 || d.typeId == 2 || d.typeId == 3,
        )
        .toList();
  }

  List<Device> get gardenDevices {
    return _authController.devices
        .where(
          (d) => d.typeId == 8,
        )
        .toList();
  }

  void clearController() {
    _authController.devices.value = <Device>[];
  }
}
