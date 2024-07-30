
import 'package:flutter/material.dart';
class WidgetHeaderList extends StatefulWidget {
  final String text;
  final int flex;
  final height;
  Function func;

  WidgetHeaderList({Key key,this.text, this.flex, this.height=null, this.func}):super(key: key);

  @override
  _WidgetHeaderListState createState() => _WidgetHeaderListState();
}

class _WidgetHeaderListState extends State<WidgetHeaderList> {
  @override
  Widget build(BuildContext context) {
    if(widget.flex!=null){
      return Expanded(
        flex: widget.flex,
          child: InkWell(
            onTap: widget.func,
            child: Container(
              height: widget.height!=null?widget.height:null,
                width: double.infinity,
                color: Colors.blueGrey,
                child: Center(
                  child: Text(widget.text, textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 13),),
                )
            ),
          ));
    }else {
      return Expanded(
          child: Container(
              width: double.infinity,
              color: Colors.blueGrey,
              child: Text(widget.text, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 13),)
          ));
    }
  }
}
