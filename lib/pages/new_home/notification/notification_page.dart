import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:akilli_anahtar/controllers/main/auth_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  String filterStatus = 'all';
  bool isLoading = false;
  final NotificationFilterController filters = Get.find();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  StreamSubscription? _notificationSubscription;
  int _pageSize = 20;
  bool _hasMore = true;
  bool _isFetching = false;
  int? lastEpoch;
  DateTime _currentDate = DateTime.now().toUtc().add(const Duration(hours: 3));
  String get currentDateKey => DateFormat('yyyy-MM-dd').format(_currentDate);

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
  }

  void _startLiveListener() {
    final userId = Get.find<AuthController>().user.value.id.toString();
    _notificationSubscription = _database
        .child('notifications/$userId/$todayKey')
        .orderByChild('received_at_epoch')
        .limitToLast(1)
        .onChildAdded
        .listen((event) {
      if (!mounted || event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data['id'] = event.snapshot.key;
      data['dateKey'] = event.snapshot.ref.parent?.key;

      final alreadyExists = notifications.any((n) => n['id'] == data['id']);
      if (alreadyExists) return;

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
    _isFetching = true;

    final userId = Get.find<AuthController>().user.value.id.toString();

    while (_hasMore && notifications.length < _pageSize) {
      final snapshot = await _database
          .child('notifications/$userId/$currentDateKey')
          .orderByChild('received_at_epoch')
          .limitToLast(100)
          .get();

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        final dayItems = data.entries.map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e.value as Map);
          final id = e.key;
          final dateKey = snapshot.key;
          map['id'] = id;
          map['dateKey'] = dateKey;
          return map;
        }).toList();

        dayItems.sort((a, b) => (a['received_at_epoch'] ?? 0)
            .compareTo(b['received_at_epoch'] ?? 0));

        notifications.addAll(dayItems);

        notifications.sort((a, b) => (b['received_at_epoch'] ?? 0)
            .compareTo(a['received_at_epoch'] ?? 0));

        if (notifications.length > _pageSize) {
          notifications = notifications.sublist(0, _pageSize);
          _hasMore = true;
          break;
        }
      }

      _currentDate = _currentDate.subtract(const Duration(days: 1));
    }

    _isFetching = false;
    setState(() {});
  }

  Future<void> markAllAsRead() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    final Map<String, Map<String, dynamic>> updatesPerDate = {};

    for (final notif in notifications) {
      final id = notif['id'];
      final dateKey = notif['dateKey'];
      if (id != null && dateKey != null) {
        updatesPerDate.putIfAbsent(dateKey, () => {});
        updatesPerDate[dateKey]!["$id/isRead"] = 1;
      }
    }

    for (final entry in updatesPerDate.entries) {
      final dateKey = entry.key;
      final updates = entry.value;
      final ref =
          FirebaseDatabase.instance.ref("notifications/$userId/$dateKey");
      await ref.update(updates);
    }

    if (!mounted) return;

    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = 1;
      }
      if (filterStatus == 'unread') {
        filterStatus = 'read';
      }
    });

    successSnackbar("Başarılı", "Tüm bildirimler okundu olarak işaretlendi.");
  }

  Future<void> deleteLast20() async {
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

    if (confirmed != true) return;

    final userId = Get.find<AuthController>().user.value.id.toString();
    final toDelete = notifications.take(20).toList();
    final Map<String, Map<String, dynamic>> deletePerDate = {};

    for (final notif in toDelete) {
      final id = notif['id'];
      final dateKey = notif['dateKey'];
      if (id != null && dateKey != null) {
        deletePerDate.putIfAbsent(dateKey, () => {});
        deletePerDate[dateKey]![id] = null;
      }
    }

    for (final entry in deletePerDate.entries) {
      final dateKey = entry.key;
      final deleteMap = entry.value;
      final ref =
          FirebaseDatabase.instance.ref("notifications/$userId/$dateKey");
      await ref.update(deleteMap);
    }

    setState(() {
      final ids = toDelete.map((n) => n['id']).toSet();
      notifications.removeWhere((n) => ids.contains(n['id']));
    });

    successSnackbar("Başarılı", "Son 20 bildirim silindi.");
    await _loadPaginatedNotifications();
  }

  IconData _getSensorIcon(String? sensorName) {
    if (sensorName == null) return sensorIcons['default']!;
    final lowerName = sensorName.toLowerCase();
    if (lowerName.contains('isi')) return sensorIcons['temperature']!;
    if (lowerName.contains('nem')) return sensorIcons['humidity']!;
    if (lowerName.contains('duman')) return sensorIcons['smoke']!;
    return sensorIcons['default']!;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = notifications
        .where((n) {
          final matchesSensor = filters.selectedSensor.value == null ||
              filters.selectedSensor.value!.isEmpty ||
              (n['sensor_name']?.toLowerCase() ?? '')
                  .contains(filters.selectedSensor.value!.toLowerCase());

          final selectedLocation = filters.selectedLocation.value;
          final locationName = (n['boxName'] ?? n['organisation_name'] ?? '')
              .toString()
              .toLowerCase();

          final matchesLocation = selectedLocation == null ||
              selectedLocation.isEmpty ||
              locationName.contains(selectedLocation.toLowerCase());

          final matchesAlarm = () {
            final selectedAlarm = filters.selectedAlarmLevel.value;
            if (selectedAlarm.isEmpty) return true;
            return (n['alarm']?.toString() ?? '') == selectedAlarm;
          }();

          final matchesReadStatus = () {
            if (filterStatus == 'read') return n['isRead'] == 1;
            if (filterStatus == 'unread') return n['isRead'] != 1;
            return true;
          }();

          return matchesSensor &&
              matchesLocation &&
              matchesAlarm &&
              matchesReadStatus;
        })
        .take(_pageSize)
        .toList();

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        backgroundColor: Colors.brown[50],
        title: const Text('Bildirimler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: deleteLast20,
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
                  await _loadPaginatedNotifications();

                  setState(() {});
                }
              }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPaginatedNotifications,
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

                              final isRead = item['isRead'] == 1;
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
                                              // _deleteNotification(item['id']);
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
