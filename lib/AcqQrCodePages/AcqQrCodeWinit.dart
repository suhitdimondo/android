import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hr_app/AcqNfcPages/AcqNFCWinit.dart';
import 'package:flutter_hr_app/Squadra/SquadraPage.dart';
import 'package:flutter_hr_app/common.dart';
import 'package:intl/intl.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../Model/Internet.dart';
import '../database.dart';

class AcquisizioneQrCodeWinit extends StatefulWidget {
  final String nfc;
  final int mode;
  final String name;
  final List selectedItems;
  final bool internet;

  AcquisizioneQrCodeWinit(
      {Key key,
      this.nfc,
      this.mode,
      this.name,
      this.selectedItems,
      this.internet})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => new _State();
}

int _selectedIndex = 0;

class _State extends State<AcquisizioneQrCodeWinit>
    with TickerProviderStateMixin {
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
  final noteController = new TextEditingController();
  String _captureText = '';
  static String time = "";
  static String date = "";
  final qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  Checkinternet objectinternet = Checkinternet();
  Barcode barcode;
  String internet = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => setUid());
    vmode = widget.mode;
    vname = widget.name;
    noteController.text = Common.qrCodeWaitLabel;
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller.pauseCamera();
    }
    await controller.resumeCamera();
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  void setUid() {
    try {
      dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
            if (users[0]["GPS_MANDATORY"] == 1) {
              isSwitched = true;
            } else {}
            authrowid = users[0]["ID"];
            uid = users[0]["USER_ID"];
            uid = users[0]["CLIENTE_ID"];
          }));
    } on Exception catch (_) {}
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "QRCODE",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => onBackPressed(context),
        ),
      ),
      body: SafeArea(
        child: getAcquisizioniView(),
      ),
      bottomNavigationBar: footer(),
    );
  }

  checkinternet() async {
    await objectinternet.checkConnectivityState();
  }

  Widget getAcquisizioniView() => QRView(
        key: qrKey,
        onQRViewCreated: onQrViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.grey,
          borderRadius: 10,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  void onQrViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    await controller.toggleFlash();
    controller.scannedDataStream.listen((barcode) async {
      setState(() => this.barcode = barcode);
      await controller.pauseCamera();
      _captureText = barcode.code;
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
              builder: (context) => AcquisizioneNfcWinit(
                  nfc: _captureText,
                  date: date,
                  time: time,
                  selectedItems: [],
                  long: 0.0,
                  lat: 0.0,
                  internet: widget.internet,
                  color: sendcolor)));
    });
  }

  int sendcolor;

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
            )
          ],
        );
      },
    );
  }

  void dBSaveData(captureText) {
    DateTime tin = DateTime.now();
    Map<String, dynamic> timb = new Map<String, dynamic>();
    timb["USER_ID"] = uid;
    timb["DATETIME"] = dbformatter.format(tin);
    timb["VERSO"] = "";
    timb["LATITUDE"] = -1;
    timb["LONGITUDE"] = -1;
    timb["IMPORTED"] = 0;
    timb["TIPO_ACQUISIZIONE"] = vmode;
    timb["TECNOLOGIA_ACQUISIZIONE"] = "QRCODE";
    final DateFormat tsformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    timb["VALORE_ACQUISIZIONE"] = jsonEncode([
      {"qrcode": captureText, "datetime": tsformatter.format(tin)}
    ]);
    try {
      dbHelper.insert_TIMB(timb).then((val) => null);
    } on Exception catch (_) {
      _showDialogKO();
    }
  }

  Widget footer() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.pause),
          label: 'Pausa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flash_on),
          label: 'Flash',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_arrow),
          label: 'Riprendi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Squadra',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.amber[800],
      onTap: _onItemTapped,
    );
  }

  Future<void> _onItemTapped(int index) async {
    _selectedIndex = index;
    if (_selectedIndex == 0) {
      await controller.pauseCamera();
    }
    if (_selectedIndex == 1) {
      await controller.toggleFlash();
    }
    if (_selectedIndex == 2) {
      await controller.resumeCamera();
    }
    if (_selectedIndex == 3) {
      internet = await checkinternet();
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  CollaboratoriList(widget.nfc, 0.0, 0.0, widget.internet)));
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 7), child: Text("Attesa...")),
        ],
      ),
    );
  }
}
