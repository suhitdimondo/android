class Collaboratori{
  String id = "";
  String descrizione = "";
  String matricola = "";
  String IdCliente = "";
  String Descrizione = "";
  Collaboratori({ this.id,  this.descrizione,  this.matricola});
  Collaboratori.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    descrizione = json['descrizione'];
    matricola = json['matricola'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['descrizione'] = this.descrizione;
    data['matricola'] = this.matricola;
    return data;
  }
  factory Collaboratori.fromMap(Map<String, dynamic> data) => new Collaboratori(
      id: data['Id'],
      descrizione: data['descrizione'],
      matricola: data['matricola']
  );
}