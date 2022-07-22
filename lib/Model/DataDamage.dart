import 'dart:convert';
DataDamage dataDamageFromJson(String str) =>
    DataDamage.fromJson(json.decode(str));
String dataDamageToJson(DataDamage data) => json.encode(data.toJson());
class DataDamage {
  DataDamage({
     this.id,
     this.tipo,
     this.email,
     this.sottotipo,
  });
  int id;
  String tipo;
  String email;
  String sottotipo;
  factory DataDamage.fromJson(Map<String, dynamic> json) => DataDamage(
        id: json["Id"],
        tipo: json["tipo"],
        email: json["email"],
        sottotipo: json["sottotipo"],
      );
  Map<String, dynamic> toJson() => {
        "Id": id,
        "Tipo": tipo,
        "email": email,
        "sottotipo": sottotipo,
      };
}
