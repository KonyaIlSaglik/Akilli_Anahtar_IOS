import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_anahtar/pages/splash_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  initializeDateFormatting('tr_TR', null).then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
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
          primarySwatch: MaterialColor(
            0xFFFFFFFF,
            <int, Color>{
              50: Color(0xFFFFFFFF),
              100: Color(0xFFFFFFFF),
              200: Color(0xFFFFFFFF),
              300: Color(0xFFFFFFFF),
              400: Color(0xFFFFFFFF),
              500: Color(0xFFFFFFFF),
              600: Color(0xFFFFFFFF),
              700: Color(0xFFFFFFFF),
              800: Color(0xFFFFFFFF),
              900: Color(0xFFFFFFFF),
            },
          ),
        ),
        home: SplashPage(),
      ),
    );
  }
}
