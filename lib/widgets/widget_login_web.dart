
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:andeanvalleysystem/widgets/widget_main_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class WidgetLoginWeb extends StatefulWidget {
  @override
  _WidgetLoginWebState createState() => _WidgetLoginWebState();
}

class _WidgetLoginWebState extends State<WidgetLoginWeb> {

  String errTxtUsuario;
  TextEditingController ecUsuario = TextEditingController();
  String errTxtPass;
  TextEditingController ecPass = TextEditingController();

  Future verifyUser()async{
    await SharedPreferences.getInstance().then((sp){
      if(sp.containsKey("sessionID") && sp.containsKey("userName")){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WidgetMainPage(),));
      }else{
        return false;
      }
    });
    return false;
  }

  @override
  void initState() {
    verifyUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset("assets/images/fondo1.png", fit: BoxFit.fill,),
          ),
          Column(
          children: [
            SizedBox(height: 50,),
            Center(child:Image.asset("assets/images/logo.png")),
            SizedBox(height: 50,),
            Center(
              child: Container(
                padding: EdgeInsets.all(2),
                width: 400,
                height: 220,
                child: Center(
                  child: Column(
                    children: [
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              color: Colors.white
                            ),
                            child: Row(
                              children: [
                                Image.asset("assets/images/usuario1.png",width: 60,height: 60,),
                                Expanded(
                                  flex: 9,
                                  child: Container(
                                    child: TextField(
                                      controller: ecUsuario,
                                      style: TextStyle(color: Colors.blueGrey),
                                      decoration: InputDecoration(isDense: false,
                                          border: InputBorder.none,
                                          labelText: "USUARIO",
                                          labelStyle: TextStyle(color: Colors.grey),
                                          errorText: errTxtUsuario,
                                          errorStyle: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width *
                                                  .006)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10,),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: Colors.white
                            ),
                            child: Row(
                              children: [
                                Image.asset("assets/images/password1.png",width: 60,height: 60,),
                                Expanded(
                                  flex:9,
                                  child: Container(
                                    // margin: EdgeInsets.fromLTRB(60, 2, 30, 2),
                                    child: TextField(
                                      onSubmitted: (value) {
                                        submitProcess();
                                      },
                                      controller: ecPass,
                                      obscureText: true,
                                      style: TextStyle(color: Colors.blueGrey),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                          labelText: "CONTRASEÑA",
                                          labelStyle: TextStyle(color: Colors.grey),
                                          errorText: errTxtPass,
                                          errorStyle: TextStyle(
                                              fontSize: MediaQuery.of(context).size.width *
                                                  .006)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10,),
                      WidgetButtons(color1: Colors.grey,color2: Colors.blueGrey,
                        colorText: Colors.white,txt: "INGRESAR", func: (){
                          submitProcess();
                        },)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ])
    );
  }
  submitProcess(){
    ApiConnections().loginUser(ecUsuario.text, ecPass.text).then((value){
      if(value!=null){
        SharedPreferences.getInstance().then((sp) {
          sp.setInt("sessionID", value.id);
          sp.setString("userName", value.name);
          sp.setString("almacenes", value.almacenes);
          sp.setString("modulos", value.modulos);

          sp.setString("nombres", value.nombres);
          sp.setString("apPaterno", value.apPaterno);
          sp.setString("apMAterno", value.apMaterno);
          sp.setString("carnetIdentidad", value.carnetIdentidad);
          sp.setString("email", value.email);
          sp.setString("password", value.password);
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WidgetMainPage(),));
      }else{
        Toast.show("Usuario no Encontrado", context, duration: Toast.LENGTH_LONG);
      }
    });
  }
}
