import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/Model/DataDamage.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../ws.dart';

class DamageCompiled extends StatefulWidget {
  final String codice;
  final String cantiere;

  const DamageCompiled({this.cantiere, this.codice});

  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<DamageCompiled> {
  String nfc = "";
  final dbHelper = DatabaseHelper.instance;
  String matricola;
  String codiceTag;
  String cantiere;
  final myController = TextEditingController();
  final myControllerNote = TextEditingController();
  String dropdownTypeValue = 'Sel tipologia';
  String dropdownDescriptionValue = 'Sel tipologia';
  List dataDamageList = [];
  List dataDamageTypeList = [];
  List dataDamageDescriptionList = [];
  bool typeSelected = false;
  XFile _image;
  XFile _video;

  _imgFromCamera() async {
    XFile image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  _videoFromCamera() async {
    XFile video = await ImagePicker().pickVideo(source: ImageSource.camera);
    setState(() {
      _video = video;
    });
  }

  _imgFromGallery() async {
    XFile image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                  new ListTile(
                    leading: new Icon(Icons.video_call_rounded),
                    title: new Text('Video'),
                    onTap: () {
                      _videoFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    initPlatformState();
    codiceTag = widget.codice;
    cantiere = widget.cantiere;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[100],
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(
          "ClockApp 2.0",
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomePageWinit(),
              )),
        ),
        backgroundColor: Colors.blue,
      ),
      body: new Container(
          padding: new EdgeInsets.all(20.0),
          child: new Form(
            child: new ListView(
              children: <Widget>[
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              'Matricola dispositivo:',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.50,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              '$matricola',
                              style:
                                  TextStyle(fontSize: 17, color: Colors.blue),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              'Data e Ora:',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "${getSystemDate()} ${getSystemTime()}",
                              style:
                                  TextStyle(fontSize: 17, color: Colors.blue),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.50,
                        padding: EdgeInsets.all(10.0),
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Text(
                              "Codice Badge:",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "$codiceTag",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.50,
                        padding: EdgeInsets.all(10.0),
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "Cantiere:",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "$cantiere",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.50,
                        padding: EdgeInsets.all(10.0),
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "Tipologia:",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new DropdownButton2(
                              isExpanded: true,
                              hint: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.list,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Tipologia',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              alignment: Alignment.centerLeft,
                              items: dataDamageTypeList
                                  .map((item) => DropdownMenuItem(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              value: dropdownTypeValue,
                              onChanged: (newValue) {
                                setState(() {
                                  dropdownTypeValue = newValue;
                                  typeSelected = false;
                                  getDataDamageDescription(newValue);
                                });
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios_outlined,
                              ),
                              iconSize: 14,
                              iconEnabledColor: Colors.white,
                              iconDisabledColor: Colors.grey,
                              buttonHeight: 50,
                              buttonWidth:
                                  MediaQuery.of(context).size.width * 0.60,
                              buttonPadding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              buttonDecoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                ),
                                color: Colors.blue,
                              ),
                              buttonElevation: 2,
                              itemHeight: 40,
                              dropdownMaxHeight: 200,
                              dropdownWidth:
                                  MediaQuery.of(context).size.width * 0.35,
                              dropdownPadding: null,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: Colors.black,
                              ),
                              dropdownElevation: 8,
                              scrollbarRadius: const Radius.circular(40),
                              scrollbarThickness: 6,
                              scrollbarAlwaysShow: true,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.50,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "Codice:",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                            (typeSelected != false)
                                ? Container(
                                    height: 40,
                                    child: DropdownButton(
                                      value: dropdownDescriptionValue,
                                      icon: const Icon(Icons.arrow_downward),
                                      iconSize: 15,
                                      elevation: 16,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 15),
                                      underline: Container(
                                        height: 2,
                                        color: Colors.deepPurpleAccent,
                                      ),
                                      onChanged: (newVal) {
                                        setState(() {
                                          dropdownDescriptionValue = newVal;
                                        });
                                      },
                                      items: dataDamageDescriptionList
                                          .map((val) => DropdownMenuItem(
                                                value: val,
                                                child: Text(val),
                                              ))
                                          .toList(),
                                    ))
                                : Row(),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.20,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Text(
                              "Note:",
                              style: TextStyle(
                                  fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * 0.35,
                        padding: EdgeInsets.all(10.0),
                        alignment: Alignment.centerLeft,
                      )
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new GestureDetector(
                        onTap: () {
                          _showPicker(context);
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey,
                          child: (_image != null || _video != null)
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    width: 100,
                                    height: 100,
                                    child: Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 50,
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(40)),
                                  width: 100,
                                  height: 100,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 10, thickness: 10, color: Colors.grey[200]),
                new Form(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      new MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: Colors.blue)),
                        color: Colors.blue,
                        textColor: Colors.white,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () => {sendDamage()},
                        child: Text(
                          "INVIA".toUpperCase(),
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
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

  String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("HH:mm").format(now);
  }

  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
  }

  sendDamage() async {
    RESTApi wsClient = new RESTApi();
    var toast;
    if (_image != null) {
      toast = await wsClient.sendDamage(
          matricola,
          "${getSystemDate()} ${getSystemTime()}",
          myController.text,
          dropdownTypeValue,
          dropdownDescriptionValue,
          _image.path,
          "",
          "",
          0);
    } else {
      toast = await wsClient.sendDamage(
          matricola,
          "${getSystemDate()} ${getSystemTime()}",
          myController.text,
          dropdownTypeValue,
          dropdownDescriptionValue,
          _video.path,
          "",
          "",
          1);
    }
    if (toast) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePageWinit()));
    } else {
      _toast("Segnalazione non inviata");
    }
  }

  _toast(String messaggio) {
    Fluttertoast.showToast(
        msg: messaggio,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  getDamage() async {
    dataDamageList = await dbHelper.getDataDamage();
    for (int i = 0; i < dataDamageList.length; i++) {
      dataDamageTypeList.add(dataDamageList[i]["tipo"]);
    }
    dropdownTypeValue = dataDamageTypeList.first;
  }

  generateDataDamageTypeList() async {
    //dropdownTypeValue = dataDamageTypeList.first;
  }

  getDataDamageDescription(String tipo) {
    DataDamage tmp;
    dbHelper.getDataDamagesDescription(tipo).then((value) => setState(() {
          for (var val in value) {
            tmp = (DataDamage.fromJson(val));
            dataDamageDescriptionList.add(tmp.sottotipo);
          }
          dropdownDescriptionValue = dataDamageDescriptionList.first;
          typeSelected = true;
        }));
  }

  getMatricola() async {
    await dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
          matricola = users[0]["NAME"];
        }));
  }

  void onBackPressed(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePageWinit()));
  }

  initPlatformState() async {
    await getDamage();
    getMatricola();
  }
}
