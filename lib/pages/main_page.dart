import 'package:andeanvalleysystem/widgets/widget_main_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      desktop: WidgetMainPage(),
      mobile: Container(),
    );
  }
}
