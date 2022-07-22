import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/preferenze.dart';
import 'package:flutter_hr_app/ws.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';
import 'package:qrcode/qrcode.dart';

import '../HomePages/homePage.dart';
import '../common.dart';
import '../database.dart';
import 'loadingPage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<LoginPage> with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController errorController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  final DateFormat wsformatter = DateFormat('yyyy-MM-dd');
  final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  String instanceCode = "";
  bool isSwitched = true;
  bool authSemaphore = false;
  int errnums = 0;
  List<String> optList;
  List<DropdownMenuItem> instanceCodeList;
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> uuidRows;
  String uuid;
  RESTApi wsClient = new RESTApi();
  QRCaptureController _captureController = QRCaptureController();
  String _captureText = '';
  bool _flexibleUpdateAvailable = false;
  @override
  void initState() {
    super.initState();
    List optList;
    List instanceCodeList;
    passwordController.text = '';
    errorController.text = '';
    _captureController.onCapture((data) {
      if (authSemaphore == true) {
        return;
      }
      authSemaphore = true;
      _captureController.pause();
      setState(() {
        _captureText = data;
        String hashNoUrl = _captureText.split("###")[0];
        String bkdurl = _captureText.split("###")[1];
        String user = _captureText.split('###')[2];
        Preferenze.piattaformaTimbratureHost = bkdurl;
        passwordController.text = _captureText;
        RESTApi wsClient = new RESTApi();
        DateTime tin = DateTime.now();
        String day;
        day = wsformatter.format(tin);
        wsClient.CheckAuthService(
            nameController.text, hashNoUrl, instanceCode, day, uuid)
            .then((val) => setState(() {
          if (val != 'Error') {
            try {
              final dbHelper = DatabaseHelper.instance;
              dbHelper.queryRowCount_AUTH_USER().then((numr) =>
                  setState(() {
                    int numRows = numr;
                    var userResponse = jsonDecode(val);
                    int uid2Update = int.parse(userResponse[0]["uid"]);
                    if (numRows > 0) //aggiorna la riga user se utente
                        {
                      dbHelper.queryAllRows_AUTH_USER().then((users) =>
                          setState(() {
                            if (users[0]["USER_ID"] == uid2Update) {
                              Map<String, dynamic> row =
                              new Map<String, dynamic>();
                              row["ID"] = users[0]["ID"];
                              row["MOB_ATT_ENABLED"] = 1;
                              row["GPS_MANDATORY"] = 1;
                              row["NAME"] = userResponse[0]["name"];
                              row["CLIENTE_ID"] =
                              userResponse[0]["cid"];
                              row["BASEURL"] = bkdurl;
                              row["TIPO_ISTANZA"] = user;
                              row["SKIPLOGIN"] =
                              isSwitched == true ? 1 : 0;
                              dbHelper
                                  .update_AUTH_USER(row)
                                  .then((result) => setState(() {
                                acquisizioneConfigurazione(day,
                                    row["CLIENTE_ID"], user);
                                getTipologiaAcquisizioni(
                                    wsClient,
                                    row["CLIENTE_ID"],
                                    dbHelper);
                                getTecnologieTipologie(
                                    wsClient,
                                    row["CLIENTE_ID"],
                                    dbHelper);
                              }));
                            } else {
                              dbHelper
                                  .delete_AUTH_USER(uid2Update)
                                  .then((result) => setState(() {
                                Map<String, dynamic> row =
                                new Map<String, dynamic>();
                                row["MOB_ATT_ENABLED"] = 1;
                                row["GPS_MANDATORY"] = 1;
                                row["BASEURL"] = bkdurl;
                                row["TIPO_ISTANZA"] = user;
                                row["USER_ID"] = uid2Update;
                                row["NAME"] =
                                userResponse[0]["name"];
                                row["PASSWORD"] =
                                    passwordController.text;
                                row["DELETED"] = 0;
                                row["DISABLED"] = 0;
                                row["CLIENTE_ID"] =
                                userResponse[0]["cid"];
                                row["TSLOGIN"] = tsformatter
                                    .format(DateTime.now());
                                row["SKIPLOGIN"] =
                                isSwitched == true ? 1 : 0;
                                dbHelper
                                    .insert_AUTH_USER(row)
                                    .then((result) =>
                                    setState(() {
                                      acquisizioneConfigurazione(
                                          day,
                                          row["CLIENTE_ID"],
                                          user);
                                      getTipologiaAcquisizioni(
                                          wsClient,
                                          row["CLIENTE_ID"],
                                          dbHelper);
                                      getTecnologieTipologie(
                                          wsClient,
                                          row["CLIENTE_ID"],
                                          dbHelper);
                                    }));
                              }));
                            }
                          }));
                    } else {
                      Map<String, dynamic> row =
                      new Map<String, dynamic>();
                      row["MOB_ATT_ENABLED"] = 1;
                      row["GPS_MANDATORY"] = 1;
                      row["BASEURL"] = bkdurl;
                      row["TIPO_ISTANZA"] = user;
                      row["USER_ID"] = uid2Update;
                      row["NAME"] = userResponse[0]["name"];
                      row["PASSWORD"] = passwordController.text;
                      row["DELETED"] = 0;
                      row["DISABLED"] = 0;
                      row["CLIENTE_ID"] = userResponse[0]["cid"];
                      row["SKIPLOGIN"] = isSwitched == true ? 1 : 0;
                      row["TSLOGIN"] =
                          tsformatter.format(DateTime.now());
                      dbHelper.insert_AUTH_USER(row).then((result) =>
                          setState(() {
                            acquisizioneConfigurazione(
                                day, row["CLIENTE_ID"], user);
                            getTipologiaAcquisizioni(
                                wsClient, row["CLIENTE_ID"], dbHelper);
                            getTecnologieTipologie(
                                wsClient, row["CLIENTE_ID"], dbHelper);
                          }));
                    }
                  }));
            } on Exception catch (_) {
              errnums++;
              errorController.text = Common.erroreAutenticazione +
                  "(" +
                  errnums.toString() +
                  ")";
              _captureController.resume();
              authSemaphore = false;
              rebuildAllChildren(context);
            }
          } else {
            errnums++;
            errorController.text = Common.erroreAutenticazione +
                "(" +
                errnums.toString() +
                ")";
            _captureController.resume();
            authSemaphore = false;
            rebuildAllChildren(context);
          }
        }))
            .catchError((e) {
          errnums++;
          errorController.text =
              Common.erroreAutenticazione + "(" + errnums.toString() + ")";
          _captureController.resume();
          rebuildAllChildren(context);
          authSemaphore = false;
        });
      });
    });
    dbHelper.queryAllRows_UUID().then((val) => setState(() {
      uuidRows = val;
      if (uuidRows != null && uuidRows.length > 0) {
        uuid = uuidRows[0]["UUID"];
      }
    }));
  }

  onBackPressed(BuildContext context) {
    exit(0);
  }

  void getTipologiaAcquisizioni(
      RESTApi wsClient, String cliId, DatabaseHelper dbHelper) {
    wsClient.GetTipologiaAcquisizioni(
        Preferenze.piattaformaTimbratureHost, int.parse(cliId))
        .then((tacq) => setState(() {
      String rb = tacq;
      if (rb != 'Error') {
        dynamic tacqst = jsonDecode(rb);
        Map<String, dynamic> tacqs = jsonDecode(tacqst);
        if (tacqs != null && tacqs["tipologia_acquisizioni"] != null) {
          if (tacqs["tipologia_acquisizioni"].length > 0) {
            dbHelper.delete_AllTIPOACQUISIZIONE();
            for (int i = 0;
            i < tacqs["tipologia_acquisizioni"].length;
            i++) {
              Map<String, dynamic> tipoacquisizione =
              new Map<String, dynamic>();
              Map<String, dynamic> intiacq =
              tacqs["tipologia_acquisizioni"][i];
              tipoacquisizione["ID"] =
                  int.parse(intiacq["Id"].toString());
              tipoacquisizione["NOME"] = intiacq["Nome"];
              tipoacquisizione["ABILITATA"] = intiacq["Abilitata"];
              tipoacquisizione["COLORE"] = intiacq["colore"];
              dbHelper.insert_TIPOACQUISIZIONE(tipoacquisizione);
            }
          }
        }
      }
    }));
  }

  void getTecnologieTipologie(
      RESTApi wsClient, String cliId, DatabaseHelper dbHelper) {
    wsClient.GetTecnologieTipologie(
        Preferenze.piattaformaTimbratureHost, int.parse(cliId))
        .then((tacq) => setState(() {
      String rb = tacq;
      if (rb != 'Error') {
        dynamic ttst = jsonDecode(rb);
        Map<String, dynamic> tts = jsonDecode(ttst);
        if (tts != null && tts["tecnologie_tipologie"] != null) {
          if (tts["tecnologie_tipologie"].length > 0) //se ho dei dati
              {
            dbHelper.delete_AllTIPOLOGIETECNOLOGIE();
            for (int i = 0;
            i < tts["tecnologie_tipologie"].length;
            i++) {
              Map<String, dynamic> tipott = new Map<String, dynamic>();
              Map<String, dynamic> intitt =
              tts["tecnologie_tipologie"][i];
              tipott["ID"] = int.parse(intitt["id"].toString());
              tipott["IDTIPOLOGIA"] = intitt["idTipologia"];
              tipott["IDTECNOLOGIA"] = intitt["idTecnologia"];
              tipott["NOMETECNOLOGIA"] =
                  intitt["Tecnologia"].toString().trim();
              tipott["NOMETIPOLOGIA"] =
                  intitt["Nome"].toString().trim();
              dbHelper.insert_TIPOLOGIETECNOLOGIE(tipott);
            }
          }
        }
      }
    }));
  }

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
  AppUpdateInfo _updateInfo;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Center(
            child: Image.asset('assets/Winit/LOGOHSM2.png', height: 50, width: 150,),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
        ),
        body: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                Container(
                  height: Common.BtnHeight * 3,
                  padding: EdgeInsets.only(top: 50),
                  child: Text("INQUADRA IL QRCODE CHE TI E' STATO FORNITO",
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      textAlign: TextAlign.center),
                ),
                Container(
                  height: Common.BtnHeight,
                  padding: EdgeInsets.all(10),
                  child: Text(errorController.text,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center),
                ),
                Container(
                  height: Common.BtnHeight,
                  padding: EdgeInsets.all(10),
                  child: Text("",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center),
                ),
                Container(
                  width: 250,
                  height: 250,
                  child: QRCaptureView(
                    controller: _captureController,
                  ),
                ),
                ElevatedButton(
                  child: Text('Perform immediate update'),
                  onPressed: _updateInfo?.updateAvailability ==
                      UpdateAvailability.updateAvailable
                      ? () {
                    InAppUpdate.performImmediateUpdate()
                        .catchError((e) => showSnack(e.toString()));
                  }
                      : null,
                ),
                ]),
            ));
  }
  void showSnack(String text) {
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text(text)));
    }
  }
  void acquisizioneConfigurazione(String day, String clienteId, String user) {
    wsClient.GetConfigurazione(
        "fake", passwordController.text, clienteId, day, uuid)
        .then((val) {
      if (val != 'Error') {
        dynamic configurazione = jsonDecode(val);
        Map<String, dynamic> configuraziones = jsonDecode(configurazione);
        if (configuraziones != null && configuraziones["moduli"] != null) {
          if (configuraziones["moduli"].length > 0) //se ho dei dati
              {
            dbHelper.delete_AllPARAMETRI();
            dbHelper.delete_AllMODULI();
            int i = 0;
            for (var m in configuraziones["moduli"]) {
              Map<String, dynamic> modulo = new Map<String, dynamic>();
              Map<String, dynamic> inmod = configuraziones["moduli"][i];
              modulo["CODICE"] = inmod["CODICE"].toString();
              modulo["NOME"] = inmod["NOME"];
              modulo["NOME_IN_APP"] = inmod["NOME_IN_APP"];
              modulo["STATO"] = inmod["STATO"];
              dbHelper.insert_MODULI(modulo).then((idm) => setState(() {
                int j = 0;
                if (modulo["PARAMETRI"] != null &&
                    modulo["PARAMETRI"].length > 0) {
                  for (var p in modulo["PARAMETRI"]) {
                    Map<String, dynamic> parametro =
                    new Map<String, dynamic>();
                    Map<String, dynamic> paramj = modulo["PARAMETRI"][j];
                    parametro["NOME"] = paramj["Nome"].toString();
                    parametro["VALORE"] = paramj["valore"].toString();
                    parametro["TIPO"] = paramj["Tipo"].toString();
                    dbHelper.insert_PARAMETRI(parametro);
                    j++;
                  }
                }
              }));

              i++;
            }
          }
          int cid;
          dbHelper
              .queryAllRows_AUTH_USER()
              .then((users) => {cid = users[0]["CLIENTE_ID"]});
          RESTApi wsClient = new RESTApi();
          wsClient.GetEventi(cid).then((value) => {
            if (value != null) {dbHelper.insertEventi(value)}
          });
          if (user == "jlb") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoadingPageWinit(true)),
            );
          }
        } else {
          errnums++;
          errorController.text =
              Common.erroreAutenticazione + "(" + errnums.toString() + ")";
          _captureController.resume();
          rebuildAllChildren(context);
        }
      } else {
        errnums++;
        errorController.text =
            Common.erroreAutenticazione + "(" + errnums.toString() + ")";
        _captureController.resume();
        rebuildAllChildren(context);
      }
    });
  }
}
