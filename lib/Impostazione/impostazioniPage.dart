import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/HomePages/homePage.dart';
import '../database.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';
class ImpostazioniPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}
class Module {
  bool enabled = false;
  String name = "";
  String displayName = "";
  String code = "";
  Color color;
  IconData icon;
  int position = 0;
}
class _State extends State<ImpostazioniPage> {
  List<Module> moduleList;
  final dbHelper = DatabaseHelper.instance;
  int authrowid = 0;
  String version = "";
  String user = "";
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getAuthRowId());
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });
  }
  void getAuthRowId() {
    try {
      List<Map<String, dynamic>> users;
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            print(users);
            authrowid = users[0]["ID"];
            user = users[0]["NAME"];
          }));
    } on Exception catch (_) {
    }
  }
  @override
  Widget build(BuildContext context) {
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
              // leading: new Container(),
            ),
            body: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: getImpostazioniView()));
  }
  void onBackPressed(BuildContext context) {
    return Navigator.of(context).pop(true);
  }
  Padding getImpostazioniView() {
    List<Widget> wList = [];
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {},
      child: TextField(
        decoration: InputDecoration(
          labelText: "",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    ));
    wList.add(RaisedButton(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
          side: BorderSide(color: Common.moduleBorderColor)),
      textColor: Colors.white,
      color: Colors.black,
      child: Text(Common.ExitBtnLabel,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: Common.moduleFontSize)),
      onPressed: () {
        Map<String, dynamic> row = new Map<String, dynamic>();
        row["ID"] = authrowid;
        row["SKIPLOGIN"] = 0;
        dbHelper
            .update_AUTH_USER(row)
            .then((result) => setState(() {
                  SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop', true);
                  exit(0);
                }))
            .catchError((result) => setState(() {
                  SystemChannels.platform
                      .invokeMethod('SystemNavigator.pop', true);
                  exit(0);
                }));
      },
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {},
      child: TextField(
        decoration: InputDecoration(
          labelText: "",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    ));
    wList.add(MaterialButton(
      color: Colors.white,
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(0.0),
      splashColor: Colors.blueAccent,
      onPressed: () {},
      child: TextField(
        decoration: InputDecoration(
          labelText: "Version: " + version + " (" + user + ")",
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabled: false,
        ),
      ),
    ));
    return Padding(
        padding: EdgeInsets.all(0),
        child: Stack(children: <Widget>[
          Positioned(
              child: Align(
            alignment: Alignment.topLeft,
            child:
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
                          fontSize: Common.moduleFontSize, color: Colors.black),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Common.impostazioniModuleIcon,
                            size: Common.moduleIconSize),
                        labelText: Common.impostazioniModuleName,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabled: false,
                      ),
                    )),
          )),
          Positioned(
            child: Align(
                alignment: Alignment.bottomLeft,
                child: Text("v. " + version + " (" + user + ")",
                    style: TextStyle(fontSize: Common.moduleFontSize / 2))),
          ),
          Positioned(
              child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                      width: double.infinity,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Colors.black,
                        child: Text(Common.ExitBtnLabel,
                            style: TextStyle(
                                fontWeight: FontWeight
                                    .bold)),
                        onPressed: () {
                          Map<String, dynamic> row = new Map<String, dynamic>();
                          dbHelper
                              .resetApp();
                        },
                      )))),
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
                      MaterialPageRoute(builder: (context) => HomePage(doUpdate: false)),
                    );
                  },
                  label: Text("",
                      style: TextStyle(fontSize: Common.moduleFontSize)),
                  icon: Icon(Icons.arrow_back, size: 28),
                  color: Common.impostazioniModuleColor,
                )),
          )
        ]));
  }
}
