import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
ConnectivityResult _connectivityResult;
StreamSubscription _connectivitySubscription;
class Checkinternet
{
  ConnectivityResult _connectivityResult;
  bool _isConnectionSuccessful;
  tryConnection() async {
    try {
      final response = await InternetAddress.lookup('www.woolha.com');
      _isConnectionSuccessful = response.isNotEmpty;

    } on SocketException catch (e) {
      print(e);
      _isConnectionSuccessful = false;
    }
  }
  checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.wifi) {
      return true;
    } else if (result == ConnectivityResult.mobile) {
      return true;
    } else {
      return false;
    }
      _connectivityResult = result;
  }
}