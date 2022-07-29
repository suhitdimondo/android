class AuthUser {
  int USER_ID= 0;
  String NAME ="";
  String PASSWORD = "";
  int MOB_ATT_ENABLED  = 0;
  int GPS_MANDATORY = 0;
  int DELETED = 0;
  int DISABLED = 0;
  int SKIPLOGIN = 0 ;
  String BASEURL = "";
  int getUSER_ID() {
    return USER_ID;
  }
  void setUSER_ID(int USER_ID) {
    this.USER_ID = USER_ID;
  }
  String getNAME() {
    return NAME;
  }
  void setNAME(String NAME) {
    this.NAME = NAME;
  }
  String getPASSWORD() {
    return PASSWORD;
  }
  void setPASSWORD(String PASSWORD) {
    this.PASSWORD = PASSWORD;
  }
  int getDELETED() {
    return DELETED;
  }
  void setDELETED(int DELETED) {
    this.DELETED = DELETED;
  }
  int getDISABLED() {
    return DISABLED;
  }
  void setDISABLED(int DISABLED) {
    this.DISABLED = DISABLED;
  }
  int getMOB_ATT_ENABLED() {
    return MOB_ATT_ENABLED;
  }
  void setMOB_ATT_ENABLED(int MOB_ATT_ENABLED) {
    this.MOB_ATT_ENABLED = MOB_ATT_ENABLED;
  }
  int getGPS_MANDATORY() {
    return GPS_MANDATORY;
  }
  void setGPS_MANDATORY(int GPS_MANDATORY) {
    this.GPS_MANDATORY = GPS_MANDATORY;
  }
  int getSKIPLOGIN() {
    return SKIPLOGIN;
  }
  void setSKIPLOGIN(int SKIPLOGIN) {
    this.SKIPLOGIN = SKIPLOGIN;
  }
  String getBASEURL() {
    return BASEURL;
  }
  void setBASEURL(String BASEURL) {
    this.BASEURL = BASEURL;
  }
}
