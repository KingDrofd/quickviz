import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickviz/services/csv_handler.dart';
import 'package:quickviz/services/directory_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directories directories = Directories();
  List<Map<String, dynamic>> _data = [];
  Map<String, int> genderCounts = {};
  int _sortColumnIndex = 0;
  bool _ascending = true;
  Future<void> loadCsvFile() async {
    try {
      File csvFile = await directories.getCSVPath();

      String content = await csvFile.readAsString();

      List<List<dynamic>> csvTable = CsvToListConverter().convert(content);

      setState(() {
        _data = csvTable
            .skip(1)
            .map(
              (row) => {
                'gender': row[0],
                'race/ethnicity': row[1],
                'parental level of education': row[2],
                'lunch': row[3],
                'test preparation course': row[4],
                'math score': row[5],
                'reading score': row[6],
                'writing score': row[7],
              },
            )
            .toList();
      });
      var maleCounts = _getOccurrences(_data, 'gender', 'male');
      print("male counts $maleCounts");
    } catch (e) {
      print('Error reading CSV file: $e');
    }
  }

  int _getOccurrences(
      List<Map<String, dynamic>> data, String columnName, String item) {
    return data
        .where((row) =>
            row[columnName].toString().toLowerCase() == item.toLowerCase())
        .length;
  }

  _sort<T>(Comparable<dynamic> Function(Map<String, dynamic>) getField,
      int columnIndex, bool ascending) {
    _data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      if (ascending) {
        return Comparable.compare(aValue, bValue);
      } else {
        return Comparable.compare(bValue, aValue);
      }
    });
    setState(() {
      _sortColumnIndex = columnIndex;
      _ascending = ascending;
    });
  }

  @override
  void initState() {
    loadCsvFile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _ascending,
            columns: [
              DataColumn(
                label: Column(
                  children: [
                    Text('Gender'),
                    Text("Males: ${_getOccurrences(_data, 'gender', 'male')}"),
                  ],
                ),
                onSort: (columnIndex, ascending) {
                  _sort<String>((data) => data['gender'].toString(),
                      columnIndex, ascending);
                },
              ),
              DataColumn(
                label: Text('Race/Ethnicity'),
                onSort: (columnIndex, ascending) {
                  _sort<String>((data) => data['race/ethnicity'].toString(),
                      columnIndex, ascending);
                },
              ),
              DataColumn(
                label: Text('Parental level of education'),
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (data) => data['parental level of education'].toString(),
                      columnIndex,
                      ascending);
                },
              ),
              DataColumn(
                label: Text('lunch'),
                onSort: (columnIndex, ascending) {
                  _sort<String>((data) => data['lunch'].toString(), columnIndex,
                      ascending);
                },
              ),
              DataColumn(
                label: Text('Test preparation course'),
                onSort: (columnIndex, ascending) {
                  _sort<String>(
                      (data) => data['test preparation course'].toString(),
                      columnIndex,
                      ascending);
                },
              ),
              DataColumn(
                label: Text('Math Score'),
                onSort: (columnIndex, ascending) {
                  _sort<int>((data) => int.parse(data['math score'].toString()),
                      columnIndex, ascending);
                },
              ),
              DataColumn(
                label: Text('Reading Score'),
                onSort: (columnIndex, ascending) {
                  _sort<int>(
                      (data) => int.parse(data['reading score'].toString()),
                      columnIndex,
                      ascending);
                },
              ),
              DataColumn(
                label: Text('Writing Score'),
                onSort: (columnIndex, ascending) {
                  _sort<int>(
                      (data) => int.parse(data['writing score'].toString()),
                      columnIndex,
                      ascending);
                },
              ),
            ],
            rows: _data.map((data) {
              return DataRow(cells: [
                DataCell(Text(data['gender'].toString())),
                DataCell(Text(data['race/ethnicity'].toString())),
                DataCell(Text(data['parental level of education'].toString())),
                DataCell(Text(data['lunch'].toString())),
                DataCell(Text(data['test preparation course'].toString())),
                DataCell(Text(data['math score'].toString())),
                DataCell(Text(data['reading score'].toString())),
                DataCell(Text(data['writing score'].toString())),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
// Center(
//               child: SizedBox(
//                 width: 400,
//                 height: 400,
//                 child: BarChart(
//                   BarChartData(
//                     minY: 0,
//                     maxY: 03,
//                     barGroups: List.generate(
//                       snapshot.data!.length - 1,
//                       (index) => BarChartGroupData(
//                         x: 0,
//                         barRods: [
//                           BarChartRodData(
//                               toY: snapshot.data![index + 1]
//                                   ['Earning Per Share'])
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             );
// Center(
//                 child: DataTable(
//                   columns: const [
//                     DataColumn(label: Text('Year')),
//                     DataColumn(label: Text('Company')),
//                     DataColumn(label: Text('Category')),
//                     DataColumn(label: Text('Market Cap(in B USD)')),
//                     DataColumn(label: Text('Revenue')),
//                     DataColumn(label: Text('Gross Profit')),
//                     DataColumn(label: Text('Net Income')),
//                   ],
//                   rows: snapshot.data!.skip(1).map((data) {
//                     return DataRow(cells: [
//                       DataCell(Text(data['Year'].toString())),
//                       DataCell(Text(data['Company'].toString())),
//                       DataCell(Text(data['Category'].toString())),
//                       DataCell(Text(data['Market Cap(in B USD)'].toString())),
//                       DataCell(Text(data['Revenue'].toString())),
//                       DataCell(Text(data['Gross Profit'].toString())),
//                       DataCell(Text(data['Net Income'].toString())),
//                     ]);
//                   }).toList(),
//                 ),
//               ),