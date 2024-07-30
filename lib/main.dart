
import 'package:andeanvalleysystem/pages/LoginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Andean Valley',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        secondaryHeaderColor: Color.fromRGBO(68, 209, 49, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}
