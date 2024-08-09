import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:get/get.dart';

class DeviceController extends GetxController {
  var deviceTypes = <DeviceType>[].obs;
  var boxWithDevices = <BoxWithDevices>[].obs;

  var controlDevices = <ControlDeviceModel>[].obs;
  var sensorDevices = <SensorDeviceModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getDeviceTypes();
    await getBoxesWithDevices();
  }

  Future<void> getDeviceTypes() async {
    try {
      var response = await DeviceService.getDeviceTypes();
      if (response != null) {
        deviceTypes.value = response;
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oluştu');
    }
  }

  Future<void> getBoxesWithDevices() async {
    var id = Get.find<UserController>().user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getUserDevices(id);
        if (response != null) {
          boxWithDevices.value = response;
        }
      } catch (e) {
        Get.snackbar('Error', 'Bir hata oluştu');
      }
    }
  }

  Future<void> getControlDevices() async {
    var uc = Get.find<UserController>();
    var id = uc.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getControlDevices(id, 0);
        if (response != null) {
          controlDevices.value = response;
        }
      } catch (e) {
        Get.snackbar('Error', 'Bir hata oluştu');
      }
    }
  }

  Future<void> getSensorDevices() async {
    var uc = Get.find<UserController>();
    var id = uc.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getSensorDevices(id);
        if (response != null) {
          sensorDevices.value = response;
        }
      } catch (e) {
        Get.snackbar('Error', 'Bir hata oluştu');
      }
    }
  }
}
