import 'dart:convert';
Licence eventiFromJson(String str) => Licence.fromJson(json.decode(str));
String eventiToJson(Licence data) => json.encode(data.toJson());
class Licence {
  Licence({
     this.end,
  });
  DateTime end;
  factory Licence.fromJson(Map<String, dynamic> json) => Licence(
        end: json["DataScadenza"],
      );
  Map<String, dynamic> toJson() => {
        "DataScadenza": end,
      };
}
