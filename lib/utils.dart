
import 'package:flutter/material.dart';

class Utils {

  static void showSnackBar(GlobalKey<ScaffoldMessengerState> scaffoldKey,value){
    final snackBar = SnackBar(
        content: Text(value)
    );
    scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}