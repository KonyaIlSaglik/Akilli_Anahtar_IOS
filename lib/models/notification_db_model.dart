class NotificationDbModel {
  final String id;
  final String dateKey;
  final int? receivedAtEpoch;
  final String? receivedAt;
  final String? sensorName;
  final String? organisationName;
  final String? deger;
  final int? alarm;
  bool isRead;

  NotificationDbModel({
    required this.id,
    required this.dateKey,
    required this.receivedAtEpoch,
    required this.receivedAt,
    required this.sensorName,
    required this.organisationName,
    required this.deger,
    required this.alarm,
    required this.isRead,
  });

  factory NotificationDbModel.fromFirebase(
      String id, String dateKey, Map<dynamic, dynamic> data) {
    return NotificationDbModel(
      id: id,
      dateKey: dateKey,
      receivedAtEpoch: data['received_at_epoch'] ?? 0,
      receivedAt: data['received_at'],
      sensorName: data['sensor_name'],
      organisationName: data['organisation_name'],
      deger: data['deger']?.toString(),
      alarm: int.tryParse(data['alarm']?.toString() ?? '0'),
      isRead: data['isRead'] == 1,
    );
  }
}
