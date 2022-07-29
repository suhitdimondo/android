import 'dart:convert';
Cantiere activitiesFromJson(String str) =>
    Cantiere.fromJson(json.decode(str));
String activities(Cantiere data) => json.encode(data.toJson());
class Cantiere {
  Cantiere({
     this.tag,
     this.descrizione,
     this.nfc,
     this.date,
     this.time,
     this.fissa
  });
  String tag;
  String descrizione;
  String nfc;
  String date;
  String time;
  String fissa;
  factory Cantiere.fromJson(Map<String, dynamic> json) => Cantiere(
    tag: json["TagCan"],
    descrizione: json["DescrizioneCan"],
    nfc: json["nfc"],
    date: json["date"],
    time: json["time"],
    fissa: json["fissa"]
  );
  Map<String, dynamic> toJson() => {
    "Tag": tag,
    "DescrizioneCan": descrizione,
    "nfc": nfc,
    "date": date,
    "time": time,
    "fissa": fissa
  };
}
