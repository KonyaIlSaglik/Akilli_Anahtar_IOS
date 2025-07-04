import 'package:akilli_anahtar/main.dart';
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
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool _dataLoaded = false;
  bool _minTimePassed = false;
  Timer? _minLoadingTimer;
  final NotificationFilterController filters = Get.find();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  StreamSubscription? _notificationSubscription;
  Timer? _dateCheckTimer;
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

  Future<void> _initLastDateKey() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    final ref = _database.child('notifications/$userId');
    final snapshot = await ref.get();

    if (!mounted) return;

    if (snapshot.exists && snapshot.value is Map) {
      final keys = (snapshot.value as Map).keys.toList();
      if (keys.isNotEmpty) {
        keys.sort();
        final lastKey = keys.last;

        try {
          final millis = int.tryParse(lastKey);
          if (millis != null) {
            _currentDate = DateTime.fromMillisecondsSinceEpoch(millis);
          } else {
            _currentDate = DateTime.now().toUtc().add(const Duration(hours: 3));
          }
        } catch (e) {
          _currentDate = DateTime.now().toUtc().add(const Duration(hours: 3));
        }
      } else {
        _currentDate = DateTime.now().toUtc().add(const Duration(hours: 3));
      }
    } else {
      _currentDate = DateTime.now().toUtc().add(const Duration(hours: 3));
    }
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _dataLoaded = false;
    _minTimePassed = false;
    flutterLocalNotificationsPlugin.cancelAll();

    _minLoadingTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _minTimePassed = true;
      if (!_dataLoaded) {
        setState(() {
          isLoading = false;
        });
      }
    });

    (() async {
      await _initLastDateKey();
      await _loadPaginatedNotifications(reset: false, retryCount: 0);
      _startLiveListener();
      if (!mounted) return;
      _dataLoaded = true;
      setState(() {
        isLoading = false;
      });
    })();
  }

  void _startLiveListener() {
    final userId = Get.find<AuthController>().user.value.id.toString();

    _notificationSubscription?.cancel();
    _dateCheckTimer?.cancel();

    _notificationSubscription =
        _database.child('notifications/$userId').onChildAdded.listen((event) {
      if (!mounted || event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data['id'] = event.snapshot.key;
      final alreadyExists = notifications.any((n) => n['id'] == data['id']);
      if (alreadyExists) {
        return;
      }
      setState(() {
        notifications.insert(0, data);
        if (notifications.length > _pageSize) {
          notifications = notifications.take(_pageSize).toList();
        }
      });
    }, onError: (error) {});

    _database.child('notifications/$userId').onChildChanged.listen((event) {
      if (!mounted || event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      data['id'] = event.snapshot.key;
      setState(() {
        final idx = notifications.indexWhere((n) => n['id'] == data['id']);
        if (idx != -1) {
          notifications[idx] = data;
        }
      });
    });

    _database.child('notifications/$userId').onChildRemoved.listen((event) {
      if (!mounted || event.snapshot.key == null) return;
      setState(() {
        notifications.removeWhere((n) => n['id'] == event.snapshot.key);
      });
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      isLoading = true;
      _dataLoaded = false;
      _minTimePassed = false;
    });
    _minLoadingTimer?.cancel();
    _minLoadingTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _minTimePassed = true;
      if (!_dataLoaded) {
        setState(() {
          isLoading = false;
        });
      }
    });
    _hasMore = true;
    _isFetching = false;
    notifications.clear();
    await _loadPaginatedNotifications(reset: true, retryCount: 0);
    _startLiveListener();
    _dataLoaded = true;
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadPaginatedNotifications(
      {bool reset = false, int retryCount = 0}) async {
    if (_isFetching) {
      return;
    }
    _isFetching = true;

    if (reset) {
      notifications.clear();
      lastEpoch = null;
      _hasMore = true;
    } else {
      if (retryCount == 0) {
        lastEpoch = null;
        _hasMore = true;
      }
    }

    final userId = Get.find<AuthController>().user.value.id.toString();
    final ref = FirebaseDatabase.instance.ref('notifications/$userId');

    Query query = ref.orderByKey().limitToLast(_pageSize);
    if (lastEpoch != null) {
      query = query.endBefore(lastEpoch.toString());
    }

    final snapshot = await query.get();

    if (!mounted) return;
    if (!snapshot.exists || snapshot.value is! Map) {
      _hasMore = false;
      _isFetching = false;
      setState(() {});
      return;
    }
    final rawData = Map<String, dynamic>.from(snapshot.value as Map);
    final sortedKeys = rawData.keys.toList()..sort();
    final newItems = sortedKeys.map((k) {
      final data = Map<String, dynamic>.from(rawData[k]);
      data['id'] = k;
      final millis = int.tryParse(k);
      if (millis != null) {
        data['received_at'] =
            DateTime.fromMillisecondsSinceEpoch(millis).toIso8601String();
      }
      return data;
    }).toList();
    notifications = newItems.reversed.take(_pageSize).toList();
    _hasMore = false;
    _isFetching = false;
    setState(() {});
  }

  Future<void> markAllAsRead() async {
    final userId = Get.find<AuthController>().user.value.id.toString();
    final Map<String, dynamic> updates = {};
    for (final notif in notifications) {
      final id = notif['id'];
      if (id != null) {
        updates['$id/isRead'] = 1;
      }
    }
    final ref = FirebaseDatabase.instance.ref("notifications/$userId");
    await ref.update(updates);

    if (!mounted) return;

    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = 1;
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
    final Map<String, dynamic> deletes = {};
    for (final notif in toDelete) {
      final id = notif['id'];
      if (id != null) {
        deletes[id] = null;
      }
    }
    final ref = FirebaseDatabase.instance.ref("notifications/$userId");
    await ref.update(deletes);

    setState(() {
      final ids = toDelete.map((n) => n['id']).toSet();
      notifications.removeWhere((n) => ids.contains(n['id']));
    });

    successSnackbar("Başarılı", "Son 20 bildirim silindi.");
    await _loadPaginatedNotifications(reset: false, retryCount: 0);
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

          return matchesSensor && matchesLocation && matchesAlarm;
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
                  await _loadPaginatedNotifications(
                      reset: false, retryCount: 0);
                  setState(() {});
                }
              }),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  Expanded(
                    child: (filtered.isEmpty && !_minTimePassed)
                        ? const Center(child: CircularProgressIndicator())
                        : (filtered.isEmpty && _minTimePassed)
                            ? const Center(
                                child: Text("Henüz hiçbir bildirim yok"))
                            : ListView.builder(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: filtered.length + (_hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == filtered.length) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final item = filtered[index];
                                  final isRead = item['isRead'] == 1;
                                  final borderColor =
                                      getAlarmStatusColor(item['alarm']);
                                  final sensorIcon =
                                      _getSensorIcon(item['sensor_name']);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Slidable(
                                      key: ValueKey(item['id']),
                                      endActionPane: ActionPane(
                                        motion: const DrawerMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: (context) async {
                                              final userId =
                                                  Get.find<AuthController>()
                                                      .user
                                                      .value
                                                      .id
                                                      .toString();
                                              final notifId = item['id'];
                                              final ref =
                                                  FirebaseDatabase.instance.ref(
                                                      'notifications/$userId/$notifId');
                                              await ref.update({'isRead': 1});
                                              setState(() {
                                                item['isRead'] = 1;
                                              });
                                            },
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            icon: Icons.mark_email_read,
                                            label: 'Okundu',
                                          ),
                                          SlidableAction(
                                            onPressed: (context) async {
                                              final userId =
                                                  Get.find<AuthController>()
                                                      .user
                                                      .value
                                                      .id
                                                      .toString();
                                              final notifId = item['id'];
                                              final ref =
                                                  FirebaseDatabase.instance.ref(
                                                      'notifications/$userId/$notifId');
                                              await ref.remove();
                                              setState(() {
                                                notifications.removeWhere(
                                                    (n) => n['id'] == notifId);
                                              });
                                            },
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Sil',
                                          ),
                                        ],
                                      ),
                                      child: GestureDetector(
                                        child: IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    border: Border.all(
                                                        color: borderColor,
                                                        width: 2),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(sensorIcon,
                                                                  color:
                                                                      borderColor),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      item['sensor_name'] ??
                                                                          'Sensör',
                                                                      style: theme
                                                                          .textTheme
                                                                          .titleMedium
                                                                          ?.copyWith(
                                                                              fontWeight: FontWeight.bold),
                                                                    ),
                                                                    Text(
                                                                      item['organisation_name'] ??
                                                                          'Lokasyon Bilinmiyor',
                                                                      style: theme
                                                                          .textTheme
                                                                          .bodySmall
                                                                          ?.copyWith(
                                                                              color: Colors.grey[700]),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Text(
                                                                "${item['deger'] ?? '-'}",
                                                                style: theme
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color:
                                                                            borderColor),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 8),
                                                          Text(
                                                            DateFormat(
                                                                    "dd.MM.yyyy HH:mm:ss")
                                                                .format(DateTime.tryParse(
                                                                        item['received_at'] ??
                                                                            '') ??
                                                                    DateTime
                                                                        .now()),
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: Colors
                                                                            .grey[
                                                                        600]),
                                                          ),
                                                        ],
                                                      ),
                                                      if (!isRead)
                                                        Positioned(
                                                          top: -2,
                                                          right: 0,
                                                          child: Container(
                                                            width: 12,
                                                            height: 12,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .white,
                                                                  width: 2),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: 3,
                                                decoration: BoxDecoration(
                                                  color: isRead
                                                      ? Colors.grey
                                                      : Colors.deepOrange,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(0),
                                                    bottomRight:
                                                        Radius.circular(0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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

  @override
  void dispose() {
    _scrollController.dispose();
    _notificationSubscription?.cancel();
    _dateCheckTimer?.cancel();
    _minLoadingTimer?.cancel();
    filters.clearFilters();
    super.dispose();
  }
}
