import 'package:flutter/material.dart';

class PagineApp extends StatefulWidget {
  //Parametri da passare
  final String txt;
  final bool selected;
  final VoidCallback? onTap;
  const PagineApp({super.key, required this.txt, required this.selected, required this.onTap});

  @override
  State<PagineApp> createState() => _PagineAppState();
}

class _PagineAppState extends State<PagineApp> {
  @override
  Widget build(BuildContext context) {
    return 
    //Pulsante della NavBar per andare in quella pagine
    GestureDetector
    (
      //È stato premuto questo pulsante
      onTap: widget.onTap,
      child: 
      Container
      (
        decoration: 
        BoxDecoration
        (
          //Lascio trasparente se non è selezionato il pulsante
          //color: widget.selected == true ? Colors.white : Colors.amber,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16)
        ),
        padding: EdgeInsets.all(20),
        child: 
        Column
        (
          mainAxisAlignment: MainAxisAlignment.center,

          children: 
          [
            //Immagine/Icona
            Icon(Icons.home),

            //Lascio dello spazio verticale
            SizedBox(height: 5,),

            //Testo
            //Widget.txt perchè il parametro txt sta nella classe stateful chiamata widget
            Text(widget.txt)
          ],
        )
      )
    );
 }
}