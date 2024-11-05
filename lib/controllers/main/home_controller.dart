import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class HomeController extends GetxController {
  var loading = false.obs;
  var selectedOrganisationId = 0.obs;

  var parameters = <Parameter>[].obs;
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

  Future<void> getData() async {
    loading.value = true;
    await AuthService.getData();
    groupDevices();
    loading.value = false;
  }

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

  List<Device> get favoriteDevices {
    var list = devices
        .where(
          (d) => d.favoriteSequence > -1,
        )
        .toList();
    list.sort(
      (a, b) {
        return a.favoriteSequence.compareTo(b.favoriteSequence);
      },
    );
    return list;
  }

  void groupDevices() async {
    grouping.value = true;
    await Future.delayed(Duration(milliseconds: 100));
    groupedDevices.value = List.empty();
    var list = devices
        .where(
          (d) => d.organisationId == selectedOrganisationId.value,
        )
        .toList();
    list.sort(
      (a, b) => a.boxName.compareToTr(b.boxName),
    );
    var boxNames = getDistinctBoxNames(list);
    var newList = <DeviceGroupByBox>[];
    for (var boxName in boxNames) {
      newList.add(DeviceGroupByBox(
          expanded: false,
          boxName: boxName,
          devices: list
              .where(
                (d) => d.boxName == boxName,
              )
              .toList()));
    }
    groupedDevices.value = newList;
    grouping.value = false;
  }

  List<String> getDistinctBoxNames(List<Device> devices) {
    Set<String> boxNamesSet = {};

    for (var device in devices) {
      boxNamesSet.add(device.boxName);
    }

    return boxNamesSet.toList();
  }

  void clearController() {
    devices.value = <Device>[];
  }
}
