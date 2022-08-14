import 'package:flutter/material.dart';
import 'package:problem_solving_kib/app.dart';
import 'package:problem_solving_kib/repo/file_repository.dart';

void main() {
  final fileRepo = FileRepository();
  runApp(MyApp(fileRepo: fileRepo));
}

