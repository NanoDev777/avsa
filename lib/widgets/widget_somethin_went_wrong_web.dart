
import 'package:flutter/material.dart';
class SomethinWentWrongWeb extends StatefulWidget {
  final String msj;

  SomethinWentWrongWeb({Key key,this.msj}):super(key:key);

  @override
  _SomethinWentWrongWebState createState() => _SomethinWentWrongWebState();
}

class _SomethinWentWrongWebState extends State<SomethinWentWrongWeb> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Text("Algo Salio Mal!!!!!! ERR:${widget.msj}"),
        )
      ],
    );
  }
}
