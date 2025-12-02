import 'dart:convert';

import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/dtos/home_notification_dto.dart';
import 'package:akilli_anahtar/dtos/simple_organisation_dto.dart';
import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/models/notification_model.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:turkish/turkish.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

class HomeController extends GetxController {
  var loading = false.obs;
  var selectedOrganisationId = 0.obs;

  var cities = <City>[].obs;
  var districts = <District>[].obs;
  var organisations = <Organisation>[].obs;
  var devices = <Device>[].obs;
  AuthController authController = Get.find();

  var grouping = false.obs;
  var groupedDevices = <DeviceGroupByBox>[].obs;

  var lastStatus = <int, String>{}.obs;
  var connectionErrors = <int, bool>{}.obs;
  var refreshTimestamp = 0.obs;
  final Map<int, DateTime> lastSeen = {};
  final Map<int, int> publishPeriodMs = {};

  var selectedRange = '3 Ay'.obs;
  var onlyAlarms = false.obs;
  var isLoading = false.obs;
  var reportData = <dynamic>[].obs;
  var selectedBoxId = Rxn<int>();
  var organisationList = <SimpleOrganisationDto>[].obs;
  final List<String> rangeOptions = ['Son 10 Gün', '3 Ay', '6 Ay', '1 Yıl'];

  String? getPeriodParam() {
    switch (selectedRange.value) {
      case '3 Ay':
        return '3m';
      case '6 Ay':
        return '6m';
      case '1 Yıl':
        return '1y';
      default:
        return null;
    }
  }

  @override
  void onInit() async {
    super.onInit();
    await loadUserOrganisations();
    selectedOrganisationId.value = 0;
    var oId = await LocalDb.get("selectedOrganisationId");
    if (oId != null) {
      selectedOrganisationId.value = int.tryParse(oId) ?? 0;
    }
    initDefaultOrganisation();
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
    update();
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

  Future<List<HomeNotificationDto>> getAllNotificationMessage() async {
    AuthController authController = Get.find();
    var response = await BaseService.get(
      "$apiUrlOut/Home/getAllNotificationMessage?userId=${authController.user.value.id!}",
    );
    if (response.statusCode == 200) {
      return HomeNotificationDto.fromJsonList(response.body);
    }
    return <HomeNotificationDto>[];
  }

  // Future<NotificationModel> getNotification(int deviceId) async {
  //   AuthController authController = Get.find();
  //   var response = await BaseService.get(
  //     "$apiUrlOut/Home/getNotification?userId=${authController.user.value.id!}&deviceId=$deviceId",
  //   );
  //   if (response.statusCode == 200) {
  //     return NotificationModel.fromJson(response.body);
  //   }
  //   return NotificationModel(
  //       userId: authController.user.value.id!,
  //       deviceId: deviceId,
  //       status: 1,
  //       datetime: null);
  // }

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
  var favorites = <HomeDeviceDto>[].obs;
  var box = <BmBoxDto>[].obs;
  var parameters = <Parameter>[].obs;
  //////////////
  ///

  Future<String> getVersion() async {
    var info = await PackageInfo.fromPlatform();
    return info.version;
  }

  Future<void> getDevices() async {
    loading.value = true;
    try {
      final auth = Get.find<AuthController>();
      final id = auth.user.value.id;

      if (id == null) {
        homeDevices.clear();
        return;
      }

      connectionErrors.clear();

      final result = await HomeService.getDevices(id) ?? <HomeDeviceDto>[];

      homeDevices.assignAll(result);

      if (homeDevices.isEmpty) {
        groupDevices();
        loadFavorites();
        refreshTimestamp.value = DateTime.now().millisecondsSinceEpoch;
        update();
        return;
      }

      homeDevices.sort((a, b) => a.typeId!.compareTo(b.typeId!));

      final mqtt = Get.find<MqttController>();
      for (final d in homeDevices) {
        if ((d.topicStat ?? '').isNotEmpty) {
          mqtt.subscribeToTopic(d.topicStat!);
        }
        lastStatus[d.id!] ??= "";
      }

      final boxIds =
          homeDevices.map((d) => d.boxId).whereType<int>().toSet().toList();

      if (boxIds.isNotEmpty) {
        await mqtt.subscribeAvailabilityFor(boxIds);
      }

      groupDevices();
      loadFavorites();
    } catch (e) {
    } finally {
      refreshTimestamp.value = DateTime.now().millisecondsSinceEpoch;
      loading.value = false;
    }
    update();
  }

  void loadFavorites() {
    favorites.value = homeDevices
        .where((d) => d.favoriteSequence != null)
        .toList()
      ..sort((a, b) => a.favoriteSequence!.compareTo(b.favoriteSequence!));
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

  Future<void> fetchReports() async {
    try {
      isLoading.value = true;
      final token = authController.session.value.accessToken;

      final data = await HomeService.fetchSensorMessages(
        organisationId: selectedOrganisationId.value == 0
            ? authController.user.value.organisationId
            : selectedOrganisationId.value,
        boxId: selectedBoxId.value,
        onlyAlarms: onlyAlarms.value,
        period: getPeriodParam(),
        token: token,
      );

      if (data != null) {
        reportData.assignAll(data);
      } else {
        errorSnackbar('Uyarı', 'Seçilen tarih aralığında veri bulunamadı.');
      }
    } catch (e) {
      errorSnackbar('Hata', 'Veriler alınırken hata oluştu.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> exportReport(BuildContext context, String type) async {
    final token = authController.session.value.accessToken;

    final filePath = await HomeService.downloadSensorReport(
      context: context,
      exportType: type,
      fileName: type == 'pdf'
          ? 'SensorMessagesReport.pdf'
          : 'SensorMessagesReport.xlsx',
      organisationId: selectedOrganisationId.value == 0
          ? authController.user.value.organisationId
          : selectedOrganisationId.value,
      boxId: selectedBoxId.value,
      onlyAlarms: onlyAlarms.value,
      period: getPeriodParam(),
      token: token,
    );
    if (filePath != null) {
      _showDownloadedDialog(context, filePath);
    }
  }

  static void _showDownloadedDialog(BuildContext context, String filePath) {
    final fileName = p.basename(filePath);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rapor hazır"),
        content: Text("$fileName başarıyla indirildi."),
        actions: [
          TextButton(
            onPressed: () {
              OpenFile.open(filePath);
            },
            child: const Text("Aç"),
          ),
          TextButton(
            onPressed: () {
              Share.shareXFiles([XFile(filePath)], text: "Rapor Paylaşımı");
            },
            child: const Text("Paylaş"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Kapat"),
          ),
        ],
      ),
    );
  }

  Future<void> loadUserOrganisations() async {
    try {
      final userId = authController.user.value.id;
      if (userId == null) return;

      final list = await UserService.getUserOrganisation2(userId);

      print("API RESULT = $list");

      if (list != null) {
        organisationList.assignAll(list
            .map((e) => SimpleOrganisationDto(
                  organisationId: e.organisationId,
                  organisationName: e.organisationName,
                ))
            .toList());

        print("ORG LIST COUNT = ${organisationList.length}");
      }
    } catch (e) {
      print("Organizasyon yüklenirken hata: $e");
    }
    initDefaultOrganisation();
  }

  void initDefaultOrganisation() {
    final userOrgId = authController.user.value.organisationId;

    if (userOrgId != null && userOrgId != 0) {
      selectedOrganisationId.value = userOrgId;
    }
  }

  Future<void> initializeReports() async {
    selectedRange.value = "3 Ay";

    final userOrgId = authController.user.value.organisationId;

    if (userOrgId != null && userOrgId != 0) {
      selectedOrganisationId.value = userOrgId;
    }
    await loadUserOrganisations();

    initDefaultOrganisation();
    await fetchReports();
  }

  void hardReset() {
    homeDevices.clear();
    favorites.clear();
    groupedDevices.clear();
    lastStatus.clear();
    loading.value = false;
  }
}
