import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';

class FileRepository {
  Future<FilePickerResult?> _openFileExplorer() async =>
      FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

  bool _fileValidation(FilePickerResult? file){
    return file != null && file.count > 0;
  }

 Future<List<List<dynamic>>?> convertCSVFileToList(PlatformFile file) async{
  final filePath = file.path;
   if(filePath == null || filePath.isEmpty) return null;
   final input = File(filePath).openRead();
   final fields = await input
       .transform(utf8.decoder)
       .transform(const CsvToListConverter())
       .toList();
   return fields;
 }

 Future<PlatformFile?> readCSVFile() async {
    FilePickerResult? result = await _openFileExplorer();
    bool isValidFile = _fileValidation(result);
    if (!isValidFile) return null;
    return result?.files.first;
 }

 String generateCSVFile(String fileName){
    return"";
 }

 void getProductsAverageQuantity(){

 }

  void getProductsMostPopularBrand(){

  }

}
