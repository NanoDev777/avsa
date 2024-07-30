import 'package:flutter/material.dart';
class TextBoxCustom extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final String error;
  final bool enabled;
  final bool obscure;
  final Function onChange;
  final maxLength;

  TextBoxCustom({Key key,this.hint, this.controller, this.error, this.enabled=true, this.obscure=false, this.maxLength=null, this.onChange(String value)}):super(key:key);

  @override
  _TextBoxCustomState createState() => _TextBoxCustomState();
}

class _TextBoxCustomState extends State<TextBoxCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      child: TextFormField(
        maxLength: widget.maxLength,
        controller: widget.controller,
        enabled: widget.enabled,
        obscureText: widget.obscure,
        decoration: InputDecoration(
          errorText: widget.error,
          border: OutlineInputBorder(),
          labelText: widget.hint,
        ),
        onChanged: (value){
          widget.onChange(value);
        },
      ),
    );
  }
}
