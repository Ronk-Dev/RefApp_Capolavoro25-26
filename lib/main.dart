import 'package:flutter/material.dart';
import 'package:refapp/database.dart';
import 'package:refapp/notificaLocale.dart';
import 'package:refapp/screens/HomePage.dart';
import 'package:refapp/screens/Sinfonia.dart';
import 'package:refapp/screens/Taccuino.dart';
import 'package:refapp/widgets/appBarRef.dart';
import 'dart:math';
import 'generale.dart';
import 'widgets/pagineApp.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Vado ad inizializzare le notifiche
  await NotificaLocale.init();
  await NotificaLocale.ripristinaDopoRiavvio();

  await initializeDateFormatting('it', null); // inizializza italiano

  //Inizializzo il database
  await DatabaseHelper.instance.database;

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  //Variabili e Metodi
  PageController _controllerPagine = PageController(); //Controller per spostarsi tra le schermate

  int _pageSelezionata = 0;

  var posizioneX;
  var width;

  GlobalKey _home = GlobalKey();
  GlobalKey _sinfonia = GlobalKey();
  GlobalKey _taccuino = GlobalKey();
  GlobalKey _profilo = GlobalKey();

  //Pagina cambiata
  void paginaCambiata()
  {
    _controllerPagine.animateToPage(_pageSelezionata, duration: Duration(microseconds: 100), curve: Curves.bounceIn);
  }

  //Prendo la posizione dell'elemento richiesto
  void PrendiPosizione (GlobalKey key)
  {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox;

    setState(() {
      posizioneX = renderBox.localToGlobal(Offset.zero).dx - 22;
      width = renderBox.size.width;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();    

    //Verifico login
    verificaLogin();

    //Vado a prendere gli eventi
    Generale.prendiEventi();
    //Vado a prendere le società conosciute online o (in assenza di internet), le prendo localmente

    //Vado a prendere subito la posizione della prima scheda
    WidgetsBinding.instance.addPostFrameCallback((_)
    {
      PrendiPosizione(_home);
    });
  }

  void verificaLogin() async
  {
    //Verifico se è loggato o meno
    final prefs = await SharedPreferences.getInstance();

    final logged = prefs.getBool("accounted");

    //Se è loggato, mostro la prima pagina
    if (logged == true)
    {
      _controllerPagine.animateToPage(0, duration: Duration(microseconds: 100), curve: Curves.bounceIn);
    }else
    {
      //Lo mando a fare il login/registrarsi
    }
  }

  //Fine Variabili e Metodi
  @override
  Widget build(BuildContext context) 
  {
    return 
    MaterialApp
    (
      //Tema Generale App
      theme: ThemeData
      (
        fontFamily: "Principale"
      ),
      home: 
      Scaffold
      (
        resizeToAvoidBottomInset: false, // Evita che la navBar in basso si alzi con la tastiera
        appBar: AppBarRef(retryAuth:  Generale.retryAuth.value, auth: () async {
          await Generale.sinfoniaKey.currentState?.prendiInserisciCred();
        },),
        body:
        //Viene mostrata qui ogni pagina
        //La barra di navigazione si sovrappone alle pagine (qualora necessaria)
        Stack
        (
          children: 
          [
            
            PageView
            (
              physics: const NeverScrollableScrollPhysics(), 
              controller: _controllerPagine,
              children: 
              [
                //Tutte le pagine dell'applicazione
                HomePage(),
                Sinfonia(key: Generale.sinfoniaKey,),
                Taccuino()
              ],
            ),
          

            //Barra NAVIGAZIONE
            //Presente solo nella versione Horizontal e non LANDSCAPE
            Positioned
            (
              left: 16,
              right: 16,
              bottom: 20,
              child: 
              Container
              (

                height: max(MediaQuery.of(context).size.height * 0.1, 90),
                decoration: 
                BoxDecoration
                (
                  color: const Color(0xFFC4E1F2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: 
                  [
                    //Effetto Ombra Sotto
                    BoxShadow
                    (
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 10, //Modifico Intensità dello shadow
                      offset: Offset(0, 4)
                    )
                  ]
                ),
                
                //Riga con tutte le pagine per spostarsi
                child:
                //Test Elemento Selezione
                LayoutBuilder
                (
                  builder: (context, contrainstants)
                  {
                    return
                    Stack
                    (
                      children: 
                      [
                        //Selezione
                        AnimatedPositioned
                        (
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          left: posizioneX,
                          top: 0,
                          bottom: 0,
                          child: 
                          Container
                          (
                            width: width,
                            margin: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFFF26B6B),
                              borderRadius: BorderRadius.circular(12),
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
                          ),
                        ),

                        //Elementi
                        Padding
                        (
                          padding: EdgeInsetsGeometry.all(5),
                          child: 
                          Row
                          (
                            //Mi posiziono al centro
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,

                            children: 
                            [
                              //Tutte le pagine nella navBar
                              PagineApp
                              (
                                key: _home,
                                txt: "Home",
                                selected: _pageSelezionata == 0 ? true : false,
                                onTap: () {
                                  //Vado alla Home
                                  PrendiPosizione(_home);
                                  setState(() {
                                    _pageSelezionata = 0;
                                    Generale.retryAuth.value = false;
                                  });

                                  paginaCambiata();
                                },
                              ),
                              PagineApp
                              (
                                key: _sinfonia,
                                txt: "Sinfonia", 
                                selected: _pageSelezionata == 1 ? true : false,
                                onTap: () {
                                  //Vado alla Pag.
                                  PrendiPosizione(_sinfonia);
                                  setState(() {
                                    _pageSelezionata = 1;
                                  });

                                  paginaCambiata();
                                },
                              ),
                              PagineApp
                              (
                                key: _taccuino,
                                txt: "Taccuino", 
                                selected: _pageSelezionata == 2 ? true : false,
                                onTap: () async {
                                  //Vado alla Pag.
                                  PrendiPosizione(_taccuino);
                                  setState(() {
                                      _pageSelezionata = 2;
                                      Generale.retryAuth.value = false;
                                  });

                                  paginaCambiata();
                                },
                                ),
                              PagineApp
                              (
                                key: _profilo,
                                txt: "Account", 
                                selected: _pageSelezionata == 3 ? true : false,
                                onTap: () {
                                  //Vado alla Pag.
                                  PrendiPosizione(_profilo);
                                  setState(() {
                                    _pageSelezionata = 3;
                                    Generale.retryAuth.value = false;
                                  });

                                  paginaCambiata();
                                },
                              ),
                            ],
                          )
                        )
                      ],
                    );
                  }
                )            
              )
            )
            
          ],
        ),
      )
    );
    
  }
}