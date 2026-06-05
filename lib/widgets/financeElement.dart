import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';  //Pacchetto Grafici

class FinanceElement extends StatefulWidget {
  const FinanceElement({super.key});

  @override
  State<FinanceElement> createState() => _FinanceElementState();
}

//Classe Dati per Grafico
class FinanceData 
  {
    final String mese;
    final double valore;
    FinanceData (this.mese, this.valore);
  }

class _FinanceElementState extends State<FinanceElement> {

  @override
  Widget build(BuildContext context) {
    return 
    //Container che avvolge tutto con shadow
    Container
    (
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration
      (
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: BoxBorder.all(color: Color(0xFFF26B6B)),

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
      Stack
      (
        children: 
        [
          //Titolo Andamento Finanziario
          Positioned
          (
            top: 10,
            left: 10,
            child: Text
            (
              "Finanze",
              style: 
              TextStyle
              (
                fontSize: 20,
                fontWeight: FontWeight(700)
              )
            )
          ),

          //Grafico Andamento
          Positioned
          (
            top: 40,
            left: 20,
            bottom: 0,
            right: 20,
            child: 
            SfCartesianChart
            (
              primaryXAxis: const CategoryAxis(),
              series: <CartesianSeries>
              [
                LineSeries<FinanceData, String>
                (
                  dataSource: 
                  [
                    FinanceData("Gen", 1200),
                    FinanceData("Feb", 1500),
                    FinanceData("Mar", 1100),
                    FinanceData("Apr", 1800),
                  ],
                  color: Color(0xFFC4E1F2),
                  width: 5,
                  xValueMapper: (FinanceData d, _) => d.mese,
                  yValueMapper: (FinanceData d, _) => d.valore,
                )
              ],
            )
          )
          
          
        ],
        
        
      ),
    );
  }
}