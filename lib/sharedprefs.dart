import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefs extends StatefulWidget {
  SharedPrefs({Key key}) : super(key: key);
  @override
  SharedPrefsState createState() => SharedPrefsState();
}
class SharedPrefsState extends State<SharedPrefs> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<bool> setHostUrl(String url) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setString("host", url).then((bool success) {
        return success;
      });
    });
  }
  Future<String> getHostUrl() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('host');
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {}
}
