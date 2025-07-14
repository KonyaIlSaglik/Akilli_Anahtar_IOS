import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/controllers/main/login_controller.dart';
import 'package:akilli_anahtar/pages/new_home/layout.dart';
import 'package:akilli_anahtar/pages/new_home/notification/notification_page.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:akilli_anahtar/bindings/app_binding.dart';

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
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    fcmInitialRoute = initialMessage.data['route'] ?? '/notification';
    await flutterLocalNotificationsPlugin.cancelAll();
  } else {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    fcmInitialRoute = message.data['route'] ?? '/notification';

    Get.offAll(() => SplashPage());
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'Önemli Bildirimler',
            channelDescription:
                'Bu kanal yüksek öncelikli bildirimler içindir.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print(' Arka planda gelen FCM mesajı: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Uygulama başlatılıyor");

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  print("Firebase başlatılıyor...");
  await Firebase.initializeApp();
  print("Firebase başlatıldı");

  await initializeService();
  print("Servis başlatıldı");

  await _initializeNotifications();
  print("Bildirimler başlatıldı");

  Get.put(LoginController());
  Get.put(SessionController());

  print("DateFormat yükleniyor");
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
          GetPage(name: '/notification', page: () => NotificationPage()),
          GetPage(name: '/layout', page: () => Layout()),
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
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: goldColor),
          ),
          cardTheme: CardThemeData(shadowColor: goldColor),
          dialogTheme: Theme.of(context)
              .dialogTheme
              .copyWith(backgroundColor: Colors.white),
        ),
        home: SplashPage(),
      ),
    );
  }
}
