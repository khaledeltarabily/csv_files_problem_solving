import 'dart:io';

import 'package:flutter/material.dart';
import 'package:problem_solving_kib/models/order.dart';
import 'package:problem_solving_kib/repo/file_repository.dart';
import 'package:problem_solving_kib/utils.dart';
import 'package:share_plus/share_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.fileRepo});
  final String title;
  final FileRepository fileRepo;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  List<Map<String, File>> filesList = <Map<String, File>>[];
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 45),
          const Text(
            'Please Pick up CSV File',
            style: TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text("Choose File"),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Divider(
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 15),
          isLoading
              ? const CircularProgressIndicator.adaptive(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
              : Expanded(
                  child: filesList.isEmpty
                      ? const Center(
                          child: Text(
                            'No Files Generated',
                          ),
                        )
                      : ListView.builder(
                          itemCount: filesList.length,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: InkWell(
                                  onTap: () => Share.shareFiles(
                                      [filesList[index].values.first.path],
                                      text: filesList[index].keys.first),
                                  child: Card(
                                    color: Colors.grey.shade700,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 15,
                                      ),
                                      child: Text(
                                        filesList[index].keys.first,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  )),
                            );
                          }),
                )
        ],
      ),
    );
  }

  void _pickFile() async {
    final isGranted = await widget.fileRepo.requestStoragePermission();
    if (!isGranted) return;

    //read file
    final file = await widget.fileRepo.readCSVFile();
    if (file == null) {
      Utils.showSnackBar(scaffoldMessengerKey, "Please Choose Correct File");
      return;
    }

    final fileName = file.name;
    final fields = await widget.fileRepo.convertCSVFileToList(file);
    if (fields == null || fields.isEmpty) {
      Utils.showSnackBar(scaffoldMessengerKey, "CSV File Empty");
      return;
    }

    setState(() => isLoading = true);
    filesList = [];

    final totalOrders = fields[0].length;
    Map<String, int> productsPerOrder = <String, int>{}; //<ProductName,Quantity>
    Map<String, Map<String, int>> popularBrandPerProduct = <String, Map<String, int>>{}; //<ProductName,<Brand,Count>>
    //loop on csv file rows
    for (var line in fields[0]) {
      final order = Order.fromList(line.split(','));

      productsPerOrder =
          widget.fileRepo.getProductsQuantityPerOrder(order, productsPerOrder);
      popularBrandPerProduct =
          widget.fileRepo.getPopularBrandsPerProduct(order, popularBrandPerProduct);
    }

    //Generate 0_order_log00 file
    final avgQuantityProductList = widget.fileRepo.generateAvgQuantityProductRows(totalOrders, productsPerOrder);
    final avgQuantityProductFileName = widget.fileRepo.getAverageQuantityCSVFileName(fileName);
    final avgQuantityProductPerOrderFile = await widget.fileRepo.generateCSVFile(
            avgQuantityProductFileName, avgQuantityProductList);

    if (avgQuantityProductPerOrderFile != null) filesList.add({avgQuantityProductFileName: avgQuantityProductPerOrderFile});


    //Generate 1_order_log00 file
    final mostPopularBrandForProductList = widget.fileRepo.generatePopularBrandRows(popularBrandPerProduct);

    final mostPopularBrandFileName = widget.fileRepo.getPopularBrandCSVFileName(fileName);
    final mostPopularBrandForProductFile = await widget.fileRepo.generateCSVFile(mostPopularBrandFileName, mostPopularBrandForProductList);

    if (mostPopularBrandForProductFile != null) filesList.add({mostPopularBrandFileName: mostPopularBrandForProductFile});

    setState(() => isLoading = false);
  }
}
