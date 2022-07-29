import 'package:flutter/material.dart';
import 'package:flutter_hr_app/AcqQrCodePages/AcqQrCodeWinit.dart';
import 'package:flutter_hr_app/HomePages/homePageWinit.dart';
import 'package:flutter_hr_app/Model/DataDamage.dart';
import 'package:flutter_hr_app/widgets/menu/nav-drawer-Winit.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../database.dart';
import '../ws.dart';

class Damage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<Damage> {
  String nfc = "";
  final dbHelper = DatabaseHelper.instance;
  String matricola;
  final myController = TextEditingController();
  final myControllerNote = TextEditingController();
  String dropdownTypeValue = 'Sel tipologia';
  String dropdownDescriptionValue = 'Sel tipologia';
  List<DataDamage> dataDamageList;
  List<String> dataDamageTypeList;
  List<String> dataDamageDescriptionList;
  bool typeSelected = false;
  XFile _image;
  XFile _video;
  int _selectedIndex = 0;

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.grey[100],
        drawer: NavDrawer(),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => onBackPressed(context),
          ),
          title: Text('Segnalazioni'),
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(
            child: Container(
                margin: const EdgeInsets.only(top: 10.0),
                color: Colors.grey[100],
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 3, 30, 3),
                            child: Row(children: [
                              Text(
                                'Matricola dispositivo:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black54,
                                ),
                              ),
                              Spacer(),
                              Text(
                                '$matricola',
                                style:
                                    TextStyle(fontSize: 17, color: Colors.blue),
                              ),
                            ])),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 3, 30, 3),
                            child: Row(children: [
                              Text(
                                'Data e Ora:',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black54,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${getSystemDate()} ${getSystemTime()}",
                                style:
                                    TextStyle(fontSize: 17, color: Colors.blue),
                              ),
                            ])),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 3, 30, 3),
                            child: Row(children: [
                              Text(
                                "Codice Badge:",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                              Spacer(),
                              Text(
                                "",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                            ])),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                            child: Row(children: [
                              Text(
                                "Cantiere:",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                              Spacer(),
                              Container(
                                height: 17,
                                width: 100,
                                child: TextField(
                                  controller: myController,
                                ),
                              )
                            ])),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            child: Row(children: [
                              Text(
                                "Tipologia:",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                              Spacer(),
                              Container(
                                  height: 40,
                                  child: DropdownButton<String>(
                                    value: dropdownTypeValue,
                                    icon: const Icon(Icons.arrow_downward),
                                    iconSize: 15,
                                    elevation: 16,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (String newValue) {
                                      setState(() {
                                        dropdownTypeValue = newValue;
                                        typeSelected = false;
                                        getDataDamageDescription(newValue);
                                      });
                                    },
                                    items: dataDamageTypeList
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  )),
                            ])),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            height: 40,
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                            child: Row(children: [
                              Text(
                                "Codice:",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                              Spacer(),
                              (typeSelected != false)
                                  ? Container(
                                      height: 40,
                                      child: DropdownButton<String>(
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
                                        onChanged: (String newVal) {
                                          setState(() {
                                            dropdownDescriptionValue = newVal;
                                          });
                                        },
                                        items: dataDamageDescriptionList
                                            .map<DropdownMenuItem<String>>(
                                                (String val) {
                                          return DropdownMenuItem<String>(
                                            value: val,
                                            child: Text(val),
                                          );
                                        }).toList(),
                                      ))
                                  : Row(),
                            ]
                                //bottomNavigationBar: _myBNBar(),
                                )),
                        Divider(
                          height: 10,
                          color: Colors.white,
                        ),
                        Divider(
                            height: 10, thickness: 10, color: Colors.grey[200]),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                            child: Row(children: [
                              Text(
                                "Note:",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ),
                              Spacer(),
                              Container(
                                  height: 17,
                                  width: 100,
                                  child: TextField(
                                    controller: myControllerNote,
                                  )),
                            ])),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Divider(
                          height: 15,
                          color: Colors.white,
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                            child: Row(children: [
                              Center(
                                  child: GestureDetector(
                                      onTap: () {
                                        _showPicker(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Colors.grey,
                                        child: _image != null || _video != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            40)),
                                                width: 100,
                                                height: 100,
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.grey[800],
                                                ),
                                              ),
                                      ))),
                              Spacer(),
                              MaterialButton(
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
                            ])),
                      ]))
                ]))));
  }

  void onitemtapped(int index) {
    _selectedIndex = index;
    if (_selectedIndex == 0) {
      showLoaderDialog(context);
      FlutterNfcReader.read(instruction: "It's reading").then((value) {
        String val2Write = value.id.toString();
        if (val2Write.trim().length == 0) {
          val2Write = value.content;
        }
      });
    }
    if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AcquisizioneQrCodeWinit(
                  nfc: "",
                  mode: 0,
                  name: "",
                  selectedItems: [],
                )),
      );
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
    await dbHelper.getDataDamage().then((value) => setState(() {
          for (var val in value) {
            dataDamageList.add(DataDamage.fromJson(val));
          }
          generateDataDamageTypeList();
        }));
  }

  generateDataDamageTypeList() {
    for (var data in dataDamageList) {
      if (!dataDamageTypeList.contains(data.tipo)) {
        dataDamageTypeList.add(data.tipo);
      }
    }
    dropdownTypeValue = dataDamageTypeList.first;
  }

  getDataDamageDescription(String tipo) async {
    DataDamage tmp;
    await dbHelper.getDataDamagesDescription(tipo).then((value) => setState(() {
          dataDamageDescriptionList.clear();
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

  Future<void> initPlatformState() async {
    await getDamage();
    getMatricola();
  }
}
