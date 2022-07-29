import 'dart:async';

import 'dart:ui';
import 'package:audioplayer/audioplayer.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
import 'package:flutter_hr_app/audio/AudioWinit.dart';
import 'package:flutter_hr_app/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import '../camera/PhotoWinit.dart';
import 'FormProdotto.dart';
import 'ProductD.dart';
import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';

import 'package:flutter/services.dart';

import 'package:file/local.dart';
class ProductDisplay extends StatefulWidget {
  final String fotos;
  ProductDisplay({this.fotos});
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<ProductDisplay> {
  void onPlayAudio(String audioPath) async {
    try{
    bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;
    if (hasPermission) {
    print(audioPath);

    AudioPlayer audioPlayer = AudioPlayer();
      try {
        await audioPlayer.play(audioPath+".wav", isLocal: true);
      }catch(e){
        print(e);
      }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }
  final dbHelper = DatabaseHelper.instance;
  List _journals = [];
  List data = [];
  List _getData = [];
  List _data = [];
  @override
  void initState() {
    super.initState();
  }
  getData() async {
    _getData.clear();
    _data = await dbHelper.prodotto_tutto();
    for (int i = 0; i < _data.length; i++) {
      _getData.add(_data[i]);
    }
    return _getData;
  }
  getRichiesti() async{
    _journals.clear();
    data = await dbHelper.select_prodotti();
    for (int i = 0; i < data.length; i++) {
      _journals.add(data[i]);
    }
    return _journals;
  }
  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }
  _deleteTutto() async{
    final res = await dbHelper.drop_prodotto();
    return res;
  }
  Timer _incrementCounterTimer;
  int counter = 1;
  timerBuffer() async {
    _incrementCounterTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
          counter++;
          if (counter == 4) {
              await getRichiesti();
              await getData();
            _incrementCounterTimer.cancel();
            counter = 1;
          }
        });
  }
  @override
  Widget build(BuildContext context) {
    final PageController controller_one = PageController();
    final PageController controller_two = PageController();
    return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dettagli'),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  text: "PRODOTTI",
                  icon: Icon(Icons.cloud_outlined),
                ),
                Tab(
                  text: "RICHIESTE",
                  icon: Icon(Icons.beach_access_sharp),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              PageView(

                /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                /// Use [Axis.vertical] to scroll vertically.
                controller: controller_one,
                children: [
                  SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Column(
                      children: [
                      SizedBox(
                      height:MediaQuery.of(context).size.height,
    width: MediaQuery.of(context).size.width*1.0,

    child:
    FutureBuilder(
    future: getData(),
    builder: (BuildContext context, snap) {
    if(snap.connectionState == ConnectionState.waiting) {
    return const Scaffold(body: CircularProgressIndicator(),);
    } else {
    return
    Scaffold(
                              body: Scaffold(
                                          body: new ListView.builder(
                                            shrinkWrap: true,
                                              itemCount: snap.data.length,
                                              itemBuilder: (BuildContext con, int index)  {
                                                return new Card(
                                                  child: ListTile(
                                                    leading: SizedBox(
                                                    width: 319,
                                                    height: 50,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text("Richiesta: "+snap.data[index]["datetimes"], textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue))
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                child: Column(
                                                                  children: [
                                                                    Text("Prodotto", style: TextStyle(fontWeight: FontWeight.bold),),
                                                                    Text(snap.data[index]["prodotti"].toString(), overflow: TextOverflow.clip,
                                                                        style: TextStyle(fontSize: 12.0, color: Colors.black))
                                                                  ],
                                                                ),
                                                                width: MediaQuery.of(context).size.width*0.60,
                                                              ),
                                                              Container(
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text("Quantita:",
                                                                              style: TextStyle(fontSize: 12.0, color: Colors.black, fontWeight: FontWeight.bold))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(snap.data[index]["quantita"].toString(),
                                                                              style: TextStyle(fontSize: 12.0, color: Colors.black))
                                                                        ],
                                                                      ),
                                                                      width: MediaQuery.of(context).size.width*0.10,
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                                      onTap: (){
                                                        String id_nav = snap.data[index]["id"].toString();
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) => ProductD(id: id_nav)));
                                                }),
                                                );
                                              }
                                          )
                                      ));}})
    )

    ]

    ))
                ]
              ),

PageView(
          /// [PageView.scrollDirection] defaults to [Axis.horizontal].
          /// Use [Axis.vertical] to scroll vertically.
          controller: controller_two,
          children: [
            SingleChildScrollView(
                child: Column(
                    children: [
                      SizedBox(
                          height:MediaQuery.of(context).size.height*1.0,
                          width: MediaQuery.of(context).size.width*1.0,

                          child:
    FutureBuilder(
    future: getRichiesti(),
    builder: (BuildContext context, snapshot) {
    if(snapshot.connectionState == ConnectionState.waiting) {
    return const Scaffold(body: CircularProgressIndicator(),);
    } else {
    return
    Scaffold(
                              body: new ListView.builder(
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Card(
                                        child: Column(
                                            children: [
                                              new Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text("Cantiere: Nessuno filtro",
                                                        textAlign: TextAlign.center,
                                                        style: TextStyle(fontSize: 12,
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.blue))
                                                  ],
                                                ),
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 1.0,

                                              ),
                                              new Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(snapshot.data[index]["datetimes"]
                                                        .toString(), style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue)),
                                                  ],
                                                ),
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 1.0,

                                              ),
                                              new Container(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .end,
                                                        children: [
                                                          Text("Cantiere sconosciuto: " + snapshot.data[index]["cantieri"]
                                                              .toString())
                                                        ],
                                                      ),
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.60,

                                                    ),
                                                    Container(
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text("N° Prodotti: " +
                                                              snapshot.data[index]["count"]
                                                                  .toString())
                                                        ],
                                                      ),
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.25,

                                                    ),
                                                  ],
                                                ),
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 1.0,
                                              ),
                                              new Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    (snapshot.data[index]["notes"]
                                                        .toString() == null) ?
                                                    Text("Nessuna nota") : Row(),
                                                    (snapshot.data[index]["notes"]
                                                        .toString() != null) ?
                                                    Text("Nota: " +
                                                        snapshot.data[index]["notes"]
                                                            .toString()) : Row(),
                                                  ],
                                                ),
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 1.0,

                                              ),
                                            ]));
                                  }));}})
                      )
                    ])
            )],
        )
            ]),
            floatingActionButton : Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: Row(
                  children:[
                    Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:[
                            FloatingActionButton(
                              heroTag: "btn1",
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) =>
                                        FormProduct(nfc: "")));
                              },
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.add),
                            )
                          ]
                      ),
                      width: MediaQuery.of(context).size.width*0.50,
                    ),
                    Container(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:[
                            FloatingActionButton(
                              heroTag: "btn2",
                              onPressed: () async {
                                try{
                                  await _deleteTutto();
                                  await timerBuffer();
                                  _toast("fatto..");
                                }catch(e){
                                  _toastError("errore..");
                                }

                              },
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.delete),
                            )
                          ]
                      ),
                      width: MediaQuery.of(context).size.width*0.50,
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                width: MediaQuery.of(context).size.width*1.0,
              )
            ])
        ),

    );

                                    }
  _toastError(String messaggio) {
    Fluttertoast.showToast(
        msg: messaggio,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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
                                  }
