import 'package:akilli_anahtar/controllers/user_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:get/get.dart';

class DeviceController extends GetxController {
  var loadingDeviceTypes = false.obs;
  var loadingControlDevices = false.obs;
  var loadingSensorDevices = false.obs;
  var deviceTypes = <DeviceType>[].obs;
  var boxWithDevices = <BoxWithDevices>[].obs;

  var controlDevices = <ControlDeviceModel>[].obs;
  var sensorDevices = <SensorDeviceModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    await getDeviceTypes();
    await getControlDevices();
    await getSensorDevices();
    //await getBoxesWithDevices();
  }

  Future<void> getDeviceTypes() async {
    loadingDeviceTypes.value = true;
    try {
      var response = await DeviceService.getDeviceTypes();
      if (response != null) {
        deviceTypes.value = response;
      }
    } catch (e) {
      Get.snackbar('Error', 'Bir hata oluştu');
    } finally {
      loadingDeviceTypes.value = false;
    }
  }

  // Future<void> getBoxesWithDevices() async {
  //   var id = Get.find<UserController>().user.value.id;
  //   if (id > 0) {
  //     try {
  //       var response = await DeviceService.getUserDevices(id);
  //       if (response != null) {
  //         boxWithDevices.value = response;
  //       }
  //     } catch (e) {
  //       Get.snackbar('Error', 'Bir hata oluştu');
  //     }
  //   }
  // }

  Future<void> getControlDevices() async {
    loadingControlDevices.value = true;
    var uc = Get.find<UserController>();
    var id = uc.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getControlDevices(id, 1);
        if (response != null) {
          controlDevices.value = response;
        }
      } catch (e) {
        Get.snackbar('Error', '1- Bir hata oluştu');
      } finally {
        loadingControlDevices.value = false;
      }
    }
  }

  Future<void> getSensorDevices() async {
    loadingSensorDevices.value = true;
    var uc = Get.find<UserController>();
    var id = uc.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getSensorDevices(id);
        if (response != null) {
          sensorDevices.value = response;
        }
      } catch (e) {
        Get.snackbar('Error', 'Sensorler Bir hata oluştu');
      } finally {
        loadingSensorDevices.value = false;
      }
    }
  }
}
