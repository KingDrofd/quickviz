import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Directories {
  Future<String> getDocumentsDirectoryPath() async {
    Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    return appDocumentsDir.path;
  }

  Future<File> getCSVPath() async {
    String appDocumentsDir = await getDocumentsDirectoryPath();
    final File file = File(
        '$appDocumentsDir/dataset/students performance/StudentsPerformance_csv.csv');
    return file;
  }
}
