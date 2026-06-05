import 'package:flutter/material.dart';
import 'package:refapp/enums.dart';
import 'package:refapp/generale.dart';
import 'package:refapp/widgets/contenitoreEventi.dart';

class NoteMostra extends StatefulWidget {
  //Parametro passato, lista di note
  final void Function(int index) onTap;
  const NoteMostra({required this.onTap, super.key});

  @override
  State<NoteMostra> createState() => _NoteMostraState();
}

class _NoteMostraState extends State<NoteMostra> {
  @override
  Widget build(BuildContext context) {
    return 
    //Mostra un insieme di elementi a forma di nota
    Container
    (
      width: double.infinity,
      height: 500,
      padding: EdgeInsets.all(16),

      child: 
      Generale.note.value.length > 0 ?
      ListView.builder
      (
        itemCount: Generale.note.value.length,
        //Lista di elementi
        itemBuilder: (context, index)
        {
          return
          Padding
          (
            padding: EdgeInsetsGeometry.all(3), //Padding / Distanziamento tra elementi
            child: 
            GestureDetector
            (
              onTap: () => widget.onTap(index),
              child: 
              ContenitoreEventi
              (
                titolo: Generale.note.value[0].personaFinale, 
                orario: "", 
                icona: Icon(Icons.abc)
              )
            )
          );
        }
      )
    : 
    Text("Nessuna Nota presente!")
    );
  }
}