import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  var deviceId = await getDeviceId();
  var now = DateTime.now().toString();
  var identifier = "$deviceId-$now";

  MqttServerClient client = MqttServerClient("red.oss.net.tr", identifier);
  client.port = 1883;
  client.keepAlivePeriod = 60;
  client.autoReconnect = true;
  client.resubscribeOnAutoReconnect = true;
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onSubscribed = onSubscribed;
  client.pongCallback = pong;
  final MqttConnectMessage connMess = MqttConnectMessage()
      .authenticateAs("mcan", "admknh06")
      .startClean()
      .withClientIdentifier(identifier)
      .withWillQos(MqttQos.atMostOnce);
  client.connectionMessage = connMess;

  await client.connect();

  client.subscribe('CCCC', MqttQos.atLeastOnce);

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  client.updates.listen((List<MqttReceivedMessage<MqttMessage>> event) {
    var topic = event[0].topic;
    if (topic != null && topic == "CCCC") {
      var response = event[0].payload as MqttPublishMessage;
      var message = Utf8Decoder().convert(response.payload.message!);
      // Bildirim gösterimi
      _showNotification(flutterLocalNotificationsPlugin, message);
    }
  });

  Timer.periodic(const Duration(seconds: 5), (timer) {
    print("service is successfully running ${DateTime.now().second}");
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttPayloadBuilder();
      builder.addString("message: ${DateTime.now()}");
      client.publishMessage("BBBB", MqttQos.atMostOnce, builder.payload!);
    }
  });
}

void onConnected() {
  print('MQTT client connected');
}

void onDisconnected() {
  print('MQTT client disconnected');
}

void onSubscribed(MqttSubscription sb) {
  print("${sb.topic} subscribbed");
}

void pong() {
  print('Ping response received');
}

Future<void> _showNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    String message) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your_channel_id', 'Acil Durumlar',
          channelDescription: 'Cihaz Alarm Bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      0, 'MQTT Message', message, platformChannelSpecifics);
}
