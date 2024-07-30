import 'package:andeanvalleysystem/models/model_module.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/widgets/drop_down_usuarios.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
class ModuleAccesosUsuarios extends StatefulWidget {
  const ModuleAccesosUsuarios({Key key}) : super(key: key);

  @override
  _ModuleAccesosUsuariosState createState() => _ModuleAccesosUsuariosState();
}

class _ModuleAccesosUsuariosState extends State<ModuleAccesosUsuarios> {
  ModelUser userSelect;
  List<ModelModule> modulos = List();
  List<ModelModule> subModulos = List();
  int indexModuloSelect=-1;
  ModelUser usuario;
  ModelUser lastUser;

  StateSetter refreshData;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FutureBuilder<Map<String,List<ModelModule>>>(
          future: ApiConnections().getModules(0),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              SomethingWentWrongPage();
            if(snapshot.connectionState == ConnectionState.done){
              modulos.clear();
              subModulos.clear();
              modulos.addAll(snapshot.data['modulos']);
              subModulos.addAll(snapshot.data['submodulos']);
              return Container(
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  children: [
                    DropDownUsuarios(userSelection: userSelect,refresh: (val){
                      setState(() {
                        userSelect = val;
                        ApiUsers().getUser(val.id).then((value){
                          usuario = value;
                        }).whenComplete((){
                          print(usuario.modulos);
                          subModulos.forEach((element) {
                            List<String> ms = usuario.modulos.split(',');
                            print("$ms::${element.name}");
                            if(ms.contains(element.name)) {
                              print("entro ${element.name}");
                              subModulos[subModulos.indexOf(element)].activo =
                              true;
                            }
                          });
                        });
                      });
                    },),
                    SizedBox(height: 10,),
                    WidgetButtons(colorText: Colors.white, color1: Colors.green, color2: Colors.lightGreen,txt: "GUARDAR CAMBIOS",
                    func: (){
                      setState(() {
                        String modules="";
                        subModulos.forEach((element) {
                          if(element.activo)
                            modules+="${element.name},";
                        });
                        print(modules);
                        usuario.modulos = modules;
                        ApiUsers().update(usuario.id, usuario).whenComplete((){
                          Toast.show("CAMBIOS CORRECTOS", context, duration: Toast.LENGTH_LONG);
                        });
                        clean();
                      });
                    },),
                    SizedBox(height: 10,),
                    Expanded(
                      child: Container(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            refreshData = setState;
                            return ListView.builder(
                              itemCount: modulos.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: (){
                                    if(userSelect!=null){
                                      refreshData(() {
                                        if(indexModuloSelect==index)
                                          indexModuloSelect=-1;
                                        else indexModuloSelect=index;
                                      });
                                    }else Toast.show("SELECCIONE UN USUARIO", context);
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context).size.width*0.4,
                                            child: Text(modulos[index].name,textAlign: TextAlign.center,
                                              style: TextStyle(color: Colors.black),),
                                          ),
                                          Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.black,)
                                        ],
                                      ),
                                      index==indexModuloSelect&&userSelect!=null?Column(
                                        children: subModulos.map((e){
                                          if(e.patern==modulos[indexModuloSelect].id) {
                                            return Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(e.name),
                                                Checkbox(
                                                    value: e.activo, onChanged: (val) {
                                                  setState(() {
                                                    e.activo =val;
                                                  });
                                                })
                                              ],
                                            );
                                          }else return Container();
                                        }).toList(),
                                      ):Container()
                                    ],
                                  ),
                                );
                              },);
                          },
                        )
                      ),
                    )
                  ],
                ),
              );
            }
            return LoadingPage();
          }
        )
      ],
    );
  }

  void clean() {
    userSelect = null;
    indexModuloSelect = -1;
    usuario = null;
  }
}
