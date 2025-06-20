import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:akilli_anahtar/controllers/main/notification_controller.dart';
import 'package:akilli_anahtar/pages/new_home/notification/notification_filter_page.dart';
import 'package:akilli_anahtar/controllers/main/notification_filter_controller.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  final ScrollController _scrollController = ScrollController();
  final NotificationController notificationController =
      Get.put(NotificationController());
  String filterStatus = 'all';
  bool isLoading = false;
  final NotificationController filters = Get.find();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  StreamSubscription? _notificationSubscription;
  int _loadedCount = 0;
  int _pageSize = 20;
  bool _hasMore = true;
  bool _isFetching = false;
  String? lastReceivedAt;

  final Map<String, IconData> sensorIcons = {
    'temperature': FontAwesomeIcons.temperatureHigh,
    'humidity': FontAwesomeIcons.droplet,
    'smoke': FontAwesomeIcons.fire,
    'default': Icons.sensors,
  };

  @override
  void initState() {
    super.initState();

    _loadPaginatedNotifications();
    _startLiveListener();
    deleteOldNotifications();
  }

  void _startLiveListener() {
    final userId = Get.find<AuthController>().user.value.id.toString();
    _database
        .child('notifications/$userId')
        .limitToLast(1)
        .onChildAdded
        .listen((event) {
      if (!mounted || event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data['id'] = event.snapshot.key;

      if (!mounted) return;
      setState(() {
        notifications.insert(0, data);

        if (notifications.length > _pageSize) {
          notifications = notifications.take(_pageSize).toList();
        }
      });
    });
  }

  Future<void> _loadPaginatedNotifications() async {
    if (_isFetching || !_hasMore) return;
    setState(() => _isFetching = true);

    final userId = Get.find<AuthController>().user.value.id.toString();
    var ref = FirebaseDatabase.instance
        .ref("notifications/$userId")
        .orderByChild("received_at")
        .limitToLast(_pageSize);

    if (lastReceivedAt != null) {
      ref = ref.endBefore(lastReceivedAt);
    }

    final snapshot = await ref.get();

    if (snapshot.exists && snapshot.value is Map) {
      final mapData = Map<String, dynamic>.from(snapshot.value as Map);
      final newList = mapData.entries.map((e) {
        final notif = Map<String, dynamic>.from(e.value);
        notif['id'] = e.key;
        return notif;
      }).toList();

      newList.sort((a, b) {
        final aTime = DateTime.tryParse(a['received_at'] ?? '');
        final bTime = DateTime.tryParse(b['received_at'] ?? '');
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      if (newList.isNotEmpty) {
        lastReceivedAt = newList.last['received_at'];
      }

      for (final item in newList) {
        if (!notifications.any((n) => n['id'] == item['id'])) {
          notifications.add(item);
        }
      }

      setState(() {
        _hasMore = newList.length >= _pageSize;
        _isFetching = false;
      });
    } else {
      setState(() {
        _hasMore = false;
        _isFetching = false;
      });
    }
  }

  Future<void> deleteOldNotifications() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    final ref = FirebaseDatabase.instance.ref("notifications/$userId");

    final snapshot = await ref.get();
    if (!snapshot.exists || snapshot.value is! Map) return;

    final Map<String, dynamic> all =
        Map<String, dynamic>.from(snapshot.value as Map);
    final now = DateTime.now();

    for (final entry in all.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      final receivedAtStr = data['received_at'];
      final receivedAt = DateTime.tryParse(receivedAtStr ?? '');

      if (receivedAt != null && now.difference(receivedAt).inDays > 20) {
        await ref.child(entry.key).remove();
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = Get.find<AuthController>().user.value.id.toString();
      final databaseRef =
          FirebaseDatabase.instance.ref("notifications/$userId");

      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        final mapData = Map<String, dynamic>.from(data);
        final tempList = mapData.entries.map((entry) {
          final notif = Map<String, dynamic>.from(entry.value);
          notif['id'] = entry.key;
          return notif;
        }).toList();

        tempList.sort((a, b) {
          final aTimeStr = a['received_at'];
          final bTimeStr = b['received_at'];

          final aTime = DateTime.tryParse(aTimeStr ?? '');
          final bTime = DateTime.tryParse(bTimeStr ?? '');

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
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Color getAlarmStatusColor(String? alarm) {
    switch (alarm) {
      case "2":
        return Colors.red;
      case "1":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Future<void> markAllAsRead() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    final ref = FirebaseDatabase.instance.ref("notifications/$userId");

    final updates = <String, dynamic>{};

    for (final notif in notifications) {
      updates["${notif['id']}/read"] = 1;
    }

    await ref.update(updates);

    if (!mounted) return;

    setState(() {
      for (var i = 0; i < notifications.length; i++) {
        notifications[i]['read'] = 1;
      }
    });

    successSnackbar("Başarılı", "Tüm bildirimler okundu olarak işaretlendi.");
  }

  Future<void> deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son 20 Bildirimi Sil'),
        content: const Text('Emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final userId = Get.find<AuthController>().user.value.id.toString();

      final toDelete = notifications.take(_pageSize).toList();

      for (final notif in toDelete) {
        final id = notif['id'];
        await FirebaseDatabase.instance
            .ref("notifications/$userId/$id")
            .remove();
      }

      setState(() {
        notifications.clear();
      });

      successSnackbar("Başarılı", "Son 20 bildirim silindi.");
      await _loadPaginatedNotifications();
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    await FirebaseDatabase.instance
        .ref("notifications/$userId/$notificationId")
        .remove();
    setState(() {
      notifications.removeWhere((n) => n['id'] == notificationId);
    });
    if (notifications.length < _pageSize && _hasMore && !_isFetching) {
      _loadPaginatedNotifications();
    }
  }

  IconData _getSensorIcon(String? sensorName) {
    if (sensorName == null) return sensorIcons['default']!;
    final lowerName = sensorName.toLowerCase();
    if (lowerName.contains('isi')) return sensorIcons['temperature']!;
    if (lowerName.contains('nem')) return sensorIcons['humidity']!;
    if (lowerName.contains('duman')) return sensorIcons['smoke']!;
    return sensorIcons['default']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = notifications
        .where((n) {
          final matchesSensor = filters.selectedSensor.value.isEmpty ||
              (n['sensor_name']?.toLowerCase() ?? '')
                  .contains(filters.selectedSensor.value.toLowerCase());

          final locationName = (n['boxName'] ?? n['organisation_name'] ?? '')
              .toString()
              .toLowerCase();
          final matchesLocation = filters.selectedLocation.value.isEmpty ||
              locationName
                  .contains(filters.selectedLocation.value.toLowerCase());

          final matchesDate = () {
            final selected = filters.selectedDateFilter.value;
            if (selected.isEmpty) return true;
            final time = DateTime.tryParse(n['received_at'] ?? '');
            if (time == null) return false;
            final now = DateTime.now();
            if (selected == 'Son 24 Saat')
              return time.isAfter(now.subtract(const Duration(days: 1)));
            if (selected == 'Son 7 Gün')
              return time.isAfter(now.subtract(const Duration(days: 7)));
            if (selected == 'Son 1 Ay')
              return time.isAfter(now.subtract(const Duration(days: 30)));
            return true;
          }();

          final matchesReadStatus = () {
            if (filterStatus == 'read') return n['read'] == 1;
            if (filterStatus == 'unread') return n['read'] != 1;
            return true;
          }();

          return matchesSensor &&
              matchesLocation &&
              matchesDate &&
              matchesReadStatus;
        })
        .take(_pageSize) // ✅ SADECE SON 20
        .toList();

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[50],
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: deleteAll,
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: markAllAsRead,
          ),
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () async {
                final updated = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => NotificationFilterPage(),
                );
                if (updated == true) {
                  _loadNotifications();
                  setState(() {});
                }
              }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFilterButton('Tümü', 'all'),
                        _buildFilterButton('Okundu', 'read'),
                        _buildFilterButton('Okunmadı', 'unread'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text("Henüz hiçbir bildirim yok"))
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];

                              final isRead = item['read'] == 1;
                              final borderColor =
                                  getAlarmStatusColor(item['alarm']);
                              final sensorIcon =
                                  _getSensorIcon(item['sensor_name']);

                              return Dismissible(
                                key: Key(item['id']),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    return await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Bildirimi Sil'),
                                        content: const Text(
                                            'Bu bildirimi silmek istediğinize emin misiniz?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('İptal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteNotification(item['id']);
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Sil',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return false;
                                },
                                child: GestureDetector(
                                  child: Stack(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderColor, width: 2),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(sensorIcon,
                                                    color: borderColor),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item['sensor_name'] ??
                                                            'Sensör',
                                                        style: theme.textTheme
                                                            .titleMedium
                                                            ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                      Text(
                                                        item['organisation_name'] ??
                                                            'Lokasyon Bilinmiyor',
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                                color: Colors
                                                                    .grey[700]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  "${item['deger'] ?? '-'}",
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: borderColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              DateFormat("dd.MM.yyyy HH:mm:ss")
                                                  .format(
                                                DateTime.tryParse(
                                                        item['received_at'] ??
                                                            '') ??
                                                    DateTime.now(),
                                              ),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isRead)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 2),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        },
        child: const Icon(Icons.arrow_upward),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
      ),
    );
  }

  Widget _buildFilterButton(String text, String status) {
    final isSelected = filterStatus == status;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Material(
          color: isSelected ? Colors.brown : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                filterStatus = status;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              alignment: Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationSubscription?.cancel();
    filters.clearFilters();
    super.dispose();
  }
}
