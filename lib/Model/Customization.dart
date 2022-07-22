import 'dart:convert';
class Customization {
  Customization customizationFromJson(String str) =>
      Customization.fromJson(json.decode(str));
  String customization(Customization data) => json.encode(data.toJson());
  Customization({
     this.id,
     this.scheduledGPS,
     this.intervallo,
     this.inOutPref,
     this.activities,
     this.gps,
     this.idCliente,
     this.segnalazioni,
     this.attObl,
     this.multiAtt,
     this.simpleGps,
     this.raggio,
     this.nomeSocieta,
     this.logo,
     this.registrazioni,
     this.invioAutomatico,
     this.doppiaTimbratura,
     this.intervalloDoppia,
     this.pausaPranzo,
     this.pulsanteTimbra,
     this.squadra,
     this.cantieri
  });
  int id;
  int scheduledGPS;
  int intervallo;
  int inOutPref;
  int activities;
  int gps;
  int idCliente;
  int segnalazioni;
  int attObl;
  int multiAtt;
  int simpleGps;
  int raggio;
  String nomeSocieta;
  String logo;
  int registrazioni;
  int invioAutomatico;
  int doppiaTimbratura;
  int intervalloDoppia;
  int pausaPranzo;
  int pulsanteTimbra;
  int squadra;
  int cantieri;
  factory Customization.fromJson(Map<String, dynamic> json) => Customization(
      id: json["Id"],
      scheduledGPS: json["ScheduledGPS"],
      intervallo: json["Intervallo"],
      inOutPref: json["InOutPref"],
      activities: json["Activities"],
      gps: json["GPS"],
      idCliente: json["ClienteId"],
      segnalazioni: json["Segnalazioni"],
      attObl: json["AttivitaObbligatoria"],
      multiAtt: json["AttivitaMultipla"],
      simpleGps: json["simpleGps"],
      raggio: json["Raggio"],
      nomeSocieta: json["NomeSocieta"],
      logo: json["Logo"],
      registrazioni: json["Registrazioni"],
      invioAutomatico: json["invioAutomatico"],
      doppiaTimbratura: json["doppiaTimbratura"],
      intervalloDoppia: json["intervalloDoppia"],
      pausaPranzo: json["PausaPranzo"],
      pulsanteTimbra: json["PulsanteTimbra"],
      squadra: json["Squadra"],
      cantieri: json["Cantieri"]);
  Map<String, dynamic> toJson() => {
    "id":id,
    "scheduledGPS": scheduledGPS,
    "intervallo": intervallo,
    "inOutPref": inOutPref,
    "activities": activities,
    "gps": gps,
    "idCliente": idCliente,
    "segnalazioni": segnalazioni,
    "attObl": attObl,
    "multiAtt": multiAtt,
    "simpleGps": simpleGps,
    "raggio": raggio,
    "nomeSocieta": nomeSocieta,
    "logo": logo,
    "registrazioni": registrazioni,
    "invioAutomatico": invioAutomatico,
    "doppiaTimbratura": doppiaTimbratura,
    "intervalloDoppia": intervalloDoppia,
    "pausaPranzo": pausaPranzo,
    "pulsanteTimbra": pulsanteTimbra,
    "squadra": squadra,
    "cantieri": cantieri
      };
}
