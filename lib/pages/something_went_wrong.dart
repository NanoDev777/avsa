
import 'package:andeanvalleysystem/widgets/widget_somethin_went_wrong_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class SomethingWentWrongPage extends StatefulWidget {
  final String msj;
  SomethingWentWrongPage({Key key,this.msj}):super(key:key);
  @override
  _SomethingWentWrongPageState createState() => _SomethingWentWrongPageState();
}

class _SomethingWentWrongPageState extends State<SomethingWentWrongPage> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      desktop: SomethinWentWrongWeb(msj: widget.msj,),
      mobile: Container(),
    );
  }
}
