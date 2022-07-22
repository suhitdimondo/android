import 'package:flutter/material.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:package_info/package_info.dart';
import '../database.dart';
class InfoWinit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<InfoWinit> {
  final dbHelper = DatabaseHelper.instance;
  String matricola;
  String versionName;
  String versionCode;
  @override
  void initState() {
    getMatricola();
    getDeviceVersion();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          drawer: NavDrawer(),
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => onBackPressed(context),
            ),
            title: Text(
              'Informazioni',
            ),
            backgroundColor: Colors.blue,
          ),
          body: myContainer());
  }
  Widget myContainer() {
    return Container(
      margin: const EdgeInsets.only(top: 100.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Applicazione con personalizzazione",
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 250,
                  height: 80,
                  child: Image.asset('assets/Winit/ic_launcher.png'),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: 250,
                  height: 20,
                  child: Text(
                    "Matricola dispositivo: $matricola",
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 0),
                  width: 250,
                  height: 20,
                  child: Text(
                    "Versione applicativo: $versionName",
                    style: TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 0),
                    width: 250,
                    height: 20,
                    child: Text(
                      "Versione database: 1",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    )),
                Container(
                    margin: EdgeInsets.only(top: 70),
                    width: 250,
                    height: 30,
                    child: Text(
                      "Powered by",
                      style: TextStyle(fontSize: 30, color: Colors.black45),
                      textAlign: TextAlign.center,
                    )),
                Container(
                    margin: EdgeInsets.only(top: 0),
                    width: 150,
                    height: 50,
                    child: Image.asset('assets/Winit/winitlogo.png')),
                Column(
                  children: [
                    Text("Winit Srl",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                    Text("Via Oss Mazzurana, 8 - Trento",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                    Text("Assistenza tecnica:",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                    Text("+39 0461 260470",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                    Text("supporto@winitsrl.eu",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                    Text("www.winit.it",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, fontSize: 15)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  getDeviceVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      versionName = packageInfo.version;
      versionCode = packageInfo.buildNumber;
    });
  }
  getMatricola() async {
    await dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
          matricola = users[0]["NAME"];
        }));
  }
  void onBackPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePageWinit()));
  }
}
