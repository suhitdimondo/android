import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'preferenze.dart';
import 'package:encrypt/encrypt.dart' as enc;
class Common {
  static final String appName = "HRPlanner";
  static final String rememberString = "Ricorda i dati di accesso";
  static final String loginBtnLabel = "LOGIN";
  static final String usernamePlaceHolder = "Username";
  static final String passwordPlaceHolder = "Password";
  static final String urlPlaceHolder =
      "http://backendflutterapps.winitsrl.eu:81";
  static final String instanceCode = "Seleziona Codice Istanza";
  static final String logo = "assets/hrplanner.png";
  static final String gpsNote = "Attivare il GPS per effettuare una timbratura";
  static final String TimbraturaGPSBtnLabel = "Timbratura GPS";
  static final String TimbraturaNFCBtnLabel = "Timbratura NFC";
  static final String AcquisizioneManualeBtnLabel = "Acquisizione Manuale";
  static final String AcquisizioneNFCBtnLabel = "Acquisizione NFC";
  static final String AcquisizioneGPSBtnLabel = "Acquisizione GPS";
  static final String AcquisizioneQRCodeBtnLabel = "Acquisizione QRCode";
  static final String AcquisizioniBtnLabel = "Consulta Acquisizioni";
  static final String TimbratureBtnLabel = "Vedi";
  static final String TimbratureBtnLabel2 = "CONSULTAZIONE TIMBRATURE";
  static final String AcquisizioniBtnLabel2 = "CONSULTAZIONE ACQUISIZIONI";
  static final String ExitBtnLabel = "Reset";
  static final String thereArePendingTimbs = "Ci sono dati non inviati!";
  static final String TimbratureGiornataLabel = "Timbrature Giornata";
  static final String TimbratureTableTipologia = "Tipologia";
  static final String TimbratureTableOra = "Ora";
  static final String TimbratureTableSede = "Sede";
  static final String TimbratureTableNoTimb = "Nessuna timbratura presente";
  static final String TimbratureTableTecnologia = "Tecnologia";
  static final String TimbratureLocalData = "TIMBRATURE NON INVIATE";
  static final String AcquisizioneLocalData = "ACQUISIZIONI NON INVIATE";
  static final String AcquisizioneTableLuogo = "Luogo";
  static final String AcquisizioneTableNoAcq = "Nessuna acquisizione presente";
  static final String TimbratureTableBack = "Indietro";
  static final String TimbratureTableIcon = "Seleziona il giorno";
  static final String timbratureModuleName = "TIMBRATURE";
  static final String acquisizioniModuleName = "ACQUISIZIONI";
  static final String ferieModuleName = "FERIE";
  static final String indennitaModuleName = "INDENNITA";
  static final String emptyModuleName = " ";
  static final String impostazioniModuleName = "IMPOSTAZIONI";
  static final IconData calendarioModuleIcon = Icons.credit_card;
  static final IconData acquisizioniModuleIcon = Icons.wifi;
  static final IconData ferieModuleIcon = Icons.airplanemode_active;
  static final IconData indennitaModuleIcon = Icons.attach_money;
  static final IconData emptyModuleIcon = Icons.apps;
  static final IconData impostazioniModuleIcon = Icons.apps;
  static final Color calendarioModuleColor = Colors.green;
  static final Color acquisizioniModuleColor = Colors.orange;
  static final Color ferieModuleColor = Colors.yellow;
  static final Color indennitaModuleColor = Colors.blue;
  static final Color emptyModuleColor = Colors.transparent;
  static final Color impostazioniModuleColor = Colors.grey;
  static final Color moduleBorderColor = Colors.white;
  static final double moduleRoundedCorner = 4.0;
  static final double moduleFontSize = 16.0;
  static final double moduleIconSize = 32.0;
  static final String timbratureManuali = "Timbrature";
  static final String timbratureManuali2 = "Manuali";
  static final String timbratureGps = "Timbrature";
  static final String timbratureGps2 = "GPS";
  static final String timbratureNfc = "Timbrature";
  static final String timbratureNfc2 = "NFC";
  static final String AcquisizioneManualeLabel = "ACQUISIZIONE MANUALE";
  static final String AcquisizioneManualeLuogoLabel = "Luogo *";
  static final String AcquisizioneManualeCausaleLabel = "Causale *";
  static final String AcquisizioneManualeNoteLabel = "Note";
  static final String AcquisizioneManualeInviaLabel = "Invia";
  static final String AcquisizioneQrCodeLabel = "ACQUISIZIONE QRCODE";
  static final String qrCodeWaitLabel = "Codice Rilevato";
  static final String GoBackLabel = "Indietro";
  static final String erroreAutenticazione = "QRCODE non valido!";
  static final IconData ta1Icon = Icons.credit_card;
  static final IconData ta2Icon = Icons.wifi;
  static final IconData ta3Icon = Icons.add_to_home_screen;
  static final IconData ta4Icon = Icons.attach_money;
  static final IconData ta5Icon = Icons.apps;
  static final IconData ta6Icon = Icons.airplanemode_active;
  static final Color ta1Color = Colors.green;
  static final Color ta2Color = Colors.orange;
  static final Color ta3Color = Colors.yellow;
  static final Color ta4Color = Colors.blue;
  static final Color ta5Color = Colors.brown;
  static final Color ta6Color = Colors.red;
  static final double BtnHeight = 40;
  static final double SpaceHeight = 25;
  static String normalizzaNFC(String exacode) {
    String destStr = "";
    if (exacode.toUpperCase().startsWith("0X")) {
      for (int i = 2; i < exacode.length; i++) {
        if (i % 2 == 0 && i > 2) {
          destStr += ":";
        }
        destStr += exacode[i];
      }
      return destStr;
    } else {
      return exacode;
    }
  }

  static IconData getModuleIcon(String moduleCode) {
    IconData icon;
    switch (moduleCode) {
      case "001":
        icon = ta1Icon;
        break;
      case "002":
        icon = ta2Icon;
        break;
      case "003":
        icon = ta3Icon;
        break;
      case "004":
        icon = ta4Icon;
        break;
      case "005":
        icon = ta5Icon;
        break;
      case "006":
        icon = ta6Icon;
        break;
      default:
        icon = ta6Icon;
        break;
    }
    return icon;
  }
  static IconData getTipoAcquisizioneIcon(int tipoAcquisizione) {
    IconData icon;
    switch (tipoAcquisizione) {
      case 1:
        icon = ta1Icon;
        break;
      case 2:
        icon = ta2Icon;
        break;
      case 3:
        icon = ta3Icon;
        break;
      case 4:
        icon = ta4Icon;
        break;
      case 5:
        icon = ta5Icon;
        break;
      case 6:
        icon = ta6Icon;
        break;
      default:
        icon = ta6Icon;
        break;
    }
    return icon;
  }
  static Color getModuleColor(String moduleCode) {
    Color color;
    switch (moduleCode) {
      case "001":
        color = ta1Color;
        break;
      case "002":
        color = ta2Color;
        break;
      case "003":
        color = ta3Color;
        break;
      case "004":
        color = ta4Color;
        break;
      case "005":
        color = ta5Color;
        break;
      case "006":
        color = ta6Color;
        break;
      default:
        color = ta6Color;
        break;
    }
    return color;
  }
  static Color getTipoAcquisizioneColor(int tipoAcquisizione) {
    Color color;
    switch (tipoAcquisizione) {
      case 1:
        color = ta1Color;
        break;
      case 2:
        color = ta2Color;
        break;
      case 3:
        color = ta3Color;
        break;
      case 4:
        color = ta4Color;
        break;
      case 5:
        color = ta5Color;
        break;
      case 6:
        color = ta6Color;
        break;
      default:
        color = ta6Color;
        break;
    }
    return color;
  }
  static String getAcquisizioneReadApi(int tipoAcquisizione) {
    String method;
    switch (tipoAcquisizione) {
      case 1:
        method = Preferenze.gettimbrature_url_webservice;
        break;
      default:
        method = Preferenze.getacquisizioni_url_webservice;
        break;
    }
    return method;
  }
  static String getDecryptedStr(String coded) {
    final key = enc.Key.fromUtf8(Preferenze.aeskey);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
    final iv = IV.fromUtf8(Preferenze.aesiv);
    final Encrypted encoded = Encrypted.fromBase64(coded);
    final decrypted = encrypter.decrypt(encoded, iv: iv);
    return decrypted.toString();
  }
}
enum Modules { NONE, GPS, NFC, QRCODE, INDENNITA, FERIE, UNKNOWN }
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
