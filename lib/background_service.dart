// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stopService");
}

Future<bool> isRunning() async {
  final service = FlutterBackgroundService();
  return await service.isRunning();
}

void prnt(String message) {
  print("Background Service: $message");
}

Future<void> initializeService() async {
  prnt("initializing...");
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
    service.invoke("stopService");
  }
  prnt("initialized.");
  prnt("starting...");
  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  print(notificationResponse.actionId);
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
  int? userId;
  String? userName;
  String? password;
  String? token;
  late MyMqtt mqtt;
  List<HomeDeviceDto> devices = <HomeDeviceDto>[];

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    onDidReceiveNotificationResponse: (details) {
      if (details.actionId != null) {
        switch (details.actionId) {
          case 'action_30_min':
            LocalDb.add(
              notificationKey(details.id!),
              DateTime.now().add(Duration(seconds: 30)).toString(),
            );
            break;
          case 'action_2_hour':
            LocalDb.add(
              notificationKey(details.id!),
              DateTime.now().add(Duration(hours: 2)).toString(),
            );
            break;
          case 'action_8_hour':
            LocalDb.add(
              notificationKey(details.id!),
              DateTime.now().add(Duration(hours: 8)).toString(),
            );
            break;
          default:
            // Diğer durumlar
            break;
        }
      }
    },
  );

  userName = await LocalDb.get(userNameKey);
  password = await LocalDb.get(passwordKey);

  if (userName != null && password != null) {
    await AuthService.webLogin(LoginModel2(
      userName: userName,
      password: password,
    ));
    token = await LocalDb.get(webTokenKey);
    userId = int.tryParse(await LocalDb.get(userIdKey) ?? "");
  }

  if (token != null) {
    var parameterResponse = await httpGet(
      url: "$apiUrlOut/Home/getParameters?typeId=1",
      token: token,
    );
    if (parameterResponse.statusCode == 200) {
      var parameters = Parameter.fromJsonList(parameterResponse.body);
      if (parameters.isNotEmpty) {
        mqtt = MyMqtt(parameters);
        await mqtt.initialClient();
      }
    }
    if (userId != null) {
      devices = await getDevices(token, userId);
    }
  }

  if (devices.isNotEmpty) {
    for (HomeDeviceDto device in devices) {
      mqtt.subscribeToTopic(device.topicStat!);
    }

    mqtt.onMessage(
      (topic, message) async {
        if (message.contains("{")) {
          var result = json.decode(message);
          var status = result["deger"].toString();
          var deger = (result["deger"] is num)
              ? (result["deger"] as num).toDouble()
              : null;
          if (deger != null) {
            var device = devices.singleWhere(
              (d) => d.topicStat == topic,
              orElse: () => HomeDeviceDto(),
            );
            var active = false;
            result = await LocalDb.get(notificationKey(device.id!));
            if (result == null || result == "1") {
              active = true;
            } else {
              var time = DateTime.tryParse(result);
              if (time == null) {
                active = true;
              } else {
                active = time.isBefore(DateTime.now());
                LocalDb.add(notificationKey(device.id!), "1");
              }
            }
            if (device.id! > 0 && active) {
              int alarm = getAlarm(device, deger);
              if (alarm == 1) {
                _showNotification(
                  flutterLocalNotificationsPlugin,
                  device.id!,
                  device.name!,
                  "$status değeri için Sarı Alarm",
                );
              }
              if (alarm == 2) {
                _showNotification(
                  flutterLocalNotificationsPlugin,
                  device.id!,
                  device.name!,
                  "$status değeri için Kırmızı Alarm",
                );
              }
            }
          }
        }
      },
    );
  }

  Timer.periodic(const Duration(minutes: 1), (timer) async {
    prnt("service is successfully running ${DateTime.now().second}");
    if (token != null && userId != null) {
      devices = await getDevices(token, userId);
    }
  });
}

Future<List<HomeDeviceDto>> getDevices(String token, int userId) async {
  var devicesResponse = await httpGet(
    url: "$apiUrlOut/Home/getDevices?userId=$userId",
    token: token,
  );
  if (devicesResponse.statusCode == 200) {
    return HomeDeviceDto.fromJsonList(devicesResponse.body);
  }
  return <HomeDeviceDto>[];
}

Future<http.Response> httpGet(
    {required String url, required String token}) async {
  try {
    var uri = Uri.parse(url);
    var client = http.Client();
    var response = await client.get(
      uri,
      headers: {
        'content-type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $token',
      },
    );
    client.close();
    prnt(url);
    prnt(response.statusCode.toString());
    prnt(response.body);
    return response;
  } catch (e) {
    prnt(e.toString());
    return http.Response("hata", 999);
  }
}

int getAlarm(HomeDeviceDto device, double deger) {
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
  const AndroidNotificationAction action30Min = AndroidNotificationAction(
    'action_30_min',
    '30 Dakika Ertele',
    cancelNotification: true,
  );
  const AndroidNotificationAction action2Hour = AndroidNotificationAction(
    'action_2_hour',
    '2 Saat Ertele',
    cancelNotification: true,
  );
  const AndroidNotificationAction action8Hour = AndroidNotificationAction(
    'action_8_hour',
    '8 Saat Ertele',
    cancelNotification: true,
  );

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'Acil Durumlar',
    channelDescription: 'Alarm Bildirimleri',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    actions: <AndroidNotificationAction>[
      action30Min,
      action2Hour,
      action8Hour,
    ],
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
      id, title, body, platformChannelSpecifics);
}

class MyMqtt {
  final List<Parameter> parameters;
  late MqttServerClient mqttClient;

  MyMqtt(this.parameters);

  Future<void> initialClient() async {
    var host = parameters.firstWhere((p) => p.name == "mqtt_host_public").value;
    var port = int.tryParse(
            parameters.firstWhere((p) => p.name == "mqtt_port").value) ??
        1883;
    var userName = parameters.firstWhere((p) => p.name == "mqtt_user").value;
    var password =
        parameters.firstWhere((p) => p.name == "mqtt_password").value;
    var deviceId = await getDeviceId();
    var now = DateTime.now().toString();
    var identity = "$deviceId-$now";
    mqttClient = MqttServerClient(host, identity);
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
        .withClientIdentifier(identity)
        .withWillQos(MqttQos.atMostOnce);
    mqttClient.connectionMessage = connMess;
    await mqttClient.connect();
  }

  void subscribeToTopic(String topic) {
    if (mqttClient.getSubscriptionTopicStatus(topic) ==
        MqttSubscriptionStatus.active) {
      prnt("$topic already subscribbed");
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
    prnt('MQTT client connected');
  }

  void onDisconnected() {
    prnt('MQTT client disconnected');
  }

  void onSubscribed(MqttSubscription sb) {
    prnt("${sb.topic} subscribbed");
  }

  void pong() {
    prnt('Ping response received');
  }
}
