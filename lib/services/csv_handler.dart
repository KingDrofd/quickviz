import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quickviz/services/directory_handler.dart';

class CSVFILE {
  Directories directories = Directories();

  Future<List<Map<String, dynamic>>> loadCsvFile() async {
    try {
      File csvFile = await directories.getCSVPath();
      String content = await csvFile.readAsString();

      List<List<dynamic>> csvTable =
          const CsvToListConverter().convert(content);
      List<String> header =
          csvTable.isNotEmpty ? List.from(csvTable.first) : ["unknown"];

      return csvTable
          .skip(1)
          .map((row) => Map.fromIterables(header, row.map((item) {
                return item.toString();
              })))
          .toList();
    } catch (e) {
      print('Error reading CSV file: $e');
      return [];
    }
  }

  void removeQuotationMarks(String filePath) async {
    try {
      // Read the content of the CSV file
      String content = await File(filePath).readAsString();

      // Remove quotation marks from the content
      content = content.replaceAll('"', '');

      // Write the modified content back to the file
      await File(filePath).writeAsString(content);

      print('Quotation marks removed successfully.');
    } catch (e) {
      print('Error removing quotation marks: $e');
    }
  }

  Future<void> saveCsvFile(String filePath, List<String> header,
      List<Map<String, dynamic>> data) async {
    try {
      File newCsvFile = File(filePath);

      // Write header to the file
      await newCsvFile.writeAsString('${header.join(',')}\n');

      // Write data to the file
      for (var row in data) {
        await newCsvFile.writeAsString('${row.values.join(',')}\n',
            mode: FileMode.append);
      }
    } catch (e) {
      print('Error saving CSV file: $e');
    }
  }
}
