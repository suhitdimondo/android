import '../TimbPages/timbratureListWinit.dart';
import 'Internet.dart';
class Refresh{
  int cantieridb;
  int squadradb;
  int gpsdb;
  int scheduledGPSdb;
  int segnalazioni;
  int pausaPranzo;
  String idCliente;
  Checkinternet objectInternet = Checkinternet();
  String connection;
  int activities;
  Refresh({ this.cantieridb,  this.squadradb,  this.gpsdb,  this.scheduledGPSdb,  this.segnalazioni,  this.pausaPranzo,  this.idCliente,  this.connection,  this.activities});
  getSquadraT() async {
    return await dbHelper.getCustomizationList("Squadra");
  }
  getSquadraF() async {
    List result = await dbHelper.GetPersonalizzazione("Squadra");
    int val = await result[0]["squadra"];
    return val;
  }
  getCantiereT() async {
    return await dbHelper.getCustomizationList("Cantieri");
  }
  getCantiereF() async {
    List result = await dbHelper.GetPersonalizzazione("Cantieri");
    int val = await result[0]["cantieri"];
    return val;
  }
  getGPST() async {
    return await dbHelper.getCustomizationList("GPS");
  }
  getGPSF() async {
    List result = await dbHelper.GetPersonalizzazione("GPS");
    int val = await result[0]["gps"];
    return val;
  }
  getClientIdT() async {
      return await dbHelper.getCustomizationList("ClienteId");
  }
  getClientIdF() async{
    List result = await dbHelper.GetPersonalizzazione("ClienteId");
    int val = await result[0]["idCliente"];
    return val;
  }
  getScheduledGPST() async {
    return await dbHelper.getCustomizationList("ScheduledGPS");
  }
  getScheduledGPSF() async {
    List result = await dbHelper.GetPersonalizzazione("ScheduledGPS");
    int val = await result[0]["scheduledGPS"];
    return val;
  }
  getSegnalazioneT() async {
    return await dbHelper.getCustomizationList("Segnalazioni");
  }
  getSegnalazioneF() async {
    List result = await dbHelper.GetPersonalizzazione("Segnalazioni");
    int val = await result[0]["segnalazioni"];
    return val;
  }
  getPausaPranzoT() async {
    return await dbHelper.getCustomizationList("PausaPranzo");
  }
  getPausaPranzoF() async {
    List result = await dbHelper.GetPersonalizzazione("PausaPranzo");
    int val = await result[0]["pausaPranzo"];
    return val;
  }
  getActivitiesT() async {
    return await dbHelper.getCustomizationList("Activities");
  }
  getActivitiesF() async {
    List result = await dbHelper.GetPersonalizzazione("Activities");
    int val = await result[0]["activities"];
    return val;
  }
}