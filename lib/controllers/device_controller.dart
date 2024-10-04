import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';

class DeviceController extends GetxController {
  final AuthController _authController = Get.find();

  var loadingDeviceTypes = false.obs;
  var loadingControlDevices = false.obs;
  var loadingSensorDevices = false.obs;
  var loadingGardenDevices = false.obs;
  var deviceTypes = <DeviceType>[].obs;
  var devices = <Device>[].obs;

  Future<void> getUserDevices() async {
    print("loadingControlDevices");
    loadingControlDevices.value = true;
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
        loadingControlDevices.value = false;
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
    loadingDeviceTypes.value = false;
    loadingControlDevices.value = false;
    loadingSensorDevices.value = false;
    deviceTypes.value = <DeviceType>[];

    devices.value = <Device>[];
  }
}
