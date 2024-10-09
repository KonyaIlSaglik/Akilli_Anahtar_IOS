import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
    });
  }

  Future<void> _checkInitialConnection() async {
    isConnected.value = await InternetConnectionChecker().hasConnection;
  }
}
