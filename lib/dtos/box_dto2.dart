import 'package:akilli_anahtar/dtos/bm_box_dto.dart';
import 'package:akilli_anahtar/entities/box.dart';

extension BmBoxDtoMapper on BmBoxDto {
  Box toBox() {
    return Box(
      id: id ?? 0,
      name: name ?? '',
      chipId: chipId ?? 0,
      organisationId: organisationId ?? 0,
      active: active ?? 1,
      topicRec: topicRec ?? '',
      topicRes: topicRes ?? '',
      version: version ?? '',
      localIp: localIp ?? '',
      restartTimeout: restartTimeout ?? 0,
      espType: espType ?? '',
      channel: channel ?? 0,
      boxTypeId: boxTypeId ?? 1,
      target: target ?? 0,
    );
  }
}
