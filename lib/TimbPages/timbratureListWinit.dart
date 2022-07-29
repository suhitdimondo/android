import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/AcqNfcPages/AcqNFCWinit.dart';
import 'package:flutter_hr_app/Model/Acquisizioni.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hr_app/database.dart';
import 'dart:async';
import '../ws.dart';
class TimbraturePageWinit extends StatefulWidget {
  int mode;
  TimbraturePageWinit(int mode) {
    this.mode = mode;
  }
  @override
  State<StatefulWidget> createState() => new _State();
}
int vmode = 1;
int uid = 0;
int cid = 0;
final dbHelper = DatabaseHelper.instance;
class _State extends State<TimbraturePageWinit> {
  RESTApi wsClient = new RESTApi();
  final dbHelper = DatabaseHelper.instance;
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final DateFormat formatter1 = DateFormat('H:mm');
  final TextEditingController dayController = TextEditingController();
  var finalDate;
  List<List<Valore>> acquisizioniinv = new List<List<Valore>>();
  List<ValoreDb> acquisizioniloc = new List<ValoreDb>();
  void initState() {
    if (finalDate == null) {
      finalDate = DateTime.now();
    }
    initPlatformState();
  }
  @override
  Widget build(BuildContext context) {
    if (finalDate == null) {
      setFilter(DateTime.now());
    }
    return Container(
        child: Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      drawer: NavDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => onBackPressed(context),
        ),
        title: Text(
          'Registrazioni',
          textAlign: TextAlign.right,
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
          padding: EdgeInsets.all(0),
          child: ListView(
            children: <Widget>[
              Container(
                height: Common.BtnHeight * 3,
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: myContainer(),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20, bottom: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: myTable(),
              )
            ],
          )),
    ));
  }
  Table myContainer() {
    final tchilds = <TableRow>[];
    tchilds.add(TableRow(children: [
      Text(
        '',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      Text(
        'Timbrature',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        textAlign: TextAlign.center,
      ),
      Text(
        '',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ]));
    myTable();
    return Table(
      border: TableBorder.all(color: Colors.white),
      children: tchilds,
    );
  }
  getAcquisizioni() async {
    await dbHelper.queryAllRows_AUTH_USER().then((users) => setState(
          () {
            uid = users[0]["USER_ID"];
            cid = users[0]["CLIENTE_ID"];
            wsClient.GetTimbratureWinit(cid, uid).then((value) => setState(() {
                  if (value.length != 0) {
                    acquisizioniinv.clear();
                    for (var acq in value) {
                      //if (formatter.format(acq.valore.first.datetime) ==
                      //    formatter.format(finalDate)) {
                      acquisizioniinv.contains(acq.valore.first.datetime);
                      if (!acquisizioniinv
                          .contains(acq.valore.first.datetime)) {
                        acquisizioniinv.add(acq.valore);
                      }
                    }
                  }
                }));
            dbHelper.queryAllRows_TIMB().then((value) => setState(() {
                  if (value.length != 0) {

                  }
                }));
          },
        ));
  }
  Table myTable() {
    if (acquisizioniinv != null) {
      return Table(
          columnWidths: {
            0: FlexColumnWidth(5),
            1: FlexColumnWidth(5),
            2: FlexColumnWidth(3),
            3: FlexColumnWidth(3),
          },
          border: TableBorder.symmetric(
            inside: BorderSide(width: 1),
          ),
          children: [
            TableRow(children: [
              Text(
                'Data',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              Text(
                'Ora',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              Text(
                'Verso',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
              Text(
                'Inviata',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ]),
            for (var element in acquisizioniinv)
              TableRow(children: [
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Text('${formatter.format(element.first.datetime)}'),
                    ],
                  ),
                ),
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Text('${formatter1.format(element.first.datetime)}'),
                    ],
                  ),
                ),
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Text('${element.first.verso}'),
                    ],
                  ),
                ),
                TableCell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Text('      ',
                          style: TextStyle(backgroundColor: Colors.blue)),
                    ],
                  ),
                ),
              ]),
          ]);
    }
  }
  void callDatePicker() async {
    var order = await getDate();
    setState(() {
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            uid = users[0]["USER_ID"];
            cid = users[0]["CLIENTE_ID"];
            setFilter(order);
          }));
    });
    finalDate = order;
    addDate();
  }
  Future<DateTime> getDate() {
    return showDatePicker(
      context: this.context,
      initialDate: finalDate != null ? finalDate : DateTime.now(),
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
  void substractDate() async {
    finalDate = finalDate.subtract(Duration(days: 1));
    setFilter(finalDate);
    acquisizioniinv.clear();
    initPlatformState();
  }
  void addDate() async {
    finalDate = finalDate.add(Duration(days: 1));
    setFilter(finalDate);
    acquisizioniinv.clear();
    initPlatformState();
  }
  void setFilter(var order) {
    finalDate = order;
    dayController.value = TextEditingValue(text: formatter.format(finalDate));
    dayController.text = formatter.format(finalDate);
  }
  void initPlatformState() {
    getAcquisizioni();
  }
}
