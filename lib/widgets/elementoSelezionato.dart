import 'package:flutter/material.dart';
import 'package:refapp/generale.dart';

class ElementoSelezionato extends StatefulWidget {
  final int index; //Valore in indice di questo elemento
  final bool selected;
  final String nome;
  final VoidCallback eliminaElemento;
  final VoidCallback onTap;
  const ElementoSelezionato({required this.index, required this.selected, required this.nome, required this.eliminaElemento, required this.onTap, super.key});

  @override
  State<ElementoSelezionato> createState() => _ElementoSelezionatoState();
}

class _ElementoSelezionatoState extends State<ElementoSelezionato> {
  @override
  Widget build(BuildContext context) {
    //Elemento di una lista (selezionato o non)
    return 
    Padding(padding: EdgeInsetsGeometry.only(top: 10),
    child: 
    GestureDetector
    (
      onTap: widget.onTap,

      child: 
      AnimatedContainer
      (
        padding: EdgeInsets.all(8),
        width: MediaQuery.of(context).size.width,
        height: 45,
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration
        (
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: widget.selected ? Color(0xFF4994ec) : Colors.grey, width: widget.selected ? 2 : 1)
        ),

        child: 
        Center(
          child: 
          //Testo + Icona Cancella
          Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: 
            [
              Text(widget.nome, style: TextStyle(fontSize: 15),),
              //Pulsante per Eliminare
              widget.index != 0 ?
              IconButton
              (
                padding: EdgeInsets.zero,           // ← rimuove il padding interno
                constraints: BoxConstraints(),   
                onPressed: ()
                {
                  //Vado a chiedere se vuole effettivamente eliminare
                  showDialog(context: context, builder: (context) => 
                  AlertDialog(
                    title: Text('Attenzione'),
                    content: Text('Sei sicuro di eliminare la società: ${widget.nome}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // chiudo e torno alla selezione del nome
                        child: Text('Annulla'),
                      ),
                      TextButton(
                        onPressed: widget.eliminaElemento,
                        child: Text('Elimina'),
                      ),
                    ],
                  ),);
                }, icon: Icon(Icons.delete_outline_rounded)
              )
              :
              SizedBox.shrink()
            ],
          )
          
        )
        
      ),
    )
  );
    
  }
}