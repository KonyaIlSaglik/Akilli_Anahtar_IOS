import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/dtos/bm_organisation_dto.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class BoxManagementService {
  static String url = "$apiUrlOut/BoxManagement";

  static Future<List<BmBoxDto>?> getBoxes(int userId) async {
    var response = await BaseService.get(
      "$url/getAllBox?userId=$userId",
    );
    if (response.statusCode == 200) {
      return BmBoxDto.fromJsonList(response.body);
    }
    return null;
  }

  static Future<List<BmOrganisationDto>?> getOrganisations(int userId) async {
    var response = await BaseService.get(
      "$url/getAllOrganisation?userId=$userId",
    );
    if (response.statusCode == 200) {
      return BmOrganisationDto.fromJsonList(response.body);
    }
    return null;
  }
}
