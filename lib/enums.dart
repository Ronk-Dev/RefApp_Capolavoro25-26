//Enumeratori per tutto il progetto

import 'package:flutter/material.dart';

enum PermessoPsw
{
  si,
  no,
  mai
}


enum RisAutenticazione
{
  si,
  no,
  nonPresente,
  errore
}

enum GiorniSettimana
{
  Lunedi,
  Martedi,
  Mercoledi,
  Giovedi,
  Venerdi,
  Sabato,
  Domenica
}

enum TipologiaNota
{
  Luogo,
  Squadra,
  Dirigente,
  Giocatore,
  Generale
}

class Nota
{
  final int? id;
  final String personaFinale;
  final String? nomePersona;
  final String? nota;
  final bool ammonito;
  final bool espulso;

  Nota({required this.personaFinale, this.id, this.nomePersona, this.nota, required this.ammonito, required this.espulso});
}


/*
class MieIcone {
  static const IconData card = IconData(0xe900, fontFamily: 'MieIcone');
  static const IconData raduno = IconData(0xe901, fontFamily: 'MieIcone');
  static const IconData allenamento = IconData(0xe902, fontFamily: 'MieIcone');
  static const IconData partita = IconData(0xe903, fontFamily: 'MieIcone');
}
*/

class Evento 
{
  final int? id;
  final String tipologia;
  final String? data;
  final String orario;
  final String? luogo;
  final String? desc;
  final List<bool>? periodicita;
  final String? sqCasa;
  final String? sqOspite;
  final int? giorniReferto;
  final double? rimborsoSpese;
  final String? catPartita;
  final int? pacco;

  Evento({this.id, required this.tipologia, this.data, required this.orario, this.luogo, this.periodicita, this.sqCasa, this.sqOspite, this.desc, this.catPartita, this.giorniReferto, this.rimborsoSpese, this.pacco});
}