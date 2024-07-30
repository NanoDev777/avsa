import 'package:andeanvalleysystem/widgets/widget_loading_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      desktop: WidgetLoadingWeb(),
      mobile: Container(),
    );
  }
}
