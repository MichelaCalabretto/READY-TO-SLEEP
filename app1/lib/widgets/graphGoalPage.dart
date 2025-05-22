import 'package:flutter/material.dart';
import 'package:app1/screens/GoalPage.dart';
import 'package:app1/utils/impact.dart';
import 'package:pie_chart/pie_chart.dart';

class GraphGoalPage extends StatelessWidget {
  GraphGoalPage({Key? key}) : super(key: key);

  final dataMap = <String, double>{
    "Ore sonno": 5,
  };

  final colorList = <Color>[
    const Color.fromARGB(255, 37, 50, 190),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("A che punto siamo?"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: PieChart(
          dataMap: dataMap,
          chartType: ChartType.ring,
          baseChartColor: Colors.grey[300]!,
          colorList: colorList,
        ),
      ),
    );
  }
}