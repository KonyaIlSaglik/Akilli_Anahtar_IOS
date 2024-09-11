// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:akilli_anahtar/entities/box.dart';

class BoxUpdateModel {
  final Box box;
  bool isOld;
  bool isSub;
  bool upgrading;
  BoxUpdateModel({
    required this.box,
    this.isOld = false,
    this.isSub = false,
    this.upgrading = false,
  });
}
