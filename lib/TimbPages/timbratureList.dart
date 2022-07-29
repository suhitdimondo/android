import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/preferenze.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hr_app/database.dart';
import 'dart:async';
import '../ws.dart';
import 'dart:convert';
class TimbraturePage extends StatefulWidget {
  int mode;
  TimbraturePage(int mode) {
    this.mode = mode;
  }
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<TimbraturePage> {
  bool isSwitched = false;
  var finaldate;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat wsformatter = DateFormat('yyyy-MM-dd');
  final DateFormat hourFormatter = DateFormat('HH:mm');
  final TextEditingController dayController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  int uid = 0;
  int cid = 0;
  String baseurl = "";
  String username = "";
  String hash = "";
  int vmode = 1;
  String tipoacq = "";
  List<Map<String, dynamic>> allRows = null;
  List<Map<String, dynamic>> allRowsNoImpT = null;
  List<Map<String, dynamic>> allRowsLocal = new List<Map<String, dynamic>>();
  List<Map<String, dynamic>> allRowsNoImp = new List<Map<String, dynamic>>();
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setInitialValues());
    vmode = widget.mode;
    dbHelper.queryAllRows_TIPOACQUISIZIONE().then((tac) => setState(() {
          for (var t in tac) {
            if (t["ID"] == vmode) {
              tipoacq = t["NOME"];
            }
          }
        }));
  }
  void setInitialValues() {
    try {
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            print(users);
            uid = users[0]["USER_ID"];
            cid = users[0]["CLIENTE_ID"];
            baseurl = users[0]["BASEURL"];
            username = users[0]["NAME"];
            hash = Preferenze.HASH;
            setFilter(DateTime.now(), baseurl);
          }));
    } on Exception catch (_) {
    }
  }
  @override
  void dispose() {
    dayController.dispose();
    super.dispose();
  }
  void subtractDate() async {
    finaldate = finaldate.subtract(Duration(days: 1));
    setFilter(finaldate, baseurl);
  }
  void addDate() async {
    finaldate = finaldate.add(Duration(days: 1));
    setFilter(finaldate, baseurl);
  }
  void setFilter(var order, String baseurl) {
    allRows = null;
    allRowsNoImpT = null;
    allRowsLocal = new List<Map<String, dynamic>>();
    allRowsNoImp = new List<Map<String, dynamic>>();
    finaldate = order;
    dayController.value = TextEditingValue(text: formatter.format(finaldate));
    dayController.text = formatter.format(finaldate);
    RESTApi wsClient = new RESTApi();
    String rb = null;
    showLoaderDialog(context);
    dbHelper
        .queryAllRows_TIMB_NOIMP(wsformatter.format(finaldate), uid, vmode)
        .then((val) => setState(() {
              allRowsNoImpT = val;
              if (allRowsNoImpT != null || allRowsNoImpT.length != 0) {
                for (var r in allRowsNoImpT) {
                  print(r);
                  Map<String, dynamic> nr = new Map<String, dynamic>();
                  nr["VERSO"] = r["VERSO"] == null ? "" : r["VERSO"];
                  nr["SEDE"] = r["SEDE"] == null ? "" : r["SEDE"];
                  nr["DATETIME"] = r["DATETIME"] == null ? "" : r["DATETIME"];
                  nr["IMPORTED"] = r["IMPORTED"] == null ? 0 : r["IMPORTED"];
                  nr["WORKED_TIME"] = "00:00";
                  nr["APPROVATA"] = 0;
                  nr["TECNOLOGIA_ACQUISIZIONE"] = r["TECNOLOGIA_ACQUISIZIONE"];
                  allRowsNoImp.add(nr);
                }
              }
            }));
    if (vmode == 1) {
      wsClient.GetTimbratureService(
              wsformatter.format(finaldate), uid, cid.toString(), vmode)
          .then((val) => setState(() {
                rb = val;
                if (rb != 'Error') {
                  Map<String, dynamic> timbs = jsonDecode(rb);
                  if (timbs != null) {
                    if (timbs["response"] != null) {
                      dbHelper.delete_TIMB_STATE(wsformatter.format(finaldate));
                      for (int i = 0; i < timbs["response"].length; i++) {
                        dbHelper.insert_TIMB_STATE(timbs["response"][i], uid);
                      }
                    }
                  }
                }
                dbHelper
                    .queryAllRows_TIMB_STATE(
                        wsformatter.format(finaldate), uid, vmode)
                    .then((val) => setState(() {
                          print("getRows");
                          allRows = val;
                          print(allRows);
                          if (allRows == null || allRows.length == 0) {
                            dbHelper
                                .queryAllRows_TIMBOfDay(
                                    wsformatter.format(finaldate), uid)
                                .then((lrows) => setState(() {
                                      if (lrows != null && lrows.length > 0) {
                                        for (var r in lrows) {
                                          Map<String, dynamic> nr =
                                              new Map<String, dynamic>();
                                          nr["VERSO"] = r["VERSO"] == null
                                              ? ""
                                              : r["VERSO"];
                                          nr["SEDE"] = r["SEDE"] == null
                                              ? ""
                                              : r["SEDE"];
                                          nr["DATETIME"] = r["DATETIME"] == null
                                              ? ""
                                              : r["DATETIME"];
                                          nr["IMPORTED"] = r["IMPORTED"] == null
                                              ? 0
                                              : r["IMPORTED"];
                                          nr["WORKED_TIME"] =
                                              r["WORKED_TIME"] == null
                                                  ? "00:00"
                                                  : r["WORKED_TIME"];
                                          allRowsLocal.add(nr);
                                        }
                                      }
                                    }));
                          }
                        }));
              }));
    } else {
      wsClient.GetAcquisizioniService(wsformatter.format(finaldate), uid,
              cid.toString(), vmode, username, hash)
          .then((val) => setState(() {
                rb = val;
                if (rb != 'Error') {
                  var timbs = jsonDecode(rb);
                  if (timbs != null) {
                    if (timbs[0]["DataOra"] != null) {
                      dbHelper.delete_TIMB_STATE(wsformatter.format(finaldate));
                      for (int i = 0; i < timbs.length; i++) {
                        var acquisizione = timbs[i];
                        Map<String, dynamic> record =
                            new Map<String, dynamic>();
                        record["USER_ID"] = uid;
                        record["DATETIME"] =
                            acquisizione["DataOra"]; //+ " 00:00:00";
                        record["VERSO"] = "U";
                        record["SEDE"] = acquisizione["Sede"];
                        record["VALORE_ACQUISIZIONE"] = acquisizione["Valore"];
                        record["TIPO_ACQUISIZIONE"] = vmode;
                        record["TECNOLOGIA_ACQUISIZIONE"] =
                            acquisizione["Tecnologia"];
                        record["APPROVATA"] = acquisizione["StatoConfermaGest"];
                        record["WORKED_TIME"] = null;
                        dbHelper.insert_TIMB_STATE(record, uid);
                      } //end for
                    }
                  }
                }
                dbHelper
                    .queryAllRows_TIMB_STATE(
                        wsformatter.format(finaldate), uid, vmode)
                    .then((val) => setState(() {
                          allRows = val;
                          if (allRows == null || allRows.length == 0) {
                            dbHelper
                                .queryAllRows_ACQUOfDay(
                                    wsformatter.format(finaldate), uid, vmode)
                                .then((lrows) => setState(() {
                                      for (var r in lrows) {
                                        Map<String, dynamic> nr =
                                            new Map<String, dynamic>();
                                        nr["VERSO"] = r["VERSO"] == null
                                            ? ""
                                            : r["VERSO"];
                                        nr["SEDE"] =
                                            r["SEDE"] == null ? "" : r["SEDE"];
                                        nr["DATETIME"] = r["DATETIME"] == null
                                            ? ""
                                            : r["DATETIME"];
                                        nr["IMPORTED"] = r["IMPORTED"] == null
                                            ? 0
                                            : r["IMPORTED"];
                                        nr["APPROVATA"] = r["APPROVATA"] == null
                                            ? 0
                                            : r["APPROVATA"];
                                        nr["WORKED_TIME"] =
                                            r["WORKED_TIME"] == null
                                                ? null
                                                : r["WORKED_TIME"];
                                        allRowsLocal.add(nr);
                                      }
                                    }));
                          }
                        }));
              }));
    }
  }
  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            print(users);
            uid = users[0]["USER_ID"];
            cid = users[0]["CLIENTE_ID"];
            baseurl = users[0]["BASEURL"];
            username = users[0]["NAME"];
            hash = Preferenze.HASH;
            setFilter(order, baseurl);
          }));
    });
  }
  Future<DateTime> getDate() {
    return showDatePicker(
      context: context,
      initialDate: finaldate != null ? finaldate : DateTime.now(),
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
  }
  Table getToolBarTable() {
    final tchilds = <TableRow>[];
    tchilds.add(TableRow(children: [
      Container(
        height: Common.BtnHeight,
        child: Text(''),
      ),
      Container(
        height: Common.BtnHeight,
        child: IconButton(
          icon: Icon(Icons.calendar_today),
          tooltip: Common.TimbratureTableIcon,
          onPressed: callDatePicker,
        ),
      ),
      Container(
        height: Common.BtnHeight,
        child: Text(''),
      )
    ]));
    tchilds.add(TableRow(children: [
      Container(
        height: Common.BtnHeight,
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          tooltip: Common.TimbratureTableIcon,
          onPressed: subtractDate,
        ),
      ),
      Container(
          height: Common.BtnHeight,
          child: TextField(
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              controller: dayController
                ..text = formatter
                    .format(finaldate != null ? finaldate : DateTime.now()),
              readOnly: true,
              onTap: callDatePicker,
              decoration: new InputDecoration(
                border: InputBorder.none,
              ))),
      Container(
        height: Common.BtnHeight,
        child: IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          tooltip: Common.TimbratureTableIcon,
          onPressed: addDate,
        ),
      )
    ]));
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: tchilds,
    );
  }
  Widget getTotaleLavoratoTable() {
    final tchilds = <TableRow>[];
    if (allRows != null &&
        allRows.length > 0 &&
        allRows[0]['WORKED_TIME'] != null &&
        allRows[0]['WORKED_TIME'] != "null" &&
        allRows[0]['WORKED_TIME'] != "00:00") {
      tchilds.add(TableRow(children: [
        Text(
          "Totale lavorato: " + allRows[0]['WORKED_TIME'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        )
      ]));
      tchilds.add(TableRow(children: [
        Text(
          (""),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        )
      ]));
    }
    else if (allRowsLocal != null &&
        allRowsLocal.length > 0 &&
        allRowsLocal[0]['WORKED_TIME'] != null &&
        allRowsLocal[0]['WORKED_TIME'] != "null" &&
        allRows[0]['WORKED_TIME'] != "00:00") {
      tchilds.add(TableRow(children: [
        Text(
          "Totale lavorato: " + allRowsLocal[0]['WORKED_TIME'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        )
      ]));
      tchilds.add(TableRow(children: [
        Text(
          (""),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
          textAlign: TextAlign.center,
        )
      ]));
    }
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: tchilds,
    );
  }
  Table getTable() {
    final tchilds = <TableRow>[];
    if ((allRows != null && allRows.length > 0) ||
        (allRowsLocal != null && allRowsLocal.length > 0)) {
      tchilds.add(TableRow(children: [
        Text(
          Common.TimbratureTableTipologia,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          Common.TimbratureTableOra,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          vmode == 1
              ? Common.TimbratureTableSede
              : Common.AcquisizioneTableLuogo,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ]));
      for (var i = 0; i < allRows.length; i++) {
        tchilds.add(TableRow(children: [
          Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.green),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
        tchilds.add(TableRow(children: [
          Text(
            ((allRows[i]['VERSO'] == 'E' && vmode == 1)
                ? 'Entrata'
                : (vmode == 1 && allRows[i]['VERSO'] == 'U')
                    ? 'Uscita'
                    : tipoacq),
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: (allRows[i]['APPROVATA'] == 1 ||
                        allRows[i]['APPROVATA'] == "1")
                    ? Colors.green
                    : Colors.red),
            textAlign: TextAlign.center,
          ),
          Text(
            hourFormatter.format(DateTime.parse(allRows[i]['DATETIME'])),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            allRows[i]['SEDE'],
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
      }
      for (var i = 0; i < allRowsLocal.length; i++) {
        tchilds.add(TableRow(children: [
          Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.green),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
        tchilds.add(TableRow(children: [
          Text(
            ((allRowsLocal[i]['VERSO'] == 'E' && vmode == 1)
                ? 'Entrata'
                : (vmode == 1 && allRowsLocal[i]['VERSO'] == 'U')
                    ? 'Uscita'
                    : tipoacq),
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: (allRowsLocal[i]['APPROVATA'] != null &&
                        allRowsLocal[i]['APPROVATA'] == 1)
                    ? Colors.green
                    : Colors.red),
            textAlign: TextAlign.center,
          ),
          Text(
            hourFormatter.format(DateTime.parse(allRowsLocal[i]['DATETIME'])),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            allRowsLocal[i]['SEDE'],
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
      }
    } else {
      tchilds.add(TableRow(children: [
        Text(
            vmode == 1
                ? Common.TimbratureTableNoTimb
                : Common.AcquisizioneTableNoAcq,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center),
      ]));
    }
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: tchilds,
    );
  }
  Table getTableNoImp() {
    final tchilds = <TableRow>[];
    if ((allRowsNoImp != null && allRowsNoImp.length > 0)) {
      tchilds.add(TableRow(children: [
        Text(
          Common.TimbratureTableTipologia,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          Common.TimbratureTableOra,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        Text(
          vmode == 1
              ? Common.TimbratureTableTecnologia
              : Common.TimbratureTableTecnologia,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ]));
      for (var i = 0; i < allRowsNoImp.length; i++) {
        tchilds.add(TableRow(children: [
          Text(
            '',
            style: TextStyle(
                fontWeight: FontWeight.normal, fontSize: 14, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            '',
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
        tchilds.add(TableRow(children: [
          Text(
            ((allRowsNoImp[i]['VERSO'] == 'E' && vmode == 1)
                ? 'Entrata'
                : (vmode == 1 && allRowsNoImp[i]['VERSO'] == 'U')
                    ? 'Uscita'
                    : tipoacq),
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: (allRowsNoImp[i]['APPROVATA'] == 1 ||
                        allRowsNoImp[i]['APPROVATA'] == "1")
                    ? Colors.green
                    : Colors.red),
            textAlign: TextAlign.center,
          ),
          Text(
            hourFormatter.format(DateTime.parse(allRowsNoImp[i]['DATETIME'])),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          Text(
            allRowsNoImp[i]['TECNOLOGIA_ACQUISIZIONE'],
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]));
      }
    } else {
      tchilds.add(TableRow(children: [
        Text(
            vmode == 1
                ? Common.TimbratureTableNoTimb
                : Common.AcquisizioneTableNoAcq,
            style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            textAlign: TextAlign.center),
      ]));
    }
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: tchilds,
    );
  }
  void onBackPressed(BuildContext context) {
    return Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    dayController.addListener(() {});
    return WillPopScope(
        onWillPop: () {
          onBackPressed(context);
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Image.asset(
                Common.logo,
                fit: BoxFit.cover,
                alignment: Alignment.topLeft,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.black, //change your color here
              ),
            ),
            body: Padding(
                padding: EdgeInsets.all(0),
                child: ListView(
                  children: <Widget>[
                    MaterialButton(
                        color: Colors.white,
                        textColor: Colors.black,
                        disabledColor: Colors.black,
                        disabledTextColor: Colors.black,
                        padding: EdgeInsets.all(0.0),
                        splashColor: Colors.blueAccent,
                        onPressed: () {},
                        child: TextField(
                          style: TextStyle(
                              fontSize: Common.moduleFontSize,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Common.calendarioModuleIcon,
                                size: Common.moduleIconSize),
                            labelText: vmode == 1
                                ? Common.TimbratureBtnLabel2
                                : Common.AcquisizioniBtnLabel2,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            enabled: false,
                          ),
                        )),
                    Container(
                      height: Common.SpaceHeight / 4,
                    ),
                    Container(
                        height: Common.BtnHeight * 2,
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        child: getToolBarTable()),
                    Container(
                      height: Common.SpaceHeight,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: getTotaleLavoratoTable(),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: getTable(),
                    ),
                    Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(top: 5.0),
                        child: (allRowsNoImp == null ||
                                allRowsNoImp.length == 0)
                            ? Text("")
                            : TextField(
                                style: TextStyle(
                                    fontSize: Common.moduleFontSize,
                                    color: Colors.black),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Common.calendarioModuleIcon,
                                      size: Common.moduleIconSize),
                                  labelText: vmode == 1
                                      ? Common.TimbratureLocalData
                                      : Common.AcquisizioneLocalData,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  enabled: false,
                                ),
                              )),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(2.0),
                      child: Text(""),
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(5.0),
                      child: (allRowsNoImp == null || allRowsNoImp.length == 0)
                          ? Text("")
                          : getTableNoImp(),
                    )
                  ],
                ))));
  }
  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text("Attesa...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        Future.delayed(Duration(seconds: 10), () {}).then((_) {
          Navigator.of(context).pop();
        });
        return alert;
      },
    );
  }
}
