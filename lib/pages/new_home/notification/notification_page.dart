import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:get/get.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();

    final userId = Get.find<AuthController>().user.value.id.toString();
    final databaseRef = FirebaseDatabase.instance.ref("notifications/$userId");

    databaseRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        final mapData = Map<String, dynamic>.from(data);

        final tempList = mapData.entries.map((entry) {
          final notif = Map<String, dynamic>.from(entry.value);
          notif["id"] = entry.key;
          return notif;
        }).toList();

        tempList.sort((a, b) {
          final aTime = a["received_at"];
          final bTime = b["received_at"];
          if (aTime == null && bTime == null) return 0;
          if (aTime == null) return 1;
          if (bTime == null) return -1;
          return bTime.compareTo(aTime);
        });

        if (mounted) {
          setState(() {
            notifications = tempList;
          });
        }
      }
    });
  }

  Color getAlarmStatusColor(int alarmStatus) {
    switch (alarmStatus) {
      case 2:
        return Colors.red[700]!;
      case 1:
        return Colors.orange[300]!;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[50],
        title: const Text('Bildirimler'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text("Henüz hiçbir bildirim yok"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                final alarmInt = int.tryParse(item['alarm'].toString()) ?? 0;
                final alarmColor = getAlarmStatusColor(alarmInt);

                final sensorType = item['sensor_name'] ?? "Sensör";
                final location =
                    item['organisation_name'] ?? "Lokasyon Bilinmiyor";
                final unit = item['unit'] ?? "";
                final value = item['deger'] ?? "-";
                final timeString =
                    item['received_at'] ?? DateTime.now().toIso8601String();
                final time = DateTime.tryParse(timeString);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: alarmColor, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            item['alarm'] == 2 ? Icons.error : Icons.warning,
                            color: alarmColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sensorType,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  location,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "$value${unit.isNotEmpty ? ' $unit' : ''}",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: alarmColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (time != null)
                        Text(
                          DateFormat("dd.MM.yyyy HH:mm:ss").format(time),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
