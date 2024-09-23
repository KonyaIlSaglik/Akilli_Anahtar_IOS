import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
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

  var controlDevices = <ControlDeviceModel>[].obs;
  var sensorDevices = <SensorDeviceModel>[].obs;
  var gardenDevices = <ControlDeviceModel>[].obs;

  Future<void> getControlDevices() async {
    print("loadingControlDevices");
    loadingControlDevices.value = true;
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getControlDevices(id, 1);
        if (response != null) {
          controlDevices.value = response;
        }
      } catch (e) {
        errorSnackbar('Error', '1- Bir hata oluştu');
      } finally {
        loadingControlDevices.value = false;
      }
    }
  }

  Future<void> getSensorDevices() async {
    loadingSensorDevices.value = true;
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getSensorDevices(id);
        if (response != null) {
          sensorDevices.value = response;
        }
      } catch (e) {
        errorSnackbar('Error', 'Sensorler Bir hata oluştu');
      } finally {
        loadingSensorDevices.value = false;
      }
    }
  }

  Future<void> getGardenDevices() async {
    print("loadingGardenDevices");
    loadingGardenDevices.value = true;
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getControlDevices(id, 3);
        if (response != null) {
          gardenDevices.value = response;
        }
      } catch (e) {
        errorSnackbar('Error', '1- Bir hata oluştu');
      } finally {
        loadingGardenDevices.value = false;
      }
    }
  }

  void clearController() {
    loadingDeviceTypes.value = false;
    loadingControlDevices.value = false;
    loadingSensorDevices.value = false;
    deviceTypes.value = <DeviceType>[];

    controlDevices.value = <ControlDeviceModel>[];
    sensorDevices.value = <SensorDeviceModel>[];
  }
}
