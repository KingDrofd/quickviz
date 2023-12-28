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
  List<String> _allColumns = []; // List to store all available columns
  List<String> _selectedColumns = []; // List to store selected columns
  String? selectedColumnType;
  List<Map<String, dynamic>> loadedData = [];
  CSVFILE _csvfile = CSVFILE();

  // Future<void> loadCsvFile() async {
  //   try {
  //     File csvFile = await directories.getCSVPath();

  //     String content = await csvFile.readAsString();

  //     List<List<dynamic>> csvTable = CsvToListConverter().convert(content);

  //     List<String> header =
  //         csvTable.isNotEmpty ? List.from(csvTable.first) : [];

  //     setState(() {
  //       _data = csvTable
  //           .skip(1)
  //           .map(
  //             (row) => Map.fromIterables(
  //               header,
  //               row.map((item) => item.toString()),
  //             ),
  //           )
  //           .toList();

  //       _allColumns = header;
  //       _selectedColumns = List.from(_allColumns);
  //     });
  //   } catch (e) {
  //     print('Error reading CSV file: $e');
  //   }
  // }

  int _getOccurrences(
      List<Map<String, dynamic>> data, String columnName, String item) {
    return data
        .where((row) =>
            row[columnName].toString().toLowerCase() == item.toLowerCase())
        .length;
  }

  _sort<T>(
    Comparable<dynamic> Function(Map<String, dynamic>) getField,
    int columnIndex,
    bool ascending,
  ) {
    setState(() {
      try {
        _sortColumnIndex = columnIndex;
        _ascending = ascending;

        _data.sort((a, b) {
          final aValue = getField(a);
          final bValue = getField(b);
          if (ascending) {
            return Comparable.compare(aValue, bValue);
          } else {
            return Comparable.compare(bValue, aValue);
          }
        });
      } catch (e) {
        print('Error during sorting: $e');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("We encountered an error"),
              content: Text("Please make sure you picked the correct type"),
            );
          },
        );
      }
    });
  }

  void loadData() async {
    loadedData = await _csvfile.loadCsvFile();
    setState(() {
      _data = loadedData;
      _allColumns = loadedData.isNotEmpty ? loadedData.first.keys.toList() : [];
      _selectedColumns = List.from(_allColumns);
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

// value: _getOccurrences(_data, 'gender', 'male').toDouble(),
//                   title:
//                       '${double.parse(((_getOccurrences(_data, 'gender', 'male') / _data.length) * 100).toStringAsFixed(2))}%',

  Widget buildDataTable() {
    if (_data.isEmpty) {
      return CircularProgressIndicator();
    }

    List<DataColumn> columns = [];
    List<DataRow> rows = [];
    Map<String, dynamic> firstRow = _data.first;

    // Create DataColumn widgets dynamically based on selected columns
    for (String columnName in _selectedColumns) {
      columns.add(
        DataColumn(
          label: Text(columnName.toUpperCase()),
          onSort: (columnIndex, ascending) {
            try {
              if (selectedColumnType == 'int') {
                _sort<int>(
                  (data) =>
                      int.parse(data[_selectedColumns[columnIndex]].toString()),
                  columnIndex,
                  ascending,
                );
              } else if (selectedColumnType == 'double') {
                _sort<double>(
                  (data) => double.parse(
                      data[_selectedColumns[columnIndex]].toString()),
                  columnIndex,
                  ascending,
                );
              } else {
                // Default to treating it as a string or handle other types as needed
                _sort<String>(
                  (data) => data[_selectedColumns[columnIndex]].toString(),
                  columnIndex,
                  ascending,
                );
              }
            } catch (e) {
              // Handle any errors that might occur during sorting
              print('Error during sorting: $e');
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("We encountered an error"),
                    content:
                        Text("Please make sure you picked the correct type"),
                  );
                },
              );
            }
          },
        ),
      );
    }

    // Create DataRow widgets dynamically based on data and selected columns
    for (Map<String, dynamic> data in _data) {
      List<DataCell> cells = [];
      for (String columnName in _selectedColumns) {
        cells.add(DataCell(Text(data[columnName].toString())));
      }
      rows.add(DataRow(cells: cells));
    }

    return DataTable(
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _ascending,
      columns: columns,
      rows: rows,
    );
  }

  Future<String?> showColumnTypeSelectionDialog(BuildContext context) async {
    String selectedType = 'string'; // Default type, change as needed

    try {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select Column Type'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Choose the type for sorting:'),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: selectedType,
                  onChanged: (String? newValue) {
                    selectedType = newValue!;
                    Navigator.of(context).pop(selectedType);
                  },
                  items: ['string', 'int', 'double']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedType);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error in showColumnTypeSelectionDialog: $e');
      return 'string';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        actions: [],
      ),
      body: Center(
          child: SingleChildScrollView(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 1000,
                        height: 400,
                        child: Wrap(
                          children: _allColumns
                              .map(
                                (column) => CheckboxListTile(
                                  title: Text(column),
                                  value: _selectedColumns.contains(column),
                                  onChanged: (bool? value) async {
                                    if (value != null) {
                                      selectedColumnType =
                                          await showColumnTypeSelectionDialog(
                                              context);
                                      setState(() {
                                        if (value) {
                                          _selectedColumns.add(column);
                                        } else {
                                          _selectedColumns.remove(column);
                                        }
                                      });
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      buildDataTable(),
                    ],
                  )))),
    );
  }

  SizedBox buildPieChart() {
    return SizedBox(
      width: 500,
      height: 500,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              badgePositionPercentageOffset: 1.4,
              badgeWidget: Text(
                "Male:",
                style: GoogleFonts.roboto(fontSize: 25),
              ),
              color: Colors.blue,
              value: _getOccurrences(_data, 'gender', 'male').toDouble(),
              title:
                  '${double.parse(((_getOccurrences(_data, 'gender', 'male') / _data.length) * 100).toStringAsFixed(2))}%',
              titleStyle: GoogleFonts.oswald(fontSize: 20),
            ),
            PieChartSectionData(
              badgePositionPercentageOffset: 1.4,
              badgeWidget: Text(
                "Female:",
                style: GoogleFonts.roboto(fontSize: 25),
              ),
              color: Colors.pink,
              value: _getOccurrences(_data, 'gender', 'female').toDouble(),
              title:
                  '${double.parse(((_getOccurrences(_data, 'gender', 'female') / _data.length) * 100).toStringAsFixed(2))}%',
              titleStyle: GoogleFonts.oswald(fontSize: 20),
            ),
          ],
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

// DataTable(
//             sortColumnIndex: _sortColumnIndex,
//             sortAscending: _ascending,
//             columns: [
//               DataColumn(
//                 label: Column(
//                   children: [
//                     Text('Gender'),
//                     Text("Males: ${_getOccurrences(_data, 'gender', 'male')}"),
//                   ],
//                 ),
//                 onSort: (columnIndex, ascending) {
//                   _sort<String>((data) => data['gender'].toString(),
//                       columnIndex, ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Race/Ethnicity'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<String>((data) => data['race/ethnicity'].toString(),
//                       columnIndex, ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Parental level of education'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<String>(
//                       (data) => data['parental level of education'].toString(),
//                       columnIndex,
//                       ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('lunch'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<String>((data) => data['lunch'].toString(), columnIndex,
//                       ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Test preparation course'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<String>(
//                       (data) => data['test preparation course'].toString(),
//                       columnIndex,
//                       ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Math Score'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<int>((data) => int.parse(data['math score'].toString()),
//                       columnIndex, ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Reading Score'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<int>(
//                       (data) => int.parse(data['reading score'].toString()),
//                       columnIndex,
//                       ascending);
//                 },
//               ),
//               DataColumn(
//                 label: Text('Writing Score'),
//                 onSort: (columnIndex, ascending) {
//                   _sort<int>(
//                       (data) => int.parse(data['writing score'].toString()),
//                       columnIndex,
//                       ascending);
//                 },
//               ),
//             ],
//             rows: _data.map((data) {
//               return DataRow(cells: [
//                 DataCell(Text(data['gender'].toString())),
//                 DataCell(Text(data['race/ethnicity'].toString())),
//                 DataCell(Text(data['parental level of education'].toString())),
//                 DataCell(Text(data['lunch'].toString())),
//                 DataCell(Text(data['test preparation course'].toString())),
//                 DataCell(Text(data['math score'].toString())),
//                 DataCell(Text(data['reading score'].toString())),
//                 DataCell(Text(data['writing score'].toString())),
//               ]);
//             }).toList(),
//           ),
//         ),
