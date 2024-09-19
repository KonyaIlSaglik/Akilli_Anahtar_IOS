import 'package:akilli_anahtar/entities/operation_claim.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/services/api/operation_claim_service.dart';
import 'package:get/get.dart';

class ClaimController extends GetxController {
  Future<List<OperationClaim>?> getUserClaims(User user) async {
    if (user.id > 0) {
      var claimsResult = await OperationClaimService.getClaims(user);
      if (claimsResult.success) {
        return claimsResult.data!;
      }
    }
    return null;
  }
}
