import 'dart:async';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hr_app/audio/AudioWinit.dart';
import 'package:flutter_hr_app/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../camera/PhotoWinit.dart';
import 'package:flutter_hr_app/Prodotti/googleAuthApi.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import './googleAuthApi.dart';
import 'ProductD.dart';
class Product extends StatefulWidget {
  final String nfc;
  Product({this.nfc});
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<Product> {
  @override
  void initState() {
    super.initState();
    getData();
    select_buffer();
    if(widget.nfc == null){
      txtcantiere.text = "Cantiere";
    }else{
      txtcantiere.text = "${widget.nfc}";
    }
  }
  List products = [];
  static String time = "";
  static String date = "";
  String _selectValue ="";
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
  add_buffer(int qty, String prod) async{
    return await dbHelper.insert_buffer(int.parse(qty.toString()), prod.toString());
  }
  delete_buffer(String key) async{
    return await dbHelper.deletebuffer(key);
  }
  delete_product(String key) async{
    return await dbHelper.deleteProdotti(key);
  }
  select_buffer() async{
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
    for(int i=0; i<data.length; i++){
       _journals.add(data[i]);
    }
    return _journals;
  }
  String getSystemDate() {
    var now = new DateTime.now();
    return new DateFormat("dd/MM/yyyy").format(now);
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
              onTap: () async{
                await _delete(this.buffer[position]["id"].toString());
              },
            )
          ),
        );
      },
    );
  }
  ListView getProdotto() {
    return ListView.builder(
      itemCount: _journals.length,
      itemBuilder: (BuildContext context, position) {
        return new Card(
            child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Text(this._journals[position]["cantieri"].toString(), style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold))
                      ],
                    ),
                    width: MediaQuery.of(context).size.width*0.70,
                  ),
                  Container(
                    child: Column(
                      children: [
                        IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async{
                              await _deleteProdotto(this._journals[position]["fotos"].toString());
                            }
                        )
                      ],
                    ),
                    width: MediaQuery.of(context).size.width*0.13,
                  ),
                  Container(
                    child: Column(
                      children: [
                          GestureDetector(
                          child: Icon(Icons.message, color: Colors.grey,),
                          onTap: () {
                          String id = this._journals[position]["fotos"].toString();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProductD(fotos : id)));
                          },
                          )
                      ]
                    ),
                    width: MediaQuery.of(context).size.width*0.13,
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width*1.0,
              padding: EdgeInsets.only(top:2.5, bottom: 2.5),
            )
          ],
        )
        );
      },
    );
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

  void _delete(String id) async {
    int result = await delete_buffer(id);

    if (result != 0) {
      _toast('Fatto..');
      await timerBuffer();

    }
  }
  void _deleteProdotto(String id) async {
    int result = await delete_product(id);
    if (result != 0) {

      _toast('Fatto..');
      await timerBuffer();

    }
  }

  Timer _incrementCounterTimer;
  int counter = 1;
  timerBuffer() async {
    _incrementCounterTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
          counter++;
          if (counter == 4) {
            await select_buffer();
            await getData();
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
    dbHelper.queryAllRows_AUTH_USER().then((users) => setState(() {
      matricola = users[0]["NAME"];
    }));
    return matricola;
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
          title: const Text('PRODOTTO'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                text: "Invia",
                icon: Icon(Icons.cloud_outlined),
              ),
              Tab(
                text: "Dettagli",
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
              child: Column(
                children:[
                  Container(
                    child: Row(
                      children: [
                        Container(
                          child: Column(
                            children: [
                              new Align(alignment: Alignment.centerLeft, child: Text("Matricola:",
                                  style: TextStyle(fontSize: 18.0, color: Colors.black))),
                            ],
                          ),
                          margin: EdgeInsets.only(top:10.0, bottom: 10.0, left:10),
                          width: MediaQuery.of(context).size.width*0.30,
                        ),
                        Container(
                          child: Column(
                            children: [
                              new Align(alignment: Alignment.centerLeft, child: Text("${getMatricola()}",
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black))),
                            ],
                          ),
                          margin: EdgeInsets.only(top:10.0, bottom: 10.0, left:20),
                          width: MediaQuery.of(context).size.width*0.60,
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
                              new Align(alignment: Alignment.centerLeft, child: Text("Data e ora:",
                                  style: TextStyle(fontSize: 18.0, color: Colors.black))),
                            ],
                          ),
                          padding: EdgeInsets.only(top:10.0, bottom: 10.0, left:10.0),
                          width: MediaQuery.of(context).size.width*0.40,
                        ),
                        Container(
                          child: Column(
                            children: [
                              new Align(alignment: Alignment.centerLeft, child: Text("${getSystemTime()}",
                                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black))),
                            ],
                          ),
                          padding: EdgeInsets.only(top:10.0, bottom: 10.0),
                          width: MediaQuery.of(context).size.width*0.40,
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
                          width: MediaQuery.of(context).size.width*1.0,
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
                              new Align(alignment: Alignment.centerLeft, child: Text("Quantita",
                                  style: TextStyle(fontSize: 18.0, color: Colors.black))),
                            ],
                          ),
                          width: MediaQuery.of(context).size.width*0.23,
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black, width: 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      TextFormField(
                                        textAlign: TextAlign. center,
                                        decoration: InputDecoration(
                                            contentPadding: EdgeInsets.zero
                                        ),
                                        onChanged:(text) {
                                          quantities.clear();
                                          quantities.add(text);
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          width: MediaQuery.of(context).size.width*0.30,
                        ),
                      ],
                    ),
                    width: MediaQuery.of(context).size.width*1.0,
                    margin: EdgeInsets.only(left:10),
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
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                new Align(alignment: Alignment.centerLeft, child: Text("${_selectValue}",
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black))),
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
                    width: MediaQuery.of(context).size.width*0.91,
                    margin: EdgeInsets.only(left:10),
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
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.black, width: 1),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                DropdownButtonHideUnderline(
                                                  child: ButtonTheme(
                                                    alignedDropdown: true,
                                                    child: DropdownButton<String>(
                                                      hint: new Text("Seleziona Prodotto"),
                                                      items: _do.map((String value) {
                                                        return DropdownMenuItem<String>(
                                                          value: value,
                                                          child: Text(value, style: TextStyle(color: Colors.black)),
                                                        );
                                                      }).toList(),
                                                      onChanged: (String val){
                                                        products.clear();
                                                        products.add(val);
                                                        _selectValue = val.toString();
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
                    width: MediaQuery.of(context).size.width*1.0,
                    padding: EdgeInsets.only(left:10),
                  ),
                  SizedBox(
                  height:200,
                  child: Scaffold(
                    body: getNoteListView(),
                    )
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () async{
                            for(int j=0;j<quantities.length;j++) {
                              await add_buffer(
                                  int.parse(quantities[j]), products[j].toString());
                            }
                            timerBuffer();
                            quantities.clear();
                            products.clear();
                          },
                          child: const Text('Aggiungi Prodotti..'),
                        ),
                      ],
                    ),
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
                    width: MediaQuery.of(context).size.width*1.0,
                  ),
                  Container(
                    child: Row(
                      children: [
                        Center( child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: IconButton(
                                icon: const Icon(Icons.image, color: Colors.green),
                                tooltip: 'Foto',
                                onPressed:()  async {
                                  // Fetch the available cameras before initializing the app.
                                  try {
                                    List<CameraDescription> cameras;
                                    WidgetsFlutterBinding.ensureInitialized();
                                    cameras = await availableCameras();
                                  } on CameraException catch (e) {
                                    logError(e.code, e.description);
                                  }
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (context) => new CameraApp(),
                                    ),
                                  );
                                },
                              )),
                              Text(""),
                              Center(child: Text("Foto", style: TextStyle(fontSize: 20, color: Colors.black),))
                            ],
                          ),
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width*0.43,
                        )),
                        Center( child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: IconButton(
                                icon: const Icon(Icons.audiotrack, color: Colors.red),
                                tooltip: 'Audio',
                                onPressed: () {
                                  setState(() {
                                    dbHelper.create_medias();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => RecorderExample()));
                                  });
                                },
                              )),
                              Text(""),
                              Center(child: Text("Audio", style: TextStyle(fontSize: 20, color: Colors.black)))
                            ],
                          ),
                          padding: EdgeInsets.all(10.0),
                          margin: EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width*0.43,
                        )),
                      ],
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xFF0D47A1),
                                  Color(0xFF1976D2),
                                  Color(0xFF42A5F5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(16.0),
                            primary: Colors.white,
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          onPressed: () async {
                            try {
                              String cantiere = txtcantiere.text;
                              String note = txtnote.text;
                              String marticola_no = "${getMatricola()}";
                              String data_ora = "${getSystemTime()}";
                              List media = await dbHelper.select_medias();
                              qty = await dbHelper.select_buffer_quantity();
                              pr = await dbHelper.select_buffer_product();
                              await Emailer(cantiere, note, marticola_no, media, qty, pr);

                              if(note != "" && cantiere != "" && qty.length > 0 && pr.length > 0){
                                for(int k=0;k<qty.length;k++) {
                                  await dbHelper.insert_prodotti(
                                      marticola_no.toString(),
                                      data_ora.toString(),
                                      qty[k]["quantity"].toString(),
                                      pr[k]["product"].toString(),
                                      media[0]["media"].toString(),
                                      media[0]["media"].toString(),
                                      note.toString(),
                                      cantiere.toString()
                                  );
                                }
                                final res = await getData();
                                _toast("Fatto..");
                              }
                            }catch(e){
                              _toastError(e);
                              _toastError("Errore..");
                            }
                          },
                          child: const Text('Invia Richiesta..'),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 10,)
                ],
              ),
            )
              ],
            ),
            PageView(
              /// [PageView.scrollDirection] defaults to [Axis.horizontal].
              /// Use [Axis.vertical] to scroll vertically.
              controller: controller_two,
              children: [
                SingleChildScrollView(
                  child: Column(
                    children:[
                      /*
                      Container(
                        child: Row(
                          children: [
                            */
                            SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Scaffold(
                                  body: getProdotto(),
                                )
                            )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
        )
    );
  }
  Future Emailer(String _luogo, String note, String marticola, List media, List qty, List pr) async {
    try{

      final user = await GoogleAuthApi.signIn();
      if(user == null) return;
      final email = user.email;
      final auth  = await user.authentication;
      final token  = auth.accessToken;

      print('Autenticated : $email');

      final smtpServer = gmailSaslXoauth2(email, token);
      String collaboratore = matricola;
      String luogo = _luogo;
      String notes = note;
      String oggetti = "";

      for(int i=0;i<buffer.length;i++){
        oggetti += "<tr><td style='text-align:center;padding:10px 10px;'>"+buffer[i]["quantity"].toString()+"</td><td style='text-align:center;padding:10px 10px;'>"+buffer[i]["product"].toString()+"</td></tr>";
      }
      String nested_table = "";
      nested_table = "<table border='1'>";
      nested_table += "<tr><td style='text-align:center;padding:10px 10px;'>Quantita</td><td style='text-align:center;padding:10px 10px;'>Prodotto</td></tr>";
      nested_table += oggetti;
      nested_table += "</table>";

      final message = Message()
        ..from = Address(email, 'das das')
        ..recipients = ["suhit@jlbbooks.it","mgionta@winitsrl.eu","dTezzon@winitsrl.it"]
        ..subject = 'ClockApp - Richiesta prodotti'
        ..html = "<table style='border-collapse: collapse;'><tr><td style='text-align:center;'><p>"+"Il giorno "+"${DateFormat('d MMMM y').format(DateTime.now())}"+" alle ore "+"${DateFormat('hh:mm').format(DateTime.now())}"+" sono stati richiesti i seguenti prodotti:</p></td></tr><tr><td style='text-align:center;padding:10px 10px;'>Matricola collaboratore: "+collaboratore+"</td></tr><tr><td style='text-align:center;padding:10px 10px;'>"+nested_table+"</td></tr><tr><td style='text-align:center;padding:10px 10px;'>"+"Luogo: "+luogo+"</td></tr><tr><td style='text-align:center;padding:10px 10px;'>"+"Note sulla richiesta: "+notes+"</td></tr></table>";
      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: ' + sendReport.toString());
        GoogleAuthApi.signOut();

      } on MailerException catch (e) {
        print(e);
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
      _toast("Fatto Inviare Email..");
    }catch(e){
      _toastError("Errore..");
    }
  }
}
