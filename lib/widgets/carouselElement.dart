import 'dart:math';

import 'package:flutter/material.dart';

class CarouselElement extends StatefulWidget {
  final String title;
  final String description;

  const CarouselElement({super.key, required this.title, required this.description});

  @override
  State<CarouselElement> createState() => _CarouselElementState();
}

class _CarouselElementState extends State<CarouselElement> {
  bool _premuto = false;
  @override
  Widget build(BuildContext context) {
    return 
    //Immagine di sfondo opaca
    GestureDetector
    (
      onTap: () {
        //Verifico se è collegato qualcosa alla pressione
        print("Premuto");
        setState(() {
          _premuto = true;
        });
        
      },
      child: 
      AnimatedScale
      (
        scale: _premuto ? 1.05 : 1, 
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,

        child: 
        Stack
        (
          children: 
          [
            Opacity
            (
              opacity: 0.45,
              child:
              Container
              (
                
                decoration: 
                BoxDecoration
                (
                  border: BoxBorder.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(16),
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
                ClipRRect
                (
                  borderRadius: BorderRadiusGeometry.circular(16),
                  child: 
                  Image.network
                  (
                    width: MediaQuery.of(context).size.width,
                    "https://imgs.search.brave.com/7IXShE4r5x7S8A7IoIYbIk-A6UWrD9WNgE8jAEBGWGo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5nZXR0eWltYWdl/cy5jb20vaWQvMTY5/Nzc0MTc4My9waG90/by9hbGxpYW56LXN0/YWRpdW0tdHVyaW4t/aXRhbHktdGhlLW9m/ZmljaWFsLXNlcmll/LWEtbWF0Y2gtYmFs/bC1wdW1hLW9yYml0/YS1pcy1zZWVuLW9u/LWEtcGxpbnRoLmpw/Zz9zPTYxMng2MTIm/dz0wJms9MjAmYz1Z/M0lJcE83NFhkMGFB/T0FsLWJQRThjT0Uw/cXJjc0huYnA1YW5R/alVXU1pNPQ"
                  ),
                )
              )
            ),

            //Testi in sovrimpressione
            Positioned
            (
              bottom: 20,
              left: 20,
              right: 20,
              child:
              Column
              (
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: 
                [
                  //Titolo in sovrimpressione
                  Text
                  (
                    widget.title, 
                    style: 
                    TextStyle
                    (
                      fontSize: 20,
                      fontWeight: FontWeight(700)
                    )
                  ),

                  //Breve descrizione
                  Text
                  (
                    widget.description,
                    style: TextStyle(fontSize: 12),
                  )
                ],
              )
              
            )
            
          ],
        )
      )
      
    );
    
    
  }
}