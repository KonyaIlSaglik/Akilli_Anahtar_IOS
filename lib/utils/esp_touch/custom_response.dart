import 'dart:typed_data';

import 'package:akilli_anahtar/utils/esp_touch/custom_request.dart';

/// Provisioning response
class CustomProvisioningResponse {
  /// Device BSSID
  final Uint8List bssid;

  /// Device IP address (available only in EspTouchV1 protocol)
  Uint8List? ipAddress;

  /// Textual representation of [bssid] in format aa:bb:cc:dd:ee:ff
  String get bssidText =>
      bssid.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');

  /// Textual representation of [ipAddress]
  String? get ipAddressText => ipAddress?.join('.');

  CustomProvisioningResponse(this.bssid, {this.ipAddress}) {
    if (bssid.length != CustomProvisioningRequest.bssidLength) {
      throw ArgumentError("Invalid BSSID");
    }
  }

  static bool bssidsAreEqual(Uint8List bssid1, Uint8List bssid2) {
    if (bssid1.length != 6 || bssid2.length != 6) {
      throw ArgumentError("Invalid BSSID");
    }

    for (int i = 0; i < 6; i++) {
      if (bssid1[i] != bssid2[i]) {
        return false;
      }
    }

    return true;
  }

  /// Equality checking by [bssid]
  @override
  bool operator ==(Object result) {
    if (result is CustomProvisioningResponse) {
      return bssidsAreEqual(result.bssid, bssid);
    }

    return false;
  }

  @override
  int get hashCode => bssid.hashCode;

  @override
  String toString() {
    return (StringBuffer()
          ..writeAll([
            "bssid=$bssidText",
            ipAddress == null ? '' : ", ip=$ipAddressText",
          ]))
        .toString();
  }
}
