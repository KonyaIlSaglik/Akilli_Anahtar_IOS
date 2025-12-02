import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:akilli_anahtar/dtos/home_device_dto.dart';

class MqttController extends GetxController {
  var host = "".obs;
  var port = 1883.obs;
  var userName = "".obs;
  var password = "".obs;
  var connecting = false.obs;
  late MqttServerClient client;
  var isConnected = false.obs;
  final availability = <int, String>{}.obs;
  var status = 'Disconnected'.obs;
  List<Function(String topic)> subListenerList = <Function(String topic)>[].obs;
  var globalTopic = "".obs;
  final List<String> _pendingTopics = [];
  final availabilityByBoxId = <int, String>{}.obs;
  final availabilityTs = <int, DateTime>{}.obs;
  final deviceValueById = <int, String>{}.obs;
  final deviceAlarmById = <int, int>{}.obs;
  final lastMsgAtById = <int, DateTime>{}.obs;
  StreamSubscription? _updatesSub;
  bool _wired = false;
  final retainedByTopic = <String, String>{}.obs;

  final lastStatusByTopic = <String, String>{}.obs;

  void wireUpdatesOnce() {
    _updatesSub = client.updates.listen((events) {
      final msg = events.first;
      final pub = msg.payload as MqttPublishMessage;
      final payload = const Utf8Decoder().convert(pub.payload.message!);
      final topic = msg.topic.toString();

      lastStatusByTopic[topic] = payload;
      lastStatusByTopic.refresh();
      retainedByTopic[topic] = payload;
      retainedByTopic.refresh();

      if (topic.endsWith('/availability')) {
        final parts = topic.split('/');
        if (parts.length >= 3) {
          final boxId = int.tryParse(parts[1]);
          if (boxId != null) {
            final state = payload.trim().toLowerCase();
            availabilityByBoxId[boxId] = state;
            availabilityTs[boxId] = DateTime.now();
          }
        }
        return;
      }

      if (topic.endsWith('/stat') || topic == globalTopic.value) {
        try {
          if (payload.isNotEmpty && !payload.startsWith('{')) {
            final parts = topic.split('/');
            if (parts.length >= 3) {
              final deviceId = int.tryParse(parts[1]);
              if (deviceId != null) {
                deviceValueById[deviceId] = payload.trim();
                lastMsgAtById[deviceId] = DateTime.now();
              }
            }
          } else if (payload.isNotEmpty && payload.startsWith('{')) {
            final map = json.decode(payload);

            final int? deviceId = (map['device_id'] is int)
                ? map['device_id'] as int
                : int.tryParse('${map['device_id']}');

            if (deviceId != null) {
              final raw = map['deger'];
              final valueStr = raw == null ? '' : raw.toString();

              int alarm = 0;
              if (map.containsKey('alarm')) {
                final a = map['alarm'];
                alarm = a is int
                    ? a.clamp(0, 2)
                    : (int.tryParse('$a') ?? 0).clamp(0, 2);
              }

              deviceValueById[deviceId] = valueStr;
              deviceAlarmById[deviceId] = alarm;
              lastMsgAtById[deviceId] = DateTime.now();
            }
          }
        } catch (_) {}
      }
    });
    _wired = true;
  }

  @override
  void onClose() {
    _updatesSub?.cancel();
    client.disconnect();
    super.onClose();
  }

  Future<void> subscribeAvailabilityFor(List<int> boxId) async {
    for (final id in boxId) {
      subscribeToTopic("akilliAnahtar/$id/availability");
    }
  }

  Future<void> initClient() async {
    connecting.value = true;
    await getMqttParameters();
    var deviceId = await getDeviceId();
    var now = DateTime.now().toString();
    var identifier = "$deviceId-$now";

    client = MqttServerClient(host.value, identifier);
    client.port = port.value;
    client.keepAlivePeriod = 60;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(userName.value, password.value)
        .withClientIdentifier(identifier)
        .withSessionExpiryInterval(0)
        .keepAliveFor(30)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    client.connectionMessage = connMess;
    print("Mqtt initialized");
    await connect();
  }

  Future<void> getMqttParameters() async {
    var parameters = await HomeService.getParameters(1) ?? <Parameter>[];

    if (parameters.isNotEmpty) {
      host.value =
          parameters.firstWhere((p) => p.name == "mqtt_host_public").value;
      port.value = int.tryParse(
              parameters.firstWhere((p) => p.name == "mqtt_port").value) ??
          1883;
      userName.value =
          parameters.firstWhere((p) => p.name == "mqtt_user").value;
      password.value =
          parameters.firstWhere((p) => p.name == "mqtt_password").value;
    }
  }

  Future<void> connect() async {
    connecting.value = true;
    try {
      await client.connect();
    } catch (e) {
      isConnected.value = false;
      connecting.value = false;
      print("MQTT connection error: $e");
    }
  }

  void onConnected() {
    isConnected.value = true;
    connecting.value = false;
    status.value = 'Connected';
    print('MQTT client connected');

    wireUpdatesOnce();

    for (final topic in _pendingTopics) {
      subscribeToTopic(topic);
    }
    _pendingTopics.clear();

    if (globalTopic.value.isNotEmpty) {
      subscribeToTopic(globalTopic.value);
    }
  }

  void onDisconnected() {
    isConnected.value = false;
    connecting.value = false;
    status.value = 'Disconnected';
    print('MQTT client disconnected');
  }

  void onSubscribed(MqttSubscription sb) {
    print("${sb.topic} subscribed");
    for (var listen in subListenerList) {
      listen(sb.topic.toString());
    }

    final topic = sb.topic.toString();
    if (lastStatusByTopic.containsKey(topic)) {
      lastStatusByTopic.refresh();
    }
  }

  void pong() {
    print('Ping response received');
  }

  void subscribeToTopic(String topic) {
    if (client.connectionStatus?.state != MqttConnectionState.connected) {
      print("MQTT not ready, queuing topic: $topic");
      if (!_pendingTopics.contains(topic)) {
        _pendingTopics.add(topic);
      }
      return;
    }

    if (client.getSubscriptionTopicStatus(topic) ==
        MqttSubscriptionStatus.active) {
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void onMessage(Function(String topic, String message) onMessage) {
    client.updates.listen((event) {
      var response = event[0].payload as MqttPublishMessage;
      var message = Utf8Decoder().convert(response.payload.message!);
      onMessage(event[0].topic.toString(), message);
    });
  }

  MqttSubscriptionStatus getSubscriptionTopicStatus(topic) {
    return client.getSubscriptionTopicStatus(topic);
  }

  void publishMessage(String topic, String message, [bool retain = false]) {
    final builder = MqttPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!,
        retain: retain);
  }

  bool isDeviceOffline(HomeDeviceDto d) {
    String? state;
    final boxId = d.boxId ?? d.id;

    if (boxId != null) state = availabilityByBoxId[boxId];
    if (state == null && d.id != null) state = availability[d.id!];

    return (state ?? 'online').toLowerCase() == 'offline';
  }

  bool? getRetainedStatBool(HomeDeviceDto d) {
    final t = d.topicStat;
    if (t == null) return null;
    final p = retainedByTopic[t];
    if (p == null) return null;
    return p.trim() == '0'; // 0=ON, 1=OFF
  }

  String? getLastStatusForTopic(String? topic) {
    if (topic == null || topic.isEmpty) return null;
    return lastStatusByTopic[topic];
  }

  String? getDeviceLastStatus(HomeDeviceDto device) {
    final topic = device.topicStat;
    if (topic == null || topic.isEmpty) return null;
    return lastStatusByTopic[topic];
  }

  bool hasStatusForTopic(String? topic) {
    if (topic == null || topic.isEmpty) return false;
    return lastStatusByTopic.containsKey(topic) &&
        lastStatusByTopic[topic]!.isNotEmpty;
  }
}
