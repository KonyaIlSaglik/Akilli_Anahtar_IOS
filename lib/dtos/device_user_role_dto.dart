class DeviceRoleDto {
  final int deviceId;
  final String role;

  DeviceRoleDto({required this.deviceId, required this.role});

  factory DeviceRoleDto.fromMapEntry(MapEntry<String, dynamic> entry) {
    return DeviceRoleDto(
      deviceId: int.tryParse(entry.key) ?? 0,
      role: entry.value.toString(),
    );
  }

  factory DeviceRoleDto.fromJson(Map<String, dynamic> json) {
    return DeviceRoleDto(
      deviceId: json['deviceId'],
      role: json['role'],
    );
  }
}
