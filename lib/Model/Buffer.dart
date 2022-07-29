import 'dart:convert';
Buffer activitiesFromJson(String str) =>
    Buffer.fromJson(json.decode(str));
String activities(Buffer data) => json.encode(data.toJson());
class Buffer {
  Buffer({
    this.id,
    this.quantity,
    this.product
  });
  int id;
  String quantity;
  String product;
  factory Buffer.fromJson(Map<String, dynamic> json) => Buffer(
      id: json["id"],
      quantity: json["quantity"],
      product: json["product"]
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "product": product
  };
}
