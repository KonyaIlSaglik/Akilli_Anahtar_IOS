import 'package:akilli_anahtar/entities/city.dart';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/district.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/device_group_by_box.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class HomeController extends GetxController {
  var currentPage = "".obs;
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
    currentPage.value = testPage;
    var page = await LocalDb.get("currentPage");
    if (page != null) {
      currentPage.value = page;
    }
    selectedOrganisationId.value = 0;
    var oId = await LocalDb.get("selectedOrganisationId");
    if (oId != null) {
      selectedOrganisationId.value = int.tryParse(oId) ?? 0;
    }
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

  savePageChanges() async {
    await LocalDb.add("currentPage", currentPage.value);
    await LocalDb.add(
        "selectedOrganisationId", selectedOrganisationId.value.toString());
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
          (d) => d.favoriteSequence > 0,
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
    // Use a Set to collect distinct box names
    Set<String> boxNamesSet = {};

    for (var device in devices) {
      boxNamesSet.add(device.boxName);
    }

    // Convert the Set back to a List
    return boxNamesSet.toList();
  }

  void clearController() {
    devices.value = <Device>[];
  }
}
