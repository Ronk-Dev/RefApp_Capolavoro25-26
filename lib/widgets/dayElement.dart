import 'package:flutter/material.dart';

class GiornoElement extends StatefulWidget {
  //Parametri della classe

  //Selezionato (bool)
  final bool selezionato;

  //Giorno Attuale (bool)
  final bool attuale;

  //Giorno (int)
  final int giorno;

  //Mese (string)
  final int mese;

  //Settimana (string)
  final int giornoSettimana;

  final VoidCallback onTap;

  const GiornoElement({super.key, required this.selezionato, required this.attuale, required this.giorno, required this.giornoSettimana, required this.mese, required this.onTap});

  @override
  State<GiornoElement> createState() => _GiornoElementState();
}

class _GiornoElementState extends State<GiornoElement> {
  //Funzione per ricerca del mese
  String TrovaMese (int numeroMese)
  {
    const mesi = ['GEN','FEB','MAR','APR','MAG','GIU','LUG','AGO','SET','OTT','NOV','DIC'];
    return mesi[numeroMese- 1];
  }

  String TrovaGiorno (int numeroGiorno)
  {
    const giorni = ['LUN','MAR','MER','GIO','VEN','SAB','DOM'];
    return giorni[numeroGiorno - 1];
  }

  @override
  Widget build(BuildContext context) {
    return 
    //Elemento selezione del giorno
    GestureDetector
    (
      onTap: widget.onTap,
      child: 
      AnimatedContainer
      (
        duration: Duration(milliseconds: 250),
        
        decoration: 
        BoxDecoration
        (
          //Bordo Colorato
          border: 
          BoxBorder.all
          (
            color: widget.attuale ? Color(0xFFF26B6B) : Color.fromARGB(255, 240, 240, 240)
          ),
          //Bordo Arrotondato
          borderRadius: BorderRadius.circular(16),
          //Colore a Seconda (Selezionato = ROSSICCIO | Non Selezionato = Trasparente)
          color: widget.selezionato ? Color(0xFFF26B6B) : Theme.of(context).scaffoldBackgroundColor,
          //Shadow Leggerissimo
        ),
        width: 70,
        height: 120,

        child: 
        //Padding di distanza della Colonna
        Padding
        (
          padding: EdgeInsetsGeometry.all(5),
          child: 
          //Colonna per Mese/Numero/Giorno
          Column
          (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: 
            [
              //Il colore del testo va a seconda se selezionato o meno
              Text(TrovaMese(widget.mese), style: TextStyle(fontSize: 13, color: widget.selezionato ? Colors.white : Colors.black)),
              Text(widget.giorno.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight(700), color: widget.selezionato ? Colors.white : Colors.black),),
              Text(TrovaGiorno(widget.giornoSettimana), style: TextStyle(fontSize: 13, color: widget.selezionato ? Colors.white : Colors.black))
            ],
          )
        )
      )
    );
    
  }
}