import 'dart:convert';
Acquisizioni welcomeFromJson(String str) =>
    Acquisizioni.fromJson(json.decode(str));
String welcomeToJson(Acquisizioni data) => json.encode(data.toJson());
class Acquisizioni {
  Acquisizioni({
     this.valore,
     this.inviato,
     this.prova,
  });
  List<Valore> valore;
  String inviato;
  String prova;
  factory Acquisizioni.fromJson(Map<String, dynamic> json) => Acquisizioni(
        valore:
            List<Valore>.from(json["valore"].map((x) => Valore.fromJson(x))),
        inviato: "inviato", prova: '',
      );
  Map<String, dynamic> toJson() => {
        "valore": List<dynamic>.from(valore.map((x) => x.toJson())),
        "inviato": inviato,
      };
}
class Valore {
  Valore({
     this.datetime,
     this.verso,
  });
  DateTime datetime;
  String verso;
  factory Valore.fromJson(Map<String, dynamic> json) => Valore(
        datetime: DateTime.parse(json["datetime"]),
        verso: json["verso"],
      );
  Map<String, dynamic> toJson() => {
        "datetime": datetime.toIso8601String(),
        "verso": verso,
      };
}
ValoreDb valoreDbFromJson(String str) => ValoreDb.fromJson(json.decode(str));
String valoreDbToJson(ValoreDb data) => json.encode(data.toJson());
class ValoreDb {
  ValoreDb({
     this.nfccode,
     this.datetime,
     this.verso,
     this.motivazione,
  });
  String nfccode;
  DateTime datetime;
  String verso;
  String motivazione;
  factory ValoreDb.fromJson(Map<String, dynamic> json) => ValoreDb(
        nfccode: json["nfccode"] ?? "",
        datetime: DateTime.parse(json["DATETIME"]) ?? DateTime.now(),
        verso: json["VERSO"] ?? "",
        motivazione: json["motivazione"] ?? "",
      );
  Map<String, dynamic> toJson() => {
        "nfccode": nfccode,
        "datetime": datetime,
        "verso": verso,
        "motivazione": motivazione,
      };
}
