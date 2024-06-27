import 'dart:convert';

import 'package:akilli_anahtar/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/pages/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:json_theme/json_theme.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeStr = await rootBundle.loadString('assets/theme/light.json');
  final themeJson = jsonDecode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  initializeDateFormatting('tr_TR', null)
      .then((value) => runApp(MyApp(theme: theme)));
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
      child: MaterialApp(
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
          useMaterial3: false,
          primaryColor: goldColor,
          primarySwatch: goldMaterial,
        ),
        home: UpgradeAlert(
          child: SplashPage(),
        ),
      ),
    );
  }
}
