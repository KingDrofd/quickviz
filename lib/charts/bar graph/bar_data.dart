import 'package:quickviz/charts/bar%20graph/individual_bar.dart';

class BarData {
  final double company1;
  final double company2;
  final double company3;
  final double company4;
  final List years;
  List<IndividualBar> barData = [];

  BarData(
    this.years, {
    required this.company1,
    required this.company2,
    required this.company3,
    required this.company4,
  });

  void initializeBarData() {
    barData = [
      IndividualBar(x: years[0], y: company1),
      IndividualBar(x: years[1], y: company2),
      IndividualBar(x: years[2], y: company3),
      IndividualBar(x: years[3], y: company4),
    ];
  }
}
