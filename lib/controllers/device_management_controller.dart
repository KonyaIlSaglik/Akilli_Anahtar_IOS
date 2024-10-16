import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/device_type.dart';
import 'package:akilli_anahtar/services/api/device_service.dart';
import 'package:get/get.dart';

class DeviceManagementController extends GetxController {
  var loading = false.obs;
  var deviceTypes = <DeviceType>[].obs;
  var selectedTypeId = 0.obs;
  Future<List<Device>?> getAllByBoxId(int id) async {
    return await DeviceService.getAllByBoxId(id);
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
    return await DeviceService.add(device);
  }

  Future<Device?> updateDevice(Device device) async {
    return await DeviceService.update(device);
  }

  Future<bool> delete(int id) async {
    return await DeviceService.delete(id);
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
