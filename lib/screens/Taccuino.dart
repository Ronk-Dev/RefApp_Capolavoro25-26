import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:refapp/enums.dart';
import 'package:refapp/generale.dart';
import 'package:refapp/widgets/checkBoxElement.dart';
import 'package:refapp/widgets/noteMostra.dart';

class Taccuino extends StatefulWidget {
  const Taccuino({super.key});

  @override
  State<Taccuino> createState() => _TaccuinoState();
}

class _TaccuinoState extends State<Taccuino> {
  //Variabili e Metodi
  final GlobalKey _keyColonnaMostra = GlobalKey();

  final _valueRiferimento = ValueNotifier<String?>(null); //Valore scelto nel dptbtnPicker
  final FocusNode _focusNode = FocusNode();  //Focus o no del dptbtnPicker

  final GlobalKey<FormFieldState> _keyTipologia = GlobalKey<FormFieldState>();

  final TextEditingController _descText = TextEditingController();
  final TextEditingController _nominativoText = TextEditingController();

  bool _ammonizione = false;
  bool _espulsione = false;

  void reimpostaValoriForm()
  {
    _valueRiferimento.value = null;
    _descText.text = "";
    _nominativoText.text = "";
    _ammonizione = false;
    _espulsione = false;
  }

  void apriNuovoEvento(BuildContext context, bool modifica, int idModifica) async {
    await showModalBottomSheet
    (
      isScrollControlled: true, //Andiamo a scrollare all'interno del modal
      context: context,
      builder: (BuildContext context) {
        return 
        StatefulBuilder
        (
          builder: (context, setModalState)
          {
            return
            Container
            (
            padding: EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //Pagina del Modal
                //Form per inserimento Evento
                Container
                (
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
    
                  child: 
                  SingleChildScrollView
                  (
                    child: 
                    Column
                    (
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
    
                      children: 
                      [
                        //Testo Aggiunta Evento
                        Align
                        (
                          alignment: AlignmentGeometry.centerStart,
                          child: Text("Aggiunta Nota", style: TextStyle(fontWeight: FontWeight(700), fontSize: 20),)
                        ),
    
                        //Lascio dello spazio
                        SizedBox(height: 10,),
    
                        //Descrizione sull'aggiunta
                        Text
                        (
                          "Aggiungi una nota per ricordati di quel momento, quel giocatore o quella partita...",
                          textAlign: TextAlign.justify,
                        ),
    
                        //Lascio dello spazio
                        SizedBox
                        (
                          height: 20,
                        ),
    
                        //Form con tutti i dettagli
                        Form
                        (
                          key: _formKey,
                          child: 
                          Container
                          (
                            //Grafica con bordino
                            decoration: 
                            BoxDecoration
                            (
                              border: BoxBorder.all(color: Color(0xFFC4E1F2), width: 2),
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: 
                            Padding
                            (
                              padding: EdgeInsetsGeometry.all(16),
                              child: 
                              Column
                              (
                                spacing: 15,
                                children: 
                                [
                                  //Tipologia Evento - Menù a tendina
                                  DropdownButtonFormField2<String>
                                  (
                                    isExpanded: true,
                                    alignment: AlignmentDirectional.bottomStart,
                                    decoration: 
                                    InputDecoration
                                    (
                                      contentPadding:
                                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                      labelStyle: TextStyle(color: Colors.black),
                                      labelText: "Riferimento Nota",
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                      border: Generale.bordoForms
    
                                      //Bordo Errore
                                    ),
    
                                    valueListenable: _valueRiferimento,     
    
                                    focusNode: _focusNode,   
    
                                    key: _keyTipologia,                                        
    
                                    dropdownStyleData: 
                                    DropdownStyleData
                                    (
                                      decoration: 
                                      BoxDecoration
                                      (
                                        borderRadius: BorderRadius.circular(15)
                                      )
                                    ),
    
                                    dropdownSeparator: const 
                                    DropdownSeparator
                                    (
                                      height: 4,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Divider(),
                                      ),
                                    ),
    
                                    menuItemStyleData: 
                                    MenuItemStyleData
                                    (
                                      useDecorationHorizontalPadding: true
                                    ),
    
                                    items: 
                                    TipologiaNota.values.map((c) =>
                                      DropdownItem<String>(
                                        value: c.name,       // "normale", "importante", ecc.
                                        child: Text(c.name),
                                      )
                                    ).toList(),
                                    onChanged: (value) 
                                    {
                                      //Vado a reimpostare gli errori
                                      setState(() {
                                        setModalState(()
                                        {
                                          _valueRiferimento.value = value;
                                        });
                                      });
    
                                      _keyTipologia.currentState?.validate();
                                    },
                                    onMenuStateChange: (isOpen) {
                                      //Verifichiamo se è chiuso e se non è selezionato nulla, vado a togliere il focused
                                      if (isOpen == false && _valueRiferimento.value == null)
                                      {
                                        _focusNode.unfocus();
                                      }
                                    },
    
                                    validator: (value) {
                                      //Vado a validare la tipologia di evento
                                      if (value == null)
                                      {
                                        return "Seleziona un Riferimento";
                                      }
    
                                      //Altrimenti ritorno null -> dunque valido
                                      return null;
                                    },
                                  ),

                                  //Nominativo
                                  TextFormField
                                  (
                                    enabled: _valueRiferimento.value != "Generale",
                                    controller: _nominativoText,
                                    decoration: 
                                    InputDecoration
                                    (
                                      contentPadding: EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 5),
                                      labelText: "Nominativo",
                                      floatingLabelAlignment: FloatingLabelAlignment.start,
                                      border: Generale.bordoForms,
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                    ),
    
                                    validator: (value) 
                                    {
                                      if (_valueRiferimento.value != "Generale" && value == "")
                                      {
                                        return "Inserire un nominativo";
                                      }
                                      //Vado a validare la desc
                                      return null;
                                    },                                                  
                                  ),
    
                                  //Descrizione
                                  TextFormField
                                  (
                                    controller: _descText,
                                    maxLines: 5,
                                    decoration: 
                                    InputDecoration
                                    (
                                      contentPadding: EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 5),
                                      labelText: "Descrizione",
                                      floatingLabelAlignment: FloatingLabelAlignment.start,
                                      border: Generale.bordoForms,
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                    ),
    
                                    validator: (value) 
                                    {
                                      if (_valueRiferimento.value == "Generale" && value == "")
                                      {
                                        return "Inserire una nota";
                                      }
                                      //Vado a validare la desc
                                      return null;
                                    },                                                  
                                  ),

                                  //Ammonito
                                  CheckBoxElement(value: _ammonizione, onChanged: (value) {
                                    setModalState(() {
                                      setState(() {
                                        _ammonizione = !_ammonizione;
                                      });
                                    },);
                                  }, label: "Ammonizione"),

                                  //Espulso
                                  CheckBoxElement(value: _ammonizione, onChanged: (value) {
                                    setModalState(() {
                                      setState(() {
                                        _ammonizione = !_ammonizione;
                                      });
                                    },);
                                  }, label: "Espulsione"),
    
                                  //Pulsante per inviare il form
                                  FilledButton
                                  (
                                    style: FilledButton.styleFrom
                                    (
                                      backgroundColor: Colors.green,
                                      minimumSize: Size(double.infinity, 48)
                                    ),
                                    onPressed: ()
                                    {
                                      if(_formKey.currentState!.validate())
                                      {
                                        //Non ci sono errori
                                        //Si salvano i valori
                                        //Se non sto modificando aggiungo
                                        if (modifica != true)
                                        {
                                          Generale.aggiungiNota
                                          (
                                            Nota
                                            (
                                              personaFinale: _valueRiferimento.value ?? "", 
                                              nomePersona: _valueRiferimento.value != "Generale" ? _nominativoText.text : "",
                                              ammonito: _ammonizione, 
                                              espulso: _espulsione,
                                              nota: _descText.text,
                                            )
                                          );
                                        }else
                                        {
                                          //Modifico
                                          Generale.modificaNota
                                          (
                                            Nota
                                            (
                                              id: idModifica,
                                              personaFinale: _valueRiferimento.value ?? "", 
                                              nomePersona: _valueRiferimento.value != "Generale" ? _nominativoText.text : "",
                                              ammonito: _ammonizione, 
                                              espulso: _espulsione,
                                              nota: _descText.text,
                                            )
                                          );
                                        }
    
                                        //Resetto il pannello
                                        _formKey.currentState?.reset();
    
                                        reimpostaValoriForm();
    
                                        //Vado a chiudere il pannello
                                        Navigator.pop(context);
                                      }
                                    }, 
                                    child: Text(modifica == false ? "Crea Nota" : "Modifica")
                                  )
                                ],
                              )
                            )
                            
                          )
                          
                        )
                      ],
                    )
                  )
                )
              ],
            ),
          );
        
          }
        );
        
      },
    );

    //Una volta chiuso, se è in modifica cancello i dati
    if (modifica == true)
    {
      _formKey.currentState?.reset();

      reimpostaValoriForm();
    }                
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return 
    //Pagina che presenta gli ammoniti, esplusi, note
    SingleChildScrollView
    (
      padding: EdgeInsets.all(2),
      child: 
      Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,

        children: 
        [
          //Lascio dello spazio verticale per distanziarsi dalla appBar
          SizedBox(height: 20,),

          //Campo Ricerca Note
          Padding
          (
            padding: EdgeInsetsGeometry.only(left: 20, right: 20),
            child: 
            Stack
            (
              children: 
              [
                TextField
                (
                  decoration: 
                  InputDecoration
                  (
                    border: Generale.bordoForms,
                    enabledBorder: Generale.bordoForms,
                    focusedBorder: Generale.bordoFormsFocus,

                    labelStyle: TextStyle(color: Colors.black),
                    labelText: "Ricerca Note"
                  ),
                ),

                Positioned
                (
                  right: 20,
                  top: 5,
                  child: IconButton(onPressed: (){}, icon: Icon(Icons.search))
                )
              ],
            )
            
          ),

          //Pulsante per aggiungere note
          Padding
          (
            padding: EdgeInsetsGeometry.only(left: 20, right: 20, top: 10),
            child: 
            FilledButton.icon
            (
              style: FilledButton.styleFrom
              (
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 48)
              ),
              onPressed: ()
              {
                apriNuovoEvento(context, false, -1);
              }, 
              label: 
              Text("Nuova Nota"),
              icon: Icon(Icons.add),
            )
          ),
          

          //Tutte le note insieme
          NoteMostra
          (
            onTap: (index) {
              mostraNota(Generale.note.value[index]);
            },
          )
        ],
      )
    );
  }

  double _altezzaContenuto = 0;

  void _aggiornaAltezza(StateSetter setModalState) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = _keyColonnaMostra.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setModalState(() {
          _altezzaContenuto = renderBox.size.height + 122; // +52 per il padding (26*2)
        });
      }
    });
  }

  void mostraNota(Nota nota)
  {
    showModalBottomSheet
    (
      isScrollControlled: true, //Andiamo a scrollare all'interno del modal
      context: context,
      builder: (BuildContext context) 
      {
        return 
        StatefulBuilder
        (
          builder: (context, setModalState)
          {
            _aggiornaAltezza(setModalState);
            return 
            Container
            (
              padding: EdgeInsets.all(26),
              width: MediaQuery.of(context).size.width,
              height: _altezzaContenuto,

              child: 
              SingleChildScrollView
              (
                child: 
                Column
                (
                  children: 
                  [
                    Container
                    (
                      decoration: 
                      BoxDecoration
                      (
                        border: BoxBorder.all(color: Color(0xFFC4E1F2), width: 2),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: 
                      Column
                      (
                        key: _keyColonnaMostra,
                        spacing: 10,
                        children: 
                        [
                          //Mostro tutti i dati della nota
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: 
                            [
                              //Mostro l'icona
                              //Icon(nota.ammonito || nota.espulso ? MieIcone.card : Icons.note, color: nota.ammonito ? Colors.amber : nota.espulso ? Colors.red : Colors.black,),
                              nota.personaFinale == "Giocatore" || nota.personaFinale == "Luogo" || nota.personaFinale == "Dirigente" || nota.personaFinale == "Squadra" ?
                              Text(nota.nomePersona ?? "", style: TextStyle(fontWeight: FontWeight(700), fontSize: 25),)
                              : 
                              Text("Nota Generale", style: TextStyle(fontWeight: FontWeight(700), fontSize: 25),),
                            ],
                          ),

                          //Lascio spazio Extra
                          SizedBox(height: 5,),

                          //Descrizione Nota
                          nota.nota != "" ? 
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: 
                            [
                              Text("Descrizione: "),
                              Text(nota.nota ?? "", style: TextStyle(fontWeight: FontWeight(700)),),
                            ],
                          )
                          :
                          SizedBox.shrink()
                              
                          ],
                        )
                          
                    ),
                        
                      
                    

                    //Spazio Verticale
                    SizedBox(height: 10,),

                    //Inserisco i pulsanti Modifica e Elimina
                    Padding
                    (
                      padding: EdgeInsetsGeometry.all(5),
                      child: 
                      Row
                      (
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,

                        children: 
                        [
                          Expanded
                          (
                            child:
                            FilledButton.icon
                            (
                              style: FilledButton.styleFrom
                              (
                                backgroundColor: Colors.amber,
                                minimumSize: Size(double.infinity, 48)
                              ),
                              onPressed: ()
                              {
                                //Chiudo il presente dialog
                                Navigator.pop(context);
                                //Inserisco tutti i dati nei controller e mostro il creaEvento
                               
                                //Gli passo anche l'id per la modifica
                                apriNuovoEvento(context, true, nota.id ?? -1);
                              },
                              icon: Icon(Icons.settings),
                              label: Text("Modifica")
                            )
                          ),

                          Expanded
                          (
                            child:
                            FilledButton.icon
                            (
                              style: FilledButton.styleFrom
                              (
                                backgroundColor: Colors.red,
                                minimumSize: Size(double.infinity, 48)
                              ),
                              onPressed: ()
                              {
                                //Chiedo conferma di andare ad eliminare
                                showDialog(context: context, builder: (context) => 
                                AlertDialog
                                (
                                  title: Text('Attenzione'),
                                  content: Text("Sei sicuro di eliminare la nota?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context), // chiudo e torno alla selezione del nome
                                      child: Text('Annulla'),
                                    ),
                                    TextButton(
                                      onPressed: ()
                                      {
                                        //Elimino l'evento
                                        Generale.eliminaNota(nota);

                                        //Chiudo i dialog
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Elimina'),
                                    ),
                                  ],
                                ),);
                              },
                              icon: Icon(Icons.delete),
                              label: Text("Elimina")
                            )
                          )
                        ],
                      )
                    )]))
            );
          }
        );
      }
    );
  }

}