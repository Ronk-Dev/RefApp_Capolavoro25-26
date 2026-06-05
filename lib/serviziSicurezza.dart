//Servizi di sicurezza per mantenimento dati psw e utente Sinfonia4You
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:refapp/enums.dart';
import 'package:local_auth/local_auth.dart';

class ServiziSicurezza 
{
  static const _storage = FlutterSecureStorage(); //Storage che include i dati al sicuro

  static const _keyUsername = 'username';
  static const _keyPassword = 'password';

  //Salvo le credenziali
  static Future<void> salva (String usr, String psw) async
  {
    await _storage.write(key: _keyUsername, value: usr);
    await _storage.write(key: _keyPassword, value: psw);
  }

  //Leggo le credenziali
  static Future<Map<String, String?>> leggi () async
  {
    return 
    {
      "username": await _storage.read(key: _keyUsername),
      "password": await _storage.read(key: _keyPassword)
    };
  }

  //Verifico se esistono le credenziali
  static Future<bool> esistono () async
  {
    final usr = await _storage.read(key: _keyUsername);
    if (usr != null)
    {
      return true;
    }

    //Altrimenti ritorno false
    return false;
  }

  //Verifico quale è stata la scelta dell'utente
  static Future<PermessoPsw> sceltaUtente () async
  {
    final prefs = await SharedPreferences.getInstance();
    PermessoPsw scelta = PermessoPsw.values[prefs.getInt("sceltaUtentePsw") ?? 1]; //In caso in cui non ci sia nulla imposto no, cosi che andra a richiedere
  
    return scelta;
  }

  static Future<void> cambiaSceltaUtente(PermessoPsw scelta) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("sceltaUtentePsw", scelta.index);
  }

  static Future<RisAutenticazione> autenticaUtente() async
  {
    try
    {
      final LocalAuthentication auth = LocalAuthentication();
      //Faccio autenticare l'utente tramite pin o biometria
      final bool disponibile = await auth.canCheckBiometrics;
      if (! disponibile)
      {
        return RisAutenticazione.nonPresente;
      }

      //Faccio Autenticale
      final risAuth = await auth.authenticate
      (
        localizedReason: "Autenticati per accedere a S4Y",
        persistAcrossBackgrounding: false,
        biometricOnly: false
      );

      if (risAuth == true)
      {
        return RisAutenticazione.si;
      }else
      {
        return RisAutenticazione.no;
      }
    }catch (e)
    {
      print("Errore: $e");
      return RisAutenticazione.errore;
    }
    
  }
}