import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:akilli_anahtar/entities/device.dart';
import 'package:http/http.dart' as http;
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

String url = "$apiUrlOut/Auth";

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
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
    ),
  );
  if (await service.isRunning()) {
    service.invoke("stop");
  }
  service.startService();
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
  var userId = await LocalDb.get(userIdKey) ?? "";
  var accessToken = "";
  var host = await LocalDb.get(mqttHostKey) ?? "";
  var port = int.tryParse((await LocalDb.get(mqttPortKey)) ?? "1883") ?? 1883;
  var userName = await LocalDb.get(mqttUserKey) ?? "";
  var password = await LocalDb.get(mqttPasswordKey) ?? "";

  var loginUser = await LocalDb.get(userNameKey) ?? "";
  var loginPassword = await LocalDb.get(passwordKey) ?? "";
  await login(loginUser, loginPassword);
  accessToken = await LocalDb.get(accessTokenKey) ?? "";

  MqttServerClient mqttClient = MqttServerClient(host, identifier);
  mqttClient.port = port;
  mqttClient.keepAlivePeriod = 60;
  mqttClient.autoReconnect = true;
  mqttClient.resubscribeOnAutoReconnect = true;
  mqttClient.onConnected = onConnected;
  mqttClient.onDisconnected = onDisconnected;
  mqttClient.onSubscribed = onSubscribed;
  mqttClient.pongCallback = pong;
  final MqttConnectMessage connMess = MqttConnectMessage()
      .authenticateAs(userName, password)
      .startClean()
      .withClientIdentifier(identifier)
      .withWillQos(MqttQos.atMostOnce);
  mqttClient.connectionMessage = connMess;

  await mqttClient.connect();

  List<Device> devices = <Device>[];

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  Timer.periodic(const Duration(seconds: 10), (timer) async {
    print("service is successfully running ${DateTime.now().second}");
    if (devices.isEmpty) {
      if (userId.isNotEmpty && accessToken.isNotEmpty) {
        devices = await getDevices(userId, accessToken) ?? List.empty();
        if (devices.isNotEmpty) {
          for (Device device in devices) {
            if (device.typeId == 1 ||
                device.typeId == 2 ||
                device.typeId == 3) {
              mqttClient.subscribe(device.topicStat, MqttQos.atLeastOnce);
            }
          }
        }
      }
      mqttClient.updates.listen((List<MqttReceivedMessage<MqttMessage>> event) {
        var topic = event[0].topic;
        var response = event[0].payload as MqttPublishMessage;
        var message = Utf8Decoder().convert(response.payload.message!);
        print("$topic : $message");
        if (topic != null) {
          if (devices.isNotEmpty) {
            var device = devices.singleWhere(
              (d) => d.topicStat == topic,
              orElse: () {
                return Device();
              },
            );
            if (device.id > 0 && topic == device.topicStat) {
              if (message.contains("{")) {
                var result = json.decode(message);
                var status = result["deger"].toString();
                int alarm = 0;
                var deger = (result["deger"] is num)
                    ? (result["deger"] as num).toDouble()
                    : null;
                if (deger != null) {
                  print("gelen deger: $deger");
                  if (device.normalMinValue != null ||
                      device.normalMaxValue != null) {
                    if (deger < device.normalMinValue! ||
                        deger > device.normalMaxValue!) {
                      alarm = 1;
                    }
                  }
                  if (device.criticalMinValue != null ||
                      device.criticalMaxValue != null) {
                    if (deger < device.criticalMinValue! ||
                        deger > device.criticalMaxValue!) {
                      alarm = 2;
                    }
                  }
                  print("alarm durum: $alarm");
                  if (alarm == 1) {
                    _showNotification(
                      flutterLocalNotificationsPlugin,
                      device.id,
                      device.name,
                      "$status değeri için Sarı Alarm",
                    );
                  }

                  if (alarm == 2) {
                    _showNotification(
                      flutterLocalNotificationsPlugin,
                      device.id,
                      device.name,
                      "$status değeri için Kırmızı Alarm",
                    );
                  }
                  alarm = 0;
                }
              }
            }
          }
        }
      });
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
  int id,
  String title,
  String body,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('your_channel_id', 'Acil Durumlar',
          channelDescription: 'Cihaz Alarm Bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false);
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      id, title, body, platformChannelSpecifics);
}

Future<void> login(String userName, String password) async {
  var uri = Uri.parse("$url/webLogin");
  var client = http.Client();
  print(json.encode({
    "userName": userName,
    "password": password,
    "identity": "",
  }));
  try {
    var response = await client
        .post(
          uri,
          headers: {
            'content-type': 'application/json; charset=utf-8',
          },
          body: json.encode({
            "userName": userName,
            "password": password,
            "identity": "",
          }),
        )
        .timeout(Duration(seconds: 10));
    client.close();
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      var token = data["token"] as String;
      await LocalDb.add(accessTokenKey, token);
      // var expiration = User.fromJson(json.encode(data["expiration"]));
      // LocalDb.add(userIdKey, user.id.toString());
      return;
    } else {
      errorSnackbar("Hata", response.body);
    }
  } catch (e) {
    errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
    print(e);
  }
  return;
}

Future<List<Device>?> getDevices(userId, accessToken) async {
  try {
    var uri = Uri.parse("$url/getData?userId=$userId");
    var httpClient = http.Client();
    var response = await httpClient.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $accessToken',
      },
    );
    httpClient.close();

    print("$url/getData?userId=$userId");
    print(accessToken);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = json.decode(response.body) as Map<String, dynamic>;
      print(json.encode(data["devices"]));
      var devices = Device.fromJsonList(json.encode(data["devices"]));
      return devices;
    }
  } catch (e) {
    print(e);
    return null;
  }
  return null;
}
