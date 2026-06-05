import 'package:flutter/material.dart';
import 'package:refapp/enums.dart';
import "package:carousel_slider/carousel_slider.dart";
import 'package:easy_date_timeline/easy_date_timeline.dart';  //Libreria calendario
import 'package:flutter/services.dart';
import 'package:refapp/widgets/carouselElement.dart';
import 'package:refapp/widgets/checkBoxElement.dart';
import 'package:refapp/widgets/contenitoreEventi.dart';
import 'package:refapp/widgets/dayElement.dart';
import 'package:refapp/widgets/elementoSelezionato.dart';
import 'package:refapp/widgets/financeElement.dart'; //Importo la libreria del carosello eventi
import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:refapp/generale.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//Classe per dati Evento


class _HomePageState extends State<HomePage> {
  //Funzione per messageBox nomi quadre
  void nomiNonTrovati(String nomeSquadra)
  {
    showDialog
    (
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Attenzione'),
        content: Text('Non è stata trovata nessuna corrispondenza con il nome: $nomeSquadra'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // chiudo e torno alla selezione del nome
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //Aggiungo la società alla lista locale e mando richiesta per quella online
              Generale.societaConosciute.value.add(nomeSquadra);

              //Vado a togliere il focus
              FocusScope.of(context).unfocus();
            },
            child: Text('Prosegui e Salva'),
          ),
        ],
      ),
    );
  }

  void nomiTrovati (String nomeSquadra, List<int> posizioniTrovate, List<String> societa, TextEditingController controllerRitorno)
  {
    int _selected = 0; //Squadra selezionata (di base, quella scritta)

    //Vado a prendere i dati da mostrare
    List<String> societaMostrare = 
    [
      nomeSquadra
    ];

    //Riempo le società da mostrare
    for(int i = 0; i < posizioniTrovate.length; i++)
    {
      //Aggiungo solo le società trovate
      //Inoltre verifico che le società siano diverse da quella cercata
      if (societa[posizioniTrovate[i]].toLowerCase() != nomeSquadra.toLowerCase())
      {
        societaMostrare.add(societa[posizioniTrovate[i]]);
      }
      
    }
    
    showDialog
    (
      context: context,
      builder: (context) => 
      StatefulBuilder(builder: (context, setStateDialog) =>
      AlertDialog(
        title: Text('Attenzione'),
        content: 
        SingleChildScrollView(
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Quale di queste corrispondenze?'),
              SizedBox(height: 20),
              ...societaMostrare.asMap().entries.map((entry) {
                return ElementoSelezionato
                (
                  index: entry.key,
                  selected: _selected == entry.key ? true : false, 
                  nome: entry.value, 
                  onTap: () 
                  {
                    print("Cambia");
                    setStateDialog(() {
                      _selected = entry.key;
                    });
                  },
                  eliminaElemento: () 
                  {
                    //Vado ad eliminare l'elemento
                    Navigator.pop(context);

                    //Se era quella selezionata, reimposto la prima
                    if (_selected == entry.key)
                    {
                      if (_selected != 0)
                      {
                        _selected = 0;
                      }else{
                        _selected = 1;
                      }
                    }

                    //Vado a cancellare l'elemento dalla lista delle società
                    //Generale.societaConosciute.value.remove(entry.value);

                    //Lo tolgo anche alla lista precedentemente formulata 
                    setStateDialog(() {
                      societaMostrare.remove(entry.value);
                    },);

                    //Vado a togliere il focus
                    FocusScope.of(context).unfocus();
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // chiudo e torno alla selezione del nome
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //Vado a prendere e impostare la società selezionata
              controllerRitorno.text = societaMostrare[_selected];

              //Vado a salvare la società se non è presente
              if (_selected == 0)
              {
                Generale.societaConosciute.value.add(societaMostrare[_selected]);
                //Invio richiesta di salvare anche online
              }

              //Vado a togliere il focus
              FocusScope.of(context).unfocus();
            },
            child: Text('Prosegui e Salva'),
          ),
        ],
      ),
      )
    );
  }

  var _selectedDate = DateTime.now();

  

  final _valueTipologiaEvento = ValueNotifier<String?>(null); //Valore scelto nel dptbtnPicker
  final _valueCategoria = ValueNotifier<String?>(null); //Valore scelto nel dptbtnPicker

  final FocusNode _focusNodeTipEvento = FocusNode();  //Focus o no del dptbtnPicker
  final FocusNode _focusNodeCategoria = FocusNode();  //Focus o no del dptbtnPicker

  final TextEditingController _squadraCasaText = TextEditingController(); //Controller Testo per Squadra di Casa
  final TextEditingController _squadraOspText = TextEditingController(); //Controller Testo per Squadra Ospite

  final TextEditingController _refertoText = TextEditingController(); //Controller Testo per Giorni del Referto
  final TextEditingController _rimborsoText = TextEditingController(); //Controller Testo per € rimborso spese

  final TextEditingController _luogoText = TextEditingController(); //Controller Testo per Luogo dell'Evento

  final TextEditingController _descText = TextEditingController(); //Controller Testo per Descrizione dell'Evento

  void reimpostaValoriForm()
  {
    //Resetta i valori iniziali dei Text Controller
    setState(() {
      _valueTipologiaEvento.value = null;
      _valueCategoria.value = null;

      _squadraCasaText.clear();
      _squadraOspText.clear();
      _refertoText.clear();
      _rimborsoText.clear();
      _luogoText.clear();
      _descText.clear();

      _lunediEvento = false;
      _martediEvento = false;
      _mercolediEvento = false;
      _giovediEvento = false;
      _venerdiEvento = false;
      _sabatoEvento = false;
      _domenicaEvento = false;
    });
  }

  //Chiavi per tutti gli elementi nella FORM
  final _keyTipologiaEvento = GlobalKey<FormFieldState>();
  final _keySqCasaEvento = GlobalKey<FormFieldState>();
  final _keySqOspEvento = GlobalKey<FormFieldState>();
  final _keyRimborsoEvento = GlobalKey<FormFieldState>();
  final _keyRefertoEvento = GlobalKey<FormFieldState>();
  final _keyCategoriaEvento = GlobalKey<FormFieldState>();
  final _keyLuogoEvento = GlobalKey<FormFieldState>();

  final _formKey = GlobalKey<FormState>(); //Chiave per il form

  final _keyColonnaMostra = GlobalKey();

  DateTime _dataNuovoEvento = DateTime.now();

  TimeOfDay _orarioNuovoEvento = TimeOfDay(hour: 0, minute: 0);

  bool _lunediEvento = false;
  bool _martediEvento = false;
  bool _mercolediEvento = false;
  bool _giovediEvento = false;
  bool _venerdiEvento = false;
  bool _sabatoEvento = false;
  bool _domenicaEvento = false;

  @override
  Widget build(BuildContext context) {
    return 
    //Pagina Completa Home
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
          
          Padding
          (
            padding: EdgeInsetsGeometry.only(right: 25, left: 25), 
            child: 
              EasyDateTimeLinePicker.itemBuilder(
              firstDate: DateTime.now().subtract(Duration(days: 3)),
              lastDate: DateTime(2030, 3, 18),
              focusedDate: _selectedDate,
              currentDate: DateTime.now(),
              headerOptions: HeaderOptions
              (
                headerType: HeaderType.none
              ),
              itemExtent: 64.0,
              itemBuilder: (context, date, isSelected, isDisabled, isToday, onTap) {
                return 
                GiornoElement
                (
                  onTap: onTap,
                  selezionato: isSelected,
                  attuale: isToday, 
                  giorno: date.day, 
                  mese: date.month, 
                  giornoSettimana: 
                  date.weekday,
                );
              },
              
              onDateChange: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),

          //Lascio dello spazio verticale
          SizedBox(height: 10,),  

          //Aggiungi Evento alla Giornata  
          Padding
          (
            padding: EdgeInsetsGeometry.only(right: 25, left: 25, bottom: 15),
            child:
              FilledButton.icon
              (
                style: FilledButton.styleFrom
                (
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 48)
                ),
                label: 
                Text("Nuovo Evento"),
                icon: Icon(Icons.add),
              
                onPressed: ()
                {
                  //Vado a mettere come data del nuovo evento quella del giorno selezionato
                  setState(() {
                    _dataNuovoEvento = _selectedDate;
                  });

                  //Verifico se la data usata è quella odierna
                  if (Generale.convertiData(_dataNuovoEvento) == Generale.convertiData(DateTime.now()))
                  {
                    //Eventualmente setto l'orario come quello attuale
                    setState(() {
                      _orarioNuovoEvento = TimeOfDay.now();
                    });
                  }

                  apriNuovoEvento(context, false, -1);
                
                },
              ),   
            
          ),

          //Eventi della giornata
          Padding
          (
            padding: EdgeInsetsGeometry.only(right: 25, left: 25), 
            child:
            AnimatedSwitcher
            (
              duration: Duration(milliseconds: 150),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(begin: Offset(0, 0.1), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: 

              //Da mettere in ascolto con il notifier
              
              ListView.builder
              (
                key: ValueKey(_selectedDate), // ← FONDAMENTALE, triggera l'animazione
                shrinkWrap: true,                        // si adatta al contenuto
                physics: NeverScrollableScrollPhysics(), // disabilita lo scroll interno
                itemCount: Generale.eventi.value.length,
                itemBuilder: (context, index)
                {
                  //Inoltre, andiamo a visualizzare anche eventi fissi come allenamento e designazioni
                  if (Generale.eventi.value[index].periodicita![_selectedDate.weekday-1] == true)
                  {
                    //Se il giorno della settimana è spuntato, mostro l'evento
                    return 
                    Padding
                    (
                      padding: EdgeInsetsGeometry.all(3), //Padding / Distanziamento tra elementi
                      child: 
                      GestureDetector
                      (
                        onTap: () {
                          //Vado ad aprire il modello con questo evento
                          mostraEvento(Generale.eventi.value[index]);
                        },
                        child: ContenitoreEventi(titolo: Generale.eventi.value[index].tipologia, orario: Generale.eventi.value[index].orario, icona: Icon(Icons.abc))
                      )
                    );
                  }
                  if (Generale.eventi.value[index].data == "${_selectedDate.day > 10 ? _selectedDate.day : "0${_selectedDate.day}"}-${_selectedDate.month > 10 ? _selectedDate.month : "0${_selectedDate.month}"}-${_selectedDate.year}")
                  {
                    //Se corrisponde al giorno attuale, ritorno
                    return 
                    Padding
                    (
                      padding: EdgeInsetsGeometry.all(3), //Padding / Distanziamento tra elementi
                      child: 
                      GestureDetector
                      (
                        onTap: () {
                          print("Pressed");
                          //Vado ad aprire il modello con questo evento
                          mostraEvento(Generale.eventi.value[index]);
                        },
                        child: ContenitoreEventi(titolo: Generale.eventi.value[index].tipologia, orario: Generale.eventi.value[index].orario, icona: Icon(Icons.abc))
                      )                    );
                  }
                  return SizedBox.shrink(); // widget vuoto, non occupa spazio              
                }
              )
            ),
          ),

          //Lascio dello spazio verticale
          SizedBox(height: 20,),       

          //Carosello Eventi
          Container
          (
            //height: 200,
            child:
            Padding
            (
              padding: EdgeInsetsGeometry.only(right: 25, left: 25),
              child: 
              CarouselSlider
              (
                items: 
                [
                  CarouselElement(title: "Rimborsi", description: "In arrivo in giornata i pacchi 14 e 15",)
                ], 
                options: 
                CarouselOptions
                (
                  //pageSnapping: false,
                  //height: 200,
                  aspectRatio: 16/9,
                  //viewportFraction: 0.8,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  scrollDirection: Axis.horizontal,
                )
              )
            ) 
          ),

          SizedBox(height: 20,),

          //Zona Finanze
          Padding
          (
            padding: EdgeInsetsGeometry.only(right: 25, left: 25),
            child: FinanceElement(),
          ),

          //Quiz Del Giorno
          //Se è presente

          //Zona Allenamento
        ],
      )
    );
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
                          child: Text("Aggiunta Evento", style: TextStyle(fontWeight: FontWeight(700), fontSize: 20),)
                        ),
    
                        //Lascio dello spazio
                        SizedBox(height: 10,),
    
                        //Descrizione sull'aggiunta
                        Text
                        (
                          "Aggiungi un nuovo evento per ricordarti di farlo, ti invieremo una notifica qualche ora prima!\nIn questo modo non ti scorderai più di inviare il referto!",
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
                                      labelText: "Tipologia Evento",
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                      border: Generale.bordoForms
    
                                      //Bordo Errore
                                    ),
    
                                    valueListenable: _valueTipologiaEvento,     
    
                                    focusNode: _focusNodeTipEvento,   
    
                                    key: _keyTipologiaEvento,                                        
    
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
                                    Generale.elementiEventi.map((c) => 
                                    DropdownItem
                                    (
                                      value: c, 
                                      child: 
                                      Text(c),
                                    )).toList(),
                                    onChanged: (value) 
                                    {
                                      //Vado a reimpostare gli errori
                                      setState(() {
                                        setModalState(()
                                        {
                                          _valueTipologiaEvento.value = value;
                                        });
                                      });
    
                                      _keyTipologiaEvento.currentState?.validate();
                                    },
                                    onMenuStateChange: (isOpen) {
                                      //Verifichiamo se è chiuso e se non è selezionato nulla, vado a togliere il focused
                                      if (isOpen == false && _valueTipologiaEvento.value == null)
                                      {
                                        _focusNodeTipEvento.unfocus();
                                      }
                                    },
    
                                    validator: (value) {
                                      //Vado a validare la tipologia di evento
                                      if (value == null)
                                      {
                                        return "Seleziona un Evento";
                                      }
    
                                      //Altrimenti ritorno null -> dunque valido
                                      return null;
                                    },
                                  ),
    
    
                                  //Data Evento
                                  InputDecorator(
                                    decoration: InputDecoration(
                                      //Abilitata solo se non ci troviamo nei casi di periodicità o nessuna periodicità è selezionata
                                      enabled: Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                        [
                                          _lunediEvento,
                                          _martediEvento,
                                          _mercolediEvento,
                                          _giovediEvento,
                                          _venerdiEvento,
                                          _sabatoEvento,
                                          _domenicaEvento
                                        ]) == false ? true : false,
                                      contentPadding: EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 5),
                                      labelText: "Data Evento",
                                      border: Generale.bordoForms,
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                    ),
                                    child: 
                                    //Riga per mostrare data e apertura date
                                    Row
                                    (
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
    
                                      children: 
                                      [
                                        Text(Generale.convertiData(_dataNuovoEvento), style: TextStyle(fontSize: 15, color: Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                          [
                                            _lunediEvento,
                                            _martediEvento,
                                            _mercolediEvento,
                                            _giovediEvento,
                                            _venerdiEvento,
                                            _sabatoEvento,
                                            _domenicaEvento
                                          ]) == false ? Colors.black : Colors.grey,),),
                                        IconButton
                                        ( 
                                          onPressed: () async
                                          {
                                            //Verifico se è possibile selezionare una data (ovvero non c'è la periodicità)
                                            if (Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                                [
                                                  _lunediEvento,
                                                  _martediEvento,
                                                  _mercolediEvento,
                                                  _giovediEvento,
                                                  _venerdiEvento,
                                                  _sabatoEvento,
                                                  _domenicaEvento
                                                ]) == false)
                                            {
                                              //Posso aprire il menù
                                              final nuovaData = await showDatePicker
                                              (
                                                context: context,
                                                currentDate: _dataNuovoEvento,
                                                firstDate: DateTime.now(), 
                                                lastDate: DateTime.now().add(Duration(days: 730)),
                                              );
    
                                              //E stata scelta una nuova data
                                              //La riporto in quella decisa
                                              setModalState(()
                                              {
                                                _dataNuovoEvento = nuovaData ?? _selectedDate;
                                              });
    
                                              //Verifico che l'orario vada bene
                                              if (Generale.convertiData(_dataNuovoEvento) == Generale.convertiData(DateTime.now()))
                                              {
                                                //Eventualmente setto l'orario come quello attuale
                                                setModalState(() {
                                                  _orarioNuovoEvento = TimeOfDay.now();
                                                },);
                                              }
                                            }
                                          }, 
                                          icon: Icon(Icons.date_range_rounded, color: Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                          [
                                            _lunediEvento,
                                            _martediEvento,
                                            _mercolediEvento,
                                            _giovediEvento,
                                            _venerdiEvento,
                                            _sabatoEvento,
                                            _domenicaEvento
                                          ]) == false ? Colors.black : Colors.grey,)
                                        )
                                      ],
                                    )
                                  ),
    
                                  //Orario
                                  InputDecorator(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 5),
                                      labelText: "Orario Evento",
                                      border: Generale.bordoForms,
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
                                    ),
                                    child: 
                                    //Riga per mostrare data e apertura date
                                    Row
                                    (
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
    
                                      children: 
                                      [
                                        Text(Generale.convertiOrario(_orarioNuovoEvento), style: TextStyle(fontSize: 15),),
                                        IconButton
                                        ( 
                                          onPressed: () async
                                          {
                                            var nuovoOrario = await showTimePicker
                                            (
    
                                              context: context, 
                                              initialTime: TimeOfDay(hour: 0, minute: 0),
                                              builder: (context, child) {
                                                return MediaQuery
                                                (
                                                  data: MediaQuery.of(context).copyWith(
                                                    alwaysUse24HourFormat: true
                                                  ), 
                                                  child: child!,
                                                );
                                              },
                                            );
    
                                            if (nuovoOrario != null)
                                            {
                                              //Verifico se la data usata è quella odierna
                                              if (Generale.convertiData(_dataNuovoEvento) == Generale.convertiData(DateTime.now()))
                                              {
                                                //Eventualmente setto l'orario come quello attuale
                                                //Verifico che l'orario scelto dall'utente sia "più grande"
                                                int minutiNuovo = nuovoOrario!.hour * 60 + nuovoOrario.minute;
                                                int minutiOra = TimeOfDay.now().hour * 60 + TimeOfDay.now().minute;
                                                if (minutiNuovo < minutiOra)
                                                {
                                                  nuovoOrario = TimeOfDay.now();
                                                }
                                              }
    
                                              //E stato scelto un nuovo orario
                                              //Lo riporto
                                              setModalState(()
                                              {
                                                _orarioNuovoEvento = nuovoOrario ?? TimeOfDay(hour: 0, minute: 0);
                                              });
                                            }
                                            
                                          }, 
                                          icon: Icon(Icons.timer_outlined)
                                        )
                                      ],
                                    )
                                  ),
    
                                  
                                  //Partita - Se tipologia Evento = Partita
                                  //Carica Foto - Beta
                                  //Squadra Casa
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("SqCasa"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    _valueTipologiaEvento.value == "Partita" ?
                                    TextFormField
                                    (
                                      key: _keySqCasaEvento,
                                      controller: _squadraCasaText,
                                      decoration: 
                                      InputDecoration
                                      (
                                        border: Generale.bordoForms,
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
    
                                        labelStyle: TextStyle(color: Colors.black),
                                        labelText: "Squadra Casa"
                                      ),
    
                                      onEditingComplete: () 
                                      {
                                        //Vado a settare come giusto
                                        _keySqCasaEvento.currentState?.validate();
                                        //Appena l'utente invia, tolgo il focus e quindi si chiude la tastiera
                                        FocusScope.of(context).unfocus();
                                        //Verifico se ciò che ha inserito corrisponde a qualche società conosciuta
                                        List<int> posizioniTrovate = Generale.trovaElementi(_squadraCasaText.text, Generale.societaConosciute.value);
    
                                        //Verifico se è stato trovato qualcosa
                                        if (posizioniTrovate.isNotEmpty)
                                        {
                                          nomiTrovati(_squadraCasaText.text, posizioniTrovate, Generale.societaConosciute.value, _squadraCasaText);
                                          //Vado a mostrare quale intendeva
                                        }else
                                        {
                                          //Vado a dire all'utente che non ho trovato alcuna società con quel nome
                                          //Gli chiedo di salvarla o annullare
                                          
                                          nomiNonTrovati(_squadraCasaText.text);
                                        }
                                      },
    
                                      validator: (value) 
                                      {
                                        //Vado a validare la squadra di casa
                                        if (value == "")
                                        {
                                          return "Inserire una squadra corretta";
                                        }
    
                                        //Altrimenti ritorno null -> dunque valido
                                        return null;
                                      },
                                    )
                                    :
                                    SizedBox.shrink(key: ValueKey("Vuoto"),)
                                  ),
                                  
                                  //Squadra Ospitante
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("SqOsp"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    _valueTipologiaEvento.value == "Partita" ?
                                    TextFormField
                                    (
                                      key: _keySqOspEvento,
                                      controller: _squadraOspText,
                                      decoration: 
                                      InputDecoration
                                      (
                                        border: Generale.bordoForms,
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
    
                                        labelStyle: TextStyle(color: Colors.black),
                                        labelText: "Squadra Ospite"
                                      ),
    
                                      onEditingComplete: () 
                                      {
                                        //Vado a settare come giusto
                                        _keySqOspEvento.currentState?.validate();
                                        //Appena l'utente invia, tolgo il focus e quindi si chiude la tastiera
                                        FocusScope.of(context).unfocus();
                                        //Verifico se ciò che ha inserito corrisponde a qualche società conosciuta
                                        List<int> posizioniTrovate = Generale.trovaElementi(_squadraOspText.text, Generale.societaConosciute.value);
    
                                        //Verifico se è stato trovato qualcosa
                                        if (posizioniTrovate.isNotEmpty)
                                        {
                                          nomiTrovati(_squadraOspText.text, posizioniTrovate, Generale.societaConosciute.value, _squadraOspText);
                                          //Vado a mostrare quale intendeva
                                        }else
                                        {
                                          //Vado a dire all'utente che non ho trovato alcuna società con quel nome
                                          //Gli chiedo di salvarla o annullare
                                          
                                          nomiNonTrovati(_squadraOspText.text);
                                        }
                                      },
    
                                      validator: (value) 
                                      {
                                        //Vado a validare la squadra di casa
                                        if (value == "")
                                        {
                                          return "Inserire una squadra corretta";
                                        }
    
                                        //Altrimenti ritorno null -> dunque valido
                                        return null;
                                      },
                                    )
                                    :
                                    SizedBox.shrink(key: ValueKey("Vuoto2"),)
                                  ),
    
                                  //Rimborso
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("Rimborso"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    _valueTipologiaEvento.value == "Partita" ?
                                    TextFormField
                                    (
                                      key: _keyRimborsoEvento,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      controller: _rimborsoText,
                                      decoration: 
                                      InputDecoration
                                      (
                                        border: Generale.bordoForms,
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
    
                                        labelStyle: TextStyle(color: Colors.black),
                                        labelText: "Rimborso Spese",
    
                                        
                                      ),
    
                                      onChanged: (value) {
                                        //Vado a settare come giusto
                                        _keyRimborsoEvento.currentState?.validate();
                                      },
    
                                      validator: (value) 
                                      {
                                        
                                        //Vado a validare la squadra di casa
                                        if (value == "")
                                        {
                                          return "Inserire un valore per il rimborso spese";
                                        }
    
                                        //Altrimenti ritorno null -> dunque valido
                                        return null;
                                      },
                                    )
                                    :
                                    SizedBox.shrink(key: ValueKey("Vuoto8"),)
                                  ),
    
                                  //Referto Data Max.
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("Referto"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    _valueTipologiaEvento.value == "Partita" ?
                                    TextFormField
                                    (
                                      key: _keyRefertoEvento,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      controller: _refertoText,
                                      decoration: 
                                      InputDecoration
                                      (
                                        border: Generale.bordoForms,
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
    
                                        labelStyle: TextStyle(color: Colors.black),
                                        labelText: "Giorni per Referto",
    
                                        
                                      ),
    
                                      onChanged: (value) {
                                        //Vado a settare come giusto
                                        _keyRefertoEvento.currentState?.validate();
                                      },
    
                                      validator: (value) 
                                      {
                                        //Vado a validare la squadra di casa
                                        if (value == "")
                                        {
                                          return "Inserire un valore per il giorno di referto";
                                        }
    
                                        //Altrimenti ritorno null -> dunque valido
                                        return null;
                                      },
                                    )
                                    :
                                    SizedBox.shrink(key: ValueKey("Vuoto3"),)
                                  ),
    
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("CatPartita"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    _valueTipologiaEvento.value == "Partita" ?
    
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
                                        labelText: "Categoria Partita",
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
                                        border: Generale.bordoForms
    
                                        //Bordo Errore
                                      ),
    
                                      valueListenable: _valueCategoria,     
    
                                      focusNode: _focusNodeCategoria,   
    
                                      key: _keyCategoriaEvento,                                        
    
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
                                      Generale.categorie.map((c) => 
                                      DropdownItem
                                      (
                                        value: c, 
                                        child: 
                                        Text(c),
                                      )).toList(),
                                      onChanged: (value) 
                                      {
                                        //Vado a settare come giusto
                                        _keyCategoriaEvento.currentState?.validate();
    
                                        setState(() {
                                          setModalState(()
                                          {
                                            _valueCategoria.value = value;
                                          });
                                        });
                                      },
                                      onMenuStateChange: (isOpen) {
                                        //Verifichiamo se è chiuso e se non è selezionato nulla, vado a togliere il focused
                                        if (isOpen == false && _valueCategoria.value == null)
                                        {
                                          _focusNodeCategoria.unfocus();
                                        }
                                      },
    
                                      validator: (value) {
                                        //Vado a validare la tipologia di evento
                                        if (value == null)
                                        {
                                          return "Seleziona una Categoria";
                                        }
    
                                        //Altrimenti ritorno null -> dunque valido
                                        return null;
                                      },
                                    )
                                  :
                                    SizedBox.shrink(),
                                  ),
    
                                  //Periodicità per giorni a settimana
                                  AnimatedSwitcher
                                  (
                                    switchInCurve: Curves.bounceIn,
                                    switchOutCurve: Curves.bounceOut,
                                    key: ValueKey("Periodico"),
                                    duration: Duration(milliseconds: 150),
                                    child: 
                                    //Vado a mostrare solo se parliamo di allenamento, altro e designazioni
                                    Generale.periodicitaEvento(_valueTipologiaEvento.value) ?
                                    InputDecorator
                                    (
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.only(left: 16, top: 5, bottom: 5, right: 5),
                                        labelText: "Periodicità Evento",
                                        border: Generale.bordoForms,
                                        enabledBorder: Generale.bordoForms,
                                        focusedBorder: Generale.bordoFormsFocus,
                                      ),
                                      child: 
                                      //Mostro checkBox per tutti i giorni
                                      GridView.count
                                      (
                                        physics: NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        shrinkWrap: true,
                                        childAspectRatio: 2,
                                        
                                        children: 
                                        [
                                          //Tutti i giorni della settimana
                                          CheckBoxElement
                                          (
                                            value: _lunediEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _lunediEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Lunedì",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _martediEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _martediEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Martedì",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _mercolediEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _mercolediEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Mercoledì",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _giovediEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _giovediEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Giovedì",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _venerdiEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _venerdiEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Venerdì",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _sabatoEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _sabatoEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Sabato",
                                          ),
    
                                          CheckBoxElement
                                          (
                                            value: _domenicaEvento, 
                                            onChanged: (value) {
                                              setState(() {
                                                setModalState(() {
                                                  _domenicaEvento = value ?? false;
                                                },);
                                              });
                                            },
                                            label: "Domenica",
                                          ),
                                        ],
                                      )
                                    )
                                    :
                                    SizedBox.shrink()
                                  ),
    
                                  //Luogo / Campo
                                  TextFormField
                                  (
                                    key: _keyLuogoEvento,
                                    controller: _luogoText,
                                    decoration: 
                                    InputDecoration
                                    (
                                      border: Generale.bordoForms,
                                      enabledBorder: Generale.bordoForms,
                                      focusedBorder: Generale.bordoFormsFocus,
    
                                      labelStyle: TextStyle(color: Colors.black),
                                      label: 
                                      //Riga per mostrare testo ed icona
                                      Row
                                      (
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
    
                                        children: 
                                        [
                                          Text("Luogo"),
                                          Icon(Icons.location_on_outlined)
                                        ],
                                      ),
                                    ),
    
                                    onEditingComplete: () 
                                    {
                                      //Vado a settare come giusto
                                      _keyLuogoEvento.currentState?.validate();
                                      //Appena l'utente invia, tolgo il focus e quindi si chiude la tastiera
                                      FocusScope.of(context).unfocus();
                                      //Verifico se ciò che ha inserito corrisponde a qualche società conosciuta
                                      List<int> posizioniTrovate = Generale.trovaElementi(_luogoText.text, Generale.societaConosciute.value);
    
                                      //Verifico se è stato trovato qualcosa
                                      if (posizioniTrovate.isNotEmpty)
                                      {
                                        nomiTrovati(_luogoText.text, posizioniTrovate, Generale.societaConosciute.value, _luogoText);
                                        //Vado a mostrare quale intendeva
                                      }else
                                      {
                                        //Vado a dire all'utente che non ho trovato alcuna società con quel nome
                                        //Gli chiedo di salvarla o annullare
                                        
                                        nomiNonTrovati(_luogoText.text);
                                      }
                                    },
    
                                    validator: (value) 
                                    {
                                      //Vado a validare il luogo
                                      if (value == "" && _valueTipologiaEvento.value == "Partita")
                                      {
                                        return "Inserire un luogo corretto";
                                      }
    
                                      //Altrimenti ritorno null -> dunque valido
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
                                      //Vado a validare la desc
                                      return null;
                                    },                                                  
                                  ),
    
                                  //Pulsante per inviare il form
                                  FilledButton
                                  (
                                    onPressed: ()
                                    {
                                      if(_formKey.currentState!.validate())
                                      {
                                        //Non ci sono errori
                                        //Si salvano i valori
                                        //Se non sto modificando aggiungo
                                        if (modifica != true)
                                        {
                                          Generale.aggiungiEvento
                                          (
                                            Evento
                                            (
                                              tipologia: _valueTipologiaEvento.value ?? "", 
                                              orario: Generale.convertiOrario(_orarioNuovoEvento),
                                              data: Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                                [
                                                  _lunediEvento,
                                                  _martediEvento,
                                                  _mercolediEvento,
                                                  _giovediEvento,
                                                  _venerdiEvento,
                                                  _sabatoEvento,
                                                  _domenicaEvento
                                                ]) == false ? Generale.convertiData(_dataNuovoEvento) : "",
                                              luogo: _luogoText.text,
                                              desc: _descText.text,
                                              sqCasa: _valueTipologiaEvento.value == "Partita" ? _squadraCasaText.text : "",
                                              sqOspite: _valueTipologiaEvento.value == "Partita" ? _squadraOspText.text : "",
                                              catPartita: _valueTipologiaEvento.value == "Partita" ? _valueCategoria.value : "",
                                              giorniReferto: _valueTipologiaEvento.value == "Partita" ? int.tryParse(_refertoText.text) : 0,
                                              periodicita: 
                                              [
                                                _lunediEvento,
                                                _martediEvento,
                                                _mercolediEvento,
                                                _giovediEvento,
                                                _venerdiEvento,
                                                _sabatoEvento,
                                                _domenicaEvento
                                              ],
                                              rimborsoSpese: _valueTipologiaEvento.value == "Partita" ? double.tryParse(_rimborsoText.text) : 0,
                                            )
                                          );
                                        }else
                                        {
                                          //Modifico
                                          Generale.modificaEvento
                                          (
                                            Evento
                                            (
                                              id: idModifica,
                                              tipologia: _valueTipologiaEvento.value ?? "", 
                                              orario: Generale.convertiOrario(_orarioNuovoEvento),
                                              data: Generale.periodicitaEvento(_valueTipologiaEvento.value) == false || Generale.unoSelezionato(
                                                [
                                                  _lunediEvento,
                                                  _martediEvento,
                                                  _mercolediEvento,
                                                  _giovediEvento,
                                                  _venerdiEvento,
                                                  _sabatoEvento,
                                                  _domenicaEvento
                                                ]) == false ? Generale.convertiData(_dataNuovoEvento) : "",
                                              luogo: _luogoText.text,
                                              desc: _descText.text,
                                              sqCasa: _valueTipologiaEvento.value == "Partita" ? _squadraCasaText.text : "",
                                              sqOspite: _valueTipologiaEvento.value == "Partita" ? _squadraOspText.text : "",
                                              catPartita: _valueTipologiaEvento.value == "Partita" ? _valueCategoria.value : "",
                                              giorniReferto: _valueTipologiaEvento.value == "Partita" ? int.tryParse(_refertoText.text) : 0,
                                              periodicita: 
                                              [
                                                _lunediEvento,
                                                _martediEvento,
                                                _mercolediEvento,
                                                _giovediEvento,
                                                _venerdiEvento,
                                                _sabatoEvento,
                                                _domenicaEvento
                                              ],
                                              rimborsoSpese: _valueTipologiaEvento.value == "Partita" ? double.tryParse(_rimborsoText.text) : 0,
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
                                    child: Text(modifica == false ? "Crea Evento" : "Modifica")
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

  //Funzione per mostrare un evento
  void mostraEvento(Evento evento)
  {
    //Prendo le giornate di riferimento alla periodicità
    List<GiorniSettimana> listaGiorni = Generale.prendiGiorniDaBool(evento.periodicita ?? []);

    String stringaGiorni = "";

    for (var i = 0; i < listaGiorni.length; i++) 
    {
      //Se non è l'ultimo elemento, aggiungo anche la virgola finale
      if (i+1 != listaGiorni.length && i+2 != listaGiorni.length)
      {
        //Prendo la parte senza l'identificatore dell'enum
        stringaGiorni += listaGiorni[i].toString().split("GiorniSettimana.")[1] + ", ";
      }
      //Se è il penultimo aggiungo " e "
      else if (i+2 == listaGiorni.length)
      {
        stringaGiorni += listaGiorni[i].toString().split("GiorniSettimana.")[1] + " e ";
      }else
      {
        stringaGiorni += listaGiorni[i].toString().split("GiorniSettimana.")[1];
      }
      
    }

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
                          //Mostro tutti i dati dell'evento
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: 
                            [
                              //Mostro l'icona
                              Icon(Icons.abc_outlined),
                              evento.tipologia == "Partita" ?
                              Text("${evento.sqCasa} - ${evento.sqOspite}", style: TextStyle(fontWeight: FontWeight(700), fontSize: 25),)
                              : 
                              Text(evento.tipologia, style: TextStyle(fontWeight: FontWeight(700), fontSize: 25),),
                            ],
                          ),

                          //Lascio spazio Extra
                          SizedBox(height: 5,),

                          //Data Evento o Periodicità
                          evento.data == "" ?
                          Text("Tutti i $stringaGiorni")
                          :
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: 
                            [
                              Text("Data: "),
                              Text(evento.data.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                            ],
                          ),
                          
                          //Orario
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: 
                            [
                              Text("Orario: "),
                              Text(evento.orario.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                            ],
                          ),

                          //Luogo
                          evento.luogo != "" ?
                          Row
                          (
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: 
                            [
                              Text("Luogo: "),
                              Text(evento.luogo.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                            ],
                          )
                          :
                          SizedBox.shrink(),

                          //Descrizione
                          evento.desc != "" ?
                          Text("Descrizione: ${evento.desc}")
                          :
                          SizedBox.shrink(),

                          //Sezione per le partite
                          evento.tipologia == "Partita" ?
                          Column
                          (
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: 
                            [
                              //Elementi per la partita
                              //Categoria
                              Row
                              (
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: 
                                [
                                  Text("Categoria: "),
                                  Text(evento.catPartita.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                                ],
                              ),

                              //Rimborso
                              Row
                              (
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: 
                                [
                                  Text("Rimborso: "),
                                  Text(evento.rimborsoSpese.toString() + " €", style: TextStyle(fontWeight: FontWeight(700)),),
                                ],
                              ),

                              //Pacco
                              Row
                              (
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: 
                                [
                                  Text("Pacco: "),
                                  Text(evento.pacco.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                                ],
                              ),

                              //Giorni Referto
                              Row
                              (
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: 
                                [
                                  Text("Giorni Referto: "),
                                  Text(evento.giorniReferto.toString(), style: TextStyle(fontWeight: FontWeight(700)),),
                                ],
                              ),
                              
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
                                _valueTipologiaEvento.value = evento.tipologia;

                                //Metto la data solo se c'è
                                if (evento.data != "")
                                {
                                  _dataNuovoEvento = Generale.convertiDateTime(evento.data ?? "");
                                }else
                                {
                                  _dataNuovoEvento = _selectedDate;
                                }
                                
                                _orarioNuovoEvento = Generale.convertiTime(evento.orario);

                                _luogoText.text = evento.luogo.toString();
                                _descText.text = evento.desc.toString();

                                if (evento.tipologia == "Partita")
                                {
                                  _squadraCasaText.text = evento.sqCasa.toString();
                                  _squadraOspText.text = evento.sqOspite.toString();

                                  _rimborsoText.text = evento.rimborsoSpese.toString();
                                  _refertoText.text = evento.giorniReferto.toString();

                                  _valueCategoria.value = evento.catPartita.toString();
                                }

                                //Inserisco la periodicità
                                for (var i = 0; i < evento.periodicita!.length; i++) 
                                {
                                  //Aggiungo se necessario la spunta ai vari valori
                                  if (evento.periodicita![i] == true)
                                  {
                                    switch (i) {
                                      case 0:
                                        _lunediEvento = true;
                                        break;
                                      case 1:
                                        _martediEvento = true;
                                        break;
                                      case 2:
                                        _mercolediEvento = true;
                                        break;
                                      case 3:
                                        _giovediEvento = true;
                                        break;
                                      case 4:
                                        _venerdiEvento = true;
                                        break;
                                      case 5:
                                        _sabatoEvento = true;
                                        break;
                                      case 6:
                                        _domenicaEvento = true;
                                        break;
                                      default:
                                    }
                                  }
                                }
                                //Gli passo anche l'id per la modifica
                                apriNuovoEvento(context, true, evento.id ?? -1);
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
                                  content: Text("Sei sicuro di eliminare l'evento?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context), // chiudo e torno alla selezione del nome
                                      child: Text('Annulla'),
                                    ),
                                    TextButton(
                                      onPressed: ()
                                      {
                                        //Elimino l'evento
                                        Generale.eliminaEvento(evento);

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
                    )
                    
                    
                  ],
                )
                
              )
            );
          }
        );
      }
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
}