import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
class ModuleUsuarios extends StatefulWidget {
  @override
  _ModuleUsuariosState createState() => _ModuleUsuariosState();
}

class _ModuleUsuariosState extends State<ModuleUsuarios> {
  ScrollController scroll = ScrollController();
  List<ModelUser> usuarios = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: ApiUsers().get(),
            builder: (context, snapshot) {
              if(snapshot.hasError)
                SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                usuarios = snapshot.data;
                return Column(
                  children: [
                    Expanded(flex: 1,
                    child: Row(
                      children: [
                        WidgetHeaderList(flex: 1,text: "ACCIONES",),
                        WidgetHeaderList(flex: 3,text: "NOMBRE COMPLETO",),
                        WidgetHeaderList(flex: 2,text: "USUARIO",),
                        WidgetHeaderList(flex: 2,text: "CONTRASEÑA",),
                      ],
                    ),),
                    Expanded(
                      flex: 10,
                        child: Scrollbar(
                          controller: scroll,
                          isAlwaysShown: true,
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                ModelUser u = usuarios[index];
                                return Row(
                                  children: [
                                    Expanded(flex: 1,child:
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: (){
                                              _showDeleteUser(u);
                                            },
                                            child: Icon(Icons.delete_forever),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              cargarDatosUsuario(u);
                                              _showUserConfig("EDITAR USUARIO","EDITAR",(){
                                                ModelUser mu = ModelUser(
                                                  usuario: ecUsuario.text,
                                                  cargo: ecCargo.text,
                                                  carnetIdentidad: ecDocID.text,
                                                  apMaterno: ecApMaterno.text,
                                                  apPaterno: ecApPaterno.text,
                                                  email: ecCorreo.text,
                                                  nombres: ecNombres.text,
                                                  password: ecConAn.text,
                                                  modulos: u.modulos,
                                                  almacenes: u.almacenes,
                                                  fecCreacion: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                                                  fecUpdate: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                                                );
                                                ApiUsers().update(u.id,mu).whenComplete((){
                                                  usuarios[usuarios.indexOf(u)] = mu;
                                                  limpiarDatosUsuario();
                                                  Toast.show("USUARIO ACTUALIZADO CORRECTAMENTE", context);
                                                  setState(() {

                                                  });
                                                  Navigator.of(context).pop();
                                                });
                                              });
                                            },
                                            child: Icon(Icons.edit),
                                          )
                                        ],
                                      )
                                    ),
                                    Expanded(flex: 3,child:
                                    Text("${u.nombres} ${u.apPaterno} ${u.apMaterno}"),
                                    ),
                                    Expanded(flex: 2,child:
                                    Text(u.usuario),
                                    ),
                                    Expanded(flex: 2,child: Text(u.password),),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: usuarios.length
                          ),
                        ))
                  ],
                );
              }
              return LoadingPage();
            },
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              onTap: (){
                _showUserConfig("CREAR USUARIO","CREAR",(){
                  ModelUser mu = ModelUser(
                    usuario: ecUsuario.text.isNotEmpty?ecUsuario.text:"",
                    cargo: ecCargo.text.isNotEmpty?ecCargo.text:"",
                    carnetIdentidad: ecDocID.text.isNotEmpty?ecDocID.text:"",
                    apMaterno: ecApMaterno.text.isNotEmpty?ecApMaterno.text:"",
                    apPaterno: ecApPaterno.text.isNotEmpty?ecApPaterno.text:"",
                    email: ecCorreo.text.isNotEmpty?ecCorreo.text:"",
                    nombres: ecNombres.text.isNotEmpty?ecNombres.text:"",
                    password: ecConAn.text.isNotEmpty?ecConAn.text:"",
                    fecCreacion: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                    fecUpdate: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                  );
                  ApiUsers().crear(mu).whenComplete((){
                    usuarios.add(mu);
                    limpiarDatosUsuario();
                    Toast.show("USUARIO CREADO CORRECTAMENTE", context);
                    setState(() {

                    });
                    Navigator.of(context).pop();
                  });;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(50)
                ),
                child: Icon(Icons.add, color: Colors.white,),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextEditingController ecNombres = TextEditingController();
  TextEditingController ecApPaterno = TextEditingController();
  TextEditingController ecApMaterno = TextEditingController();
  TextEditingController ecDocID = TextEditingController();
  TextEditingController ecCorreo = TextEditingController();
  TextEditingController ecUsuario = TextEditingController();
  TextEditingController ecConAn = TextEditingController();
  TextEditingController ecCargo = TextEditingController();

  Future<void> _showUserConfig(String titulo, String titleButton, Function func) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width*0.6,
              child: ListBody(
                children: <Widget>[
                  TextBoxCustom(hint: "NOMBRES", controller: ecNombres,),
                  TextBoxCustom(hint: "APELLIDO PATERNO", controller: ecApPaterno,),
                  TextBoxCustom(hint: "APELLIDO MATERNO",controller: ecApMaterno,),
                  TextBoxCustom(hint: "DOCUMENTO DE IDENTIDAD", controller: ecDocID,),
                  TextBoxCustom(hint: "CORREO", controller: ecCorreo,),
                  TextBoxCustom(hint: "USUARIO", controller: ecUsuario,),
                  TextBoxCustom(hint: "CONTRASEÑA", controller: ecConAn,),
                  TextBoxCustom(hint: "CARGO", controller: ecCargo,),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(titleButton),
              onPressed: func,
            ),Container(),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                limpiarDatosUsuario();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteUser(ModelUser u) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ELIMINAR USUARIO"),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width*0.6,
              child: ListBody(
                children: <Widget>[
                  Text("SEGURO QUE QUIERE ELIMINAR EL USUARIO: ${u.usuario}?"),
                  Text("LOS DATOS SE PERDERAN PERMANENTEMENTE")
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("ACEPTAR"),
              onPressed: (){
                ApiUsers().delete(u.id).whenComplete((){
                  usuarios.removeAt(usuarios.indexOf(u));
                  limpiarDatosUsuario();
                  Toast.show("USUARIO ELIMINADO CORRECTAMENTE", context);
                  setState(() {

                  });
                  Navigator.of(context).pop();
                });
              },
            ),Container(),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                limpiarDatosUsuario();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void limpiarDatosUsuario() {
    ecNombres.text = "";
    ecApPaterno.text = "";
    ecApMaterno.text = "";
    ecDocID.text = "";
    ecCorreo.text = "";
    ecUsuario.text = "";
    ecConAn.text = "";
    ecCargo.text = "";
  }

  void cargarDatosUsuario(ModelUser u) {
    ecNombres.text = u.nombres;
    ecApPaterno.text = u.apPaterno;
    ecApMaterno.text = u.apMaterno;
    ecDocID.text = u.carnetIdentidad;
    ecCorreo.text = u.email;
    ecUsuario.text = u.usuario;
    ecConAn.text = u.password;
    ecCargo.text = u.cargo;
  }
}
