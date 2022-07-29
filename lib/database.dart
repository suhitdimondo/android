import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_hr_app/Model/Squadra.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/Model/Eventi.dart';
import 'package:flutter_hr_app/TimbPages/timbratureListWinit.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'Model/Buffer.dart';
import 'Model/Customization.dart';
import 'Model/DataDamage.dart';
import 'Model/Product.dart';
import 'common.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
class DatabaseHelper {
  static final _databaseName = "hrDatabase.db";
  static final _databaseVersion = 6;
  GetVersion() {
    int vers;
    return vers = _databaseVersion;
  }
   final String T_UUID = "UUID";
   final String T_UUID_UUID = "UUID";
   final String T_AUTH_USER = "AUTH_USER";
   final String T_AUTH_ID = "ID";
   final String T_AUTH_USER_NAME = "NAME";
   final String T_AUTH_USER_PASSWORD = "PASSWORD";
   final String T_AUTH_USER_USER_ID = "USER_ID";
   final String T_AUTH_USER_MOBILE_ATTENDANCE_ENABLED = "MOB_ATT_ENABLED";
   final String T_AUTH_USER_GPS_MANDATORY = "GPS_MANDATORY";
   final String T_AUTH_USER_DELETED = "DELETED";
   final String T_AUTH_USER_DISABLED = "DISABLED";
   final String T_AUTH_USER_SKIPLOGIN = "SKIPLOGIN";
   final String T_AUTH_USER_BASEURL = "BASEURL";
   final String T_AUTH_USER_TIPO_ISTANZA = "TIPO_ISTANZA";
   final String T_AUTH_CLIENTE_ID = "CLIENTE_ID";
   final String T_AUTH_TSLOGIN = "TSLOGIN";
   final String T_TIMB = "TIMBRATURE";
   final String T_TIMB_ID = "ID";
   final String T_TIMB_USER_ID = "USER_ID";
   final String T_TIMB_DATETIME = "DATETIME";
   final String T_TIMB_VERSO = "VERSO";
   final String T_TIMB_LATITUDE = "LATITUDE";
   final String T_TIMB_LONGITUDE = "LONGITUDE";
   final String T_TIMB_IMPORTED = "IMPORTED";
   final String T_TIMB_VALORE_ACQUISIZIONE = "VALORE_ACQUISIZIONE";
   final String T_TIMB_TIPO_ACQUISIZIONE =
      "TIPO_ACQUISIZIONE"; //"TIMB" , "ALTRO"
   final String T_TIMB_TECNOLOGIA_ACQUISIZIONE =
      "TECNOLOGIA_ACQUISIZIONE";
   final String T_TIMB_WORKED_TIME = "WORKED_TIME";
   final String T_TIMB_STATE = "TIMBRATURE_STATE";
   final String T_TIMB_STATE_ID = "ID";
   final String T_TIMB_STATE_USER_ID = "USER_ID";
   final String T_TIMB_STATE_DATETIME = "DATETIME";
   final String T_TIMB_STATE_VERSO = "VERSO";
   final String T_TIMB_STATE_SEDE = "SEDE";
   final String T_TIMB_STATE_APPROVATA = "APPROVATA";
   final String T_TIMB_STATE_TIPO_ACQUISIZIONE = "TIPO_ACQUISIZIONE";
   final String T_TIMB_STATE_VALORE_ACQUISIZIONE = "VALORE_ACQUISIZIONE";
   final String T_TIMB_STATE_TECNOLOGIA_ACQUISIZIONE =
      "TECNOLOGIA_ACQUISIZIONE";
   final String T_TIMB_STATE_WORKED_TIME = "WORKED_TIME";
   final String T_MOD = "MODULI";
   final String T_MOD_ID = "ID";
   final String T_MOD_CODICE = "CODICE";
   final String T_MOD_NOME = "NOME";
   final String T_MOD_NOME_IN_APP = "NOME_IN_APP";
   final String T_MOD_STATO = "STATO";
   final String T_MOD_REFRESH = "REFRESH";
   final String T_PAR = "PARAMETRI";
   final String T_PAR_ID = "ID";
   final String T_PAR_NOME = "NOME";
   final String T_PAR_VALORE = "VALORE";
   final String T_PAR_TIPO = "TIPO";
   final String T_CLI = "CLIENTE";
   final String T_CLI_ID = "ID";
   final String T_CLI_ID_CLIENTE = "ID_CLIENTE";
   final String T_CLI_CODICE_ISTANZA = "CODICE_ISTANZA";
   final String T_TACQ = "TIPO_ACQUISIZIONE";
   final String T_TACQ_ID = "ID";
   final String T_TACQ_NOME = "NOME";
   final String T_TACQ_ABILITATA = "ABILITATA";
   final String T_TACQ_COLORE = "COLORE";
   final String T_EVENTI = "EVENTI";
   final String T_CONTIERI = "CANTIERI";
   final String T_COLLABORATORI = "COLLABORATORI";
   final String T_EVENTI_ID = "Id";
   final String T_EVENTI_CODICE = "Codice";
   final String T_EVENTI_EVENTO = "Evento";
   final String T_EVENTO_TIPO_INTESTATARIO = "Tipo_Intestatario";
   final String T_EVENTI_CANTIERE = "Cantiere";
   final String T_CUSTOMIZATION = "PERSONALIZZAZIONI";
   final String T_CUSTOMIZATION_ID = "id";
   final String T_CUSTOMIZATION_INOUTPREF = "InOutPref";
   final String T_CUSTOMIZATION_ATTIVITA = "Activities";
   final String T_CUSTOMIZATION_GIORNALIERE = "Giornaliere";
   final String T_CUSTOMIZATION_GPS = "Gps";
   final String T_CUSTOMIZATION_SEGNALAZIONI = "Segnalazioni";
   final String T_CUSTOMIZATION_MULTIATT = "Attivitamultipla";
   final String T_CUSTOMIZATION_OBLATT = "Attivitaobbligatoria";
   final String T_CUSTOMIZATION_SIMPLEGPS = "Simple Gps";
   final String T_CUSTOMIZATION_RAGGIO = "Raggio Simple Gps";
   final String T_CUSTOMIZATION_NOMESOC = "Nome societa";
   final String T_CUSTOMIZATION_LOGO = "Logo";
   final String T_CUSTOMIZATION_REG = "Registrazioni";
   final String T_CUSTOMIZATION_AUTOINV = "Invio automatico";
   final String T_CUSTOMIZATION_DOPPIATIMB = "Doppia timbratura";
   final String T_CUSTOMIZATION_DOPPIATIMBINTER =
      "Intervallo doppia timbratura";
   final String T_CUSTOMIZATION_CLIENTID = "idCliente";
   final String T_CUSTOMIZATION_SQUADRA = "Squadra";
   final String T_CUSTOMIZATION_Scheduled_GPS = "ScheduledGPS";
   final String T_DATADAMAGE = "DATADAMAGE";
   final String T_DATADAMAGE_ID = "Id";
   final String T_DATADAMAGE_TIPO = "tipo";
   final String T_DATADAMAGE_MAIL = "email";
   final String T_DATADAMAGE_DESCRIZIONE = "sottotipo";
   final String T_CUSTOMIZATION_DB = "customization";
   final String T_TT = "TECNOLOGIE_TIPOLOGIE";
   final String T_TT_ID = "ID";
   final String T_TT_IDTIPOLOGIA = "IDTIPOLOGIA";
   final String T_TT_IDTECNOLOGIA = "IDTECNOLOGIA";
   final String T_TT_NOMETECNOLOGIA = "NOMETECNOLOGIA";
   final String T_TT_NOMETIPOLOGIA = "NOMETIPOLOGIA";
   final String T_CONTIERI_ID = "IdCantiere";
   final String T_CONTIERI_DESC = "DescrizioneCantiere";
   final String T_CONTIERI_IDCLIENTE = "IdCliente";
   final String T_CONTIERI_STANZA = "TipologiaStanza";
   final String T_CONTIERI_UNITA = "UnitaFissaAssociata";
  DatabaseHelper._privateConstructor();
  static DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }
  Future _onCreate(Database db, int version) async {
    String CREATE_PRODOTTI = "CREATE TABLE if not exists prodotto (id integer, matricola varchar(1000) NOT NULL, datetimes varchar(1000) NOT NULL, quantita int(11) NOT NULL, prodotti varchar(1000) NOT NULL, fotos longblob NOT NULL, audios longblob NOT NULL, notes varchar(1000) NOT NULL, cantieri varchar(1000) NOT NULL)";
    await db.execute(CREATE_PRODOTTI);

    String buffer = "create table if not exists buffer(id integer, quantity integer not null, product varchar(200) not null)";
    await db.execute(buffer);

    String medias = "create table medias(id integer, audio varchar(200) not null, foto varchar(200) not null)";
    await db.execute(medias);

    String audio = "create table if not exists ascolta(id integer, audio varchar(200) not null)";
    await db.execute(audio);

    String photo = "create table if not exists photo(id integer, foto varchar(200) not null)";
    await db.execute(photo);


    String CREATE_UUID = "CREATE TABLE IF NOT EXISTS " +
        T_UUID +
        " (" +
        T_UUID_UUID +
        " TEXT" +
        ");";
    await db.execute(CREATE_UUID);
    var uuid = Uuid();
    String uid = uuid.v1();
    uid = uid + "#" + uuid.v4();
    String SAVE_UUID = "INSERT INTO " +
        T_UUID +
        " (" +
        T_UUID_UUID +
        ") VALUES ('" +
        uid +
        "')";
    await db.execute(SAVE_UUID);
    String CREATE_AUTH_USER = "CREATE TABLE IF NOT EXISTS " +
        T_AUTH_USER +
        " (" +
        T_AUTH_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_AUTH_USER_NAME +
        " TEXT, " +
        T_AUTH_USER_PASSWORD +
        " TEXT, " +
        T_AUTH_USER_USER_ID +
        " INT,  " +
        T_AUTH_USER_MOBILE_ATTENDANCE_ENABLED +
        " INT, " +
        T_AUTH_USER_GPS_MANDATORY +
        " INT, " +
        T_AUTH_USER_DELETED +
        " INT, " +
        T_AUTH_USER_DISABLED +
        " INT, " +
        T_AUTH_USER_SKIPLOGIN +
        " INT, " +
        T_AUTH_USER_BASEURL +
        " TEXT, " +
        T_AUTH_CLIENTE_ID +
        " INT, " +
        T_AUTH_TSLOGIN +
        " TEXT, " +
        T_AUTH_USER_TIPO_ISTANZA +
        " TEXT"
            ");";
    await db.execute(CREATE_AUTH_USER);
    String CREATE_T_TIMB = "CREATE TABLE IF NOT EXISTS " +
        T_TIMB +
        " (" +
        T_TIMB_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_TIMB_USER_ID +
        " INT, " +
        T_TIMB_DATETIME +
        " TEXT, " +
        T_TIMB_VERSO +
        " TEXT,  " +
        T_TIMB_LATITUDE +
        " TEXT, " +
        T_TIMB_LONGITUDE +
        " TEXT, " +
        T_TIMB_IMPORTED +
        " INT ," +
        T_TIMB_VALORE_ACQUISIZIONE +
        " TEXT ," +
        T_TIMB_TIPO_ACQUISIZIONE +
        " INT ," +
        T_TIMB_TECNOLOGIA_ACQUISIZIONE +
        " TEXT , " +
        T_TIMB_WORKED_TIME +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_TIMB);
    String CREATE_T_TIMB_STATE = "CREATE TABLE IF NOT EXISTS " +
        T_TIMB_STATE +
        " (" +
        T_TIMB_STATE_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_TIMB_STATE_USER_ID +
        " INT, " +
        T_TIMB_STATE_DATETIME +
        " TEXT, " +
        T_TIMB_STATE_VERSO +
        " TEXT,  " +
        T_TIMB_STATE_SEDE +
        " TEXT, " +
        T_TIMB_STATE_APPROVATA +
        " TEXT ," +
        T_TIMB_STATE_VALORE_ACQUISIZIONE +
        " TEXT ," +
        T_TIMB_STATE_TIPO_ACQUISIZIONE +
        " INT ," +
        T_TIMB_STATE_TECNOLOGIA_ACQUISIZIONE +
        " TEXT, " +
        T_TIMB_STATE_WORKED_TIME +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_TIMB_STATE);
    String CREATE_T_MOD = "CREATE TABLE IF NOT EXISTS " +
        T_MOD +
        " (" +
        T_MOD_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_MOD_CODICE +
        " TEXT, " +
        T_MOD_NOME +
        " TEXT, " +
        T_MOD_NOME_IN_APP +
        " TEXT,  " +
        T_MOD_STATO +
        " INT, " +
        T_MOD_REFRESH +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_MOD);
    String CREATE_T_PAR = "CREATE TABLE IF NOT EXISTS " +
        T_PAR +
        " (" +
        T_PAR_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_PAR_NOME +
        " TEXT, " +
        T_PAR_VALORE +
        " TEXT,  " +
        T_PAR_TIPO +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_PAR);
    String CREATE_T_CLI = "CREATE TABLE IF NOT EXISTS " +
        T_CLI +
        " (" +
        T_CLI_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_CLI_ID_CLIENTE +
        " INTEGER, " +
        T_CLI_CODICE_ISTANZA +
        " TEXT  " +
        ");";
    await db.execute(CREATE_T_CLI);
    String CREATE_T_TAQ = "CREATE TABLE IF NOT EXISTS " +
        T_TACQ +
        " (" +
        T_TACQ_ID +
        " INTEGER NOT NULL," +
        T_TACQ_NOME +
        " TEXT, " +
        T_TACQ_ABILITATA +
        " INT,  " +
        T_TACQ_COLORE +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_TAQ);
    String CREATE_T_EVENTI = "CREATE TABLE IF NOT EXISTS " +
        T_EVENTI +
        " (" +
        T_EVENTI_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_EVENTI_CODICE +
        " TEXT, " +
        T_EVENTI_EVENTO +
        " TEXT, " +
        T_EVENTO_TIPO_INTESTATARIO +
        " TEXT, " +
        T_EVENTI_CANTIERE +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_EVENTI);
    String CREATE_T_CANTIERI = "CREATE TABLE IF NOT EXISTS " +
        T_CONTIERI +
        " (" +
        T_CONTIERI_ID +
        " INTEGER," +
        T_CONTIERI_DESC +
        " TEXT, " +
        T_CONTIERI_IDCLIENTE +
        " TEXT, " +
        T_CONTIERI_STANZA +
        " TEXT, " +
        T_CONTIERI_UNITA +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_CANTIERI);
    String CREATE_T_CUSTOMIZATION = "CREATE TABLE " + T_CUSTOMIZATION + " (" + "id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER"+");";
    await db.execute(CREATE_T_CUSTOMIZATION);
    String CREATE_T_DAMAGE_DATA = "CREATE TABLE IF NOT EXISTS " +
        T_DATADAMAGE +
        " (" +
        T_DATADAMAGE_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_DATADAMAGE_TIPO +
        " TEXT, " +
        T_DATADAMAGE_MAIL +
        " TEXT, " +
        T_DATADAMAGE_DESCRIZIONE +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_DAMAGE_DATA);
    String CREATE_T_TT = "CREATE TABLE IF NOT EXISTS " +
        T_TT +
        " (" +
        T_TT_ID +
        " INTEGER NOT NULL," +
        T_TT_IDTECNOLOGIA +
        " INTEGER NOT NULL," +
        T_TT_IDTIPOLOGIA +
        " INTEGER NOT NULL," +
        T_TT_NOMETECNOLOGIA +
        " TEXT, " +
        T_TT_NOMETIPOLOGIA +
        " TEXT " +
        ");";
    await db.execute(CREATE_T_TT);
    String attivita = "CREATE TABLE `attivita` ("+
    "`CodiceAtt` varchar(10) NOT NULL,"+
    "`DescrizioneAtt` varchar(50) NOT NULL,"+
    "`IdCliente` int(11) NOT NULL,"+
    "flag int(11)"+
    ")";
    await db.execute(attivita);
  }
  insert_attivita(String codice, String descrizione, String idcliente, String flag) async{
    Database db = await instance.database;
    String attivita = "insert into attivita(CodiceAtt, DescrizioneAtt, IdCliente, flag) values ('"+codice+"', '"+descrizione+"', '16', '"+flag+"')";
    db.execute(attivita);
  }
  update_attivita_flag(String codice, String flag) async{
    Database db = await instance.database;
    final update = "update attivita set flag='"+flag+"' where DescrizioneAtt='"+codice+"'";
    db.execute(update);
  }
  attivita_select() async {
    Database db = await instance.database;
    List res = await db.rawQuery("select * from attivita");
    return res;
  }
  count_attivita_flag() async{
    Database db = await instance.database;
    int count_attivita = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM attivita'));
    return count_attivita;
  }
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 5) {
      String insert = "UPDATE " +
          T_AUTH_USER +
          " SET " +
          T_AUTH_USER_TIPO_ISTANZA +
          "= 'winit'";
      await db.execute(insert);
      String migrationScript2 =
          "ALTER TABLE " + T_TACQ + " ADD " + T_TACQ_COLORE + " TEXT";
      await db.execute(migrationScript2);
      String migrationScript3 = "ALTER TABLE " +
          T_TIMB_STATE +
          " ADD " +
          T_TIMB_STATE_WORKED_TIME +
          " TEXT ";
      await db.execute(migrationScript3);
      String migrationScript4 =
          "ALTER TABLE " + T_EVENTI + " ADD " + T_EVENTI_CANTIERE + " TEXT";
      await db.execute(migrationScript4);
      String CREATE_T_CUSTOMIZATION = "CREATE TABLE " + T_CUSTOMIZATION + " (" + "id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER"+");";
      await db.execute(CREATE_T_CUSTOMIZATION);
    }
  }
  create_table() async{
    Database db = await instance.database;
    //await db.execute("drop table if exists PERSONALIZZAZIONI");
    String CREATE_T_CUSTOMIZATION = "CREATE TABLE " + T_CUSTOMIZATION + " (" + "id integer, scheduledGPS INTEGER, intervallo INTEGER, inOutPref INTEGER, activities INTEGER, gps INTEGER, idCliente INTEGER, segnalazioni INTEGER, attObl INTEGER, multiAtt INTEGER, simpleGps INTEGER, raggio INTEGER, nomeSocieta VARCHAR(20), logo VARCHAR(20), registrazioni INTEGER, invioAutomatico INTEGER, doppiaTimbratura INTEGER, intervalloDoppia INTEGER, pausaPranzo INTEGER, pulsanteTimbra INTEGER, squadra  INTEGER, cantieri INTEGER"+");";
    await db.execute(CREATE_T_CUSTOMIZATION);
  }
  Future<List<Map<String, dynamic>>> resetApp() async {
    Database db = await instance.database;
    await db.delete(T_UUID);
    await db.delete(T_AUTH_USER);
    await db.delete(T_TIMB);
    await db.delete(T_TIMB_STATE);
    await db.delete(T_MOD);
    await db.delete(T_PAR);
    await db.delete(T_CLI);
    await db.delete(T_TACQ);
    await db.delete(T_TT);
    var uuid = Uuid();
    String uid = uuid.v1();
    uid = uid + "#" + uuid.v4();
    String SAVE_UUID = "INSERT INTO " +
        T_UUID +
        " (" +
        T_UUID_UUID +
        ") VALUES ('" +
        uid +
        "')";
    await db.execute(SAVE_UUID);
    sleep(Duration(seconds: 1));
    SystemChannels.platform.invokeMethod('SystemNavigator.pop', true);
    exit(0);
  }
  Future<List<int>> insertCustomization(
      List<Customization> customization) async {
    Database db = await instance.database;
    List<int> listId = [];
    for (var cust in customization) {
      var id = await db.insert(T_CUSTOMIZATION, cust.toJson());
      listId.add(id);
    }
    return listId;
  }
  Future<int> deleteCustomization() async {
    Database db = await instance.database;
    return await db.delete(T_CUSTOMIZATION);
  }
  Future<void> updateCustomization(List<Customization> customization) async {
    Database db = await instance.database;
    for (var cust in customization) {
      db.update(T_CUSTOMIZATION, cust.toJson());
    }
  }
  Future<List<int>> insertEventi(List<Eventi> eventi) async {
    Database db = await instance.database;
    List<int> listId = [];
    for (var event in eventi) {
      var id = await db.insert(T_EVENTI, event.toJson());
      listId.add(id);
    }
    return listId;
  }
  Future<int> deleteEvent() async {
    Database db = await instance.database;
    return await db.delete(T_EVENTI);
  }
  Future<void> updateEventi(List<DataDamage> dataEventi) async {
    Database db = await instance.database;
    for (var data in dataEventi) {
      await db.update(T_EVENTI, data.toJson());
    }
  }
  Future<List<int>> insertDataDamage(List<DataDamage> dataDamage) async {
    Database db = await instance.database;
    List<int> listId = [];
    for (var data in dataDamage) {
      var id = await db.insert(T_DATADAMAGE, data.toJson());
      listId.add(id);
    }
    return listId;
  }
  Future<int> deleteDataDamage() async {
    Database db = await instance.database;
    return await db.delete(T_DATADAMAGE);
  }
  getDataDamage() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map> result = await db.query(T_DATADAMAGE);
    return result;
  }
  Future<List<Map<String, dynamic>>> getDataDamagesMail(String tipo) async {
    Database db = await instance.database;
    List<String> columnsToSelect = [T_DATADAMAGE_MAIL];
    List<Map> result = await db.query(T_DATADAMAGE,
        columns: columnsToSelect,
        where: '$T_DATADAMAGE_TIPO = ? ',
        whereArgs: [tipo]);
    return result;
  }
  Future<List<Map<String, dynamic>>> getDataDamagesDescription(
      String tipo) async {
    Database db = await instance.database;
    List<String> columnsToSelect = ["*"];
    List<Map> result = await db.query(T_DATADAMAGE,
        columns: columnsToSelect,
        where: '$T_DATADAMAGE_TIPO = ? ',
        whereArgs: [tipo]);
    return result;
  }
  Future<Map<String, dynamic>> getEvent(String codice) async {
    var a;
    Database db = await instance.database;
    List<String> columnsToSelect = ["*"];
    List<Map<dynamic, dynamic>> result = await db.query(T_EVENTI,
        columns: columnsToSelect,
        where: '$T_EVENTI_CODICE = ? ',
        whereArgs: [codice]);
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return a = null;
    }
  }
  Future<List<Map<String, dynamic>>> queryAllRows_UUID() async {
    Database db = await instance.database;
    return await db.query(T_UUID);
  }
  Future<int> queryRowCount_UUID() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_UUID'));
  }
  Future<int> insert_AUTH_USER(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_AUTH_USER, row);
  }
  queryAllRows_AUTH_USER() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map> result = await db.query(T_AUTH_USER);
    return result;
  }
  Future<int> queryRowCount_AUTH_USER() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_AUTH_USER'));
  }
  Future<int> update_AUTH_USER(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_AUTH_ID];
    return await db
        .update(T_AUTH_USER, row, where: '$T_AUTH_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AUTH_USER(int id) async {
    Database db = await instance.database;
    return await db
        .delete(T_AUTH_USER, where: '$T_AUTH_ID = ?', whereArgs: [id]);
  }
  Future<int> insert_TIMB(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_TIMB, row);
  }
  Future<int> insert_EVENTI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_EVENTI, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIMB() async {
    Database db = await instance.database;
    return await db.query(T_TIMB);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIMBOfDay(
      String day, int uid) async {
    Database db = await instance.database;
    String getDailyTimb = "SELECT * from " +
        T_TIMB +
        " WHERE " +
        T_TIMB_TIPO_ACQUISIZIONE +
        "=1 AND " +
        T_TIMB_USER_ID +
        "=" +
        uid.toString() +
        " AND " +
        T_TIMB_DATETIME +
        ">='" +
        day +
        " 00:00:00" +
        "' AND " +
        T_TIMB_DATETIME +
        " <= '" +
        day +
        " 23:59:59'";
    return await db.rawQuery(getDailyTimb);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_ACQUOfDay(
      String day, int uid, int tipoAcquisizione) async {
    Database db = await instance.database;
    String getDailyTimb = "SELECT * from " +
        T_TIMB +
        " WHERE " +
        T_TIMB_USER_ID +
        "=" +
        uid.toString() +
        " AND " +
        T_TIMB_TIPO_ACQUISIZIONE +
        "=" +
        tipoAcquisizione.toString() +
        " AND " +
        T_TIMB_DATETIME +
        ">='" +
        day +
        " 00:00:00" +
        "' AND " +
        T_TIMB_DATETIME +
        " <= '" +
        day +
        " 23:59:59'";
    return await db.rawQuery(getDailyTimb);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIMBOfDayNotImported() async {
    Database db = await instance.database;
    String getDailyTimb =
        "SELECT * from " + T_TIMB + " WHERE " + T_TIMB_IMPORTED + " =0 ";
    List<Map> result = await db.query(T_TIMB);
    result.forEach((row) => row);
    return await db.rawQuery(getDailyTimb);
  }
  Future<List<Map<String, dynamic>>>
      queryAllRows_CountTIMBOfDayNotImported() async {
    Database db = await instance.database;
    String getDailyTimb = "SELECT count(*) as ct from " +
        T_TIMB +
        " WHERE " +
        T_TIMB_IMPORTED +
        " =0 ";
    return await db.rawQuery(getDailyTimb);
  }
  Future<int> queryRowCount_TIMB() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_TIMB'));
  }
  Future<int> update_TIMB(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_TIMB_ID];
    return await db
        .update(T_TIMB, row, where: '$T_TIMB_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_TIMB(int id) async {
    Database db = await instance.database;
    return await db.delete(T_TIMB, where: '$T_TIMB_ID = ?', whereArgs: [id]);
  }
  Future<void> insert_TIMB_STATE(Map<String, dynamic> row, int uid) async {
    int tipoAcquisizione = 1;
    if (row["TIPO_ACQUISIZIONE"] != null) {
      tipoAcquisizione = row["TIPO_ACQUISIZIONE"];
    }
    Database db = await instance.database;
    String ins = "";
    if (row["APPROVATA"] == null) {
      ins = "INSERT INTO " +
          T_TIMB_STATE +
          " (" +
          T_TIMB_STATE_USER_ID +
          "," +
          T_TIMB_STATE_DATETIME +
          "," +
          T_TIMB_STATE_VERSO +
          "," +
          T_TIMB_STATE_SEDE +
          "," +
          T_TIMB_STATE_APPROVATA +
          "," +
          T_TIMB_STATE_TIPO_ACQUISIZIONE +
          "," +
          T_TIMB_STATE_WORKED_TIME +
          ") VALUES (" +
          uid.toString() +
          ",'" +
          row["datetime"] +
          "','" +
          row["verso"] +
          "','" +
          row["sede"] +
          "','" +
          row["approvata"].toString() +
          "','" +
          tipoAcquisizione.toString() +
          "','" +
          row["WORKED_TIME"].toString() +
          "')";
    } else {
      ins = "INSERT INTO " +
          T_TIMB_STATE +
          " (" +
          T_TIMB_STATE_USER_ID +
          "," +
          T_TIMB_STATE_DATETIME +
          "," +
          T_TIMB_STATE_VERSO +
          "," +
          T_TIMB_STATE_SEDE +
          "," +
          T_TIMB_STATE_APPROVATA +
          "," +
          T_TIMB_STATE_TIPO_ACQUISIZIONE +
          "," +
          T_TIMB_STATE_WORKED_TIME +
          ") VALUES (" +
          uid.toString() +
          ",'" +
          row["DATETIME"] +
          "','" +
          row["VERSO"] +
          "','" +
          row["SEDE"] +
          "','" +
          row["APPROVATA"].toString() +
          "','" +
          tipoAcquisizione.toString() +
          "','" +
          row["WORKED_TIME"].toString() +
          "')";
    }
    await db.rawQuery(ins);
    return;
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIMB_STATE(
      String date, int uid, int tipoAcquisizione) async {
    Database db = await instance.database;
    String getDailyTimb = "SELECT * from " +
        T_TIMB_STATE +
        " WHERE " +
        T_TIMB_STATE_TIPO_ACQUISIZIONE +
        " = " +
        tipoAcquisizione.toString() +
        " AND " +
        T_TIMB_STATE_DATETIME +
        ">='" +
        date +
        " 00:00:00" +
        "' AND " +
        T_TIMB_STATE_DATETIME +
        " <= '" +
        date +
        " 23:59:59'";
    return await db.rawQuery(getDailyTimb);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIMB_NOIMP(
      String date, int uid, int tipoAcquisizione) async {
    Database db = await instance.database;
    String getDailyTimb = "SELECT * from " +
        T_TIMB +
        " WHERE " +
        T_TIMB_TIPO_ACQUISIZIONE +
        " = " +
        tipoAcquisizione.toString() +
        " AND " +
        T_TIMB_IMPORTED +
        " = 0 " +
        " AND " +
        T_TIMB_DATETIME +
        ">='" +
        date +
        " 00:00:00" +
        "' AND " +
        T_TIMB_DATETIME +
        " <= '" +
        date +
        " 23:59:59'";
    return await db.rawQuery(getDailyTimb);
  }
  Future<int> queryRowCount_TIMB_STATE() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_TIMB_STATE'));
  }
  Future<int> update_TIMB_STATE(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_TIMB_STATE_ID];
    return await db.update(T_TIMB_STATE, row,
        where: '$T_TIMB_STATE_ID = ?', whereArgs: [id]);
  }
  Future<void> delete_TIMB_STATE(String date) async {
    Database db = await instance.database;
    String delDailyTimb = "DELETE  from " +
        T_TIMB_STATE +
        " WHERE " +
        T_TIMB_STATE_DATETIME +
        ">='" +
        date +
        " 00:00:00" +
        "' AND " +
        T_TIMB_STATE_DATETIME +
        " <= '" +
        date +
        " 23:59:59'";
    await db.rawQuery(delDailyTimb);
    return;
  }
  Future<int> insert_MODULI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_MOD, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_MODULI() async {
    Database db = await instance.database;
    return await db.query(T_MOD);
  }
  Future<int> queryRowCount_MODULI() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_MOD'));
  }
  Future<int> update_MODULI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_MOD_ID];
    return await db.update(T_MOD, row, where: '$T_MOD_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_MODULI(int id) async {
    Database db = await instance.database;
    return await db.delete(T_MOD, where: '$T_MOD_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AllMODULI() async {
    Database db = await instance.database;
    return await db.delete(T_MOD);
  }
  Future<int> insert_PARAMETRI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_PAR, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_PARAMETRI() async {
    Database db = await instance.database;
    return await db.query(T_PAR);
  }
  Future<int> queryRowCount_PARAMETRI() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_PAR'));
  }
  Future<int> update_PARAMETRI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_PAR_ID];
    return await db.update(T_PAR, row, where: '$T_PAR_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_PARAMETRI(int id) async {
    Database db = await instance.database;
    return await db.delete(T_PAR, where: '$T_PAR_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AllPARAMETRI() async {
    Database db = await instance.database;
    return await db.delete(T_PAR);
  }
  Future<int> insert_CLIENTI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_CLI, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_CLIENTI() async {
    Database db = await instance.database;
    return await db.query(T_CLI);
  }
  Future<int> queryRowCount_CLIENTI() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_CLI'));
  }
  Future<int> update_CLIENTI(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_CLI_ID];
    return await db.update(T_CLI, row, where: '$T_CLI_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_CLIENTI(int id) async {
    Database db = await instance.database;
    return await db.delete(T_CLI, where: '$T_CLI_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AllCLIENTI() async {
    Database db = await instance.database;
    return await db.delete(T_CLI);
  }
  Future<int> insert_TIPOACQUISIZIONE(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_TACQ, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIPOACQUISIZIONE() async {
    Database db = await instance.database;
    return await db.query(T_TACQ);
  }
  Future<int> queryRowCount_TIPOACQUISIZIONE() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_TACQ'));
  }
  Future<int> update_TIPOACQUISIZIONE(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_TACQ_ID];
    return await db
        .update(T_TACQ, row, where: '$T_TACQ_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_TIPOACQUISIZIONE(int id) async {
    Database db = await instance.database;
    return await db.delete(T_TACQ, where: '$T_TACQ_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AllTIPOACQUISIZIONE() async {
    Database db = await instance.database;
    return await db.delete(T_TACQ);
  }
  Future<bool> isModuleEnabled(Modules code) async {
    Database db = await instance.database;
    String getEnabledModule = "SELECT count(*) from " +
        T_MOD +
        " WHERE " +
        T_MOD_CODICE +
        "='" +
        code.toString() +
        "' and " +
        T_MOD_STATO +
        " = 1";
    int n = Sqflite.firstIntValue(await db.rawQuery(getEnabledModule));
    if (n > 0) {
      return true;
    } else {
      return false;
    }
  }
  Future<Color> getTipoAcquisizioneColor(int tipoAcquisizioneId) async {
    Database db = await instance.database;
    String getTaColor = "SELECT " +
        T_TACQ_COLORE +
        " from " +
        T_TACQ +
        " WHERE " +
        T_TACQ_ID +
        "=" +
        tipoAcquisizioneId.toString();
    try {
      List<Map> result = await db.rawQuery(getTaColor);
      if (result != null && result.length > 0) {
        return HexColor(result[0]['COLORE']);
      }
    } on Exception catch (_) {
      return HexColor("#808080");
    }
    return HexColor("#808080");
  }
  Future<int> insert_TIPOLOGIETECNOLOGIE(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(T_TT, row);
  }
  Future<List<Map<String, dynamic>>> queryAllRows_TIPOLOGIETECNOLOGIE() async {
    Database db = await instance.database;
    return await db.query(T_TT);
  }
  Future<int> queryRowCount_TIPOLOGIETECNOLOGIE() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $T_TT'));
  }
  Future<int> update_TIPOLOGIETECNOLOGIE(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[T_TT_ID];
    return await db.update(T_TT, row, where: '$T_TT_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_TIPOLOGIETECNOLOGIE(int id) async {
    Database db = await instance.database;
    return await db.delete(T_TT, where: '$T_TT_ID = ?', whereArgs: [id]);
  }
  Future<int> delete_AllTIPOLOGIETECNOLOGIE() async {
    Database db = await instance.database;
    return await db.delete(T_TT);
  }
  Future<List<dynamic>> get_TipologieTecnologie(String tipoacquisizione) async {
    Database db = await instance.database;
    String getTecnAb = "SELECT " +
        T_TT_NOMETECNOLOGIA +
        " from " +
        T_TT +
        " WHERE UPPER(" +
        T_TT_NOMETIPOLOGIA +
        ")=UPPER('" +
        tipoacquisizione.trim() +
        "')";
    return await db.rawQuery(getTecnAb);
  }
  collaboratore_select() async {
    Database db = await instance.database;
    return await db.rawQuery("select distinct descrizione, matricola from collaboratori");
  }
  Future<List<Map<String, dynamic>>> matricola() async {
    Database db = await instance.database;
    return await db.query(
        "collaboratori",
    );
  }
  update_collaboratore(String descrizione) async {
    Database db = await instance.database;
    await db.rawQuery("update collaboratori set descrizione='Collaboratore Prova' where descrizione='"+descrizione.toString()+"'");
  }
  update_customization() async{
    Database db = await instance.database;
    await db.rawQuery("update PERSONALIZZAZIONI set activities='1', segnalazioni='1', pausaPranzo='1' where squadra='1'");
  }
  delete_collaboratore(int id) async {
    Database db = await instance.database;
    //await db.rawQuery("DELETE FROM collaboratori");
    //await db.rawQuery("DELETE FROM sqlite_sequence WHERE name = 'collaboratori'");
    await db.rawQuery("delete from collaboratori where Id='"+id.toString()+"'");
  }
  getCollaboratoriList() async {
   try{
    var dbHelper = DatabaseHelper.instance;
    int cid;
    List result = await dbHelper.queryAllRows_AUTH_USER();
    cid = result[0]["CLIENTE_ID"];
    String productURl= "http://backend.winitsrl.eu:81/app/ws/Collaboratori?IdCliente="+cid.toString();
    http.Response response = await http.get(Uri.parse(productURl),headers:{"Content-Type":"application/json"});
    List jsonResponse = json.decode(response.body);
    return jsonResponse;
   }catch(e){
     print("siamo offline");
   }
  }
  getAttivita() async {
    try{
      var dbHelper = DatabaseHelper.instance;
      int cid;
      List result = await dbHelper.queryAllRows_AUTH_USER();
      cid = result[0]["CLIENTE_ID"];
      String productURl= "http://backend.winitsrl.eu:81/app/ws/Attivita?IdCliente="+cid.toString();
      http.Response response = await http.get(Uri.parse(productURl),headers:{"Content-Type":"application/json"});
      List jsonResponse = json.decode(response.body);
      return jsonResponse;
    }catch(e){
      print("siamo offline");
    }
  }
  getCantiereList() async {
    var dbHelper = DatabaseHelper.instance;
    int cid;
    await dbHelper.queryAllRows_AUTH_USER().then((users) => {cid = users[0]["CLIENTE_ID"]});
    String productURl= "http://backend.winitsrl.eu:81/app/ws/Cantieri?IdCliente="+cid.toString();
    http.Response response = await http.get(Uri.parse(productURl),headers:{"Content-Type":
    "application/json"});
    List jsonResponse = json.decode(response.body);
    List _ids = [];
    for(int i=0;i<jsonResponse.length;i++) {
      _ids.add(jsonResponse[i]['DescrizioneCantiere']);
    }
    return _ids;
  }
  getEmail() async{
    var dbHelper = DatabaseHelper.instance;
    int cid;
    await dbHelper.queryAllRows_AUTH_USER().then((users) => {cid = users[0]["CLIENTE_ID"]});
    String productURl= "http://backend.winitsrl.eu:81/app/ws/Clienti?IdCliente="+cid.toString();
    http.Response response = await http.get(Uri.parse(productURl),headers:{"Content-Type":
    "application/json"});
    List jsonResponse = json.decode(response.body);
    String emails = "";
    for(int i=0;i<jsonResponse.length;i++) {
      emails = jsonResponse[i]["EmailContatto"];
    }
    return emails;
  }
  getCustomizationList(String types) async{
    http.Client client;
    var dbHelper = DatabaseHelper.instance;
    Database db = await instance.database;
    String CREATE_AUTH_USER = "CREATE TABLE IF NOT EXISTS " +
        T_AUTH_USER +
        " (" +
        T_AUTH_ID +
        " INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT," +
        T_AUTH_USER_NAME +
        " TEXT, " +
        T_AUTH_USER_PASSWORD +
        " TEXT, " +
        T_AUTH_USER_USER_ID +
        " INT,  " +
        T_AUTH_USER_MOBILE_ATTENDANCE_ENABLED +
        " INT, " +
        T_AUTH_USER_GPS_MANDATORY +
        " INT, " +
        T_AUTH_USER_DELETED +
        " INT, " +
        T_AUTH_USER_DISABLED +
        " INT, " +
        T_AUTH_USER_SKIPLOGIN +
        " INT, " +
        T_AUTH_USER_BASEURL +
        " TEXT, " +
        T_AUTH_CLIENTE_ID +
        " INT, " +
        T_AUTH_TSLOGIN +
        " TEXT, " +
        T_AUTH_USER_TIPO_ISTANZA +
        " TEXT"
            ");";
    int cid = 0;
    db.execute(CREATE_AUTH_USER);
    await dbHelper.queryAllRows_AUTH_USER().then((users) => {cid = users[0]["CLIENTE_ID"]});
    final response = await http.get(Uri.parse("http://backend.winitsrl.eu:81/app/ws/Customization?IdCliente="+cid.toString()));
    List<dynamic> values= [];
    values = json.decode(response.body);
    if(values.length>0){
      for(int i=0;i<values.length;i++){
        if(values[i]!=null){
          Map<String,dynamic> map=values[i];
          switch(types) {
            case "Cantieri": {
              return map['${types}'].toString();
            }
            break;

            case "Squadra": {
              return map['${types}'].toString();
            }
            break;

            case "GPS": {
              return map['${types}'].toString();
            }
            break;

            case "ScheduledGPS": {
              return map['${types}'].toString();
            }
            break;

            case "ClienteId": {
              return map['${types}'].toString();
            }
            break;

            case "Segnalazioni": {
              return map['${types}'].toString();
            }
            break;

            case "PausaPranzo": {
              return map['${types}'].toString();
            }
            break;

            case "Activities": {
              return map['${types}'].toString();
            }
            break;
          }
        }
      }
    }
  }
  GetPersonalizzazione(String types) async{
    switch(types) {
      case "Cantieri": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["cantieri"], limit: 1);
      }
      break;

      case "Squadra": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["squadra"], limit: 1);
      }
      break;

      case "GPS": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["gps"], limit: 1);
      }
      break;

      case "ScheduledGPS": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["scheduledGPS"], limit: 1);
      }
      break;

      case "ClienteId": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["idCliente"], limit: 1);
      }
      break;

      case "Segnalazioni": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["Segnalazioni"], limit: 1);
      }
      break;

      case "PausaPranzo": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["pausaPranzo"], limit: 1);
      }
      break;

      case "Activities": {
        Database db = await DatabaseHelper.instance.database;
        return await db.query("PERSONALIZZAZIONI", columns: ["activities"], limit: 1);
      }
      break;
    }
  }
  Future<List<int>> insertCollaboratori(List<Collaboratori> collaboratori) async {
    Database db = await instance.database;
    List<int> listId = new List<int>();
    for (var collaboratore in collaboratori) {
      var id = await db.insert(T_COLLABORATORI, collaboratore.toJson());
      listId.add(id);
    }
    return listId;
  }
  Future<int> deleteCollaboratori() async {
    Database db = await instance.database;
    return await db.delete(T_COLLABORATORI);
  }
  Future<int> deletePersonalizzazione() async {
    Database db = await instance.database;
    return await db.delete(T_CUSTOMIZATION);
  }
  Future<void> updateCollaboratori(List<DataDamage> dataCollaboratori) async {
    Database db = await instance.database;
    for (var data in dataCollaboratori) {
      await db.update(T_COLLABORATORI, data.toJson());
    }
  }
  select_timbratura() async{
    Database db = await instance.database;
    return await db.rawQuery("select * from TIMBRATURE where datetime='2022-04-12 15:11:44'");
  }
  customization() async {
    Database db = await instance.database;
    List<Map> result = await db.query("PERSONALIZZAZIONI", distinct: true, orderBy: "idCliente");
    result.forEach((row) => row);
  }
  select_cantieri() async {
    Database db = await DatabaseHelper.instance.database;
    return await db.rawQuery("select distinct DescrizioneCantiere from CANTIERI order by IdCliente");
  }
  get_cust_clienteid() async{
    Database db = await DatabaseHelper.instance.database;
    List<Map> result = await db.query("PERSONALIZZAZIONI");
    return result.forEach((row) => row["idCliente"]);
  }
  insert_eventi(String codice, String evento, String tipo, String cantiere, String idcliente) async{
    Database db = await instance.database;
    await db.rawQuery("insert into eventi(Codice, Evento, Tipo_Intestatario, Cantiere) values('"+codice.toString()+"','"+evento.toString()+"','"+tipo.toString()+"','"+cantiere.toString()+"')");
  }
  select_eventi_codice() async{
    Database db = await DatabaseHelper.instance.database;
    List<Map> result = await db.query("CANTIERI");
    return result.forEach((row) => row["UnitaFissaAssociata"]);
  }
  select_attivita() async{
    Database db = await instance.database;
    List<Map> result = await db.query("attivita");
    return result.forEach((row) => row["CodiceAtt"]);
  }
  select_decrizione_cantieri(String descrizione) async{
    Database db = await DatabaseHelper.instance.database;
    return await db.rawQuery("select * from cantieri where DescrizioneCantiere='"+descrizione+"'");
  }
  insert_prodotti(String matricola, String data, String quantita, String products, String foto, String audio, String notes, String cantieri) async{
    Database db = await instance.database;
    List id = await select_id_prodotto();
    int num;
    if(id.length == 0){
      num = 1;
    }else{
      for(int i=0;i<id.length;i++){
        num = id[i]["id"] + 1;
      }
    }
    var res = "insert into prodotto(id, matricola, datetimes, quantita, prodotti, fotos, audios, notes, cantieri) values ('"+num.toString()+"','"+matricola+"', '"+data+"', '"+quantita+"', '"+products+"', '"+foto+"', '"+audio+"', '"+notes+"', '"+cantieri+"');";
    var result =  await db.rawQuery(res);
    return result;
  }
  select_prodotti() async{
    Database db = await instance.database;
    var rows = await db.rawQuery("select distinct fotos, cantieri, datetimes, notes, count(*) as count from prodotto group by fotos order by count(fotos) desc");
    return rows;
  }
  prodotto_tutto() async{
    Database db = await instance.database;
    var result = await db.query("prodotto");
    return result;
  }
  Id_Prodotto(String id) async{
    Database db = await instance.database;
    try{
     final res = await db.rawQuery("select * from prodotto where id ='"+id.toString()+"'");
     return res;
    }catch(e){
      print(e);
    }
  }
  updateProdotti(int id, String notes) async{
    Database db = await instance.database;
    return await db.rawQuery("update prodotto set('"+notes.toString()+"') where id='"+id.toString()+"'");
  }
  create_prodotti() async{
    Database db = await instance.database;
    await db.execute("drop table if exists prodotto");
    return await db.rawQuery("CREATE TABLE if not exists prodotto (id integer, matricola varchar(1000) NOT NULL, datetimes varchar(1000) NOT NULL, quantita int(11) NOT NULL, prodotti varchar(1000) NOT NULL, fotos longblob NOT NULL, audios longblob NOT NULL, notes varchar(1000) NOT NULL, cantieri varchar(1000) NOT NULL)");
  }
  drop_prodotto() async{
    Database db = await instance.database;
    return await db.rawQuery("delete from prodotto");
  }
  select_id_prodotto() async{
    Database db = await instance.database;
    List result = await db.rawQuery("select * from prodotto order by id desc limit 1");
    return result;
  }
  insert_buffer(int quantity, String product) async{
    Database db = await instance.database;
    List id = await select_id_buffer();
    int num;
    if(id.length == 0){
      num = 1;
    }else{
      for(int i=0;i<id.length;i++){
        num = id[i]["id"] + 1;
      }
    }
    var res = "insert into buffer(id, quantity,	product) values ('"+num.toString()+"','"+quantity.toString()+"', '"+product+"');";
    var result =  await db.rawQuery(res);
    return result;
  }
  deletebuffer(String id) async{
    Database db = await instance.database;
    try{
      await db.rawQuery("delete from buffer where id='"+id.toString()+"'");
    }catch(e){
      print(e);
    }
  }
  select_buffer() async {
    Database db = await instance.database;
    List res = await db.query("buffer");
    return res;
  }
  create_buffer() async{
    Database db = await instance.database;
    String buffer = "create table if not exists buffer(id integer, quantity integer not null, product varchar(200) not null)";
    await db.execute(buffer);
  }
  select_id_buffer() async{
    Database db = await instance.database;
    List result = await db.rawQuery("select * from buffer order by id desc limit 1");
    return result;
  }
  select_buffer_product() async{
    Database db = await instance.database;
    List res = await db.rawQuery("select product from buffer");
    return res;
  }
  select_buffer_quantity() async{
    Database db = await instance.database;
    List result = await db.rawQuery("select quantity from buffer");
    return result;
  }
  drop_buffer() async{
    Database db = await instance.database;
    return await db.rawQuery("delete from buffer");
  }
  create_audio() async{
    Database db = await instance.database;
    String audio = "create table if not exists ascolta(id integer, audio varchar(200) not null)";
    await db.execute(audio);
  }
  create_foto() async{
    Database db = await instance.database;
    String foto = "create table if not exists photo(id integer, foto varchar(200) not null)";
    await db.execute(foto);
  }
  insert_audio(String audio) async{
    Database db = await instance.database;
    List result = await db.rawQuery("select * from ascolta order by id desc limit 1");
    int id;
    for(int i=0;i<result.length;i++){
      id = result[i]["id"] + 1;
    }
    if(id == null){
      id = 1;
    }else{
      for(int i=0;i<result.length;i++){
        id = result[i]["id"] + 1;
      }
    }
    var res = "insert into ascolta(id, audio) values ('"+id.toString()+"','"+audio.toString()+"');";
    var insert_ascolta =  await db.rawQuery(res);
    return insert_ascolta;
  }
  insert_foto(String foto) async{
    Database db = await instance.database;
    List result = await db.rawQuery("select * from photo order by id desc limit 1");
    int id;
    for(int i=0;i<result.length;i++){
      id = result[i]["id"] + 1;
    }
    if(id == null){
      id = 1;
    }else{
      for(int i=0;i<result.length;i++){
        id = result[i]["id"] + 1;
      }
    }
    var res = "insert into photo(id, foto) values ('"+id.toString()+"','"+foto.toString()+"');";
    var insert_foto =  await db.rawQuery(res);
    return insert_foto;
  }
  insert_medias() async{
    Database db = await instance.database;
    List result = await db.rawQuery("select * from medias order by id desc limit 1");
    int id;
    if(id == null){
      id = 1;
    }else{
      for(int i=0;i<result.length;i++){
        id = result[i]["id"] + 1;
      }
    }
    int count_audio = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ascolta'));
    int count_foto = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM photo'));
    List foto = [];
    List audio = [];
    String ad = "";
    String ph = "";
    if(count_audio != 0 && count_foto != 0){
      print("1");
      audio = await db.rawQuery("select * from ascolta order by id desc limit 1");
      for(int i=0;i<audio.length;i++){
        ad = audio[i]["audio"].toString();
      }
      foto = await db.rawQuery("select * from photo order by id desc limit 1");
      for(int j=0;j<foto.length;j++){
        ph = foto[j]["foto"].toString();
      }
      await db.execute("insert into medias (id, audio, foto) values ('"+id.toString()+"','"+ad.toString()+"','"+ph.toString()+"')");
      print("inserted 1");
    }
    if(count_audio != 0 && count_foto == 0) {
      print("2");
      audio = await db.rawQuery("select * from ascolta order by id desc limit 1");
      await db.execute("insert into medias(id, audio, foto) values ('"+id.toString()+"','"+ad.toString()+"', '0')");
      print("inserted 2");
    }
    if(count_audio == 0 && count_foto != 0) {
      print("3");
      foto = await db.rawQuery("select * from photo order by id desc limit 1");
      await db.execute("insert into medias(id, audio, foto) values ('"+id.toString()+"','0','"+ph.toString()+"')");
      print("inserted 3");
    }
  }
  deletemedias(String id) async{
    Database db = await instance.database;
    return await db.rawQuery("delete from medias where id='"+id.toString()+"'");
  }
  select_medias() async{
    Database db = await instance.database;
    List res = await db.rawQuery("select * from medias order by id desc limit 1");
    return res;
  }
  create_medias() async{
    Database db = await instance.database;
    String medias = "create table if not exists medias (id integer, audio varchar(200) not null, foto varchar(200) not null)";
    await db.execute(medias);
  }
  drop_medias() async{
    Database db = await instance.database;
    return await db.rawQuery("drop table medias");
  }
  email_cliente(String mat) async{
    Database db = await instance.database;
    var res = await db.rawQuery("select CLIENTE_Id from users where Matricola='"+mat.toString()+"'");
    var email = await db.rawQuery("select EmailContatto from cliente where Id='"+res.toString()+"'");
    return email;
  }
  select_audio() async{
    Database db = await instance.database;
    String voice = "";
    List result = await db.rawQuery("select * from ascolta order by id desc limit 1");
    for(int i=0;i<result.length;i++){
      voice = result[i]["audio"];
    }
    print(voice);
    return voice;
  }
  select_foto() async{
    Database db = await instance.database;
    String image = "";
    List result = await db.rawQuery("select * from photo order by id desc limit 1");
    for(int i=0;i<result.length;i++){
       image = result[i]["foto"];
    }
    return image;
  }
  delete_audio() async{
    Database db = await instance.database;
    final res = await db.execute("delete from ascolta");
    return res;

  }
  delete_photo() async{
    Database db = await instance.database;
    final res = await db.execute("delete from photo");
    return res;
  }
}
