import 'dart:convert';

class NodemcuApModel {
  String ssidName;
  int signal;
  String encType;
  NodemcuApModel({
    this.ssidName = "",
    this.signal = 0,
    this.encType = "",
  });

  NodemcuApModel copyWith({
    String? ssidName,
    int? signal,
    String? encType,
  }) {
    return NodemcuApModel(
      ssidName: ssidName ?? this.ssidName,
      signal: signal ?? this.signal,
      encType: encType ?? this.encType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ssidName': ssidName,
      'signal': signal,
      'encType': encType,
    };
  }

  factory NodemcuApModel.fromMap(Map<String, dynamic> map) {
    return NodemcuApModel(
      ssidName: map['ssidName'] as String,
      signal: map['signal'] as int,
      encType: map['encType'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory NodemcuApModel.fromJson(String source) =>
      NodemcuApModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
