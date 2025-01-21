import 'dart:convert';

import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/services/api/home_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:get/get.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MqttController extends GetxController {
  var host = "".obs;
  var port = 1883.obs;
  var userName = "".obs;
  var password = "".obs;
  var connecting = false.obs;
  late MqttServerClient client;
  var isConnected = false.obs;
  var status = 'Disconnected'.obs;
  List<Function(String topic)> subListenerList = <Function(String topic)>[].obs;
  var globalTopic = "".obs;
  late FlutterLocalNotificationsPlugin localNotifications;

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
        .startClean()
        .withClientIdentifier(identifier)
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
    try {
      status.value = 'Connecting';
      await client.connect();
    } catch (e) {
      status.value = 'Connection failed: $e';
      client.disconnect();
    } finally {
      connecting.value = false;
    }
  }

  void onConnected() {
    isConnected.value = true;
    status.value = 'Connected';
    print('MQTT client connected');
    if (globalTopic.value.isNotEmpty) {
      subscribeToTopic(globalTopic.value);
    }
  }

  void onDisconnected() {
    isConnected.value = false;
    status.value = 'Disconnected';
    print('MQTT client disconnected');
  }

  void onSubscribed(MqttSubscription sb) {
    print("${sb.topic} subscribbed");
    for (var listen in subListenerList) {
      listen(sb.topic.toString());
    }
  }

  void pong() {
    print('Ping response received');
  }

  void subscribeToTopic(String topic) {
    if (client.getSubscriptionTopicStatus(topic) ==
        MqttSubscriptionStatus.active) {
      print("$topic already subscribbed");
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

  void publishMessage(String topic, String message) {
    final builder = MqttPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  @override
  void onClose() {
    client.disconnect();
    super.onClose();
  }

  Future<void> showNotification(String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'Your Channel Name',
            channelDescription: 'Your Channel Description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotifications.show(
        0, 'MQTT Message', message, platformChannelSpecifics);
  }
}
