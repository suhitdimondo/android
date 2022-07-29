class Preferenze {
//aes keys
  static final aeskey = 'upercut2k10upercut2k10upercut2k1';
  static final aesiv = '{{{{{{{{{{{{{{{{';

  static final String encryption_key = "0%k6P0Ijk7}E9Zv:SU*D]2?DZ+tK%a+)";

  // static final String checkauth_url_webservice  =  "/api/auth";
  // static final String gettimbrature_url_webservice  = "/api/timbrature";
  //static final String punch_url_webservice  = "/punch";
  static final String punch_url_webservice = "/appws/sendData";
  static final String CODE = "30010524";
  static final String HASH = "6ab52777977d172e51138d290a5b07740d1550";

  static final String host = "https://demo.timbrature.it";

  //"https://testapp.timbrature.it/app/ws"
  //static  final String host ="http://jlb.timbrature.it";
  // /app/ws/getDominiClienti
  // static  final String piattaformaTimbratureHost ="http://applibet.dev.jlbbooks.com";

  static String piattaformaTimbratureHost =
      /*"http://acquisitore.dev.jlbbooks.com/"*/ "http://backend.winitsrl.eu:81";
  static int Id;
  static String tipoIstanza = "";
  static int scheduledGPS = 0;
  static int gps = 1;
  static int intervallo = 0;
  static int inOutPref = 1;
  static int activities = 0;
  static int segnalazioniCount = 0;
  static int rip = -1;
  static int gpsoff = 0;
  static int eventi = 0;
  static int registrazioni = 0;
  static double long;
  static double lat;
  static int nuovo = 0;
  static int save = 0;
  static int clock = 0;
  static int segnalazioni = 0;
  static int attObl = 0;
  static int multiAtt = 0;
  static int simpleGps = 0;
  static int raggio = 0;
  static String nomeSocieta = "";
  static double rigthlong;
  static double rigthlat;
  static String logo = "";
  static int invioAutomatico = 0;
  static int doppiaTimbratura = 0;
  static int intervalloDoppia = 0;
  static int pausaPranzo = 0;
  static int pulsanteTimbra = 0;
  static int Squadra = 0;
  static int abilSquadra = 0;
  static int ClienteId = 0;
  static int Cantieri = 0;
  //  "https://testapp.timbrature.it";
  //"http://piattaforma_timbrature_server.loc";
  //    "http://192.168.0.18";

  static final String getDominiClientiService = "/app/ws/getDominiClienti";
  static final String checkauth_url_webservice = "app/ws/checkAuthService";
  static final String getconfigurazione_url_webservice =
      "/app/ws/getConfigurazione";
  static final String sendData_url_webservice = "/app/ws/sendData";
  static final String gettimbrature_url_webservice = "/app/ws/readTimbrature";
  static final String getacquisizioni_url_webservice =
      "/app/ws/readAcquisizioni";
  static final String getTipologiaAcquisizioniService =
      "/app/ws/getTipologiaAcquisizioni";
  static final String getEventi_url_webservice = "/app/ws/Eventi";
  static final String getCustomization_url_webservice = "/app/ws/Customization";
  static final String getDataDamage_url_webservice = "/app/ws/Segnalazioni";
  static final String getActivity_url_webservice = "/app/ws/Attivita";
  static final String getLicenza_url_webservice = "/app/ws/Licenza";
  static final String sendDamage_url_webservice = "app/ws/sendSegnalazioni";

  static final String has2UpdateConf_url_webservice = "/app/ws/has2UpdateConf";
  static final String getTimbrature_url_webservice = "/app/ws/readTimbrature";

  static final String getTecnologieTipologieService =
      "/app/ws/getTecnologieTipologie";
  static final String getCantiereService =
      "/app/ws/getCantiere";
}
