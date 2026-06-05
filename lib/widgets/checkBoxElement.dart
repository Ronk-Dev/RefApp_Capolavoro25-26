import 'package:flutter/material.dart';

class CheckBoxElement extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  const CheckBoxElement({super.key, required this.value, required this.onChanged, required this.label});

  @override
  State<CheckBoxElement> createState() => _CheckBoxElementState();
}

class _CheckBoxElementState extends State<CheckBoxElement> {
  @override
  Widget build(BuildContext context) {
    return 
    IntrinsicWidth
    (
    child: 
      Row
      (
        spacing: 0,
        //crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start  ,
        children: 
        [
          Transform.translate
          (
            offset: Offset(-15, 0),
            child: 
            Checkbox
            (
              value: widget.value, 
              onChanged: widget.onChanged
            ),
          ),
          
          //Riduco lo spazio
          Transform.translate
          (
            offset: Offset(-20, 0.5),
            child: 
            //Anche se preme sulla label seleziono la casella
            GestureDetector
            (
              onTap: () => widget.onChanged(!widget.value), //Gli passo il contrario di quello attuale
              child: 
              Text(widget.label)
            )
            
          )
          
        ],
      ),
    );
  }
}