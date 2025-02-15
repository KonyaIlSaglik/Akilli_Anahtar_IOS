import 'package:akilli_anahtar/background_service.dart';
import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/splash_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  startBackgroundService();
  initializeDateFormatting('tr_TR', null).then(
    (value) => runApp(MyApp(theme: ThemeData.light())),
  );
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
  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data:
          MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.90)),
      child: GetMaterialApp(
        title: 'Akıllı Anahtar',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [Locale('tr')],
        locale: Locale("tr"),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          progressIndicatorTheme: ProgressIndicatorThemeData(color: goldColor),
          iconTheme: IconThemeData(color: goldColor),
          useMaterial3: true,
          textTheme: GoogleFonts.robotoTextTheme(),
          primaryColor: goldColor,
          primarySwatch: goldMaterial,
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: goldColor)),
          cardTheme: CardTheme(shadowColor: goldColor),
          dialogTheme: Theme.of(context)
              .dialogTheme
              .copyWith(backgroundColor: Colors.white),
        ),
        home: SplashPage(),
      ),
    );
  }
}
