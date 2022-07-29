class Timbratura {
  int id;
  int user_id;
  String dateTime;
  String verso;
  String latitude;
  String longitude;
  int imported;
  String valore_acquisizione;
  String tipo_acquisizione;
  int getId() {
    return id;
  }
  void setId(int id) {
    this.id = id;
  }
  int getUser_id() {
    return user_id;
  }
  void setUser_id(int user_id) {
    this.user_id = user_id;
  }
  String getDateTime() {
    return dateTime;
  }
  void setDateTime(String dateTime) {
    this.dateTime = dateTime;
  }
  String getVerso() {
    return verso;
  }
  void setVerso(String verso) {
    this.verso = verso;
  }
  String getLatitude() {
    return latitude;
  }
  void setLatitude(String latitude) {
    this.latitude = latitude;
  }
  String getLongitude() {
    return longitude;
  }
  void setLongitude(String longitude) {
    this.longitude = longitude;
  }
  int getImported() {
    return imported;
  }
  void setImported(int imported) {
    this.imported = imported;
  }
  void setValore_acquisizione(String valore_acquisizione) {
    this.valore_acquisizione = valore_acquisizione;
  }
  String getValore_acquisizione() {
    return valore_acquisizione;
  }
  void setTipo_acquisizione(String tipo_acquisizione) {
    this.tipo_acquisizione = tipo_acquisizione;
  }
  String getTipo_acquisizione() {
    return tipo_acquisizione;
  }
}
