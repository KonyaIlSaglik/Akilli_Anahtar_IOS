import 'package:get/get.dart';

class NotificationController extends GetxController {
  final selectedSensor = ''.obs;
  final selectedLocation = ''.obs;
  final selectedDateFilter = ''.obs;

  var showSensorOptions = true.obs;
  var showLocationOptions = true.obs;
  var showDateOptions = true.obs;

  void clearFilters() {
    selectedSensor.value = '';
    selectedLocation.value = '';
    selectedDateFilter.value = '';
  }
}
