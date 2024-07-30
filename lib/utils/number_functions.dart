import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class NumberFunctions{
  static String formatNumber(double numero, int decimalDigits){
    return NumberFormat.currency(locale: 'eu', symbol: '',decimalDigits: decimalDigits).format(numero);
  }
}