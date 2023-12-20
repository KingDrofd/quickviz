import 'dart:io';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  CSVFILE _csvfile = CSVFILE();
  Future<List<Map<String, dynamic>>> readCsvFile() async {
    try {
      File csvFile = await directories.getCSVPath();

      String content = await csvFile.readAsString();
      print('CSV Content:\n$content');
      List<List<dynamic>> csvTable = CsvToListConverter().convert(content);

      List<Map<String, dynamic>> data = csvTable
          .map(
            (row) => {
              'gender': row[0],
            },
          )
          .toList();

      return data;
    } catch (e) {
      print('Error reading CSV file: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: readCsvFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No data available.'),
            );
          } else {
            List<String> columns = snapshot.data!.first.keys.toList();

            return Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: columns
                      .map((col) => DataColumn(label: Text(col)))
                      .toList(),
                  rows: snapshot.data!.map((data) {
                    return DataRow(
                        cells: columns.map((col) {
                      return DataCell(Text(data[col].toString()));
                    }).toList());
                  }).toList(),
                ),
              ),
            );
          }
        },
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