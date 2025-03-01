import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/models/notification_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:turkish/turkish.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  var loading = false.obs;
  var selectedOrganisationId = 0.obs;

  var cities = <City>[].obs;
  var districts = <District>[].obs;
  var organisations = <Organisation>[].obs;
  var devices = <Device>[].obs;

  var grouping = false.obs;
  var groupedDevices = <DeviceGroupByBox>[].obs;

  @override
  void onInit() async {
    super.onInit();
    selectedOrganisationId.value = 0;
    var oId = await LocalDb.get("selectedOrganisationId");
    if (oId != null) {
      selectedOrganisationId.value = int.tryParse(oId) ?? 0;
    }
  }

  saveOrganisationChanges() async {
    await LocalDb.add(
        "selectedOrganisationId", selectedOrganisationId.value.toString());
  }

  // Future<void> getData() async {
  //   loading.value = true;
  //   await AuthService.getData();
  //   groupDevices();
  //   loading.value = false;
  // }

  List<Device> get controlDevices {
    var cd = devices
        .where(
          (d) =>
              d.typeId == 4 || d.typeId == 5 || d.typeId == 6 || d.typeId == 9,
        )
        .toList();
    return selectedOrganisationId.value == 0 ? cd : cd;
  }

  List<Device> get sensorDevices {
    return devices
        .where(
          (d) => d.typeId == 1 || d.typeId == 2 || d.typeId == 3,
        )
        .toList();
  }

  List<Device> get gardenDevices {
    return devices
        .where(
          (d) => d.typeId == 8,
        )
        .toList();
  }

  // List<Device> get favoriteDevices {
  //   var list = devices
  //       .where(
  //         (d) => d.favoriteSequence > -1,
  //       )
  //       .toList();
  //   list.sort(
  //     (a, b) {
  //       return a.favoriteSequence.compareTo(b.favoriteSequence);
  //     },
  //   );
  //   return list;
  // }

  void groupDevices() async {
    grouping.value = true;
    await Future.delayed(Duration(milliseconds: 100));
    groupedDevices.value = List.empty();
    var list = homeDevices;
    // .where(
    //   (d) => d.organisationId == selectedOrganisationId.value,
    // )
    // .toList();
    list.sort(
      (a, b) => (a.boxName ?? "").compareToTr(b.boxName ?? ""),
    );
    var boxNames = getDistinctBoxNames(list);
    var newList = <DeviceGroupByBox>[];
    for (var boxName in boxNames) {
      newList.add(DeviceGroupByBox(
          expanded: false,
          boxName: boxName,
          devices: list
              .where(
                (d) => d.boxName != null && d.boxName! == boxName,
              )
              .toList()));
    }
    groupedDevices.value = newList;
    grouping.value = false;
  }

  List<String> getDistinctBoxNames(List<HomeDeviceDto> devices) {
    Set<String> boxNamesSet = {};

    for (var device in devices) {
      boxNamesSet.add(device.boxName ?? "");
    }

    return boxNamesSet.toList();
  }

  void clearController() {
    devices.value = <Device>[];
  }

  Future<List<NotificationModel>> getAllNotificationMessage() async {
    AuthController authController = Get.find();
    var response = await BaseService.get(
      "$apiUrlOut/Home/getAllNotificationMessage?userId=${authController.user.value.id!}",
    );
    if (response.statusCode == 200) {
      return NotificationModel.fromJsonList(response.body);
    }
    return <NotificationModel>[];
  }

  Future<NotificationModel> getNotification(int deviceId) async {
    AuthController authController = Get.find();
    var response = await BaseService.get(
      "$apiUrlOut/Home/getNotification?userId=${authController.user.value.id!}&deviceId=$deviceId",
    );
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(response.body);
    }
    return NotificationModel(
        userId: authController.user.value.id!,
        deviceId: deviceId,
        status: 1,
        datetime: null);
  }

  Future<bool> updateNotification(NotificationModel notificationModel) async {
    AuthController authController = Get.find();
    notificationModel.userId = authController.user.value.id!;
    var response = await BaseService.update(
      "$apiUrlOut/Home/updateNotification",
      notificationModel.toJson(),
    );
    if (response.statusCode == 200) {
      return response.body == "true";
    }
    return false;
  }

  var watherVisible = false.obs;
  var city = "".obs;
  var tempeture = "".obs;
  var homeDevices = <HomeDeviceDto>[].obs;
  var lastStatus = <int, String>{}.obs;
  var favorites = <HomeDeviceDto>[].obs;
  var parameters = <Parameter>[].obs;
  //////////////
  ///

  Future<String> getVersion() async {
    var info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<void> getDevices() async {
    loading.value = true;
    AuthController authController = Get.find();
    var id = authController.user.value.id;
    homeDevices.value = await HomeService.getDevices(id!) ?? <HomeDeviceDto>[];
    homeDevices.sort(
      (a, b) => a.typeId!.compareTo(b.typeId!),
    );
    MqttController mqttController = Get.find();
    for (var device in homeDevices) {
      mqttController.subscribeToTopic(device.topicStat!);
      if (lastStatus[device.id!] == null) {
        lastStatus[device.id!] = "";
      }
    }
    groupDevices();
    loadFavorites();
    loading.value = false;
  }

  void loadFavorites() {
    favorites.value =
        homeDevices.where((d) => d.favoriteSequence != null).toList();
    favorites
        .sort((a, b) => a.favoriteSequence!.compareTo(b.favoriteSequence!));
  }

  Future<void> updateFavoriteSequence(int deviceId, int sequence) async {
    AuthController authController = Get.find();
    var id = authController.user.value.id;
    var response =
        await HomeService.updateFavoriteSequence(id!, deviceId, sequence);
    if (response != null) {
      if (sequence == 0) {
        homeDevices.singleWhere((d) => d.id == deviceId).favoriteSequence =
            null;
        homeDevices.singleWhere((d) => d.id == deviceId).favoriteName = null;
      } else {
        homeDevices.singleWhere((d) => d.id == deviceId).favoriteSequence =
            sequence;
      }
      loadFavorites();
    }
  }

  Future<void> updateFavoriteName(int deviceId, String? name) async {
    AuthController authController = Get.find();
    var id = authController.user.value.id;
    var response = await HomeService.updateFavoriteName(id!, deviceId, name);
    if (response != null) {
      homeDevices.singleWhere((d) => d.id == deviceId).favoriteName = name;
      loadFavorites();
    }
  }

  int getNextFavoriteSequence() {
    return favorites.isEmpty
        ? 1
        : favorites
                .map((device) => device.favoriteSequence!)
                .reduce((a, b) => a > b ? a : b) +
            1;
  }

  Future<void> getWather() async {
    watherVisible.value = (await LocalDb.get(watherVisibleKey) ?? "0") == "1";
    if (watherVisible.value) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
      var position = await Geolocator.getCurrentPosition();
      var placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      print(placemarks[0]);
      city.value =
          "${placemarks[0].administrativeArea!}/${placemarks[0].subAdministrativeArea!}";
      var url =
          "https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,relative_humidity_2m&forecast_days=1";
      var uri = Uri.parse(url);
      var client = http.Client();
      var response = await client.get(uri);
      if (response.statusCode == 200) {
        print(response.body);
        var data = json.decode(response.body) as Map<String, dynamic>;
        var result = data["current"] as Map<String, dynamic>;
        var unitResult = data["current_units"] as Map<String, dynamic>;
        tempeture.value =
            "${result["temperature_2m"]} ${unitResult["temperature_2m"]}";
      }
      client.close();
    }
  }
}
