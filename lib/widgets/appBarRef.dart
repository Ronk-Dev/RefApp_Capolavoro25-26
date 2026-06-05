import 'package:flutter/material.dart';

class AppBarRef extends StatefulWidget implements PreferredSizeWidget  {
  final bool retryAuth;
  final VoidCallback auth;
  const AppBarRef({required this.retryAuth, required this.auth, super.key});

  @override
  State<AppBarRef> createState() => _AppBarRefState();

  //Permette di dare una size fissa (per essere accettato come AppBar)
  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _AppBarRefState extends State<AppBarRef> {
  @override
  Widget build(BuildContext context) {
    return 
    //AppBar Generale
    Container
    (
      decoration: 
      BoxDecoration
      (
        boxShadow: 
        [
          //Effetto Ombra Sotto
          BoxShadow
          (
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5, //Modifico Intensità dello shadow
            offset: Offset(4, 0)
          )
        ]
      ),
      child: 
      Stack
    (
      children: 
      [
        //Immagine di sfondo
        Image.asset
        (
          width: MediaQuery.of(context).size.width,
          "assets/imgs/placeholderRefApp.png",
          fit: BoxFit.fitWidth,
        ),

        //Saluto con Nome
        Positioned
        (
          left: 20,
          bottom: 20,
          right: 20,
          child: Text("Benvenuto in RefApp", style: TextStyle(color: Color(0xFFF26B6B), fontWeight: FontWeight.w700, fontSize: 20),)
        ),

        //Icone Info e Account
        Positioned
        (
          right: 20,
          top: 20,
          child: 
          Row
          (
            children: 
            [
              widget.retryAuth == true ? 
              IconButton
              (
                onPressed: widget.auth, 
                icon: Icon(Icons.verified_user_outlined, color: Color(0xFFF26B6B))
              )
              :
              SizedBox.shrink(),
              Icon(Icons.info_outline_rounded, color: Color(0xFFF26B6B),),
              SizedBox(width: 10,),
              Icon(Icons.account_circle_outlined, color: Color(0xFFF26B6B),)
            ],
          )
        ),

        //Riga terminale
        Positioned
        (
          bottom: 0,
          left: 0,
          child: 
          Container
          (
            width: MediaQuery.of(context).size.width, // larghezza intera
            color: Color(0xFFF26B6B),
            height: 2, // spessore della riga
          )
        )
        
      ],
    )
    );
    
  }
}