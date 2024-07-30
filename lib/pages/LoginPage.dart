import 'package:andeanvalleysystem/widgets/widget_login_mobile.dart';
import 'package:andeanvalleysystem/widgets/widget_login_web.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout(
      desktop: WidgetLoginWeb(),
      mobile: WidgetLoginMobile(),
    );
  }
}
