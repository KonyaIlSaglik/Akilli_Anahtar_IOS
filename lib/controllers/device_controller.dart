import 'package:akilli_anahtar/controllers/auth_controller.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/models/box_with_devices.dart';
import 'package:akilli_anahtar/models/control_device_model.dart';
import 'package:akilli_anahtar/models/sensor_device_model.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:akilli_anahtar/utils/hive_constants.dart';
import 'package:get/get.dart';

import '../services/local/i_cache_manager.dart';

class DeviceController extends GetxController {
  final AuthController _authController = Get.find();
  var controlDevicesManager = CacheManager<ControlDeviceModel>(
      HiveConstants.controlDevicesKey,
      HiveConstants.controlDevicesTypeId,
      ControlDeviceModelAdapter());
  var sensorDevicesManager = CacheManager<SensorDeviceModel>(
      HiveConstants.sensorDevicesKey,
      HiveConstants.sensorDevicesTypeId,
      SensorDeviceModelAdapter());

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
    loadingControlDevices.value = true;
    controlDevicesManager.init().then(
      (value) {
        var result = controlDevicesManager.getAll();
        if (result == null || result.isEmpty) {
          getControlDevices();
        } else {
          controlDevices.value = result;
          loadingControlDevices.value = false;
        }
      },
    );

    loadingSensorDevices.value = true;
    sensorDevicesManager.init().then(
      (value) {
        var result = sensorDevicesManager.getAll();
        if (result == null || result.isEmpty) {
          getSensorDevices();
        } else {
          sensorDevices.value = result;
          loadingSensorDevices.value = false;
        }
      },
    );
  }

  Future<void> getControlDevices() async {
    loadingControlDevices.value = true;
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getControlDevices(id, 1);
        if (response != null) {
          controlDevices.value = response;
          controlDevicesManager.clear();
          controlDevicesManager.addList(response);
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
    var id = _authController.user.value.id;
    if (id > 0) {
      try {
        var response = await DeviceService.getSensorDevices(id);
        if (response != null) {
          sensorDevices.value = response;
          sensorDevicesManager.clear();
          sensorDevicesManager.addList(response);
        }
      } catch (e) {
        Get.snackbar('Error', 'Sensorler Bir hata oluştu');
      } finally {
        loadingSensorDevices.value = false;
      }
    }
  }
}
