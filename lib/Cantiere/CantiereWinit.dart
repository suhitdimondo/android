import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:intl/intl.dart';

import '../AcqNfcPages/AcqNFCWinit.dart';
import '../Model/Impostazione.dart';
import '../Model/Internet.dart';
import '../Model/Refresh.dart';
import '../common.dart';
import '../database.dart';
import '../preferenze.dart';
import 'UnitaFissaAssociata.dart';

String name1 = "";
String name2 = "";
String name3 = "";
String attivita = "";
String att = "";
String att2 = "";
String att3 = "";
int ripetizioni = Preferenze.rip;

class Cantieri extends StatefulWidget {
  final String fissa;
  final bool internet;

  const Cantieri({this.fissa, this.internet});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Cantieri> {
  final AudioCache _audioCache = AudioCache();
  int vmode = 0;
  String vname = "";
  Checkinternet objectinternet = Checkinternet();
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  int cantieridb = 0;
  int squadradb = 0;
  int gpsdb = 0;
  int scheduledGPSdb = 0;
  int activities = 0;
  int segnalazioni = 0;
  int pausaPranzo = 0;
  int getcantiere = 0;
  int getgps = 0;
  int getscheduledgps = 0;
  int getcliente = 0;
  int getsquadra = 0;
  int getsegnalazione = 0;
  int getpausapranzo = 0;
  int getactivities = 0;
  String val2Write = "";
  Impostazione objectImpostazione = Impostazione();
  Refresh objectRefresh = Refresh();
  static String time = "";
  static String date = "";
  final DateFormat dati = DateFormat('yyyy-MM-dd HH:mm:ss');
  DateTime tin = DateTime.now();
  final dbHelper = DatabaseHelper.instance;
  Container loadEvent = new Container();
  String _journals = "";
  List<String> data = [];
  List unitafissa = [];
  String intesttazionedesc = "";
  String internet = "";

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _journals = '${widget.fissa}';
  }

  checkinternet() async {
    await objectinternet.checkConnectivityState();
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "CANTIERI",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageWinit(),
              )),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                children: [],
              ),
            ),
            SizedBox(
                child: Center(
                    child: Container(
                        child: Column(
              children: [
                Container(
                  child: Center(
                    child: Text(
                      dati.format(tin).split(" ")[1].split(":")[0] +
                          ":" +
                          dati.format(tin).split(" ")[1].split(":")[1],
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: [],
                  ),
                  margin: EdgeInsets.all(10),
                ),
                Container(
                  child: Center(
                    child: Text(
                      dati.format(tin).split(" ")[0],
                      style: TextStyle(fontSize: 25, color: Colors.black),
                    ),
                  ),
                ),
              ],
            )))),
            Container(
              margin: EdgeInsets.fromLTRB(15, 12, 15, 12),
              height: Common.SpaceHeight,
              child: Row(children: [
                Text(
                  "Cantiere:",
                  style: TextStyle(fontSize: 20, color: Colors.black54),
                ),
                Spacer(),
                Text(
                  _journals,
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
              ]),
            ),
            Divider(height: 10, thickness: 10, color: Colors.grey[200]),
            SizedBox(
                height: 400,
                width: MediaQuery.of(context).size.width * 1.0,
                child: Container(
                  child: Column(
                    children: [
                      (_journals.toString() != "[null]")
                          ? Container(
                              width: 300.0,
                              height: 40.0,
                              margin: EdgeInsets.only(bottom: 20.0),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                textColor: Colors.white,
                                padding: EdgeInsets.all(8.0),
                                onPressed: () async {
                                  time = getSystemTime();
                                  date = getSystemDate();
                                  internet = await checkinternet();
                                  List color = await dbHelper.attivita_select();
                                  for (int i = 0; i < color.length; i++) {
                                    String flag = color[i]["flag"].toString();
                                    if (flag == "true") {
                                      sendcolor = 1;
                                      break;
                                    }
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AcquisizioneNfcWinit(
                                                  nfc: widget.fissa,
                                                  date: date,
                                                  time: time,
                                                  selectedItems: [],
                                                  long: 0.0,
                                                  lat: 0.0,
                                                  internet: widget.internet,
                                                  color: sendcolor)));
                                },
                                child: Text(
                                  "ENTRATA".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: GradientColors.skyLine,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )),
                            )
                          : Row(),
                      (_journals.toString() != "[null]")
                          ? Container(
                              margin: EdgeInsets.only(bottom: 20.0),
                              width: 300.0,
                              height: 40.0,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                textColor: Colors.white,
                                padding: EdgeInsets.all(8.0),
                                onPressed: () async {
                                  time = getSystemTime();
                                  date = getSystemDate();
                                  internet = await checkinternet();
                                  List color = await dbHelper.attivita_select();
                                  for (int i = 0; i < color.length; i++) {
                                    String flag = color[i]["flag"].toString();
                                    if (flag == "true") {
                                      sendcolor = 1;
                                      break;
                                    }
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AcquisizioneNfcWinit(
                                                  nfc: widget.fissa,
                                                  date: date,
                                                  time: time,
                                                  selectedItems: [],
                                                  long: 0.0,
                                                  lat: 0.0,
                                                  internet: widget.internet,
                                                  color: sendcolor)));
                                },
                                child: Text(
                                  "USCITA".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                colors: GradientColors.skyLine,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )),
                            )
                          : Row(),
                      Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        width: 300.0,
                        height: 40.0,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          textColor: Colors.white,
                          padding: EdgeInsets.all(8.0),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DescrizioneCantiere(
                                        items: [],
                                        code: "",
                                        internet: widget.internet)));
                          },
                          child: Text(
                            "SELEZIONARE CANTIERI".toUpperCase(),
                            style: TextStyle(
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: GradientColors.skyLine,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )),
                      ),
                    ],
                  ),
                )),
            Divider(height: 10, thickness: 10, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }

  int sendcolor;

  void audio() {
    _audioCache.play('Audio/my_audio.mp3');
  }

  void onBackPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePageWinit()));
  }
}
