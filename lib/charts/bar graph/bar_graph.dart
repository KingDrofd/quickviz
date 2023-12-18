import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quickviz/charts/bar%20graph/bar_data.dart';

class BarGraph extends StatelessWidget {
  const BarGraph({super.key, required this.revenue, required this.years});
  final List revenue;
  final List years;
  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(years,
        company1: revenue[0],
        company2: revenue[1],
        company3: revenue[2],
        company4: revenue[3]);

    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
              show: true,
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 27,
              ))),
          maxY: 3,
          minY: 0,
          barGroups: myBarData.barData
              .map(
                (data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(toY: data.y),
                  ],
                ),
              )
              .toList()),
    );
  }
}
