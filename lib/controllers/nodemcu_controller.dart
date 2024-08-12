import 'package:akilli_anahtar/controllers/device_controller.dart';
import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/controllers/wifi_controller.dart';
import 'package:akilli_anahtar/services/api/parameter_service.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class NodemcuController extends GetxController {
  var routerIP = "".obs;
  var chipId = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    routerIP.value = Get.find<WifiController>().routerIP.value;
  }

  Future<void> getChipId() async {
    await WiFiForIoTPlugin.forceWifiUsage(true);
    var uri = Uri.parse("http://${routerIP.value}/_ac");
    var client = http.Client();
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      var doc = parse(response.body);
      var table = doc.body!.getElementsByClassName("info")[0];
      var rows = table.getElementsByTagName("tr");
      for (var row in rows) {
        if (row.getElementsByTagName("td")[0].innerHtml == "Chip ID") {
          var id =
              int.tryParse(row.getElementsByTagName("td")[1].innerHtml) ?? 0;
          chipId.value = id;
          return;
        }
      }
    }
  }

  Future<void> sendMqttSettings() async {
    // await WiFiForIoTPlugin.forceWifiUsage(false);
    // var parameters = await ParameterService.getParametersbyType(1);
    // if (parameters != null) {
    //   await WiFiForIoTPlugin.forceWifiUsage(true);
    //   var uri = Uri.parse("http://${routerIP.value}/mqttsettings");
    //   var client = http.Client();
    //   client
    //       .post(
    //     uri,
    //     headers: {
    //       'content-type': 'application/json',
    //     },
    //     body: mqttModel.toJson(),
    //   )
    //       .then((response) {
    //     if (response.statusCode == 200) {
    //       CherryToast.success(
    //         toastPosition: Position.bottom,
    //         title: Text(response.body),
    //       ).show(context);
    //     } else {
    //       CherryToast.error(
    //         toastPosition: Position.bottom,
    //         title: Text(response.body),
    //       ).show(context);
    //     }
    //   });
    // }
  }
}
