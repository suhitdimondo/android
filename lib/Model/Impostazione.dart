import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import '../database.dart';
import '../preferenze.dart';
import '../ws.dart';
import 'Refresh.dart';
import 'dart:convert';
class Impostazione{
  int cantieridb;
  int squadradb;
  int gpsdb;
  int scheduledGPSdb;
  int activities;
  int segnalazioni;
  int pausaPranzo;
  String connection;
  String idCliente;
  http.Response response;
  bool finish = false;
  Impostazione({ this.cantieridb,  this.squadradb,  this.gpsdb,  this.scheduledGPSdb,  this.activities,  this.pausaPranzo,  this.idCliente,  this.segnalazioni,  this.connection});
  recuperoimpostazioni() async {
    try{
    var dbHelper = DatabaseHelper.instance;
    int cid = 0;
    await dbHelper.queryAllRows_AUTH_USER().then((users) =>
    {
      cid = users[0]["CLIENTE_ID"]
    });
    RESTApi wsClient = new RESTApi();
    wsClient.GetEventi(cid).then((value) =>
    {
      if (value != null)
        {
          dbHelper.deleteEvent(),
          dbHelper.insertEventi(value),
        } else
        {
        }
    });
    wsClient.GetDataDamage(cid).then((value) =>
    {
      if (value != null)
        {dbHelper.deleteDataDamage(), dbHelper.insertDataDamage(value),}
    });
    Refresh objectRefresh = Refresh(cantieridb: 0,
        squadradb: 0,
        gpsdb: 0,
        scheduledGPSdb: 0,
        segnalazioni: 0,
        pausaPranzo: 0,
        idCliente: "",
        connection: "",
        activities: 0);
    cantieridb = int.parse(await objectRefresh.getCantiereT());
    gpsdb = int.parse(await objectRefresh.getGPST());
    scheduledGPSdb = int.parse(await objectRefresh.getScheduledGPST());
    squadradb = int.parse(await objectRefresh.getSquadraT());
    wsClient.GetCustomization(cid).then((value) =>
    {
      if (value != null)
        {
          value.forEach((element) {
            Preferenze.scheduledGPS = element.scheduledGPS;
            Preferenze.intervallo = element.intervallo;
            Preferenze.gps = element.gps;
            Preferenze.inOutPref = element.inOutPref;
            Preferenze.activities = element.activities;
            Preferenze.segnalazioni = element.segnalazioni;
            Preferenze.attObl = element.attObl;
            Preferenze.multiAtt = element.multiAtt;
            Preferenze.simpleGps = element.simpleGps;
            Preferenze.raggio = element.raggio;
            Preferenze.nomeSocieta = element.nomeSocieta;
            Preferenze.logo = element.logo;
            Preferenze.registrazioni = element.registrazioni;
            Preferenze.invioAutomatico = element.invioAutomatico;
            Preferenze.doppiaTimbratura = element.doppiaTimbratura;
            Preferenze.intervalloDoppia = element.intervalloDoppia;
            Preferenze.pausaPranzo = element.pausaPranzo;
            Preferenze.pulsanteTimbra = element.pulsanteTimbra;
            Preferenze.Squadra = element.squadra;
            Preferenze.ClienteId = element.idCliente;
            Preferenze.Cantieri = element.cantieri;
          }),
          dbHelper.insertCustomization(value),
        }
    });
    Preferenze.eventi = 1;
    _gpsService();
    Database db = await DatabaseHelper.instance.database;
    try {
      await db.rawQuery("DELETE FROM prodotto");
      await db.rawQuery("DELETE FROM buffer");
      await db.rawQuery("DELETE FROM medias");
      await db.rawQuery("DELETE FROM ATTIVITA");
      await db.rawQuery("DELETE FROM collaboratori");
      await db.rawQuery("DELETE FROM personalizzazioni");
      await db.rawQuery("DELETE FROM cantieri");
      await db.rawQuery("DELETE FROM eventi");
      await db.rawQuery("DELETE FROM DATADAMAGE");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'prodotto'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'buffer'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'medias'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'attivita'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'collaboratori'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'personalizzazioni'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'cantieri'");
      await db.rawQuery("DELETE FROM sqlite_sequence WHERE name = 'eventi'");
      await db.rawQuery(
          "DELETE FROM sqlite_sequence WHERE name = 'DATADAMAGE'");

    _toast("9");
    try {
      String create_prodotti = "create table if not exists prodotto (id integer, matricola varchar(1000) NOT NULL, datetimes varchar(1000) NOT NULL, quantita int(11) NOT NULL, prodotti varchar(1000) NOT NULL, fotos longblob NOT NULL, audios longblob NOT NULL, notes varchar(1000) NOT NULL, cantieri varchar(1000) NOT NULL)";
      String create_buffer = "create table if not exists buffer(id integer, quantity integer not null, product varchar(200) not null)";
      String create_medias = "create table if not exists medias(id integer, media varchar(200) not null)";
      String create_collaboratori = "CREATE TABLE IF NOT EXISTS collaboratori (Id INTEGER PRIMARY KEY, descrizione varchar(100) NOT NULL, matricola int(5) NOT NULL, IdCliente int(2) NOT NULL);";
      //String create_authuser = "CREATE TABLE IF NOT EXISTS auth_user (ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, NAME TEXT, PASSWORD TEXT, USER_ID  INT, MOB_ATT_ENABLED INT, GPS_MANDATORY INT, DELETED INT, DISABLED  INT, SKIPLOGIN INT, BASEURL  TEXT, CLIENTE_ID INT, TSLOGIN  TEXT, TIPO_ISTANZA TEXT);";
      String create_customization = "CREATE TABLE IF NOT EXISTS personalizzazioni (id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER);";
      String create_cantieri = "CREATE TABLE IF NOT EXISTS cantieri (DescrizioneCantiere varchar(20),IdCliente integer,TipologiaStanza varchar(20),UnitaFissaAssociata varchar(20));";
      String create_eventi = "CREATE TABLE IF NOT EXISTS eventi (codice varchar(20),evento varchar(255),tipo_intestatario varchar(255),cantiere varchar(30),cliente_id int(25));";
      String create_datadamage = "CREATE TABLE IF NOT EXISTS DATADAMAGE (Id INTEGER, tipo TEXT, email TEXT, sottotipo TEXT);";
      String create_attivita = "CREATE TABLE IF NOT EXISTS ATTIVITA (CodiceAtt varchar(10) NOT NULL, DescrizioneAtt varchar(50) NOT NULL, IdCliente int(11) NOT NULL, flag int(11));";
      await db.execute(create_prodotti);
      await db.execute(create_buffer);
      await db.execute(create_medias);
      await db.execute(create_collaboratori);
      //await db.execute(create_authuser);
      await db.execute(create_customization);
      await db.execute(create_cantieri);
      await db.execute(create_eventi);
      await db.execute(create_datadamage);
      await db.execute(create_attivita);
    } catch (e) {
      _toastError("Provarci Ancora");
    }
    int clienteid = cid;
    int count_collaboratori = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM collaboratori'));
    //int count_authuser = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM auth_user'));
    int count_customization = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM personalizzazioni'));
    int count_cantieri = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM cantieri'));
    int count_eventi = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM eventi'));
    int count_datadamage = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM datadamage'));
    int count_attivita = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM attivita'));

    if (count_attivita == 0) {
      try {
        String url = "http://backend.winitsrl.eu:81/app/ws/Attivita?IdCliente=" +
            clienteid.toString();
        response = await http.get(
            Uri.parse(url), headers: {"Content-Type": "application/json"});
        List jsonResponse = json.decode(response.body);
        int flag = 0;
        for (int i = 0; i < jsonResponse.length; i++) {
          await db.rawQuery(
              "insert into attivita(CodiceAtt, DescrizioneAtt, IdCliente, flag) values('" +
                  jsonResponse[i]['CodiceAtt'].toString() + "', '" +
                  jsonResponse[i]['DescrizioneAtt'].toString() + "','" +
                  clienteid.toString() + "','" +
                  flag.toString() +
                  "')");
        }
        _toast("8");
      } catch (e) {

      }
    } else {
      List<Map> select_attivita = await db.query("attivita");
      return select_attivita.forEach((row) => row);
    }
    if (count_collaboratori == 0) {
      try {
        String url = "http://backend.winitsrl.eu:81/app/ws/Collaboratori?IdCliente=" +
            clienteid.toString();
        response = await http.get(
            Uri.parse(url), headers: {"Content-Type": "application/json"});
        List jsonResponse = json.decode(response.body);
        for (int i = 0; i < jsonResponse.length; i++) {
          await db.rawQuery(
              "insert into collaboratori(descrizione, matricola, IdCliente) values('" +
                  jsonResponse[i]['descrizione'].toString() + "', '" +
                  jsonResponse[i]['matricola'].toString() + "','" +
                  clienteid.toString() +
                  "')");
        }
        _toast("7");
      } catch (e) {

      }
    } else {
      List<Map> select_collaboratori = await db.query("collaboratori");
      return select_collaboratori.forEach((row) => row);
    }
    /*
      if(count_authuser == 0){
        Database db = await DatabaseHelper.instance.database;
        List<Map> result = await db.query("auth_user");
        for(int i=0;i<result.length;i++) {
          await db.rawQuery(
              "insert into auth_user(NAME, PASSWORD, USER_ID, MOB_ATT_ENABLED, GPS_MANDATORY, DELETED, DISABLED, SKIPLOGIN, BASEURL, CLIENTE_ID, TSLOGIN, TIPO_ISTANZA) values("
                  "'admin',"
                  " 'root',"
                  " '123',"
                  " '1',"
                  " '1',"
                  " '1',"
                  " '0',"
                  " '1',"
                  " '',"
                  " '16',"
                  " '1',"
                  " '1')");
        }
        print("inserted rows in auth_user");
      }else{
        List<Map> select_authuser = await db.query("auth_user");
        return select_authuser.forEach((row) => row);
      }
      */
    if (count_customization == 0) {
      try {
        String url = "http://backend.winitsrl.eu:81/app/ws/Customization?IdCliente=" +
            clienteid.toString();
        http.Response response = await http.get(
            Uri.parse(url), headers: {"Content-Type": "application/json"});
        List jsonResponse = json.decode(response.body);
        for (int i = 0; i < jsonResponse.length; i++) {
          await db.rawQuery(
              "insert into personalizzazioni(scheduledGPS,gps,idCliente,squadra,cantieri) values('" +
                  jsonResponse[i]['ScheduledGPS'].toString() + "','" +
                  jsonResponse[i]['GPS'].toString().toString() + "','" +
                  clienteid.toString() + "','" +
                  jsonResponse[i]['Squadra'].toString() + "','" +
                  jsonResponse[i]['Cantieri'].toString() + "')");
        }
        _toast("6");
      } catch (e) {

      }
    } else {
      List<Map> select_personalizzazioni = await db.query("personalizzazioni");
      return select_personalizzazioni.forEach((row) => row);
    }
    if (count_cantieri == 0) {
      try {
        String url_cantieri = "http://backend.winitsrl.eu:81/app/ws/Cantieri?IdCliente=" +
            clienteid.toString();
        http.Response response = await http.get(Uri.parse(url_cantieri),
            headers: {"Content-Type": "application/json"});
        List jsonResponse = json.decode(response.body);
        for (int i = 0; i < jsonResponse.length; i++) {
          await db.rawQuery(
              "insert into cantieri(DescrizioneCantiere,IdCliente,TipologiaStanza,UnitaFissaAssociata) values('" +
                  jsonResponse[i]['DescrizioneCantiere'].toString() + "','" +
                  clienteid.toString() + "','Suite','" +
                  jsonResponse[i]['UnitaFIssaAssociata'].toString() + "')");
          print(jsonResponse[i]['DescrizioneCantiere'].toString() + "','" +
              clienteid.toString() + "','Suite','" +
              jsonResponse[i]['UnitaFIssaAssociata'].toString());
        }
        _toast("5");
      } catch (e) {

      }
    } else {
      List<Map> select_cantieri = await db.query("cantieri");
      return select_cantieri.forEach((row) => print(row));
    }
    if (count_eventi == 0) {
      try {
        String url_cantieri = "http://backend.winitsrl.eu:81/app/ws/Eventi?IdCliente=" +
            clienteid.toString();
        http.Response response = await http.get(Uri.parse(url_cantieri),
            headers: {"Content-Type": "application/json"});
        List jsonResponse = json.decode(response.body);
        for (int i = 0; i < jsonResponse.length; i++) {
          await db.rawQuery(
              "insert into eventi(Codice, Evento, Tipo_Intestatario, Cantiere) values('" +
                  jsonResponse[i]['Codice'].toString() + "','" +
                  jsonResponse[i]['Evento'].toString() + "','" +
                  jsonResponse[i]['Tipo_Intestatario'].toString() + "','" +
                  jsonResponse[i]['Cantiere'].toString() + "')");
        }
        _toast("4");
      } catch (e) {

      }
    } else {
      List<Map> select_eventi = await db.query("eventi");
      return select_eventi.forEach((row) => row);
    }
    if (count_datadamage == 0) {
      try {
        await db.rawQuery(
            "insert into datadamage(tipo, email, sottotipo) values('data','admin@winit.it','correzione')");
        await db.rawQuery(
            "insert into datadamage(tipo, email, sottotipo) values('disk','admin@winit.it','memoria')");
        _toast("3");
      } catch (e) {

      }
    } else {
      List<Map> select_datadamage = await db.query("datadamage");
      return select_datadamage;
    }
    String idCliente = await dbHelper.get_cust_clienteid();
    print("id cliente=" + idCliente.toString());
    String codice = await dbHelper.select_eventi_codice();
    print("codice eventi=" + idCliente.toString());
    await dbHelper.select_cantieri();
    await dbHelper.insert_eventi(
        codice.toString(), "PART&PERM", "Prova", "null", idCliente.toString());
    _toast("2");
    cantieridb = await objectRefresh.getCantiereF();
    gpsdb = await objectRefresh.getGPSF();
    scheduledGPSdb = await objectRefresh.getScheduledGPSF();
    squadradb = await objectRefresh.getSquadraF();
    _toast("1");
    _toast("0");
    _toast("Finito Caricamento Database");
    return true;
    } catch (e) {
     return false;
    }
  }catch(e){
    _toastError("Provarci Ancora");
  }
  }
  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      gpsdb = 0; //Gps Spento
    } else {
      gpsdb = 1; //Gps Acceso
    }
  }
_toastError(String messaggio) {
  Fluttertoast.showToast(
      msg: messaggio,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
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