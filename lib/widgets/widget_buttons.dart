
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class WidgetButtons extends StatefulWidget {
  final Function func;
  final Color color1;
  final Color color2;
  final Color colorText;
  final String txt;

  WidgetButtons(
      {Key key,this.func, this.color1, this.color2, this.colorText, this.txt}):super(key:key);

  @override
  _WidgetButtonsState createState() => _WidgetButtonsState();
}

class _WidgetButtonsState extends State<WidgetButtons> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.func,
      child: Container(
        width: 200,
        height: 40,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.5, 10),
                  blurRadius: 20
              )
            ]
        ),
        child: Center(child: Text(widget.txt, style: TextStyle(color: widget.colorText, fontWeight: FontWeight.bold),)),
      ),
    );
  }
}
