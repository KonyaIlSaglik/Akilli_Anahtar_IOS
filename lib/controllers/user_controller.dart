import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/services/api/user_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:wifi_iot/wifi_iot.dart';

class UserController extends GetxController {
  var user = User().obs;
  var operationClaims = <OperationClaim>[].obs;

  Future<void> getUser() async {
    WiFiForIoTPlugin.forceWifiUsage(false);
    var userName = await LocalDb.get(userNameKey);
    if (userName != null) {
      var userResult = await UserService.getbyUserName(userName);
      if (userResult != null) {
        LocalDb.add(userKey, userResult.toJson());
        user.value = userResult;
        getclaims();
      }
    }
  }

  Future<void> getclaims() async {
    if (user.value.id > 0) {
      var claimsResult = await UserService.getClaims(user.value);
      if (claimsResult.success) {
        operationClaims.value = claimsResult.data!;
      }
    }
  }
}
