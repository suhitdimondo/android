import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:flutter_hr_app/preferenze.dart';
import 'package:flutter_hr_app/Impostazione/impostazioniPage.dart';
import 'package:intl/intl.dart';
import 'database.dart';
import 'ws.dart';
import 'package:flutter_hr_app/homePageTimb.dart';
import 'package:flutter_hr_app/homePageAcq.dart';
class HomePage extends StatefulWidget {
  bool doUpdate;
  HomePage(bool doUpdate) {
    this.doUpdate = doUpdate;
  }
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
class _State extends State<HomePage> {
  int cid = 0;
  bool vdoUpdate;
  List<Module> moduleList;
  final dbHelper = DatabaseHelper.instance;
  void initState() {
    vdoUpdate = widget.doUpdate;
    moduleList = List<Module>();
    final DateFormat cfformatter = DateFormat('yyyy-MM-dd');
    if (widget.doUpdate == true) {
      acquisizioneConfigurazione(cfformatter.format(DateTime.now()));
      widget.doUpdate = false;
    }
    dbHelper.queryAllRows_MODULI().then((modules) => setState(() {
          int p = 0;
          Module mod = new Module();
          mod.code = "000";
          mod.displayName = "Timbrature";
          mod.name = "Timbrature";
          mod.enabled = true;
          mod.position = p;
          mod.color = Common.impostazioniModuleColor;
          mod.icon = Common.indennitaModuleIcon;
          moduleList.add(mod);
          p = 1;
          for (var m in modules) {
            Module mod = new Module();
            mod.code = m["CODICE"];
            mod.displayName = m["NOME_IN_APP"];
            mod.name = m["NOME"];
            mod.enabled = m["STATO"] == 1 ? true : false;
            mod.position = p;
            switch (mod.code) {
              case "001":
              case "005":
                mod.color = Common.acquisizioniModuleColor;
                mod.icon = Common.acquisizioniModuleIcon;
                break;
              case "002":
              case "006":
                mod.color = Common.ferieModuleColor;
                mod.icon = Common.ferieModuleIcon;
                break;
              case "003":
              case "007":
                mod.color = Common.ferieModuleColor;
                mod.icon = Common.ferieModuleIcon;
                break;
              case "004":
              case "008":
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
  void acquisizioneConfigurazione(String day) {
    RESTApi wsClient = new RESTApi();
    dbHelper.queryAllRows_AUTH_USER().then((users) => {
          wsClient.GetConfigurazione("fake", users[0]["PASSWORD"],
                  users[0]["CLIENTE_ID"].toString(), day, "")
              .then((val) => setState(() {
                    cid = users[0]
                        ["CLIENTE_ID"];
                    if (val != 'Error') {
                      dynamic configurazione = jsonDecode(val);
                      Map<String, dynamic> configuraziones =
                          jsonDecode(configurazione);
                      if (configurazione != null &&
                          configuraziones != null &&
                          configuraziones["moduli"] != null) {
                        if (configuraziones["moduli"].length >=
                            0)
                        {
                          dbHelper.delete_AllPARAMETRI();
                          dbHelper.delete_AllMODULI();
                          int i = 0;
                          for (var m in configuraziones["moduli"]) {
                            Map<String, dynamic> modulo =
                                new Map<String, dynamic>();
                            Map<String, dynamic> inmod =
                                configuraziones["moduli"][i];
                            modulo["CODICE"] = inmod["CODICE"].toString();
                            modulo["NOME"] = inmod["NOME"];
                            modulo["NOME_IN_APP"] = inmod["NOME_IN_APP"];
                            modulo["STATO"] = inmod["STATO"];
                            final DateFormat tsformatter =
                                DateFormat('yyyy-MM-dd HH:mm:ss');
                            modulo["REFRESH"] =
                                tsformatter.format(DateTime.now());
                            dbHelper
                                .insert_MODULI(modulo)
                                .then((idm) => setState(() {
                                      int j = 0;
                                      if (modulo["PARAMETRI"] != null &&
                                          modulo["PARAMETRI"].length > 0) {
                                        for (var p in modulo["PARAMETRI"]) {
                                          Map<String, dynamic> parametro =
                                              new Map<String, dynamic>();
                                          Map<String, dynamic> paramj =
                                              modulo["PARAMETRI"][j];
                                          parametro["NOME"] =
                                              paramj["Nome"].toString();
                                          parametro["VALORE"] =
                                              paramj["valore"].toString();
                                          parametro["TIPO"] =
                                              paramj["Tipo"].toString();
                                          dbHelper.insert_PARAMETRI(parametro);
                                          j++;
                                        }
                                      }
                                    }));
                            i++;
                          }
                        } else {

                        }
                      } else {}
                    } else {}

                    getTipologiaAcquisizioni(wsClient);
                  }))
        });
  }
  void getTecnologieTipologie(RESTApi wsClient) {
    wsClient.GetTecnologieTipologie(Preferenze.piattaformaTimbratureHost, cid)
        .then((tacq) => setState(() {
              String rb = tacq;
              print(rb);
              if (rb != 'Error') {
                dynamic ttst = jsonDecode(rb);
                Map<String, dynamic> tts = jsonDecode(ttst);
                if (tts != null && tts["tecnologie_tipologie"] != null) {
                  if (tts["tecnologie_tipologie"].length > 0)
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
                      tipott["NOMETECNOLOGIA"] = intitt["Tecnologia"];
                      tipott["NOMETIPOLOGIA"] = intitt["Nome"];
                      dbHelper.insert_TIPOLOGIETECNOLOGIE(tipott);
                    }
                  }
                }
              }
            }));
  }
  void getTipologiaAcquisizioni(RESTApi wsClient) {
    wsClient.GetTipologiaAcquisizioni(Preferenze.piattaformaTimbratureHost, cid)
        .then((tacq) => setState(() {
              String rb = tacq;
              if (rb != 'Error') {
                dynamic tacqst = jsonDecode(rb);
                Map<String, dynamic> tacqs = jsonDecode(tacqst);
                if (tacqs != null && tacqs["tipologia_acquisizioni"] != null) {
                  if (tacqs["tipologia_acquisizioni"].length >
                      0)
                  {
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
                    getTecnologieTipologie(wsClient);
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
          new Future(() => false);
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
                child: getGridView(itemWidth, itemHeight, moduleList))));
  }
  GridView getGridView(
      double itemWidth, double itemHeight, List<Module> moduleList) {
    List<Widget> wList = List<Widget>();
    for (Module module in moduleList) {
      if (module.enabled == true) {
        print(module.code);
        switch (module.code) {
          case "000":
          case "001":
          case "002":
          case "003":
          case "004":
          case "005":
          case "006":
          case "007":
          case "008":
            wList.add(RaisedButton(
                color: Common.getModuleColor(module.code),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Common.moduleRoundedCorner),
                    side: BorderSide(color: Common.moduleBorderColor)),
                onPressed: () {
                  if (module.code == "000") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePageTimb(1)),
                    );
                  } else if (module.code == "001") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePageAcquisizioni()),
                    );
                  } else {
                    _showDialogNotImpl();
                  }
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
                )));
            break;
          default:
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
            MaterialPageRoute(builder: (context) => ImpostazioniPage()),
          );
        },
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: Text(
                Common.impostazioniModuleName,
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
  void _showDialogNotImpl() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Attenzione"),
          content: new Text("Modulo non implementato!"),
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
