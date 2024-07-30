import 'package:flutter/material.dart';
class WidgetLoginMobile extends StatefulWidget {
  @override
  _WidgetLoginMobileState createState() => _WidgetLoginMobileState();
}

class _WidgetLoginMobileState extends State<WidgetLoginMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              child: Column(
                children: [
                  TextFormField(),
                  TextFormField(),
                  Container(
                    child: Text("INGRESAR"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
