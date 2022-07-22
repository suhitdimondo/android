import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'database.dart';
import 'package:flutter_hr_app/homePageAcquisizioniInner.dart';
import 'package:flutter_hr_app/HomePages/homePage.dart';
class HomePageAcquisizioni extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}
class Module {
  bool enabled;
  String name;
  String displayName;
  String code;
  Color color;
  IconData icon;
  int position;
}
class _State extends State<HomePageAcquisizioni> {
  List<Module> moduleList;
  final dbHelper = DatabaseHelper.instance;
  void initState() {
    moduleList = List<Module>();
    dbHelper.queryAllRows_TIPOACQUISIZIONE().then((modules) => setState(() {
          int p = 1;
          for (var m in modules) {
            Module mod = new Module();
            mod.code = m["ID"].toString();
            mod.displayName = m["NOME"];
            mod.name = m["NOME"];
            mod.enabled = m["ABILITATA"] == 1 ? true : false;
            mod.position = p;
            switch (mod.code) {
              case "1":
              case "5":
                mod.color = Common.calendarioModuleColor;
                mod.icon = Common.calendarioModuleIcon;
                break;
              case "2":
              case "6":
                mod.color = Common.acquisizioniModuleColor;
                mod.icon = Common.acquisizioniModuleIcon;
                break;
              case "3":
              case "7":
                mod.color = Common.ferieModuleColor;
                mod.icon = Common.ferieModuleIcon;
                break;
              case "4":
              case "8":
                mod.color = Common.indennitaModuleColor;
                mod.icon = Common.indennitaModuleIcon;
                break;
              default:
                mod.color = Common.impostazioniModuleColor;
                mod.icon = Common.indennitaModuleIcon;
                break;
            }
            moduleList.add(mod);
            p++;
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
  void onBackPressed(BuildContext context) {
    return Navigator.of(context).pop(true);
  }
  @override
  Widget build(BuildContext context) {
    rebuildAllChildren(context);
    var size = MediaQuery.of(context).size;
    final int numModules = moduleList.length;
    int increment = 1;
    if (numModules % 2 == 0) {
      increment = 0;
    }
    if (numModules <= 4) {
      increment += 2;
    }
    final double itemHeight = (size.height) / 4;
    final double itemWidth = size.width / 2;
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
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                color: Colors.white, //change your color here
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(10),
              child: getGridView(itemWidth, itemHeight, moduleList),
            )));
  }
  GridView getGridView(
      double itemWidth, double itemHeight, List<Module> moduleList) {
    List<Widget> wList = List<Widget>();
    for (Module module in moduleList) {
      if (module.enabled == true) {
        print(module.code);
        switch (module.code) {
          case "1":
            break;
          default:
            wList.add(FutureBuilder<Color>(
                future:
                    dbHelper.getTipoAcquisizioneColor(int.parse(module.code)),
                builder: (BuildContext context, AsyncSnapshot<Color> snapshot) {
                  return RaisedButton(
                      color: snapshot
                          .data,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Common.moduleRoundedCorner),
                          side: BorderSide(color: Common.moduleBorderColor)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomePageAcquisizioniInner(
                                  int.parse(module.code), module.name)),
                        );
                      },
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              module.displayName,
                              style: TextStyle(fontSize: Common.moduleFontSize),
                              maxLines: null,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ));
                }));
            break;
        }
      }
    }
    wList.add(RaisedButton(
        color: Common.impostazioniModuleColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Common.moduleRoundedCorner),
            side: BorderSide(color: Common.moduleBorderColor)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        },
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back,
                size: Common.moduleIconSize,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                " ",
                style: TextStyle(fontSize: Common.moduleFontSize),
                maxLines: null,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "INDIETRO",
                style: TextStyle(fontSize: Common.moduleFontSize),
                maxLines: null,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )));
    return GridView.count(
        childAspectRatio: (itemWidth / itemHeight),
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: wList);
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
