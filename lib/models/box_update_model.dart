import 'package:akilli_anahtar/entities/box.dart';
import 'package:akilli_anahtar/models/nodemcu_info_model.dart';

class BoxUpdateModel {
  final Box box;
  NodemcuInfoModel? infoModel;
  bool isOld;
  bool isSub;
  bool upgrading;
  BoxUpdateModel({
    required this.box,
    this.infoModel,
    this.isOld = false,
    this.isSub = false,
    this.upgrading = false,
  });
}
