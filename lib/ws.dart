import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hr_app/Model/DataDamage.dart';
import 'package:flutter_hr_app/Model/Eventi.dart';
import 'package:flutter_hr_app/Model/Licence.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Model/Acquisizioni.dart';
import 'Model/Activities.dart';
import 'Model/Customization.dart';
import 'common.dart';
import 'database.dart';
import 'preferenze.dart';
import 'package:device_info/device_info.dart';
import 'dart:io' as IO;
class RESTApi extends StatefulWidget {
  @override
  _RESTApiState createState() => _RESTApiState();
  Future CheckAuthService(String username, String password, String clientId,
      String day, String uuid) async {
    String deviceData;
    String deviceData2;
    try {
      var deviceInfo = DeviceInfoPlugin();
      if (IO.Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfo.androidInfo);
        deviceData2 =
            "";
      } else if (IO.Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfo.iosInfo);
        deviceData2 = "";
      }
    } on PlatformException {
      deviceData = 'Failed to get platform version.';
      deviceData2 = 'Failed to get platform version.';
    }
    var client = new http.Client();
    try {
      String realPwd = password;
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.checkauth_url_webservice;
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "username": username,
            "hash": realPwd,
            "client_id": "0",
            "day": day,
            "uuid": uuid,
            "devicedata": deviceData,
            "devicedata2": deviceData2
          }));
      var json = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          response.body != null &&
          json[0]["status"] != null &&
          json[0]["status"] == true) {
        return response.body;
      } else {
        return 'Error';
      }
    } on Exception catch (_) {
      return 'Error';
    } finally {
      client.close();
    }
  }
  Future<List<DataDamage>> GetDataDamage(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getDataDamage_url_webservice;
      List<DataDamage> dataDamageList = new List<DataDamage>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var dam in list) {
        print(dam);
        var event = DataDamage.fromJson(dam);
        dataDamageList.add(event);
      }
      return dataDamageList;
    } catch (e) {}
  }
  Future<DateTime> GetLicenza(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getLicenza_url_webservice;
      List<Licence> dataLicenzaList = new List<Licence>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      var licence;
      for (var lic in list) {
        licence = Licence.fromJson(lic);
      }
      return licence;
    } catch (e) {}
  }

  Future<List<Customization>> GetCustomization(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getCustomization_url_webservice;
      List<Customization> customList = new List<Customization>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var cus in list) {
        var cust = Customization.fromJson(cus);
        customList.add(cust);
      }
      return customList;
    } catch (e) {}
  }
  Future<List<Activities>> GetActivities(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getActivity_url_webservice;
      List<Activities> activitiesList = new List<Activities>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var cus in list) {
        var cust = Activities.fromJson(cus);
        activitiesList.add(cust);
      }
      return activitiesList;
    } catch (e) {}
  }
  Future<List<Eventi>> GetEventi(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getEventi_url_webservice;
      List<Eventi> eventList = new List<Eventi>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var ev in list) {
        var event = Eventi.fromJson(ev);
        eventList.add(event);
      }
      return eventList;
    } catch (e) {}
  }
  Future<List<DataDamage>> GetSegnalazioni(int idCliente) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getDataDamage_url_webservice;
      List<DataDamage> eventList = new List<DataDamage>();
      url = '$url?IdCliente=$idCliente';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var ev in list) {
        var event = DataDamage.fromJson(ev);
        eventList.add(event);
      }
      return eventList;
    } catch (e) {}
  }
  Future<bool> has2UpdateConf() async {
    final dbHelper = DatabaseHelper.instance;
    bool has2Update = true;
    try {
      List<Map<String, dynamic>> moduli = await dbHelper.queryAllRows_MODULI();
      if (moduli != null && moduli.length > 0) {
        if (moduli[0]["REFRESH"] != null) {
          if (DateTime.parse(moduli[0]["REFRESH"])
              .isBefore(DateTime.now().subtract(Duration(seconds: 1)))) {
            has2Update = true;
          } else {
            has2Update = false;
          }
        } else {
          has2Update = true;
        }
      } else {
        has2Update = true;
      }
    } on Exception catch (_) {
      has2Update = true;
    }
    return has2Update;
  }
  Future GetConfigurazione(String username, String password, String clientId,
      String day, String uuid) async {
    var client = new http.Client();
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getconfigurazione_url_webservice;
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "username": username,
            "hash": password,
            "client_id": clientId,
            "day": day,
            "uuid": uuid
          }));
      var json = jsonDecode(response.body);
      json = jsonDecode(json);
      if (response.statusCode == 200 &&
          response.body != null &&
          json["status"] != null &&
          json["status"] == true) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future<String> GetTimbratureService(
      String date, int uid, String clientid, int mode) async {
    var client = new http.Client();
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Common.getAcquisizioneReadApi(
              mode);
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"client_id": clientid, "uid": uid, "day": date}));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future<List<Acquisizioni>> GetTimbratureWinit(
      int clienteId, int userId) async {
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.getTimbrature_url_webservice;
      List<Acquisizioni> acquisizioniList = new List<Acquisizioni>();
      url = '$url?IdCliente=$clienteId&userId=$userId';
      Uri url2 = Uri.parse(url);
      var response = await http.get(url2);
      List<dynamic> list = json.decode(response.body);
      for (var acq in list) {
        var acquisizione = Acquisizioni.fromJson(acq);
        acquisizioniList.add(acquisizione);
      }
      return acquisizioniList;
    } catch (e) {}
  }
  Future<String> GetAcquisizioniService(String date, int uid, String clientid,
      int mode, String username, String hash) async {
    var client = new http.Client();
    try {
      String url = Preferenze.piattaformaTimbratureHost +
          Common.getAcquisizioneReadApi(
              mode);
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            "client_id": clientid,
            "uid": uid,
            "username": "fake",
            "day": date,
            "hash": Preferenze.HASH,
            "tipo_acquisizione": mode
          }));
      var json = jsonDecode(response.body);
      json = json[0];
      if (response.statusCode == 200 &&
              response.body != null &&
              json["DataOra"] != null
          ) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future PushService(
      String time,
      String verso,
      int uid,
      String giorno,
      String luogo,
      String idTimb,
      double longitudine,
      double latitudine,
      String urlsite) async {
    var client = new http.Client();
    try {
      String bodyj = jsonEncode([
        {
          "time": time,
          "verso": verso,
          "user_id": uid,
          "giorno": giorno,
          "luogo": luogo,
          "hash": Preferenze.HASH,
          "id_timb": idTimb,
          "longitudine": longitudine,
          "latitudine": latitudine,
        }
      ]);
      String url = urlsite + Preferenze.punch_url_webservice;
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: bodyj);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future sendDamage(
      String disp,
      String dataOra,
      String cantiere,
      String tipologia,
      String codice,
      String media,
      String note,
      String badge,
      int file) async {
    var client = new http.Client();
    File imageFile = new File(media);
    List<int> mediaBytes = imageFile.readAsBytesSync();
    String mediaBase64 = base64Encode(mediaBytes);
    String bodyj = jsonEncode({
      "matricola": disp,
      "data": dataOra,
      "cantiere": cantiere,
      "tipo": tipologia,
      "codice": codice,
      "media": mediaBase64,
      "note": note,
      "badge": badge,
      "file": file
    });
    String url = Preferenze.piattaformaTimbratureHost +
        Preferenze.sendDamage_url_webservice;
    Uri url2 = Uri.parse(url);
    final http.Response response = await client.post(url2,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: bodyj);
    var json = response.body;
    if (response.statusCode == 200 &&
        response.body != null &&
        response.body != null &&
        json.compareTo("Invio riuscito") == 0) {
      return true;
    } else {
      return false;
    }
  }
  Future<String> GetTecnologieTipologie(
      String piattaformaTimbratureHost, int cid) async {
    var client = new http.Client();
    try {
      print(piattaformaTimbratureHost +
          Preferenze.getTecnologieTipologieService +
          "/" +
          cid.toString());
      Uri url = Uri.parse(piattaformaTimbratureHost +
          Preferenze.getTecnologieTipologieService +
          "/" +
          cid.toString());
      final http.Response response = await client.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future sendData(String dataIngresso, String uid, String idCliente,
      String valore_ingresso, String tipo_ingresso, String tecnologia) async {
    var client = new http.Client();
    try {
      String bodyj = jsonEncode({
        "uid": int.parse(uid),
        "hash": Preferenze.HASH,
        "client_id": int.parse(idCliente),
        "day": dataIngresso,
        "data": [
          {
            "TipoValore": tipo_ingresso,
            "ValoreInIngresso": valore_ingresso,
            "DataInIngresso": dataIngresso,
            "Tecnologia": tecnologia
          }
        ]
      });
      String url = Preferenze.piattaformaTimbratureHost +
          Preferenze.sendData_url_webservice;
      Uri url2 = Uri.parse(url);
      final http.Response response = await client.post(url2,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: bodyj);
      var json = jsonDecode(response.body);
      json = json[0]; //jsonDecode(json);
      if (response.statusCode == 200 &&
          response.body != null &&
          json["status"] != null &&
          json["status"] == true) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future<String> GetDominiClienti(String piattaformaTimbratureHost) async {
    var client = new http.Client();
    try {
      Uri url = Uri.parse(
          piattaformaTimbratureHost + Preferenze.getDominiClientiService);
      final http.Response response = await client.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
  Future<String> GetTipologiaAcquisizioni(
      String piattaformaTimbratureHost, int cid) async {
    var client = new http.Client();
    try {
      Uri url = Uri.parse(piattaformaTimbratureHost +
          Preferenze.getTipologiaAcquisizioniService +
          "/" +
          cid.toString());
      final http.Response response = await client.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'Error';
      }
    } finally {
      client.close();
    }
  }
}
Future<String> GetCantiere(
    String piattaformaTimbratureHost, int cid) async {
  var client = new http.Client();
  try {
    Uri url = Uri.parse(piattaformaTimbratureHost +
        Preferenze.getCantiereService +
        "/" +
        cid.toString());
    final http.Response response = await client.get(url);
    if (response.statusCode == 200) {
      print(response.body);
      return response.body;
    } else {
      return 'Error';
    }
  } finally {
    client.close();
  }
}
class _RESTApiState extends State<RESTApi> {
  String restResult = '';
  Future GetTimbratureService(String urlsite) async {
    var client = new http.Client();
    try {
      Uri url = Uri.parse(urlsite + Preferenze.gettimbrature_url_webservice);
      final http.Response response = await client.get(url);
      if (response.statusCode == 200) {
        print(response.body);
      } else {
        throw Exception('Failed to print get response.');
      }
    } finally {
      client.close();
    }
  }
  @override
  Widget build(BuildContext context) {}
}
String _readAndroidBuildData(AndroidDeviceInfo build) {
  return "device:" + build.device;
}
String _readIosDeviceInfo(IosDeviceInfo data) {
  return "model:" + data.model;
}