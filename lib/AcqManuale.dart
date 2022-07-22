import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/homePageAcquisizioniInner.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'ws.dart';
class AcquisizioneManuale extends StatefulWidget {
  int mode = 0;
  String name = "";
  AcquisizioneManuale(int mode, String name) {
    this.mode = mode;
    this.name = name;
  }
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<AcquisizioneManuale> {
  int vmode = 0;
  String vname = "";
  bool isSwitched = false;
  final DateFormat wsformatter = DateFormat('yyyy-MM-dd');
  final DateFormat timeformatter = DateFormat('HH:mm:ss');
  final DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final dbHelper = DatabaseHelper.instance;
  int authrowid = 0;
  int uid = 0;
  int cid = 0;
  final luogoController = new TextEditingController();
  final causaleController = new TextEditingController();
  final noteController = new TextEditingController();
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => setUid());
    vmode = widget.mode;
    vname = widget.name;
  }
  void setUid() {
    try {
      print("setGPSMandatory");
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            print(users);
            if (users[0]["GPS_MANDATORY"] == 1) {
              isSwitched = true;
              print("GPS obbligatorio");
            } else {
              print("GPS non obbligatorio");
            }
            authrowid = users[0]["ID"];
            uid = users[0]["USER_ID"];
            uid = users[0]["CLIENTE_ID"];
          }));
    } on Exception catch (_) {

    }
  }
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
  void onBackPressed(BuildContext context) {
    return Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Image.asset(
                Common.logo,
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
            body: Padding(
                padding: EdgeInsets.all(0),
                child: Stack(
                  children: getAcquisizioniView(),
                )));
  }
  List<Widget> getAcquisizioniView() {
    return [
      Positioned(
          child: Container(
              child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
        MaterialButton(
            color: Colors.white,
            textColor: Colors.black,
            disabledColor: Colors.black,
            disabledTextColor: Colors.black,
            padding: EdgeInsets.all(0.0),
            splashColor: Colors.blueAccent,
            onPressed: () {},
            child: TextField(
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixIcon: Icon(Common.acquisizioniModuleIcon),
                labelText: Common.AcquisizioneManualeLabel,
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                enabled: false,
              ),
            )),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight,
            child: Text(Common.AcquisizioneManualeLuogoLabel,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight * 2,
            child: TextField(
              controller: luogoController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 2.0,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              decoration: new InputDecoration.collapsed(
                hintText: 'Inserisci Luogo',
                enabled: true,
                border: OutlineInputBorder(),
              ),
            )),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight,
            child: Text(Common.AcquisizioneManualeCausaleLabel,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight * 2,
            child: TextField(
              controller: causaleController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 2.0,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              decoration: new InputDecoration.collapsed(
                hintText: 'Inserisci causale',
                enabled: true,
                border: OutlineInputBorder(),
              ),
            )),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight,
            child: Text(Common.AcquisizioneManualeNoteLabel,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black))),
        Container(
          height: Common.SpaceHeight / 2,
        ),
        Container(
            height: Common.SpaceHeight * 2,
            child: TextField(
              controller: noteController,
              textAlign: TextAlign.center,
              style: TextStyle(
                  height: 2.0,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey),
              decoration: new InputDecoration.collapsed(
                hintText: 'Inserisci note',
                enabled: true,
                border: OutlineInputBorder(),
              ),
            )),

        Container(
          height: Common.SpaceHeight,
        ),
        Container(
            height: Common.BtnHeight,
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: RaisedButton(
              textColor: Colors.white,
              color: Colors.green,
              child: Text(Common.AcquisizioneManualeInviaLabel,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                if (luogoController.text.trim() == "" ||
                    causaleController.text.trim() == "") {
                  _showDialogKO();
                } else {
                  DateTime tin = DateTime.now();
                  Map<String, dynamic> timb = new Map<String, dynamic>();
                  timb["USER_ID"] = uid;
                  timb["DATETIME"] = dbformatter.format(tin);
                  timb["VERSO"] = "";
                  timb["LATITUDE"] = -1;
                  timb["LONGITUDE"] = -1;
                  timb["IMPORTED"] = 0;
                  timb["TIPO_ACQUISIZIONE"] = vmode;
                  timb["TECNOLOGIA_ACQUISIZIONE"] = "MAN";
                  timb["VALORE_ACQUISIZIONE"] = jsonEncode([
                    {
                      "luogo": luogoController.text,
                      "causale": causaleController.text,
                      "note": noteController.text,
                    }
                  ]);
                  try {
                    dbHelper.insert_TIMB(timb).then((val) => setState(() {
                          luogoController.text = "";
                          causaleController.text = "";
                          noteController.text = "";
                          _showDialogOK();
                          sendAllDataNotImported();
                        }));
                  } on Exception catch (_) {
                    _showDialogKO();
                  }
                }
              },
            )),
        Container(
          height: Common.SpaceHeight,
        )
      ]))),
      Positioned(
        child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Common.moduleRoundedCorner / 2),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          HomePageAcquisizioniInner(vmode, vname)),
                );
              },
              label:
                  Text("", style: TextStyle(fontSize: Common.moduleFontSize)),
              icon: Icon(Icons.arrow_back, size: 28),
              color: Common.impostazioniModuleColor,
            )),
      )
    ];
  }
  void _showDialogKO() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore Inserimento"),
          content: new Text(
              "Verifica i dati immessi! I campi con l'asterisco sono obbligatori!"),
          actions: <Widget>[
            new MaterialButton(
              child: new Text("Chiudi"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showDialogOK() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Conferma Inserimento"),
          content:
              new Text("I dati immessi sono stati acquisiti correttamente!"),
          actions: <Widget>[
            new MaterialButton(
              child: new Text("Chiudi"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  sendAllDataNotImported() {
    dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
          print(users);
          uid = users[0]["USER_ID"];
          cid = users[0]["CLIENTE_ID"];
          dbHelper
              .queryAllRows_TIMBOfDayNotImported()
              .then((timbs) => setState(() {
                    if (timbs != null) {
                      for (var timb in timbs) {
                        try {
                          RESTApi wsClient = new RESTApi();
                          String rb = "";
                          String valore =
                              timb["VALORE_ACQUISIZIONE"].toString();
                          String tipo = timb["TIPO_ACQUISIZIONE"].toString();
                          String tecnologia =
                              timb["TECNOLOGIA_ACQUISIZIONE"].toString();
                          String giornata =
                              timb["DATETIME"].toString().substring(0, 10);
                          wsClient
                              .sendData(giornata, uid.toString(),
                                  cid.toString(), valore, tipo, tecnologia)
                              .then((val) => setState(() {
                                    rb = val;
                                    if (rb != 'Error') {
                                      Map<String, dynamic> ti =
                                          new Map<String, dynamic>();
                                      ti["ID"] =
                                          int.parse(timb["ID"].toString());
                                      ti["IMPORTED"] = 1;
                                      print("try updating imported:");
                                      dbHelper
                                          .update_TIMB(ti)
                                          .then((val) => setState(() {
                                              }))
                                          .catchError((e) {
                                      });
                                    } else {
                                    }
                                  }))
                              .catchError((e) {
                          });
                        } on Exception catch (_) {
                        }
                      }
                    }
                  }))
              .catchError((e) {
          });
        }));
  }
}
