// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

import 'package:akilli_anahtar/entities/device.dart';
import 'package:akilli_anahtar/entities/user.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';

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
      initialNotificationTitle: "Akıllı Anahtar",
      initialNotificationContent: "Arka planda çalışıyor",
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
  String? userName;
  String? password;
  TokenModel? tokenModel;
  User? user;
  late MyMqtt mqtt;
  List<Device>? devices;

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  userName = await LocalDb.get(userNameKey);
  password = await LocalDb.get(passwordKey);

  if (userName != null && password != null) {
    tokenModel = await login(userName, password);
  }

  if (tokenModel != null) {
    user = await getByUserName(userName!, tokenModel.token!);

    var mqttModel = await getMqttParameters(tokenModel.token!);
    if (mqttModel != null) {
      mqtt = MyMqtt(mqttModel);
      await mqtt.initialClient();
    }
  }

  if (tokenModel != null && user != null) {
    devices = await getDevices(user.id, tokenModel.token!);
  }

  if (devices != null && devices.isNotEmpty) {
    for (Device device in devices) {
      mqtt.subscribeToTopic(device.topicStat);
    }

    mqtt.onMessage(
      (topic, message) {
        if (message.contains("{")) {
          var result = json.decode(message);
          var status = result["deger"].toString();
          var deger = (result["deger"] is num)
              ? (result["deger"] as num).toDouble()
              : null;
          if (deger != null) {
            var device = devices!.singleWhere(
              (d) => d.topicStat == topic,
              orElse: () => Device(),
            );
            if (device.id > 0) {
              int alarm = getAlarm(device, deger);
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
            }
          }
        }
      },
    );
  }

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    print("service is successfully running ${DateTime.now().second}");
    if (tokenModel != null && user != null) {
      devices = await getDevices(user.id, tokenModel.token!);
    }
  });
}

int getAlarm(Device device, double deger) {
  int alarm = 0;
  if (device.normalMinValue != null || device.normalMaxValue != null) {
    if (deger < device.normalMinValue! || deger > device.normalMaxValue!) {
      alarm = 1;
    }
  }
  if (device.criticalMinValue != null || device.criticalMaxValue != null) {
    if (deger < device.criticalMinValue! || deger > device.criticalMaxValue!) {
      alarm = 2;
    }
  }
  return alarm;
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

class MyMqtt {
  final MqttModel mqttModel;
  late MqttServerClient mqttClient;

  MyMqtt(this.mqttModel);

  Future<void> initialClient() async {
    mqttClient = MqttServerClient(mqttModel.host, mqttModel.identity);
    mqttClient.port = mqttModel.port;
    mqttClient.keepAlivePeriod = 60;
    mqttClient.autoReconnect = true;
    mqttClient.resubscribeOnAutoReconnect = true;
    mqttClient.onConnected = onConnected;
    mqttClient.onDisconnected = onDisconnected;
    mqttClient.onSubscribed = onSubscribed;
    mqttClient.pongCallback = pong;
    final MqttConnectMessage connMess = MqttConnectMessage()
        .authenticateAs(mqttModel.userName, mqttModel.password)
        .startClean()
        .withClientIdentifier(mqttModel.identity)
        .withWillQos(MqttQos.atMostOnce);
    mqttClient.connectionMessage = connMess;
    await mqttClient.connect();
  }

  void subscribeToTopic(String topic) {
    if (mqttClient.getSubscriptionTopicStatus(topic) ==
        MqttSubscriptionStatus.active) {
      print("$topic already subscribbed");
      return;
    }
    mqttClient.subscribe(topic, MqttQos.atMostOnce);
  }

  void onMessage(Function(String topic, String message) onMessage) {
    mqttClient.updates.listen((event) {
      var response = event[0].payload as MqttPublishMessage;
      var message = Utf8Decoder().convert(response.payload.message!);
      onMessage(event[0].topic.toString(), message);
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
}

Future<TokenModel?> login(String userName, String password) async {
  String url = "$apiUrlOut/Auth";
  var uri = Uri.parse("$url/webLogin");
  var client = http.Client();
  try {
    print("$url/webLogin");
    print(json.encode({
      "userName": userName,
      "password": password,
      "identity": "",
    }));
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
      return TokenModel.fromJson(response.body);
    }
  } catch (e) {
    errorSnackbar("Hata", "Oturum Açma Sırasında bir hata oluştu.");
    print(e);
  }
  return null;
}

Future<User?> getByUserName(String userName, String token) async {
  String url = "$apiUrlOut/User";
  try {
    var uri = Uri.parse("$url/getByUserName?userName=$userName");
    print("$url/getByUserName?userName=$userName");
    var httpClient = http.Client();
    var response = await httpClient.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );
    httpClient.close();
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return User.fromJson(response.body);
    }
  } catch (e) {
    print(e);
    return null;
  }
  return null;
}

Future<MqttModel?> getMqttParameters(String token) async {
  String url = "$apiUrlOut/Parameter";
  try {
    var uri = Uri.parse("$url/getAllByTypeId?id=1");
    print("$url/getAllByTypeId?id=1");
    var httpClient = http.Client();
    var response = await httpClient.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );
    httpClient.close();
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var parameters = Parameter.fromJsonList(response.body);
      if (parameters.isNotEmpty) {
        var host =
            parameters.firstWhere((p) => p.name == "mqtt_host_public").value;
        var port = int.tryParse(
                parameters.firstWhere((p) => p.name == "mqtt_port").value) ??
            1883;
        var userName =
            parameters.firstWhere((p) => p.name == "mqtt_user").value;
        var password =
            parameters.firstWhere((p) => p.name == "mqtt_password").value;
        var deviceId = await getDeviceId();
        var now = DateTime.now().toString();
        var identity = "$deviceId-$now";
        return MqttModel(
            host: host,
            port: port,
            userName: userName,
            password: password,
            identity: identity);
      }
    }
  } catch (e) {
    print(e);
    return null;
  }
  return null;
}

Future<List<Device>?> getDevices(userId, token) async {
  String url = "$apiUrlOut/Device";
  try {
    var uri = Uri.parse("$url/getAllByUserId?id=$userId");
    print("$url/getAllByUserId?id=$userId");
    var httpClient = http.Client();
    var response = await httpClient.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );
    httpClient.close();
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      var devices = Device.fromJsonList(response.body);
      return devices;
    }
  } catch (e) {
    print(e);
    return null;
  }
  return null;
}

class TokenModel {
  String? token;
  String? expiration;
  TokenModel({
    this.token,
    this.expiration,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
      'expiration': expiration,
    };
  }

  factory TokenModel.fromMap(Map<String, dynamic> map) {
    return TokenModel(
      token: map['token'] != null ? map['token'] as String : null,
      expiration:
          map['expiration'] != null ? map['expiration'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenModel.fromJson(String source) =>
      TokenModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class MqttModel {
  String host;
  int port;
  String userName;
  String password;
  String identity;
  MqttModel({
    required this.host,
    required this.port,
    required this.userName,
    required this.password,
    required this.identity,
  });
}
