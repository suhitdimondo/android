import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database.dart';

class ProductD extends StatefulWidget {
  final String id;
  ProductD({this.id});
  @override
  State<StatefulWidget> createState() => new _State();
}
class _State extends State<ProductD> {
  @override
  void initState() {
    super.initState();
  }
  final dbHelper = DatabaseHelper.instance;
  List _journals = [];
  List data = [];

  getData() async {
    _journals.clear();
    data = await dbHelper.Id_Prodotto("${widget.id}");
    print(data);
    for (int i = 0; i < data.length; i++) {
      _journals.add(data[i]);
    }
    return _journals;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: CircularProgressIndicator(),);
          } else {
            return Scaffold(
              appBar: new AppBar(title: new Text("Dettagli prodotto"),),
              body: new ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return new Card(
                              child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text("Prodotto:",
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(snapshot.data[index]["prodotti"].toString(),
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          )
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width*1.0,
                                      padding: EdgeInsets.only(top:2.5, bottom: 2.5),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text("Quantita:",
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(snapshot.data[index]["quantita"].toString(),
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          )
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width*1.0,
                                      padding: EdgeInsets.only(top:2.5, bottom: 2.5),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text("Nota:",
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(snapshot.data[index]["notes"].toString(),
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          )
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width*1.0,
                                      padding: EdgeInsets.only(top:2.5, bottom: 2.5),
                                    ),
                                    Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                Text("Cantiere:",
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          ),
                                          Container(
                                            child: Column(
                                              children: [
                                                Text(snapshot.data[index]["cantieri"].toString(),
                                                    style: TextStyle(fontSize: 18.0, color: Colors.black))
                                              ],
                                            ),
                                            width: MediaQuery.of(context).size.width*0.47,
                                          )
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width*1.0,
                                      padding: EdgeInsets.only(top:2.5, bottom: 2.5),
                                    )
                              ],
                            )
                          );
                        }
                    )
            );
          }
        }
    );
  }
  Timer _incrementCounterTimer;
  int counter = 1;
  timerBuffer() async {
    _incrementCounterTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
          counter++;
          if (counter == 2) {
            await getData();
            _incrementCounterTimer.cancel();
            counter = 1;
          }
        });
  }
}