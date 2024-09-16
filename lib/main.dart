import 'dart:ui';

import 'package:akilli_anahtar/controllers/mqtt_controller.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/pages/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:upgrader/upgrader.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter("localdb");
  await initializeService();
  initializeDateFormatting('tr_TR', null).then((value) => runApp(MyApp(
        theme: ThemeData.light(),
      )));
}

class MyApp extends StatelessWidget {
  static const MaterialColor goldMaterial = MaterialColor(
    0xffb49664,
    <int, Color>{
      50: Color(0xffb49664),
      100: Color(0xffb49664),
      200: Color(0xffb49664),
      300: Color(0xffb49664),
      400: Color(0xffb49664),
      500: Color(0xffb49664),
      600: Color(0xffb49664),
      700: Color(0xffb49664),
      800: Color(0xffb49664),
      900: Color(0xffb49664),
    },
  );
  final ThemeData theme;
  const MyApp({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: GetMaterialApp(
        title: 'Flutter Demo',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('tr')],
        locale: Locale("tr"),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: goldColor,
          primarySwatch: goldMaterial,
          dialogTheme: Theme.of(context)
              .dialogTheme
              .copyWith(backgroundColor: Colors.white),
        ),
        home: UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          cupertinoButtonTextStyle: TextStyle(color: Colors.black),
          child: SplashPage(),
        ),
      ),
    );
  }
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
      isForegroundMode: false,
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
  await Hive.initFlutter("localdb");
  var mqttController = Get.put(MqttController());
  await mqttController.initClient();
  mqttController.subscribeToTopic("mc");
  mqttController.onMessage((topic, message) {
    if (topic == "mc") {
      print("Mesaj Geldi");
      mqttController.showNotification("Mesaj geldi");
    }
  });
}
