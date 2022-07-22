import 'dart:convert';
Activities activitiesFromJson(String str) =>
    Activities.fromJson(json.decode(str));
String activities(Activities data) => json.encode(data.toJson());
class Activities {
  Activities({
     this.codice,
     this.descrizione,
  });
  String codice;
  String descrizione;
  factory Activities.fromJson(Map<String, dynamic> json) => Activities(
        codice: json["CodiceAtt"],
        descrizione: json["DescrizioneAtt"],
      );
  Map<String, dynamic> toJson() => {
        "CodiceAtt": codice,
        "DescrizioneAtt": descrizione,
      };
}
