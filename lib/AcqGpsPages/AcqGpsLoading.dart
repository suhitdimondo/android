import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Model/Impostazione.dart';
import '../common.dart';
import 'package:location/location.dart';
import '../widgets/menu/nav-drawer-Winit.dart';
class Acquisizionegps extends StatefulWidget {
  final String date;
  final String time;
  Acquisizionegps({ this.date,  this.time});
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<Acquisizionegps> {
  double longitudine = 0.0;
  double latitudine = 0.0;
  String string = "";
  Impostazione objectImpostazione = Impostazione();
  @override
  void initState() {
    super.initState();
    setState(() {
      objectImpostazione.recuperoimpostazioni();
    });
    mylocation();
  }
  mylocation() async{
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData currentLocation;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    currentLocation = await location.getLocation();
    longitudine = currentLocation.longitude;
    latitudine = currentLocation.latitude;
  }
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.grey[100],
          drawer: NavDrawer(),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () => onBackPressed(context),
            ),
            backgroundColor: Colors.blue,
          ),
          body: Row(children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(15, 92, 15, 3),
                  height: Common.SpaceHeight,
                  child: Row(children: [
                    Text(
                      "Data registrazione:",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    Spacer(),
                    Text(
                      "${widget.date}",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ]),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(15, 3, 15, 8),
                  height: Common.SpaceHeight,
                  child: Row(children: [
                    Text(
                      "Ora registrazione:",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    Spacer(),
                    Text(
                      "${widget.time}",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ]),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                Container(
                  margin: EdgeInsets.fromLTRB(150, 8, 15, 8),
                  height: Common.SpaceHeight,
                  child: Row(children: [
                    Text(
                      "Località:",
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                    Spacer(),
                  ]),
                ),
                Divider(height: 5, thickness: 10, color: Colors.grey[200]),
                Container(
                  //margin: EdgeInsets.fromLTRB(15, 3, 170, 8),
                  height: Common.SpaceHeight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(
                          "...",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ]),
                ),
                Container(
                  //margin: EdgeInsets.fromLTRB(15, 3, 170, 8),
                  height: Common.SpaceHeight,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(
                          "...",
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ]),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                Divider(
                  height: 10,
                  color: Colors.white,
                ),
                Stack(children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 3.5,
                      child: widgetgpsmapppa(),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 60),
                      child: Center(
                        child: SpinKitFadingCircle(
                          color: Colors.white,
                          size: 70,
                        ),
                      ))
                ]),
                Divider(
                  height: 6,
                  color: Colors.white,
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                Divider(
                  height: 6,
                  color: Colors.white,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
          ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            mylocation();
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.navigation),
        ),),
    );
  }
  Widget widgetgpsmapppa(){
      return FlutterMap(
        options: MapOptions(
          center: LatLng( latitudine, longitudine ),
          zoom: 18,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 100.0,
                height: 100.0,
                point: LatLng( latitudine, longitudine ),
                builder: (ctx) =>
                    Icon(
                        Icons.location_on,
                        color: Colors.red
                    ),
              ),
            ],
          ),
        ],
      );
    }
  }
void onBackPressed(BuildContext context) {}
