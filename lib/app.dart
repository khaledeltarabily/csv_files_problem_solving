import 'package:flutter/material.dart';
import 'package:problem_solving_kib/pages/home_page.dart';
import 'package:problem_solving_kib/repo/file_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key,required this.fileRepo});

  final FileRepository fileRepo;

  final Color blue = const Color(0xff013492);
  final Color green = const Color(0xff007B5E);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KIB',
      theme: ThemeData(
        snackBarTheme: const SnackBarThemeData().copyWith(
          actionTextColor: Colors.white,
          contentTextStyle: const TextStyle(color: Colors.white) ,
        ),
        appBarTheme: const AppBarTheme().copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.black12
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.dark,
          primary: blue,
          secondary: green,
        ),
      ),
      home: MyHomePage(
        title: 'Please Choose CVS File',
        fileRepo: fileRepo,
      ),
    );
  }
}