// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';

class WifiListItem extends StatelessWidget {
  final WiFiAccessPoint accessPoint;
  void Function()? onPressed;
  bool isConnected;
  WifiListItem({
    Key? key,
    required this.accessPoint,
    this.onPressed,
    required this.isConnected,
  }) : super(key: key);

  // build row that can display info, based on label: value pair.
  Widget _buildInfo(String label, dynamic value) => Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(child: Text(value.toString()))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final title = accessPoint.ssid.isNotEmpty ? accessPoint.ssid : "**EMPTY**";
    const color = Colors.white;
    final signalIcon =
        accessPoint.level >= -80 ? Icons.wifi : Icons.wifi_2_bar_outlined;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon, color: color),
      title: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: color),
      ),
      subtitle: isConnected
          ? Text(
              "Bağlandı",
              style: TextStyle(
                color: color,
              ),
            )
          : null,
      trailing: Icon(
        Icons.lock_outlined,
        color: Colors.white,
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(),
              ElevatedButton(
                onPressed: onPressed,
                child: Text("BAĞLAN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/**
 IconButton(
        icon: Icon(
          Icons.info_outline,
          color: color,
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(accessPoint.ssid),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfo("BSSDI", accessPoint.bssid),
                _buildInfo("Capability", accessPoint.capabilities),
                _buildInfo("frequency", "${accessPoint.frequency}MHz"),
                _buildInfo("level", accessPoint.level),
                _buildInfo("standard", accessPoint.standard),
                _buildInfo(
                    "centerFrequency0", "${accessPoint.centerFrequency0}MHz"),
                _buildInfo(
                    "centerFrequency1", "${accessPoint.centerFrequency1}MHz"),
                _buildInfo("channelWidth", accessPoint.channelWidth),
                _buildInfo("isPasspoint", accessPoint.isPasspoint),
                _buildInfo(
                    "operatorFriendlyName", accessPoint.operatorFriendlyName),
                _buildInfo("venueName", accessPoint.venueName),
                _buildInfo(
                    "is80211mcResponder", accessPoint.is80211mcResponder),
              ],
            ),
          ),
        ),
      ),
 */
