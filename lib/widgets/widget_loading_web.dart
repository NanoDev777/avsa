import 'package:flutter/material.dart';
class WidgetLoadingWeb extends StatefulWidget {
  @override
  _WidgetLoadingWebState createState() => _WidgetLoadingWebState();
}

class _WidgetLoadingWebState extends State<WidgetLoadingWeb> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: Container(width: 30,height: 30,child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
        ))),
        // Center(child: Image.asset("assets/images/logo_red_solo.png",width: 40,height: 40,))7
      ],
    );
  }
}
