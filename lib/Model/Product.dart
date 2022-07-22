import 'dart:convert';

Products productsFromJson(String str) => Products.fromJson(json.decode(str));

String productsToJson(Products data) => json.encode(data.toJson());

class Products {
    String id;
    String matricola;
    String data;
    String quantity;
    String product;
    String foto;
    String audio;
    String note;
    String cantiere;

  Products({
     this.id,
     this.matricola,
     this.data,
     this.quantity,
     this.product,
     this.foto,
     this.audio,
     this.note,
     this.cantiere
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
        id: json["id"],
        matricola: json["matricola"],
        data: json["data"],
        quantity: json["quantity"],
        product: json["product"],
        foto: json["foto"],
        audio: json["Audio"],
        note: json["note"],
        cantiere: json["cantiere"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "matricola": matricola,
        "data": data,
        "quantity": quantity,
        "product": product,
        "foto": foto,
        "Audio": audio,
        "note": note,
        "cantiere": cantiere
      };
}
