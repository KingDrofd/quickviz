import 'dart:io';

import 'package:quickviz/services/directory_handler.dart';

class CSVFILE {
  Directories directories = Directories();
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
}
