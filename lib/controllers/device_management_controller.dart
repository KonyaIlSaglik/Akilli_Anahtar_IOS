import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:get/get.dart';

class DeviceManagementController extends GetxController {
  var loading = false.obs;
  var deviceTypes = <DeviceType>[].obs;
  var selectedType = DeviceType().obs;
  var devices = <Device>[].obs;
  var selectedDevice = Device().obs;
  Future<void> getAllByBoxId(int id) async {
    loading.value = true;
    var result = await DeviceService.getAllByBoxId(id);
    if (result != null) {
      devices.value = result;
    }
    loading.value = false;
  }

  Future<List<Device>?> getAllByUserId(int id) async {
    return await DeviceService.getAllByUserId(id);
  }

  Future<Device?> get(int id) async {
    return await DeviceService.get(id);
  }

  Future<List<Device>?> getAll() async {
    return await DeviceService.getAll();
  }

  Future<Device?> add(Device device) async {
    var result = await DeviceService.add(device);
    if (result != null) {
      devices.add(result);
      selectedDevice.value = result;
      return result;
    }
    return null;
  }

  Future<Device?> updateDevice(Device device) async {
    var result = await DeviceService.update(device);
    if (result != null) {
      devices.remove(device);
      devices.add(result);
      selectedDevice.value = result;
      return result;
    }
    return null;
  }

  Future<bool> delete(int id) async {
    var result = await DeviceService.delete(id);
    if (result) {
      devices.remove(
        devices.firstWhere(
          (d) => d.id == id,
        ),
      );
      return true;
    }
    return false;
  }

  Future<void> getDeviceTypes() async {
    var result = await DeviceService.getDeviceTypes();
    if (result != null) {
      deviceTypes.value = result;
    }
  }

  Future<DeviceType?> addDeviceType(DeviceType deviceType) async {
    return DeviceService.addDeviceType(deviceType);
  }

  Future<DeviceType?> updateDeviceType(DeviceType deviceType) async {
    return DeviceService.updateDeviceType(deviceType);
  }

  Future<bool> deleteDeviceType(int id) async {
    return DeviceService.deleteDeviceType(id);
  }
}
