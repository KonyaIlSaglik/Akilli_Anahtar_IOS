import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/organisation.dart';
import 'package:akilli_anahtar/entities/relay.dart';
import 'package:akilli_anahtar/entities/sensor.dart';
import 'package:akilli_anahtar/entities/user_device.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/entities/user_organisation.dart';
import 'package:akilli_anahtar/services/api/box_service.dart';
import 'package:akilli_anahtar/services/api/operation_claim_service.dart';
import 'package:akilli_anahtar/services/api/organisation_service.dart';
import 'package:akilli_anahtar/services/api/relay_service.dart';
import 'package:akilli_anahtar/services/api/sensor_service.dart';
import 'package:akilli_anahtar/services/api/user_device_service.dart';
import 'package:akilli_anahtar/services/api/user_operation_claim_service.dart';
import 'package:akilli_anahtar/services/api/user_organisation_service.dart';
import 'package:get/get.dart';
import 'package:turkish/turkish.dart';

class ClaimController extends GetxController {
  var operationClaims = <OperationClaim>[].obs;
  var organisations = <Organisation>[].obs;
  var boxes = <Box>[].obs;
  var filteredBoxes = <Box>[].obs;
  var selectedOrganisationId = 0.obs;
  var selectedBoxId = 0.obs;

  var userDevices = <UserDevice>[].obs;

  var relays = <Relay>[].obs;
  var filteredRelays = <Relay>[].obs;

  var sensors = <Sensor>[].obs;
  var filteredSensors = <Sensor>[].obs;

  Future<void> getAllClaims() async {
    var claimsResult = await OperationClaimService.getAll();
    if (claimsResult != null) {
      operationClaims.value = claimsResult;
    }
  }

  Future<List<UserOperationClaim>?> getAllUserClaims(int userId) async {
    var claimsResult = await UserOperationClaimService.getAllByUserId(userId);
    if (claimsResult != null) {
      return claimsResult;
    }
    return null;
  }

  Future<UserOperationClaim?> addUserClaim(UserOperationClaim claim) async {
    var claimsResult = await UserOperationClaimService.add(claim);
    if (claimsResult.success && claimsResult.data != null) {
      return claimsResult.data;
    }
    return null;
  }

  Future<bool> deleteUserClaim(int id) async {
    var claimsResult = await UserOperationClaimService.delete(id);
    if (claimsResult.success) {
      return true;
    }
    return false;
  }

  Future<void> getOrganisations() async {
    var result = await OrganisationService.getAll();
    if (result != null) {
      organisations.value = result;
      organisations.sort(
          ((a, b) => a.name.toLowerCaseTr().compareTo(b.name.toLowerCaseTr())));
    }
  }

  Future<List<UserOrganisation>?> getAllUserOrganisations(int userId) async {
    var userOrganisationResult =
        await UserOrganisationService.getAllByUserId(userId);
    if (userOrganisationResult != null) {
      return userOrganisationResult;
    }
    return null;
  }

  Future<UserOrganisation?> addUserOrganisation(
      UserOrganisation userOrganisation) async {
    var userOrganisationResult =
        await UserOrganisationService.add(userOrganisation);
    if (userOrganisationResult.success && userOrganisationResult.data != null) {
      return userOrganisationResult.data;
    }
    return null;
  }

  Future<bool> deleteUserOrganisation(int id) async {
    var userOrganisationResult = await UserOrganisationService.delete(id);
    if (userOrganisationResult.success) {
      return true;
    }
    return false;
  }

  Future<void> getBoxes() async {
    var result = await BoxService.getAll();
    if (result != null) {
      boxes.value = result;
      boxes.sort(
          ((a, b) => a.name.toLowerCaseTr().compareTo(b.name.toLowerCaseTr())));
    }
  }

  void filterBoxes() {
    selectedBoxId.value = 0;
    filteredBoxes.value = selectedOrganisationId.value == 0
        ? boxes
        : boxes
            .where((b) => b.organisationId == selectedOrganisationId.value)
            .toList();
    filteredRelays.value =
        relays.where((r) => filteredBoxes.any((b) => b.id == r.boxId)).toList();
    filteredSensors.value = sensors
        .where((s) => filteredBoxes.any((b) => b.id == s.boxId))
        .toList();
  }

  Future<void> getAllUserDevice(int userId) async {
    var userDevicesResult = await UserDeviceService.getAllByUserId(userId);
    if (userDevicesResult != null) {
      userDevices.value = userDevicesResult;
    }
  }

  Future<UserDevice?> addUserDevice(UserDevice device) async {
    var userDeviceResult = await UserDeviceService.add(device);
    if (userDeviceResult.success && userDeviceResult.data != null) {
      return userDeviceResult.data;
    }
    return null;
  }

  Future<bool> deleteUserDevice(int id) async {
    var userDeviceResult = await UserDeviceService.delete(id);
    if (userDeviceResult.success) {
      return true;
    }
    return false;
  }

  Future<void> getRelays() async {
    var result = await RelayService.getAll();
    if (result != null) {
      relays.value = result;
    }
  }

  void filterRelays() {
    filteredRelays.value = selectedBoxId.value == 0
        ? relays
        : relays.where((b) => b.boxId == selectedBoxId.value).toList();
  }

  Future<void> getSensors() async {
    var result = await SensorService.getAll();
    if (result != null) {
      sensors.value = result;
    }
  }

  void filterSensors() {
    filteredSensors.value = selectedBoxId.value == 0
        ? sensors
        : sensors.where((b) => b.boxId == selectedBoxId.value).toList();
  }
}
