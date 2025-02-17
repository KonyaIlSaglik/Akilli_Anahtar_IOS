// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:akilli_anahtar/entities/sensor_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

import 'package:akilli_anahtar/dtos/home_device_dto.dart';
import 'package:akilli_anahtar/entities/parameter.dart';
import 'package:akilli_anahtar/models/notification_model.dart';
import 'package:akilli_anahtar/models/login_model2.dart';
import 'package:akilli_anahtar/services/api/auth_service.dart';
import 'package:akilli_anahtar/services/local/shared_prefences.dart';
import 'package:akilli_anahtar/utils/constants.dart';

Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.startService();
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
      isForegroundMode: false,
      autoStartOnBoot: false,
      initialNotificationTitle: "Akıllı Anahtar",
      initialNotificationContent: "Arka planda çalışıyor",
      foregroundServiceTypes: [
        AndroidForegroundType.remoteMessaging,
        AndroidForegroundType.location,
        AndroidForegroundType.dataSync,
      ],
    ),
  );
  if (await service.isRunning()) {
    prnt("Service already running, stopping it first...");
    service.invoke("stopService");
  }

  await Future.delayed(Duration(seconds: 3));
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
  prnt("notificationTapBackground.");
  if (notificationResponse.actionId == null) {
    prnt("No action ID provided.");
    return;
  }
  var token = await LocalDb.get(webTokenKey);
  var userId = int.tryParse(await LocalDb.get(userIdKey) ?? "");
  var data = NotificationModel(
    userId: userId,
    deviceId: notificationResponse.id!,
  );
  prnt(notificationResponse.actionId!);
  switch (notificationResponse.actionId) {
    case 'action_30_min':
      data.status = 30;
      data.datetime = DateTime.now().add(Duration(minutes: 30));
      await updateNotification(token!, data);
      break;
    case 'action_2_hour':
      data.status = 120;
      data.datetime = DateTime.now().add(Duration(minutes: 120));
      await updateNotification(token!, data);
      break;
    case 'action_8_hour':
      data.status = 480;
      data.datetime = DateTime.now().add(Duration(minutes: 480));
      await updateNotification(token!, data);
      break;
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  String? token;
  int? userId;
  var userName = await LocalDb.get(userNameKey);
  var password = await LocalDb.get(passwordKey);
  if (userName != null && password != null) {
    await AuthService.webLogin(LoginModel2(
      userName: userName,
      password: password,
    ));
    token = await LocalDb.get(webTokenKey);
    var userIdStr = await LocalDb.get(userIdKey) ?? "";
    userId = int.tryParse(userIdStr);
  }
  var minStr = await LocalDb.get(notificationRangeKey);
  int min = int.parse(minStr ?? "5");

  Timer.periodic(Duration(minutes: min), (timer) async {
    prnt("service is successfully running ${DateTime.now().second}");

    if (token != null && userId != null) {
      var devices = await getDevices(token, userId);
      for (var device in devices) {
        var response = await httpGet(
          url:
              "$apiUrlOut/Home/getNotificationMessage?userId=$userId&deviceId=${device.id}&lastMin=$min",
          token: token,
        );
        if (response.statusCode == 200) {
          var sensorMessage = SensorMessage.fromJson(response.body);
          if (sensorMessage.alarmStatus == 1) {
            _showNotification(
              flutterLocalNotificationsPlugin,
              device.id!,
              "${device.boxName!}/${device.name!}",
              "${sensorMessage.value} değeri için uyarı",
            );
          }
          if (sensorMessage.alarmStatus == 2) {
            _showNotification(
              flutterLocalNotificationsPlugin,
              device.id!,
              "${device.boxName!}/${device.name!}",
              "${sensorMessage.value} değeri için kritik değer",
            );
          }
        }
      }
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

// Future<NotificationModel> getNotification(
//   String token,
//   int userId,
//   int deviceId,
// ) async {
//   var response = await httpGet(
//     url: "$apiUrlOut/Home/getNotification?userId=$userId&deviceId=$deviceId",
//     token: token,
//   );
//   if (response.statusCode == 200) {
//     return NotificationModel.fromJson(response.body);
//   }
//   return NotificationModel(
//       userId: userId, deviceId: deviceId, status: 1, datetime: null);
// }

@pragma('vm:entry-point')
Future<bool> updateNotification(
    String token, NotificationModel notificationModel) async {
  prnt("updateNotification...............");
  prnt("$apiUrlOut/Home/updateNotification");
  prnt(notificationModel.toJson());
  var response = await http.put(
    Uri.parse("$apiUrlOut/Home/updateNotification"),
    headers: {
      'content-type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $token',
    },
    body: notificationModel.toJson(),
  );
  prnt(response.body);
  if (response.statusCode == 200) {
    return response.body == "true";
  }
  return false;
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

// int getAlarm(HomeDeviceDto device, double deger) {
//   int alarm = 0;
//   if (device.normalMaxValue != null) {
//     if (deger > device.normalMaxValue!) {
//       alarm = 1;
//     }
//   }
//   if (device.criticalMaxValue != null) {
//     if (deger > device.criticalMaxValue!) {
//       alarm = 2;
//     }
//   }
//   return alarm;
// }

Future<void> _showNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  int id,
  String title,
  String body,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'Acil Durumlar',
    channelDescription: 'Alarm Bildirimleri',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
    actions: [
      AndroidNotificationAction(
        'action_30_min',
        '30 Dakika Ertele',
        cancelNotification: true,
      ),
      AndroidNotificationAction(
        'action_2_hour',
        '2 Saat Ertele',
        cancelNotification: true,
      ),
      AndroidNotificationAction(
        'action_8_hour',
        '8 Saat Ertele',
        cancelNotification: true,
      ),
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
    try {
      await mqttClient.connect();
    } catch (e) {
      prnt("MQTT connection failed: $e");
    }
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



  // if (token != null) {
  //   var parameterResponse = await httpGet(
  //     url: "$apiUrlOut/Home/getParameters?typeId=1",
  //     token: token,
  //   );
  //   if (parameterResponse.statusCode == 200) {
  //     var parameters = Parameter.fromJsonList(parameterResponse.body);
  //     if (parameters.isNotEmpty) {
  //       mqtt = MyMqtt(parameters);
  //       await mqtt.initialClient();
  //     }
  //   }
  //   if (userId != null) {
  //     devices = await getDevices(token, userId);
  //   }
  // }

  // if (devices.isNotEmpty) {
  //   for (HomeDeviceDto device in devices) {
  //     mqtt.subscribeToTopic(device.topicStat!);
  //   }

  //   mqtt.onMessage(
  //     (topic, message) async {
  //       if (message.startsWith('{') && message.endsWith('}')) {
  //         var espMessage = EspMessageModel.fromJson(message);
  //         if (espMessage.alarm > 0) {
  //           espMessageTemp.add(espMessage);
  //         }
  //         var device = devices.singleWhere(
  //           (d) => d.topicStat == topic,
  //           orElse: () => HomeDeviceDto(),
  //         );

  //         var model = await getNotification(token!, userId!, device.id!);
  //         prnt("durum: $message");
  //         prnt("notif: ${model.toJson()}");
  //         if (model.datetime != null &&
  //             model.datetime!.isBefore(DateTime.now())) {
  //           model.status = 1;
  //           model.datetime = null;
  //           await updateNotification(token, model);
  //         }
  //         if (device.id != null && espMessage.alarm > 0) {
  //           if (espMessage.alarm == 1) {
  //             if (normalValueCountList[device.id]! == 20) {
  //               _showNotification(
  //                 flutterLocalNotificationsPlugin,
  //                 device.id!,
  //                 "${device.boxName!}/${device.name!}",
  //                 "$status değeri için Sarı Alarm",
  //               );
  //               normalValueCountList[device.id!] = 0;
  //               criticalValueCountList[device.id!] = 0;
  //             } else {
  //               normalValueCountList[device.id!] =
  //                   normalValueCountList[device.id!]! + 1;
  //             }
  //           }
  //           if (alarm == 2) {
  //             if (criticalValueCountList[device.id]! == 6) {
  //               _showNotification(
  //                 flutterLocalNotificationsPlugin,
  //                 device.id!,
  //                 "${device.boxName!}/${device.name!}",
  //                 "$status değeri için Kırmızı Alarm",
  //               );
  //               normalValueCountList[device.id!] = 0;
  //               criticalValueCountList[device.id!] = 0;
  //             } else {
  //               criticalValueCountList[device.id!] =
  //                   criticalValueCountList[device.id!]! + 1;
  //             }
  //           }
  //         }
  //       }
  //     },
  //   );
  // }
