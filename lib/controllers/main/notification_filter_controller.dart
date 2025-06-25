import 'package:get/get.dart';

class NotificationFilterController extends GetxController {
  final selectedSensor = Rx<String?>(null);

  final selectedLocation = Rx<String?>(null);

  final selectedDateFilter = Rx<String?>(null);

  final unreadCount = 0.obs;

  final selectedAlarmLevel = ''.obs;

  void clearFilters() {
    selectedSensor.value = null;
    selectedLocation.value = null;
    selectedDateFilter.value = null;
    selectedAlarmLevel.value = '';
  }
}
