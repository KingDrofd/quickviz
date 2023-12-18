import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickviz/charts/bar%20graph/bar_graph.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map<String, dynamic>>> readCsvFile() async {
    try {
      final File file = File('path to file');
      String content = await file.readAsString();
      List<List<dynamic>> csvTable = CsvToListConverter().convert(content);

      // Assuming the "Year" column is at index 0 and "Company" column is at index 1.
      List<Map<String, dynamic>> data = csvTable
          .map(
            (row) => {
              'Year': row[0],
              'Company': row[1],
              'Category': row[2],
              'Market Cap(in B USD)': row[3],
              'Revenue': row[4],
              'Gross Profit': row[5],
              'Net Income': row[6],
              'Current Ratio': row[13],
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
            return Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: 700,
                  child: BarGraph(
                      years: snapshot.data!
                          .skip(1)
                          .map((years) => years['Year'])
                          .toList(),
                      revenue: snapshot.data!
                          .skip(1)
                          .map((item) => item['Current Ratio'])
                          .toList()),
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