import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/preferenze.dart';
import 'package:flutter_hr_app/ws.dart';
import 'package:intl/intl.dart';
import 'common.dart';
import 'database.dart';
import 'HomePages/homePage.dart';
class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  final DateFormat wsformatter = DateFormat('yyyy-MM-dd');
  String instanceCode = "";
  bool isSwitched = false;
  int _value = 0;
  List<String> optList;
  List<DropdownMenuItem> instanceCodeList;
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> uuidRows = null;
  String uuid;
  RESTApi wsClient = new RESTApi();
  @override
  void initState() {
    super.initState();
    optList = List<String>();
    instanceCodeList = List<DropdownMenuItem>();
    int i = 0;
    dbHelper.queryAllRows_UUID().then((val) => setState(() {
          uuidRows = val;
          print(uuidRows);
          if (uuidRows != null && uuidRows.length > 0) {
            uuid = uuidRows[0]["UUID"];
          }
          wsClient.GetDominiClienti(Preferenze.piattaformaTimbratureHost)
              .then((clienti) => setState(() {
                    String rb = clienti;
                    if (rb != 'Error') {
                      dynamic clientst = jsonDecode(rb);
                      Map<String, dynamic> clients = jsonDecode(clientst);
                      if (clients != null && clients["clienti"] != null) {
                        if (clients["clienti"].length > 0)
                        {
                          dbHelper.delete_AllCLIENTI();
                          for (int i = 0; i < clients["clienti"].length; i++) {
                            Map<String, dynamic> cliente =
                                new Map<String, dynamic>();
                            Map<String, dynamic> incli = clients["clienti"][i];
                            cliente["ID_CLIENTE"] =
                                int.parse(incli["IdCliente"].toString());
                            cliente["CODICE_ISTANZA"] = incli["CodiceIstanza"];
                            dbHelper.insert_CLIENTI(cliente);
                          }
                          dbHelper.queryAllRows_CLIENTI().then((val) =>
                              setState(() {
                                optList.insert(0, "Seleziona Codice Istanza");
                                List<Map<String, dynamic>> cliRows = val;
                                print(cliRows);
                                if (cliRows != null && cliRows.length > 0) {
                                  for (var r in cliRows) {
                                    optList.insert(
                                        r["ID_CLIENTE"], r["CODICE_ISTANZA"]);
                                  }
                                }
                                for (var item in optList) {
                                  instanceCodeList.add(DropdownMenuItem(
                                    child: Text(optList[i]),
                                    value: i,
                                  ));
                                  i++;
                                }
                              }));
                        }
                      }
                    }
                  }));
        }));
  }
  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }
    (context as Element).visitChildren(rebuild);
  }
  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    return WillPopScope(
        onWillPop: () {
          new Future(() => false);
        },
        child:
            Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  title: Image.asset(Common.logo,
                      fit: BoxFit.cover, alignment: Alignment.center),
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
                          height: 60,
                          padding: EdgeInsets.all(10),
                          child: TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.face),
                              border: OutlineInputBorder(),
                              labelText: Common.usernamePlaceHolder,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: EdgeInsets.all(10),
                          child: TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.vpn_key),
                              border: OutlineInputBorder(),
                              labelText: Common.passwordPlaceHolder,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: EdgeInsets.all(10),
                          child: Center(
                            child: DropdownButton(
                                value: _value,
                                items: instanceCodeList,
                                onChanged: (value) {
                                  setState(() {
                                    _value = value;
                                    instanceCode =
                                        value.toString(); //optList[value];
                                  });
                                }),
                          ),
                        ),
                        Row(children: <Widget>[
                          Text(''),
                        ]),
                        Container(
                          height: 40,
                          child: Text(Common.rememberString,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        CupertinoSwitch(
                          value: isSwitched,
                          onChanged: (value) {
                            setState(() {
                              isSwitched = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                        Row(children: <Widget>[
                          Text(''),
                        ]),
                        Container(
                            height: 50,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.green,
                              child: Text(Common.loginBtnLabel),
                              onPressed: () {
                                RESTApi wsClient = new RESTApi();
                                DateTime tin = DateTime.now();
                                String day;
                                day = wsformatter.format(tin);
                                wsClient.CheckAuthService(
                                        nameController.text,
                                        passwordController.text,
                                        instanceCode,
                                        day,
                                        uuid)
                                    .then((val) => setState(() {
                                          if (val != 'Error') {
                                            try {
                                              final dbHelper =
                                                  DatabaseHelper.instance;
                                              dbHelper
                                                  .queryRowCount_AUTH_USER()
                                                  .then((numr) => setState(() {
                                                        int numRows = numr;
                                                        Map<String, dynamic>
                                                            userResponse =
                                                            jsonDecode(val);
                                                        int uid2Update =
                                                            int.parse(
                                                                userResponse[
                                                                    "UID"]);
                                                        if (numRows >
                                                            0)
                                                        {
                                                          dbHelper
                                                              .queryAllRows_AUTH_USER()
                                                              .then(
                                                                  (users) =>
                                                                      setState(
                                                                          () {
                                                                        if (users[0]["USER_ID"] ==
                                                                            uid2Update) {
                                                                          Map<String, dynamic>
                                                                              row =
                                                                              new Map<String, dynamic>();
                                                                          row["ID"] =
                                                                              users[0]["ID"];
                                                                          row["MOB_ATT_ENABLED"] =
                                                                              int.parse(userResponse["mobile_attendance_enabled"]);
                                                                          row["GPS_MANDATORY"] =
                                                                              int.parse(userResponse["gps_coord_mandatory"]);
                                                                          row["BASEURL"] =
                                                                              urlController.text;
                                                                          row["SKIPLOGIN"] = isSwitched == true
                                                                              ? 1
                                                                              : 0;
                                                                          dbHelper.update_AUTH_USER(row).then((result) =>
                                                                              setState(() {
                                                                                acquisizioneConfigurazione(day);
                                                                              }));
                                                                        } else {
                                                                          dbHelper.delete_AUTH_USER(uid2Update).then((result) =>
                                                                              setState(() {
                                                                                Map<String, dynamic> row = new Map<String, dynamic>();
                                                                                row["MOB_ATT_ENABLED"] = int.parse(userResponse["mobile_attendance_enabled"]);
                                                                                row["GPS_MANDATORY"] = int.parse(userResponse["gps_coord_mandatory"]);
                                                                                row["BASEURL"] = urlController.text;
                                                                                row["USER_ID"] = uid2Update;
                                                                                row["NAME"] = nameController.text;
                                                                                row["PASSWORD"] = passwordController.text;
                                                                                row["DELETED"] = 0;
                                                                                row["DISABLED"] = 0;
                                                                                row["CLIENTE_ID"] = instanceCode;
                                                                                row["SKIPLOGIN"] = isSwitched == true ? 1 : 0;
                                                                                dbHelper.insert_AUTH_USER(row).then((result) => setState(() {
                                                                                      acquisizioneConfigurazione(day);
                                                                                    }));
                                                                              }));
                                                                        }
                                                                      }));
                                                        } else
                                                        {
                                                          Map<String, dynamic>
                                                              row = new Map<
                                                                  String,
                                                                  dynamic>();
                                                          row["MOB_ATT_ENABLED"] =
                                                              int.parse(
                                                                  userResponse[
                                                                      "mobile_attendance_enabled"]);
                                                          row["GPS_MANDATORY"] =
                                                              int.parse(
                                                                  userResponse[
                                                                      "gps_coord_mandatory"]);
                                                          row["BASEURL"] =
                                                              urlController
                                                                  .text;
                                                          row["USER_ID"] =
                                                              uid2Update;
                                                          row["NAME"] =
                                                              nameController
                                                                  .text;
                                                          row["PASSWORD"] =
                                                              passwordController
                                                                  .text;
                                                          row["DELETED"] = 0;
                                                          row["DISABLED"] = 0;
                                                          row["CLIENTE_ID"] =
                                                              instanceCode;
                                                          row["SKIPLOGIN"] =
                                                              isSwitched == true
                                                                  ? 1
                                                                  : 0;
                                                          dbHelper
                                                              .insert_AUTH_USER(
                                                                  row)
                                                              .then((result) =>
                                                                  setState(() {
                                                                    acquisizioneConfigurazione(
                                                                        day);
                                                                  }));
                                                        }
                                                      }));
                                            } on Exception catch (_) {
                                              _showDialog2();
                                            }
                                          } else {
                                            _showDialog();
                                          }
                                        }))
                                    .catchError((e) {
                                  _showDialog();
                                });
                              },
                            )),
                      ],
                    ))));
  }

  void acquisizioneConfigurazione(String day) {
    wsClient.GetConfigurazione(nameController.text, passwordController.text,
            instanceCode, day, uuid)
        .then((val) => setState(() {
              if (val != 'Error') {
                dynamic configurazione = jsonDecode(val);
                Map<String, dynamic> configuraziones =
                    jsonDecode(configurazione);
                if (configuraziones != null &&
                    configuraziones["moduli"] != null) {
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
                                Map<String, dynamic> paramj =
                                    modulo["PARAMETRI"][j];
                                parametro["NOME"] = paramj["Nome"].toString();
                                parametro["VALORE"] =
                                    paramj["valore"].toString();
                                parametro["TIPO"] = paramj["Tipo"].toString();
                                dbHelper.insert_PARAMETRI(parametro);
                                j++;
                              }
                            }
                          }));
                      i++;
                    }
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  _showDialog();
                }
              } else {
                _showDialog();
              }
            }));
  }
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore Login"),
          content: new Text(
              "Verifica i dati immessi e la presenza della connessione di rete"),
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
  void _showDialog2() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Errore Login"),
          content: new Text(
              "Riprova tra qualche minuto o prova a contattare l'assistenza tecnica."),
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
}
