  import 'dart:async';
  import 'package:path_provider/path_provider.dart';
  import 'dart:io';
  import 'package:audioplayer/audioplayer.dart';
  import 'package:camera/camera.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_audio_recorder2/flutter_audio_recorder2.dart';
  import 'package:flutter_hr_app/Prodotti/DisplayProdotto.dart';
  import 'package:flutter_hr_app/audio/AudioWinit.dart';
  import 'package:flutter_hr_app/database.dart';
  import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
  import 'package:intl/intl.dart';
  import 'package:mailer/mailer.dart';
  import 'package:mailer/smtp_server.dart';
  import '../camera/PhotoWinit.dart';
  import 'package:flutter_gradient_colors/flutter_gradient_colors.dart';
  import 'package:flutter/services.dart';
  import 'package:file/local.dart';

  class FormProduct extends StatefulWidget {
    final LocalFileSystem localFileSystem;
    final String nfc;
    FormProduct({this.nfc, this.localFileSystem});

    @override
    State<StatefulWidget> createState() => new _State();
  }
  class _State extends State<FormProduct> {
    @override
    initState() {
      super.initState();
      select_buffer();
      getData();
      audio();
      foto();
      getmedias();
      _init();
      if (widget.nfc == null) {
        txtcantiere.text = "Cantiere";
      } else {
        txtcantiere.text = "${widget.nfc}";
      }
      status = "Not autenticated";
    }
    String insert_foto = "";
    String insert_audio = "";
    audio() async{
      insert_audio = await dbHelper.select_audio();
      return insert_audio;
    }
    String display_photo = "";
    foto() async{
      display_photo = await dbHelper.select_foto();
      final byteData = await rootBundle.load(display_photo);
      final file = File(display_photo);
      await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      return file;
    }
    ListView getNoteListView() {
      return ListView.builder(
        itemCount: buffer.length,
        itemBuilder: (BuildContext context, position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(

                title: Text(this.buffer[position]["quantity"].toString()),

                subtitle: Text(this.buffer[position]["product"]),

                trailing: GestureDetector(
                  child: Icon(Icons.delete, color: Colors.grey,),
                  onTap: () async {
                    await _delete(this.buffer[position]["id"].toString());
                  },
                )
            ),
          );
        },
      );
    }
    void _delete(String id) async {
      await delete_buffer(id);
      await timerBuffer();
    }
    void _delete_media(String id) async {
      await dbHelper.deletemedias(id);
      await timerBuffer();
    }

    String status;
    List products = [];
    static String time = "";
    static String date = "";
    String _selectValue = "";
    List qty = [];
    List pr = [];
    DateFormat dbformatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    DateFormat finalformat = DateFormat('HH:mm');
    DateFormat finalformat2 = DateFormat('dd');
    bool flag = false;
    TextEditingController txtcantiere = TextEditingController();
    TextEditingController txtnote = TextEditingController();
    List values = ["1"];
    List quantities = [];
    int value = 0;
    String matricola;
    final dbHelper = DatabaseHelper.instance;
    FlutterAudioRecorder2 _recorder;
    Recording _current;
    RecordingStatus _currentStatus = RecordingStatus.Unset;
    List<String> _do = [
      'Bagni: Anticalcare sanitari tipo SAN..',
      'Bagni: Disincrost. tazza WC',
      'DPI: Divisa da lavoro',
      'DPI: Guanti misura M',
      'Altro...'
    ];
    List buffer = [];
    List data_buffer = [];
    List _journals = [];
    List data = [];
    String getSystemTime() {
      var now = new DateTime.now();
      return new DateFormat("HH:mm").format(now) + "  " +
          DateFormat("dd/MM/yyyy").format(now);
    }

    add_buffer(int qty, String prod) async {
      return await dbHelper.insert_buffer(
          int.parse(qty.toString()), prod.toString());
    }
    delete_buffer(String key) async {
      return await dbHelper.deletebuffer(key);
    }
    select_buffer() async {
      buffer.clear();
      data_buffer = await dbHelper.select_buffer();
      for (int i = 0; i < data_buffer.length; i++) {
        buffer.add(data_buffer[i]);
      }
      return buffer;
    }
    getData() async {
      _journals.clear();
      data = await dbHelper.select_prodotti();
      for (int i = 0; i < data.length; i++) {
        _journals.add(data[i]);
      }
      return _journals;
    }
    String audio_medias = "";
    String foto_medias = "";
    List media = [];
    List data_media = [];
    getmedias() async{
      media.clear();
      await dbHelper.insert_medias();
      data_media = await dbHelper.select_medias();
      for (int i = 0; i < data_media.length; i++) {
        media.add(data_media[i]);
      }
      return media;
    }
    delete_audio_photo() async{
      await dbHelper.delete_audio();
      await dbHelper.delete_photo();
      print(media);
    }
    String getSystemDate() {
      var now = new DateTime.now();
      return new DateFormat("dd/MM/yyyy").format(now);
    }
    _stop() async {
      var result = await _recorder.stop();
      print("Stop recording: ${result.path}");
      print("Stop recording: ${result.duration}");
      File file = widget.localFileSystem.file(result.path);
      print("File length: ${await file.length()}");
      setState(() {
        _current = result;
        _currentStatus = _current.status;
      });
    }
    void onPlayAudio(String audioPath) async {
      try{
        bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;
        if (hasPermission) {
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

    Timer _incrementCounterTimer;
    int counter = 1;
    String prodotto_count;
    timerBuffer() async {
      _incrementCounterTimer =
          Timer.periodic(Duration(seconds: 1), (timer) async {
            counter++;
            if (counter == 4) {
              await select_buffer();
              await getData();
              await getmedias();
              _incrementCounterTimer.cancel();
              counter = 1;
            }
          });
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

    getMatricola() {
      dbHelper.queryAllRows_AUTH_USER().then((users) =>
          setState(() {
            matricola = users[0]["NAME"];
          }));
      return matricola;
    }
    void onBackPressed(BuildContext context) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ProductDisplay()));
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: Text(
              "Prodotto",
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => onBackPressed(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top:100),
                            ),
                            new Align(alignment: Alignment.centerLeft,
                                child: Text("Matricola:",
                                    style: TextStyle(fontSize: 18.0,
                                        color: Colors.black))),
                          ],
                        ),
                        margin: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.30,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Align(alignment: Alignment.centerLeft,
                                child: Text("${getMatricola()}",
                                    style: TextStyle(fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                          ],
                        ),
                        margin: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 20),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.60,
                      )
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Align(alignment: Alignment.centerLeft,
                                child: Text("Data e ora:",
                                    style: TextStyle(fontSize: 18.0,
                                        color: Colors.black))),
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0, left: 10.0),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.40,
                      ),
                      Container(
                        child: Column(
                          children: [
                            new Align(alignment: Alignment.centerLeft,
                                child: Text("${getSystemTime()}",
                                    style: TextStyle(fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black))),
                          ],
                        ),
                        padding: EdgeInsets.only(
                            top: 10.0, bottom: 10.0),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.40,
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                  hintText: 'Cantiere'
                              ),
                              controller: txtcantiere,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(10.0),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 1.0,
                      )
                    ],
                  ),
                ),
                Container(
                  color: Colors.white70,
                  child: Row(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            new Align(alignment: Alignment.centerLeft,
                                child: Text("Quantita",
                                    style: TextStyle(fontSize: 18.0,
                                        color: Colors.black))),
                          ],
                        ),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.23,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      12),
                                  border: Border.all(
                                      color: Colors.black, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch,
                                  children: [
                                    TextFormField(
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets
                                              .zero
                                      ),
                                      onChanged: (text) {
                                        quantities.clear();
                                        quantities.add(text);
                                      },
                                      keyboardType: TextInputType
                                          .number,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.30,
                      ),
                    ],
                  ),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 1.0,
                  margin: EdgeInsets.only(left: 10),
                ),
                Container(
                  color: Colors.white70,
                  child: Row(
                    children: [
                      Card(
                        child: Row(
                            children: [
                              Container(
                                child: Column(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .stretch,
                                            children: [
                                              new Align(
                                                  alignment: Alignment
                                                      .centerLeft,
                                                  child: Text(
                                                      "${_selectValue}",
                                                      style: TextStyle(
                                                          fontSize: 18.0,
                                                          color: Colors
                                                              .black))),
                                            ],
                                          ),
                                          padding: EdgeInsets.all(10.0),
                                        ),
                                      )
                                    ]),
                              )
                            ]
                        ),
                      )
                    ],
                  ),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.91,
                  margin: EdgeInsets.only(left: 10),
                ),
                Container(
                  color: Colors.white70,
                  child: Row(
                    children: [
                      Card(
                        child: Row(
                            children: [
                              Container(
                                child: Column(
                                    children: [
                                      SizedBox(
                                        height: 50,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius
                                                .circular(12),
                                            border: Border.all(
                                                color: Colors.black,
                                                width: 1),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .stretch,
                                            children: [
                                              DropdownButtonHideUnderline(
                                                child: ButtonTheme(
                                                  alignedDropdown: true,
                                                  child: DropdownButton<
                                                      String>(
                                                    hint: new Text(
                                                        "Seleziona Prodotto"),
                                                    items: _do.map((
                                                        String value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: Text(
                                                            value,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black)),
                                                      );
                                                    }).toList(),
                                                    onChanged: (
                                                        String val) {
                                                      products.clear();
                                                      products.add(val);
                                                      _selectValue = val
                                                          .toString();
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ]),
                              )
                            ]
                        ),
                      )
                    ],
                  ),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 1.0,
                  padding: EdgeInsets.only(left: 10),
                ),
                SizedBox(
                    height: 200,
                    child: Scaffold(
                      body: getNoteListView(),
                    )
                ),
                Container(
                  child: Row(
                    children: [
                    ],
                  ),
                  margin: EdgeInsets.all(10.0),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 1.0,
                  height: 40.0,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      for (int j = 0; j < quantities.length; j++) {
                        await add_buffer(
                            int.parse(quantities[j]),
                            products[j].toString());
                      }
                      timerBuffer();
                      quantities.clear();
                      products.clear();
                    },
                    child: Text(
                      "AGGIUNGI PRODOTTI".toUpperCase(),
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: GradientColors.skyLine,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                ),
                Container(
                  child: Column(
                    children: [
                      TextField(
                        controller: txtnote,
                        autocorrect: true,
                        decoration: InputDecoration(hintText: 'Nota'),
                      )
                    ],
                  ),
                  padding: EdgeInsets.all(10.0),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 1.0,
                ),
                Container(
                  child: Row(
                    children: [
                      Center(child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: IconButton(
                              icon: const Icon(
                                  Icons.image, color: Colors.green),
                              tooltip: 'Foto',
                              onPressed: () async {
                                // Fetch the available cameras before initializing the app.
                                try {
                                  List<CameraDescription> cameras;
                                  WidgetsFlutterBinding
                                      .ensureInitialized();
                                  cameras = await availableCameras();
                                } on CameraException catch (e) {
                                  logError(e.code, e.description);
                                }
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (
                                        context) => new CameraApp(),
                                  ),
                                );
                              },
                            )),
                            Text(""),
                            Center(child: Text("Foto", style: TextStyle(
                                fontSize: 20, color: Colors.black),))
                          ],
                        ),
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.all(10.0),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.43,
                      )),
                      Center(child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(child: IconButton(
                              icon: const Icon(
                                  Icons.audiotrack, color: Colors.red),
                              tooltip: 'Audio',
                              onPressed: () {
                                setState(() {
                                  Navigator.push(context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RecorderExample()));
                                });
                              },
                            )),
                            Text(""),
                            Center(child: Text("Audio",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black)))
                          ],
                        ),
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.all(10.0),
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.43,
                      )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: Scaffold(
                    body: ListView.builder(
                      itemCount: media.length,
                      itemBuilder: (BuildContext context, position) {
                        return Card(
                          color: Colors.white,
                          elevation: 2.0,
                          child: Card(
                            child: Row(
                              children: <Widget>[
                                Container(
                                  child: Column(
                                    children: [
                                      Image(image: FileImage(File(display_photo), scale:1), width: 200, height: 200),
                                    ],
                                  ),
                                  width: MediaQuery.of(context).size.width*0.45
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      new TextButton(
                                        onPressed: () async{
                                          //playAudio();
                                          //onPlayAudio(this.media[position]["audio"].toString());
                                          onPlayAudio(insert_audio);
                                        },
                                        child:
                                        new Text("Play", style: TextStyle(color: Colors.white)),
                                        style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(
                                              Colors.blueAccent.withOpacity(0.5),
                                            )),
                                      )
                                    ],
                                  ),
                                  width: MediaQuery.of(context).size.width*0.30
                                ),
                                /*
                                Container(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        child: Icon(Icons.delete, color: Colors.grey,),
                                        onTap: () async {
                                            await delete_audio_photo();
                                            await _delete_media(this.media[position]["id"].toString());
                                        },
                                      )
                                    ],
                                  ),
                                )
                                */
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ),
                Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 1.0,
                  height: 40.0,
                  margin: EdgeInsets.all(10.0),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () async {
                      try {
                        String cantiere = txtcantiere.text;
                        String note = txtnote.text;
                        String marticola_no = "${getMatricola()}";
                        String data_ora = "${getSystemTime()}";
                        await dbHelper.insert_audio(insert_audio.toString());
                        await dbHelper.insert_foto(insert_foto.toString());
                        await dbHelper.insert_medias();
                        qty = await dbHelper.select_buffer_quantity();
                        pr = await dbHelper.select_buffer_product();

                        if(note != "" && cantiere != "" && qty.length > 0 && pr.length > 0){
                          try{
                            await Emailer(cantiere, note, marticola_no, qty, pr);
                          }catch(e){
                            print(e);
                          }
                          for(int k=0;k<qty.length;k++) {
                            await dbHelper.insert_prodotti(
                                marticola_no.toString(),
                                data_ora.toString(),
                                qty[k]["quantity"].toString(),
                                pr[k]["product"].toString(),
                                insert_audio.toString(),
                                insert_foto.toString(),
                                note.toString(),
                                cantiere.toString()
                            );
                          }
                          _toast("Fatto..");
                          await dbHelper.delete_photo();
                          await dbHelper.delete_audio();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDisplay(fotos: "")));
                        }
                      } catch (e) {
                        _toastError(e);
                        _toastError("Errore..");
                      }
                    },
                    child: Text(
                      "INVIA RICHIESTA".toUpperCase(),
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: GradientColors.skyLine,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )),
                ),
                Divider(height: 10,),
              ],
            ),
          )
      );
    }
    _init() async {
      try {
        bool hasPermission = await FlutterAudioRecorder2.hasPermissions ?? false;

        if (hasPermission) {
          // .wav <---> AudioFormat.WAV
          // .mp4 .m4a .aac <---> AudioFormat.AAC
          // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
          _recorder =
              FlutterAudioRecorder2(insert_audio, audioFormat: AudioFormat.WAV);
          await _recorder.initialized;
          // after initialization
          var current = await _recorder.current(channel: 0);
          // should be "Initialized", if all working fine
          setState(() {
            _current = current;
            _currentStatus = current.status;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("You must accept permissions")));
        }
      } catch (e) {
        print(e);
      }
    }
    String emails = "";
    playAudio() async{
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(_current.path, isLocal: true);
    }
    Future Emailer(String _luogo, String note, String marticola, List qty, List pr) async {
      emails = await dbHelper.getEmail();
      print(emails);
      String smtpServerName = 'smtps.aruba.it';
      int smtpPort = 465;
      String smtpUserName = "segnalazioniclockapp@winitsrl.it";
      String smtpPassword = "Es0df@c2002!";

      final smtpServer = SmtpServer(
        smtpServerName,
        port: smtpPort,
        ssl: true,
        ignoreBadCertificate: false,
        allowInsecure: false,
        username: smtpUserName,
        password: smtpPassword,
      );

      String collaboratore = matricola;
      String luogo = _luogo;
      String notes = note;
      String mailBody = "<div style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: auto; width: 80%; text-align: center; border: 1px solid black;\">";
      mailBody += "<p>Il giorno " + DateFormat('d MMMM y').format(DateTime.now()) + " alle ore " + DateFormat('hh:mm').format(DateTime.now()) + " sono stati richiesti i seguenti prodotti:</p>";
      mailBody += "<div style='width: 50%; float:left; margin: 20px 0;'>Matricola collaboratore: <strong>" + collaboratore + "</strong></div>";
      mailBody += "<div style='width: 50%; float:right; margin: 20px 0;'>Luogo: <strong>" + luogo + "</strong></div>";
      mailBody += "<table style='margin: auto; border: 1px solid black;border-collapse: collapse;'>";
      mailBody += "<tr style='border-bottom: 1px solid black'><th>Prodotto </th><th style='text-align: center;' style='padding: 0 10px'>Quantità </th></tr>";

      for (int i = 0; i < buffer.length; i++) {
        mailBody += "<tr><td style='padding: 0 10px; border-right: 1px solid black'>" + buffer[i]["product"].toString() + "</td><td style='text-align: center;'>" + buffer[i]["quantity"].toString() + "</td></tr>";
      }
      mailBody += "</table>";

      mailBody += "<p>";
      mailBody += "Note sulla richiesta: ";

      if (notes == "") {
        mailBody += "nessuna";
      } else {
        mailBody += notes;
      }

      mailBody += "</p>";
      mailBody += "</div>";

      final message = Message()
        ..from = Address("segnalazioniclockapp@winitsrl.it", "Prodotto")
        ..recipients.add(emails)
        ..subject = "I: ClockApp - Richiesta prodotti"
        ..html = mailBody;
      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        print(emails);
      } on MailerException catch (e) {
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    }
  }