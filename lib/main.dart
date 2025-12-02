import 'dart:convert';

import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/bindings/app_binding.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/controllers/main/mqtt_controller.dart';
import 'package:akilli_anahtar/pages/auth/send_email_verify_code.dart';
import 'package:akilli_anahtar/pages/auth/verify_code_page.dart';
import 'package:akilli_anahtar/pages/managers/user/complete_profile_page.dart';
import 'package:akilli_anahtar/pages/new_home/device/device_select_page.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/pages/new_home/notification/notification_page.dart';
import 'package:akilli_anahtar/services/api/widget_publish_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:akilli_anahtar/pages/managers/user/complete_register_user_page.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
String? fcmInitialRoute;

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final DarwinInitializationSettings iosInit = DarwinInitializationSettings();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Önemli Bildirimler',
    description: 'Bu kanal yüksek öncelikli bildirimler içindir.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final InitializationSettings settings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
}

Future<void> initializeFCM(BuildContext context) async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    fcmInitialRoute = initialMessage.data['route'] ?? '/notification';
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    fcmInitialRoute = message.data['route'] ?? '/notification';

    Get.offAll(() => SplashPage());
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(' Arka planda gelen FCM mesajı: ${message.messageId}');
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? data) async {
  // Widget’tan gelen “tıklama / komut”leri burada ele alırsın
  if (data?.host == 'refresh') {
    // Örneğin widget üzerindeki bir butona basıldıysa
    // Uygulamayı açmadan burada gerekli işlemleri tetikleyebilirsin
    // Örnek: veri çek, HomeWidget.saveWidgetData vs.
  }
}

const platform = MethodChannel("com.akillianahtar/navigation");

void initPlatformChannel() {
  platform.setMethodCallHandler((call) async {
    if (call.method == "openPage") {
      final route = call.arguments as String;
      if (route == "/deviceSelect") {
        Get.toNamed('/deviceSelect');
      } else {
        Get.toNamed(route);
      }
    }
    if (call.method == "publishFromWidget") {
      try {
        final data = Map<String, dynamic>.from(call.arguments);
        final topic = data["topic"];
        final payload = data["payload"];

        print(" publishFromWidget → topic=$topic, payload=$payload");

        final ok = await WidgetApiService.widgetPublish(topic, payload);
        print(" API sonucu: $ok");
      } catch (e) {
        print(" publishFromWidget hata: $e");
      }
    }
  });
}

Future<void> saveTokenToNative(String token) async {
  await platform.invokeMethod("saveToken", token);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // HttpOverrides.global = PostHttpOverrides();
  Get.put(MqttController(), permanent: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Future.wait([
    Firebase.initializeApp(),
    initializeService(),
    _initializeNotifications(),
  ]);

  Get.put(LoginController());
  Get.put(SessionController());

  //HomeWidget.registerInteractivityCallback(interactiveCallback);
  initPlatformChannel();

  initializeDateFormatting('tr_TR', null).then(
    (value) => runApp(MyApp(theme: ThemeData.light())),
  );
}

class SessionController {}

class MyApp extends StatefulWidget {
  final ThemeData theme;

  const MyApp({super.key, required this.theme});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeFCM(context);
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: GetMaterialApp(
        title: 'Akıllı Anahtar',
        initialBinding: AppBinding(),
        getPages: [
          GetPage(name: '/', page: () => SplashPage()),
          GetPage(name: '/layout', page: () => Layout()),
          GetPage(name: '/notification', page: () => NotificationPage()),
          GetPage(name: '/sendMail', page: () => RegisterSendMailPage()),
          GetPage(
              name: '/completeProfile',
              page: () => const CompleteProfilePage()),
          GetPage(name: '/VerifyCodePage', page: () => const VerifyCodePage()),
          GetPage(
              name: '/Completeregister',
              page: () => const CompleteRegisterUserPage()),
          //GetPage(name: '/deviceSelect', page: () => DeviceSelectPage())
        ],
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
          iconTheme: IconThemeData(color: goldColor),
          progressIndicatorTheme: ProgressIndicatorThemeData(color: goldColor),
          textTheme: GoogleFonts.robotoTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFFAF7F2),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: goldColor),
          ),
          dialogTheme: Theme.of(context)
              .dialogTheme
              .copyWith(backgroundColor: Colors.white),
        ),
        home: SplashPage(),
      ),
    );
  }
}
