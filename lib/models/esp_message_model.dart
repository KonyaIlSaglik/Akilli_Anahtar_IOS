class EspMessageModel {
  final int deviceId;
  final double? deger;
  final int alarm;
  final String? referance;
  final DateTime? iso;

  const EspMessageModel({
    required this.deviceId,
    required this.deger,
    required this.alarm,
    required this.referance,
    required this.iso,
  });

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    try {
      final dt = DateTime.parse(v.toString());
      return dt.isUtc ? dt.toLocal() : dt;
    } catch (_) {
      return null;
    }
  }

  factory EspMessageModel.fromMap(Map<String, dynamic> map) => EspMessageModel(
        deviceId: (map['device_id'] as num).toInt(),
        deger: _toDouble(map['deger']),
        alarm: (map['alarm'] as num?)?.toInt() ?? 0,
        referance: map['referance']?.toString(),
        iso: _toDate(map['iso']),
      );
}
