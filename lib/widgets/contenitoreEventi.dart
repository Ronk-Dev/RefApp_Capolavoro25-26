import 'package:flutter/material.dart';

class ContenitoreEventi extends StatefulWidget {
  final String titolo;
  final String orario;
  final Icon icona;

  const ContenitoreEventi({super.key, required this.titolo, required this.orario, required this.icona});

  @override
  State<ContenitoreEventi> createState() => _ContenitoreEventiState();
}

class _ContenitoreEventiState extends State<ContenitoreEventi> {
  Color bordoEvento = Color(0xFFF26B6B);
  @override
  Widget build(BuildContext context) {
    return
    //Vado a contenere tutti gli altri elementi all'interno
    Container
    (
      height: 70,
      decoration: 
      BoxDecoration
      (
        color: Theme.of(context).scaffoldBackgroundColor,
        //Bordi evidenziati solo a sinistra destra e in basso
        border: Border.all(color: bordoEvento, width: 2),
        borderRadius: BorderRadius.circular(16),

        boxShadow: 
        [
          //Effetto Ombra Sotto
          BoxShadow
          (
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 3, //Modifico Intensità dello shadow
            offset: Offset(0, 4)
          )
        ]
      ),
      child:
      //Riga per mostrare informazioni
      Row
      (
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,

        children: 
        [
          //Icona
          SizedBox
          (
            width: MediaQuery.of(context).size.width * 0.2,
            child: widget.icona,
          ),

          //Titolo Evento
          
          SizedBox
          (
            width: MediaQuery.of(context).size.width * 0.4,
            child: 
            Center
            (
              child: Text(widget.titolo),
            )
          ),

          //Orario Evento
          SizedBox
          (
            width: MediaQuery.of(context).size.width * 0.2,
            child: 
            Center
            (
              child: Text(widget.orario)
            )
          ),
        ],
      )
    );
  }
}