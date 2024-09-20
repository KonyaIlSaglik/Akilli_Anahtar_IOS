import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user_operation_claim.dart';
import 'package:akilli_anahtar/services/api/operation_claim_service.dart';
import 'package:akilli_anahtar/services/api/user_operation_claim_service.dart';
import 'package:get/get.dart';

class ClaimController extends GetxController {
  var operationClaims = <OperationClaim>[].obs;

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
}
