import 'dart:async';

import 'package:flutter/material.dart';
import 'package:refapp/generale.dart';
import 'package:refapp/serviziSicurezza.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:refapp/enums.dart';

class Sinfonia extends StatefulWidget {
  const Sinfonia({super.key});

  @override
  State<Sinfonia> createState() => SinfoniaState();
}

class SinfoniaState extends State<Sinfonia> {
  late final WebViewController _controller;

  bool isLoading = true;
  bool connessionePresente = true;

  final _pageLoaded = Completer<void>();

  final completer = Completer<Map<String, String>>(); //Completer per le credenziali da leggere con JS

  Map<String, String?> credenziali = {};

  @override
  void initState() {
    super.initState();

    initStateAsync();
  }

  Future <void> initStateAsync() async
  {
    connessionePresente = await Generale.verificaConnessione();
    setState(() {
      connessionePresente;
    });

    //Eseguo altre operazioni solo se c'è internet
    if (connessionePresente == true)
    {
      await caricaWeb();

      //Vado a premere il pulsante nel caso ce ne fosse bisogno
      await _pageLoaded.future;
      //Premo il pulsante dell'informativa nel caso ci sia
      await _controller.runJavaScript
      (
        "document.querySelector('.ui-dialog-buttonset .ui-button').click();"
      );

      await prendiInserisciCred(); 
    }
    
  }

  Future <void> prendiInserisciCred() async
  {
    //Verifico se l'utente si è già espresso per la gestione della psw
    PermessoPsw sceltaUtente = await ServiziSicurezza.sceltaUtente();
    if (sceltaUtente == PermessoPsw.no)
    {
      sceltaUtente = await permessoPsw();

      //Salvo questa scelta
      ServiziSicurezza.cambiaSceltaUtente(sceltaUtente);
    }

    //Ora conoscendo la scelta dell'utente che salvo, vado o meno ad attendere il suo inserimento
    if (sceltaUtente == PermessoPsw.si)
    {
      //Vado a prendere le psw se esistono ed in caso le inserisco, altrimenti attendo il loro inserimento
      bool credenzialiEsistono = await ServiziSicurezza.esistono();

      if (credenzialiEsistono == false)
      {
        print("Credenziali Non");
        //Attendo il loro inserimento
        credenziali = await prendiCredenziali();
        print("Credenziali Non: $credenziali");

        //Salvo le credenziali prese, dopo aver controllato che ci siano
        if (credenziali["usr"] != "" && credenziali["psw"] != "")
        {
          //Salvo le credenziali
          ServiziSicurezza.salva(credenziali["usr"] ?? "", credenziali["psw"] ?? "");
        }
      }else
      {
        print("Credenziali Si");
        //Attendo un'autenticazione
        final auth = await ServiziSicurezza.autenticaUtente();

        if (auth == RisAutenticazione.si || auth == RisAutenticazione.nonPresente)
        {
          Generale.retryAuth.value = false;
          //Vado ad inserire le credenziali presenti
          //Prendo le credenziali
          credenziali = await ServiziSicurezza.leggi();

          //Aspetto che la pagina sia caricata
          await _pageLoaded.future;

          //Inserisco le credenziali all'interno del sito
          await _controller.runJavaScript('''
            document.querySelector('input[name="username"]').value = "${credenziali["username"]}";
            document.querySelector('input[type="password"]').value = "${credenziali["password"]}";
            document.querySelector('input[type="submit"]').click();
          ''');
        }else
        {
          //Mostro un pulsante per riprovare
          Generale.retryAuth.value = true;

          //Esco dalla pagina / Faccio il logout
          await _controller.loadRequest(Uri.parse("https://servizi.aia-figc.it/sinfonia4you/area_sistema/system_logout/default.asp?action=logout"));

          //Attendo qualche millisecondo
          await Future.delayed(Duration(milliseconds: 300));

          //Torno alla home page
          await _controller.loadRequest(Uri.parse("https://servizi.aia-figc.it/sinfonia4you/"));
        }

        
      }
    }
  }

  Future <Map<String, String>> prendiCredenziali () async
  {
    //Completer per attendere che l'utente faccia login
    await _pageLoaded.future; // aspetta che onPageFinished venga chiamato
    
    //Vado a prendere le credenziali da S4Y
    //Utilizzo un canale per ricevere i dati

    //Inietto per intercettare il login

    // Inietta JS per intercettare il submit del form
    
    await _controller.runJavaScript('''
      document.querySelector('form').addEventListener('submit', function() {
        var username = document.querySelector('input[type="text"], input[name="username"], input[name="email"]').value;
        var password = document.querySelector('input[type="password"]').value;
        CredentialChannel.postMessage(username + '|||' + password);
      });
    ''');

    return completer.future;
  } 

  Future <PermessoPsw> permessoPsw () async
  {
    try
    {
      //Aspetto che la pagina venga caricata
      await _pageLoaded.future;

      PermessoPsw salva = PermessoPsw.no;
      //Richiedo all'utente se è possibile salvare le password
      await showDialog
      (
        barrierDismissible: false, //Se l'utente preme fuori, non toglie il dialog
        context: context,
        builder: (_) => 
        AlertDialog
        (
          title: Text("Salvare le credenziali?"),
          content: Text(
            'Vuoi che l\'app ricordi username e password per accedere '
            'automaticamente la prossima volta?\n\n'
            'Le credenziali verranno salvate solo su questo dispositivo '
            'in modo cifrato e non saranno mai condivise.'
          ),
          actions: [
            TextButton
            (
              onPressed: () 
              {
                //No e non faccio richiedere
                salva = PermessoPsw.mai;
                Navigator.pop(context); 
              }, 
              child: Text('Non chiedere più')
            ),
            TextButton(onPressed: () {
              salva = PermessoPsw.no;
              Navigator.pop(context);
            } , child: Text('No')),
            TextButton
            (
              onPressed: () 
              {
                //Permetto di salvare le credenziali
                salva = PermessoPsw.si;
                Navigator.pop(context); 
              }, 
              child: Text('Sì')
            ),
          ],
        )
      );

      return salva;
    }catch(e)
    {
      //In caso di errore
      return PermessoPsw.no;
    }
    
  }

  Future<void> caricaWeb() async
  {
    print("Carica Web");
    //Carico Web all'inizio e non inietto niente
    try
    {
      _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel
      (
        'CredentialChannel',
          onMessageReceived: (message) async 
          {
            print("Messaggio: $message");
            final parts = message.message.split('|||');
            if (parts.length == 2) {
              //Ottenuti i dati del login, li vado a salvare
              print("Dati Trovati");
              completer.complete
              (
                {
                  "usr": parts[0],
                  "psw": parts[1]
                }
              );
            }
          },
      )
      ..setNavigationDelegate
      (
        NavigationDelegate(
          onPageFinished: (url) {
            if (! _pageLoaded.isCompleted)
            {
              _pageLoaded.complete();
            }else
            {
              //Verifico che l'utente non carichi altre pagine al di fuori di S4Y
              if (! url.contains("servizi.aia-figc.it"))
              {
                //Torno al sito principale
                _controller.loadRequest(Uri.parse("https://servizi.aia-figc.it/sinfonia4you/"));
                //Mostro il messaggip
                ScaffoldMessenger.of(context).showSnackBar
                (
                  SnackBar
                  (
                    content: Text("Attenzione: Non è possibile uscire da S4Y"),
                    duration: Duration(seconds: 5),
                    backgroundColor: Colors.amber,
                  )
                );
              }
            }
           
            setState(() {
              isLoading = false;
            });
          },
        )
      )
      ..loadRequest(Uri.parse("https://servizi.aia-figc.it/sinfonia4you/"));
    }catch(e)
    {
      //In caso di errore
      print("Errore");
    }
    
    
  }

  @override
  Widget build(BuildContext context) {
    //Pagina che riprende servizio web che mostra sinfonia4you
    return
    connessionePresente == true
    ? 
    isLoading == true
    ?
    Center
    (
      child: 
      SizedBox
      (
        width: 50, 
        height: 50,
        child: 
        CircularProgressIndicator
        (
          color: Color(0xFFF26B6B),
        )
      )
    )
    :
    WebViewWidget(controller: _controller)
    :
    //Non c'è connessione internet
    Center
    (
      child: 
      SizedBox
      (
        width: 100,
        height: 100,
        child: 
        Column
        (
          children: 
          [
            Icon(Icons.warning_outlined),
            Text("Connessione Internet Assente")
          ],
        )
      )
    );
  }
}