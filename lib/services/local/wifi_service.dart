import 'package:wifi_iot/wifi_iot.dart';

class WifiService {
  late bool isEnable;
  late String connectedSSID;

  Future<bool> isEnabled() {
    return WiFiForIoTPlugin.isEnabled();
  }
}
