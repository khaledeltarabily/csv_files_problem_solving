import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:problem_solving_kib/models/order.dart';

class FileRepository {
  final String averageQuantityCSVFileName = "0_";
  final String popularBrandCSVFileName = "1_";
  final String documentsPath = "/documents";

  String getAverageQuantityCSVFileName(String pickedFileName) => "$averageQuantityCSVFileName$pickedFileName" ;
  String getPopularBrandCSVFileName(String pickedFileName) => "$popularBrandCSVFileName$pickedFileName" ;

  bool _fileValidation(FilePickerResult? file){
    return file != null && file.count > 0;
  }

 Future<List<List<dynamic>>?> convertCSVFileToList(PlatformFile file) async{
  final filePath = file.path;
   if(filePath == null || filePath.isEmpty) return null;
   final input = File(filePath).openRead();
   final fields = await input
       .transform(utf8.decoder)
       .transform(const CsvToListConverter(fieldDelimiter: "\n"))
       .toList();
   return fields;
 }

 Future<PlatformFile?> readCSVFile() async {
    FilePickerResult? result = await  FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    bool isValidFile = _fileValidation(result);
    if (!isValidFile) return null;
    return result?.files.first;
 }


 Map<String,int> getProductsQuantityPerOrder(Order order,Map<String,int> productsPerOrder){
   productsPerOrder.update(order.name, (value) => value + order.quantity,ifAbsent:() => order.quantity);
   return productsPerOrder;
 }

  Map<String,Map<String,int>>  getPopularBrandsPerProduct(Order order,Map<String,Map<String,int>> popularBrandPerProduct){
    popularBrandPerProduct.update(
        order.name,
            (value) => value..update(order.brand, (value) => ++value,ifAbsent:() => 1),
        ifAbsent:() => <String,int>{order.brand:1}
    );
    return popularBrandPerProduct;
  }

  List<List<dynamic>> generateAvgQuantityProductRows(int totalOrders,Map<String,int> productsPerOrder){
    List<List<dynamic>> productsRows = [];
    for (String key in productsPerOrder.keys){
      productsRows.add([key,productsPerOrder[key]!/totalOrders]);
    }
    return productsRows;
  }

  List<List<dynamic>> generatePopularBrandRows(Map<String,Map<String,int>> popularBrandPerProduct){
    List<List<dynamic>> productsRows = [];
    for (String key in popularBrandPerProduct.keys){
      popularBrandPerProduct[key]?.values.toList(growable: false).sort();
      productsRows.add([key,popularBrandPerProduct[key]?.keys.first ?? ""]);
    }
    return productsRows;
  }


  Future<File?> generateCSVFile(
      String fileName,List<List<dynamic>> rows) async{
    String csv = const ListToCsvConverter().convert(rows);
    return createAndSaveCSVFile(fileName,csv);
  }



  Future<File?> createAndSaveCSVFile(String fileName,String csvRows) async{
    bool isGranted = await requestStoragePermission();
    if(!isGranted) return null;

    try{
      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationSupportDirectory();
      String fileDir = "${directory?.absolute.path}$documentsPath";
      File file =  File("$fileDir/$fileName");
      await file.create(recursive: true);
      await file.writeAsString(csvRows);
      return file;
    } catch(_){
      return null;
    }
  }

  Future<bool> requestStoragePermission() async{
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    final PermissionStatus status = await Permission.storage.request();
    return status.isGranted;
  }

}
