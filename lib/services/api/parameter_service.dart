import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/services/api/base_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';

class ParameterService {
  static String url = "$apiUrlOut/Parameter";

  static Future<List<Parameter>?> getAllByTypeId(int id) async {
    return BaseService.get2(
      "$url/getAllBytype?id=$id",
      (json) => Parameter.fromJsonList(json),
    );
  }
}
