import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/HomePages/homePage.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/loginPage.dart';
import 'package:flutter_hr_app/preferenze.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'database.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  showTheLogin().then((showLogin) async {
    if (showLogin == true) {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(MyAppLogin());
    } else {
      has2UpdateConf().then((has2Update) {
        WidgetsFlutterBinding.ensureInitialized();
        if (has2Update == true) {
          runApp(Myapphome());
        } else {
          runApp(Myapphome());
        }
      });
    }
  });
}

Future<bool> has2UpdateConf() async {
  final dbHelper = DatabaseHelper.instance;
  bool has2Update = true;
  try {
    List<Map<String, dynamic>> moduli = await dbHelper.queryAllRows_MODULI();
    if (moduli != null && moduli.length > 0) {
      if (moduli[0]["REFRESH"] != null) {
        if (DateTime.parse(moduli[0]["REFRESH"])
            .isBefore(DateTime.now().subtract(Duration(hours: 1)))) {
          has2Update = true;
        } else {
          has2Update = false;
        }
      } else {
        has2Update = true;
      }
    } else {
      has2Update = true;
    }
  } on Exception catch (_) {
    has2Update = true;
  }
  return has2Update;
}

Future<bool> showTheLogin() async {
  final dbHelper = DatabaseHelper.instance;
  bool showLogin = true;
  try {
    List<Map<String, dynamic>> users = await dbHelper.queryAllRows_AUTH_USER();
    if (users != null &&
        users.length > 0 &&
        users[0]["SKIPLOGIN"] == 1 &&
        users[0]["BASEURL"] != null &&
        users[0]["BASEURL"] != "") {
      Preferenze.piattaformaTimbratureHost = users[0]["BASEURL"];
      Preferenze.tipoIstanza = users[0]["TIPO_ISTANZA"];
      showLogin = false;
    } else {
      showLogin = true;
    }
  } on Exception catch (_) {}
  return showLogin;
}

class MyAppLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [GlobalMaterialLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          const Locale('it'),
        ],
        theme: ThemeData(primarySwatch: Colors.green),
        home: LoginPage());
  }
}

class Myapphome extends StatelessWidget {
  final bool doUpdate = false;
  final String soc = "Win";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [GlobalMaterialLocalizations.delegate],
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          const Locale('it'),
        ],
        theme: ThemeData(primarySwatch: Colors.green),
        home: HomePageWinit());
  }
}
