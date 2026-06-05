import 'dart:ffi';

import 'package:refapp/enums.dart';
import 'package:refapp/notificaLocale.dart';

import 'screens/Sinfonia.dart';
import 'package:flutter/material.dart';
import 'package:refapp/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Generale 
{
  //Classe Generale con tutte le variabili / metodi da usare nel programma
  // In un file condiviso, es. generale.dart

  static final OutlineInputBorder bordoForms = 
  OutlineInputBorder
  (
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide
    (
      color: Color(0xFFC4E1F2),
      width: 1
    )
  );

  static final OutlineInputBorder bordoFormsFocus = 
  OutlineInputBorder
  (
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide
    (
      color: Color(0xFF4994ec),
      width: 2
    )
  );

  static final GlobalKey<SinfoniaState> sinfoniaKey = GlobalKey<SinfoniaState>();

  static ValueNotifier<List<String>> societaConosciute = ValueNotifier(["jesina", "aurora"]);

  static ValueNotifier<List<Evento>> eventi = ValueNotifier([]);
  static ValueNotifier<List<Nota>> note = ValueNotifier([]);

  static ValueNotifier<bool> retryAuth = ValueNotifier(false);

  static void prendiSocietaOnline()
  {
    //Vado a prendere le società dal database online
  }

  static void nuovaSocietaConosciuta (String nomeSocieta) async
  {
    //Vado a salvare la nuova società
    //La inserisco nel database locale 
    final db = await DatabaseHelper.instance.database;

    await db.insert("societa", {"nome": nomeSocieta});

    //Faccio richiesta per inserimento online
  }

  //Vado a trovare le posizioni degli elementi "papabili"
  static List<int> trovaElementi (String testoRicerca, List<String> listaElementi)
  {
    List<int> posizioniTrovate = [];
    for(int i = 0; i < listaElementi.length; i++)
    {
      //Se è presente la parola/e cercate
      if (listaElementi[i].toLowerCase().contains(testoRicerca.toLowerCase()) || testoRicerca.toLowerCase().contains(listaElementi[i].toLowerCase()))
      {
        print("Posizioni: ${listaElementi[i]} $i");
        posizioniTrovate.add(i);
      }
    }

    //Ritorno la lista degli elementi trovati
    return posizioniTrovate;
  }

  //Elementi visibili nel menù per scegliere l'evento (ATTENZIONE, la stringa è collegata ad altri controlli, PRESTARE ATTENZIONE A MODIFICARE)
  static List<String> elementiEventi = 
  [
    "Partita",
    "RTO",
    "Allenamento",
    "Designazioni",
    "Raduno",
    "Manifestazione",
    "Altro"
  ];

  //Lista Categorie in Italia
  static List<String> categorie =
  [
    "U13 M",
    "U13 F",
    "U15 M",
    "U15 F",
    "U17 M",
    "U17 F",
    "U19 M",
    "U19 F",
    "Primavera 2 M",
    "Primavera 2 F",
    "Primavera 1 M",
    "Primavera 1 F",
    "3° Categoria",
    "2° Categoria",
    "1° Categoria",
    "Promozione",
    "Eccellenza M",
    "Eccellenza F",
    "Serie D",
    "Serie C M",
    "Serie C F",
    "Serie B M",
    "Serie B F",
    "Serie A M",
    "Serie A F",
    "Torneo Giovanile",
    "Torneo Regionale/Provinciale",
    "Torneo Nazionale",
    "Competizione Internazionale"
  ];

  static String convertiData (DateTime dataSelezionata)
  {
    //Vado a prendere la data selezionata e la converto in stringa tipo "05-01-2026"
    String data = "";
    data += dataSelezionata.day > 10 ? dataSelezionata.day.toString() : "0${dataSelezionata.day}";
    data += "-";
    data += dataSelezionata.month > 10 ? dataSelezionata.month.toString() : "0${dataSelezionata.month}";
    data += "-";
    data += dataSelezionata.year.toString();

    //Ritorno la data completa
    return data;
  }

  static DateTime convertiDateTime (String data)
  {
    final parts = data.split("-");
    DateTime dataFinale = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));

    return dataFinale;
  }

  static String convertiOrario(TimeOfDay orarioSelezionato) {
    final ore = orarioSelezionato.hour >= 10  // 👈 >= invece di >
        ? orarioSelezionato.hour.toString()
        : '0${orarioSelezionato.hour}';

    final minuti = orarioSelezionato.minute >= 10  // 👈 >= invece di >
        ? orarioSelezionato.minute.toString()
        : '0${orarioSelezionato.minute}';

    return '$ore:$minuti';
  }

  static TimeOfDay convertiTime (String time)
  {
    final parts = time.split(":");
    TimeOfDay dataFinale = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    return dataFinale;
  }

  static String creaStringaDaLista (List? lista)
  {
    //Vado a prendere una lista e la trasformo in stringa con a separazione delle ', '
    String stringa = "";

    for(int i = 0; i < lista!.length; i++)
    {
      stringa += lista[i] == false ? "0" : "1";
      stringa += ", ";
    }

    //Ritorno la stringa fatta
    return stringa;
  }

  static List<bool> creaListaDaStringa (String stringa)
  {
    //Vado a prendere la stringa e la traformo in lista
    final parti = stringa.split(", ");

    List<bool> lista = [];

    //Aggiungo alla lista definitiva
    for (var i = 0; i < parti.length - 1; i++) {
      lista.add(parti[i].contains("1") ? true : false);
    }

    return lista;
  }

  static Evento recuperaEvento(var riga)
  {    
    return Evento
    (
      id:             riga["id"],
      tipologia:      riga["tipologia"], 
      orario:         riga["orario"],
      data:           riga["data"],
      luogo:          riga["luogo"],
      desc:           riga["descrizione"],
      periodicita:    creaListaDaStringa(riga["periodicita"]),
      catPartita:     riga["catPartita"],
      giorniReferto:  riga["giorniReferto"] != null ? (riga["giorniReferto"] as double).toInt() : null,
      sqCasa:         riga["sqCasa"],
      rimborsoSpese:  riga["rimborso"],
      pacco:          riga["pacco"] != null ? (riga["pacco"] as double).toInt() : null,
      sqOspite:       riga["sqOspiti"]
    );
  }

  static List<GiorniSettimana> prendiGiorniDaBool(List<bool> listaGiorni)
  {
    List<GiorniSettimana> listaGiornate = [];
    //Prendo i giorni della settimana dai booleani
    for (var i = 0; i < listaGiorni.length; i++) 
    {
      if (listaGiorni[i] == true)
      {
        listaGiornate.add(GiorniSettimana.values[i]);
      }
    }

    //Ritorno la nuova lista
    return listaGiornate;
  }

  static void prendiEventi () async
  {
    //Vado a prendere gli eventi dal mio database
    final db = await DatabaseHelper.instance.database;

    List<Map<String, dynamic>> rows = await db.query('eventi');

    //Recupero ciascun evento verificandolo
    for(var row in rows)
    {
      //Vado a salvare nella lista eventi
      eventi.value.add(recuperaEvento(row));
    }

    for (var element in eventi.value) {
      print("Elemento: ${element.data}");
    }
  }

  static void eliminaEvento (Evento evento) async
  {
    //Vado ad eliminare l'evento nella data richiesta
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'eventi',
      where: 'id = ?',
      whereArgs: [evento.id],
    );
    //Ho eliminato il mio evento

    //Rimuovo l'evento anche dalla variabile lista
    eventi.value.remove(evento);

    //Elimino anche le notifiche
    await NotificaLocale.cancella(evento.id ?? -1);
  }

  static void eliminaNota (Nota nota) async
  {
    //Vado ad eliminare l'evento nella data richiesta
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      'note',
      where: 'id = ?',
      whereArgs: [nota.id],
    );
    //Ho eliminato il mio evento

    //Rimuovo l'evento anche dalla variabile lista
    note.value.remove(nota);
  }

  static void aggiungiEvento (Evento evento) async 
  {
    //Vado ad aggiungere l'evento al db locale ed a quello online
    final db = await DatabaseHelper.instance.database;

    //Prendo il numero di pacco a seconda del mese
    int pacco = 10;

    //Vado ad aggiungere i dati
    await db.insert
    (
      'eventi',
      {
        'tipologia':     evento.tipologia,
        'data':          evento.data,
        'orario':        evento.orario,
        'luogo':         evento.luogo,
        'descrizione':   evento.desc,
        'periodicita':   creaStringaDaLista(evento.periodicita),
        'sqCasa':        evento.sqCasa,
        'sqOspiti':      evento.sqOspite,
        'giorniReferto': evento.giorniReferto,
        'catPartita':    evento.catPartita,
        'rimborso':      evento.rimborsoSpese,
        'pacco':         pacco,
        'presenteOnline': 0, //Vado in automatico a dire che non è presente, modificare in caso di aggiunta
      },
    );

    var nuovoEvento = 
    Evento
    (
      id: eventi.value.length > 0 ? eventi.value[eventi.value.length - 1].id! + 1 : 0,
      orario: evento.orario,
      tipologia: evento.tipologia,
      catPartita: evento.catPartita,
      data: evento.data,
      desc: evento.desc,
      giorniReferto: evento.giorniReferto,
      luogo: evento.luogo,
      pacco: evento.pacco,
      periodicita: evento.periodicita,
      rimborsoSpese: evento.rimborsoSpese,
      sqCasa: evento.sqCasa,
      sqOspite: evento.sqOspite
    );

    //Vado ad aggiornare la lista delle note
    eventi.value.add(nuovoEvento);

    //Inserisco una notifica per la data dell'evento
    if (evento.data != "")
    {
      await NotificaLocale.schedula(
        id: nuovoEvento.id ?? -1,
        titolo: nuovoEvento.tipologia,
        corpo: 'Hai un evento il ${nuovoEvento.data} alle ${nuovoEvento.orario}',
        quando: diventaOrario(nuovoEvento.data ?? "", nuovoEvento.orario).subtract(const Duration(days: 1)), // notifica 1 giorno prima
      );

      await NotificaLocale.schedula(
        id: nuovoEvento.id ?? -1,
        titolo: nuovoEvento.tipologia,
        corpo: 'Hai un evento il ${nuovoEvento.data} alle ${nuovoEvento.orario}',
        quando: diventaOrario(nuovoEvento.data ?? "", nuovoEvento.orario).subtract(const Duration(hours: 3)), // notifica 3 ore prima
      );
    }

    if (evento.tipologia == "Partita")
    {
      int giorni = nuovoEvento.giorniReferto ?? 0;
      if (giorni != 0)
      {
        //Invio notifica per il referto
        await NotificaLocale.schedula(
          id: nuovoEvento.id ?? -1,
          titolo: "Referto",
          corpo: 'Hai un referto da compilare della partita ${nuovoEvento.sqCasa} - ${nuovoEvento.sqOspite}',
          quando: diventaOrario(nuovoEvento.data ?? "", nuovoEvento.orario).add(Duration(days: giorni)), // notifica 3 ore prima
        );
      }
      
    }
  }

  static DateTime diventaOrario (String data, String ora)
  {
    //Vado a trasformare data e ora stringa in DateTime
    final nuovaData = convertiDateTime(data);
    final nuovoOrario = convertiTime(ora);

    final finalData = nuovaData.copyWith(
      hour: nuovoOrario.hour,
      minute: nuovoOrario.minute,
    );

    return finalData;
  }

  static void aggiungiNota (Nota nota) async 
  {
    //Vado ad aggiungere l'evento al db locale ed a quello online
    final db = await DatabaseHelper.instance.database;

    //Vado ad aggiungere i dati
    await db.insert
    (
      'note',
      {
        'tipologia':     nota.personaFinale,
        'nominativo':    nota.nomePersona,
        'nota':          nota.nota,
        'amm':           nota.ammonito ? 1 : 0,
        'esp':           nota.espulso ? 1 : 0,
        'presenteOnline': 0, //Vado in automatico a dire che non è presente, modificare in caso di aggiunta
      },
    );

    var nuovaNota = 
    Nota
    (
      personaFinale: nota.personaFinale, 
      ammonito: nota.ammonito, 
      espulso: nota.espulso,
      //In questo caso assegno io un id considerando il più "nuovo" precedente
      id: note.value.length > 0 ? note.value[note.value.length - 1].id! + 1 : 0,
      nomePersona: nota.nomePersona,
      nota: nota.nota
    );

    //Vado ad aggiornare la lista delle note
    note.value.add(nuovaNota);
  }

  static void modificaNota (Nota nota) async 
  {
    //Vado ad aggiungere l'evento al db locale ed a quello online
    final db = await DatabaseHelper.instance.database;

    //Vado ad aggiungere i dati
    await db.update
    (
      'note',
      {
        'tipologia':     nota.personaFinale,
        'nominativo':    nota.nomePersona,
        'nota':          nota.nota,
        'amm':           nota.ammonito ? 1 : 0,
        'esp':           nota.espulso ? 1 : 0,
        'presenteOnline': 0, //Vado in automatico a dire che non è presente, modificare in caso di aggiunta
      },
      where: "id = ?",
      whereArgs: [nota.id]
    );

    //Vado ad aggiornare la lista degli eventi in cui è già presente
    for (var element in note.value) {
      if (element.id == nota.id)
      {
        //Sostituisco
        element = nota;
      }
    }
  }

  static void modificaEvento (Evento evento) async 
  {
    //Vado ad aggiungere l'evento al db locale ed a quello online
    final db = await DatabaseHelper.instance.database;

    //Prendo il numero di pacco a seconda del mese
    int pacco = 10;

    //Vado ad aggiungere i dati
    await db.update
    (
      'eventi',
      {
        'tipologia':     evento.tipologia,
        'data':          evento.data,
        'orario':        evento.orario,
        'luogo':         evento.luogo,
        'descrizione':   evento.desc,
        'periodicita':   creaStringaDaLista(evento.periodicita),
        'sqCasa':        evento.sqCasa,
        'sqOspiti':      evento.sqOspite,
        'giorniReferto': evento.giorniReferto,
        'catPartita':    evento.catPartita,
        'rimborso':      evento.rimborsoSpese,
        'pacco':         pacco,
        'presenteOnline': 0, //Vado in automatico a dire che non è presente, modificare in caso di aggiunta
      },
      where: "id = ?",
      whereArgs: [evento.id]
    );

    //Vado ad aggiornare la lista degli eventi in cui è già presente
    for (var element in eventi.value) {
      if (element.id == evento.id)
      {
        //Sostituisco
        element = evento;
      }
    }
  }

  static Future<bool> verificaConnessione() async
  {
    //Verifico se c'è connessione internet
    final result = await Connectivity().checkConnectivity();
    if (result != ConnectivityResult.none)
    {
      return true;
    }
    return false;
  }

  static bool unoSelezionato (List<bool> booleani)
  {
    //Ritorna true se almeno uno dei booleani della lista è true
    bool valoreRitorno = false;
    for(int i = 0; i < booleani.length; i++)
    {
      if (booleani[i] == true)
      {
        valoreRitorno = true;
      }
    }

    //Ritorno il valore
    return valoreRitorno;
  }

  static bool periodicitaEvento (String? evento)
  {
    //Ritorno true se l'evento prevede una periodicità su giorni della settimana
    if (evento == "Allenamento" || evento == "Designazioni" || evento == "Altro")
    {
      return true;
    }

    return false; //Se non è in nessuno dei casi precedenti
  }
}