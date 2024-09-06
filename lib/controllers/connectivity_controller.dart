import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:wifi_iot/wifi_iot.dart';

class ConnectivityController extends GetxController {
  // Reactive variable to hold the internet connection status
  var isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    InternetConnectionChecker().onStatusChange.listen((status) async {
      isConnected.value = status == InternetConnectionStatus.connected;
      print(isConnected.value ? "Network Connected" : "Network Not Connected");
      if (!isConnected.value) {
        await WiFiForIoTPlugin.forceWifiUsage(false);
      }
    });
  }

  Future<void> _checkInitialConnection() async {
    isConnected.value = await InternetConnectionChecker().hasConnection;
  }
}
