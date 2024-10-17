import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final AuthController _authController = Get.find();

  var loadingDevices = false.obs;
  var devices = <Device>[].obs;

  var loadingOrganisations = false.obs;
  var organisations = <Organisation>[].obs;
  var selectedOrganisationId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getUserDevices();
    getOrganisations();
  }

  Future<void> getUserDevices() async {
    loadingDevices.value = true;
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getAllByUserId(id);
        if (response != null) {
          devices.value = response;
        }
      } catch (e) {
        errorSnackbar('Error', '1- Bir hata oluştu');
      } finally {
        loadingDevices.value = false;
      }
    }
  }

  List<Device> get controlDevices {
    return devices
        .where(
          (d) =>
              d.typeId == 4 || d.typeId == 5 || d.typeId == 6 || d.typeId == 9,
        )
        .toList();
  }

  List<Device> get sensorDevices {
    return devices
        .where(
          (d) => d.typeId == 1 || d.typeId == 2 || d.typeId == 3,
        )
        .toList();
  }

  List<Device> get gardenDevices {
    return devices
        .where(
          (d) => d.typeId == 8,
        )
        .toList();
  }

  void clearController() {
    devices.value = <Device>[];
  }

  Future<void> getOrganisations() async {
    loadingOrganisations.value = true;
    var result = await HomeService.getAllOrganisation();
    if (result != null) {
      organisations.value = result;
    }
    loadingOrganisations.value = false;
  }
}
