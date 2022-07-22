import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
class PositionRecord extends StatefulWidget {
  Position currentPosition = null;
  Future<Position> getStoredPosition() async {
    currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    return currentPosition;
  }
  @override
  State<StatefulWidget> createState() {
  }
}
