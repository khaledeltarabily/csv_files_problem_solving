import 'package:flutter/material.dart';
import 'package:problem_solving_kib/models/product.dart';
import 'package:problem_solving_kib/repo/file_repository.dart';
import 'package:problem_solving_kib/utils.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title,required this.fileRepo});
  final String title;
  final FileRepository fileRepo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: Text(widget.title,style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please Pick up CSV File',
            ),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("Choose File"),
            ),
          ],
        ),
      ),
    );
  }

  void _pickFile() async{
    //read file
    final file = await widget.fileRepo.readCSVFile();
    if(file == null){
      Utils.showSnackBar(scaffoldMessengerKey, "Please Choose Correct File");
     return;
    }
    final fileName = file.name;
    final fields =  await widget.fileRepo.convertCSVFileToList(file);
    if(fields == null || fields.isEmpty) {
      Utils.showSnackBar(scaffoldMessengerKey, "CSV File Empty");
      return;
    }
    print(fields[0]);
    var productsList = <Product>[];
    for (var line in fields[0]) {
      print("line ${line.toString()}");
      print("line.split(',') ${line.split(',')}");
      productsList.add(Product.fromList(line.split(',')));
    }
    print("******************** __________________ **********************");
    print("productsList __________________${productsList.toString()}");
  }

}
