import 'dart:convert';
Eventi eventiFromJson(String str) => Eventi.fromJson(json.decode(str));
String eventiToJson(Eventi data) => json.encode(data.toJson());
class Eventi {
  Eventi({
     this.codice,
     this.evento,
     this.tipoIntestatario,
     this.cantiere,
  });
  String codice;
  String evento;
  String tipoIntestatario;
  String cantiere;
  factory Eventi.fromJson(Map<String, dynamic> json) => Eventi(
        codice: json["Codice"],
        evento: json["Evento"],
        tipoIntestatario: json["Tipo_Intestatario"],
        cantiere: json["Cantiere"],
      );
  Map<String, dynamic> toJson() => {
        "Codice": codice,
        "Evento": evento,
        "Tipo_Intestatario": tipoIntestatario,
        "Cantiere": cantiere,
      };
}
