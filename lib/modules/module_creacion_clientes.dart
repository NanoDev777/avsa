import 'dart:convert';

import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
class ModuleCracionClientes extends StatefulWidget {
  final int tipoCliente;

  ModuleCracionClientes({Key key,this.tipoCliente}):super(key: key);

  @override
  _ModuleCracionClientesState createState() => _ModuleCracionClientesState();
}

class _ModuleCracionClientesState extends State<ModuleCracionClientes> {
  ScrollController scroll = ScrollController();
  List<ModelCliente> cliente = List();
  List<ModelCliente> clientesNacionales = List();
  List<ModelCliente> clientesNacionalesAll = List();
  List<ModelCliente> clientesActivos = List();
  List<ModelCliente> clientesInactivos = List();
  StateSetter listRefresh;
  bool exist=false;
  bool creando=false;
  bool ac=false;
  String clienteEstado="";

  int sortRS=0;
  int sortIC=0;
  int sortCC=0;
  int sortPA=0;
  int sortPC=0;

  Future getData()async{
    if(widget.tipoCliente==2){
      cliente.clear();
      clientesNacionalesAll.clear();
      clientesNacionales.clear();
      cliente = await ApiCliente().get();
      clientesNacionalesAll = await ApiCliente().getNacional();
      clientesNacionales.addAll(clientesNacionalesAll);
      clientesNacionales.forEach((element) {
        if(element.estado==1) clientesActivos.add(element);
        else clientesInactivos.add(element);
      });
    }else if (widget.tipoCliente==1){
      cliente.clear();
      clientesNacionalesAll.clear();
      clientesNacionales.clear();
      cliente = await ApiCliente().get();
      clientesNacionalesAll = await ApiCliente().getExterior();
      clientesNacionales.addAll(clientesNacionalesAll);
      clientesNacionales.forEach((element) {
        if(element.estado==1) clientesActivos.add(element);
        else clientesInactivos.add(element);
      });
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if(snapshot.hasError)
                SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                return Column(
                  children: [
                    Expanded(flex: 1,
                      child: Row(
                        children: [
                          WidgetHeaderList(flex: 1,text: "Habilitar",),
                          WidgetHeaderList(flex: 3,text: "RAZON SOCIAL",func: (){
                            listRefresh(() {
                              if (clientesNacionales != null && sortRS == 0) {
                                sortRS = 1;
                                clientesNacionales.sort((a, b) =>
                                    a.razonSocial.compareTo(b.razonSocial));
                              } else if (clientesNacionales != null) {
                                sortRS = 0;
                                clientesNacionales.sort((a, b) =>
                                    b.razonSocial.compareTo(a.razonSocial));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 2,text: "ID CLIENTE",func: (){
                            listRefresh(() {
                              if (clientesNacionales != null && sortIC == 0) {
                                sortIC = 1;
                                clientesNacionales.sort((a, b) =>
                                    a.id.compareTo(b.id));
                              } else if (clientesNacionales != null) {
                                sortIC = 0;
                                clientesNacionales.sort((a, b) =>
                                    b.id.compareTo(a.id));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 2,text: "CODIGO CLIENTE",func: (){
                            listRefresh(() {
                              if (clientesNacionales != null && sortCC == 0) {
                                sortCC = 1;
                                clientesNacionales.sort((a, b) =>
                                    a.codigo.compareTo(b.codigo));
                              } else if (clientesNacionales != null) {
                                sortCC = 0;
                                clientesNacionales.sort((a, b) =>
                                    b.codigo.compareTo(a.codigo));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 2,text: "PAIS",func: (){
                        listRefresh(() {
                        if (clientesNacionales != null && sortPA == 0) {
                          sortPA = 1;
                        clientesNacionales.sort((a, b) =>
                        a.pais.compareTo(b.pais));
                        } else if (clientesNacionales != null) {
                          sortPA = 0;
                        clientesNacionales.sort((a, b) =>
                        b.pais.compareTo(a.pais));
                        }
                        });
                        }),
                          WidgetHeaderList(flex: 2,text: "PERSONA DE CONTACTO",func: (){
                            listRefresh(() {
                              if (clientesNacionales != null && sortPC == 0) {
                                sortPC = 1;
                                clientesNacionales.sort((a, b) =>
                                    a.contacto.compareTo(b.contacto));
                              } else if (clientesNacionales != null) {
                                sortPC = 0;
                                clientesNacionales.sort((a, b) =>
                                    b.contacto.compareTo(a.contacto));
                              }
                            });
                          }),
                        ],
                      ),),
                    Expanded(
                        flex: 10,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            listRefresh = setState;
                            TextStyle s = TextStyle(fontSize: 12);
                            return Scrollbar(
                              controller: scroll,
                              isAlwaysShown: true,
                              child: ListView.separated(
                                controller: scroll,
                                  itemBuilder: (context, index) {
                                    ModelCliente u = clientesNacionales[index];
                                    return Row(
                                      children: [
                                        Expanded(flex: 1,child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            InkWell(
                                                onTap: (){

                                                },
                                                child: Checkbox(
                                                  value: u.estado==0?false:true,
                                                  onChanged: (value) {
                                                    listRefresh((){
                                                      u.estado=value==true?1:0;
                                                      ApiCliente().update(u).whenComplete(() {
                                                        // cliente.add(u);
                                                        Toast.show("CLIENTE EDITADO CON EXITO", context);
                                                        allClear();
                                                        listRefresh(() {});
                                                      });
                                                    });
                                                  },
                                                )
                                            ),
                                            InkWell(
                                              onTap: (){
                                                ac=true;
                                                ecRazonSocial.text = u.razonSocial;
                                                ecNit.text = u.nit;
                                                ecDireccion.text = u.direccion;
                                                ecTelefono.text = u.telf;
                                                ecPais.text = u.pais;
                                                ecCorreo.text = u.email;
                                                ecCodigo.text = u.codigo;

                                                ecCNombre.text = u.contacto;
                                                ecCCargo.text = u.c_cargo;
                                                ecCDireccion.text = u.c_direccion;
                                                ecCPais.text = u.c_pais;
                                                ecCTelefono.text = u.c_telefono;
                                                ecCCorreo.text = u.c_correo;
                                                // ecCAdicional.text = u.;
                                                _showCLienteCreate("EDITAR CLIENTE","EDITAR", false, (){
                                                  ModelCliente mc = ModelCliente(
                                                      id: u.id,
                                                      estado: u.estado,
                                                      email: ecCorreo.text.isEmpty ? null : ecCorreo
                                                          .text,
                                                      codigo: ecCodigo.text.toUpperCase(),
                                                      tipo: widget.tipoCliente,
                                                      c_cargo: ecCCargo.text.isEmpty
                                                          ? null
                                                          : ecCCargo.text,
                                                      c_correo: ecCCorreo.text.isEmpty
                                                          ? null
                                                          : ecCCorreo.text,
                                                      c_direccion: ecCDireccion.text.isEmpty
                                                          ? null
                                                          : ecCDireccion.text,
                                                      c_pais: ecCPais.text.isEmpty ? null : ecCPais
                                                          .text,
                                                      c_telefono: ecCTelefono.text.isEmpty
                                                          ? null
                                                          : ecCTelefono.text,
                                                      contacto: ecCNombre.text.isEmpty
                                                          ? ""
                                                          : ecCNombre.text,
                                                      direccion: ecDireccion.text,
                                                      nit: ecNit.text,
                                                      pais: ecPais.text,
                                                      razonSocial: ecRazonSocial.text,
                                                      telf: ecTelefono.text.isEmpty
                                                          ? null
                                                          : ecTelefono.text
                                                  );
                                                  print(mc.id);
                                                  ApiCliente().update(mc).whenComplete(() {
                                                    setState((){
                                                      clientesNacionales[index] = mc;
                                                      ac=false;
                                                      Toast.show("CLIENTE EDITADO CON EXITO", context);
                                                      allClear();
                                                      Navigator.of(context).pop();
                                                    });
                                                  });
                                                });
                                              },
                                              child: Icon(Icons.edit),
                                            ),
                                          ],
                                        )
                                        ),
                                        Expanded(flex: 3,child:
                                          Text("${u.razonSocial}",style: s),
                                        ),
                                        Expanded(flex: 2,child:
                                        Center(child: Text("${u.id.toString().padLeft(5,'0')}",style: s,)),
                                        ),
                                        Expanded(flex: 2,child:
                                        Center(child: Text(u.codigo,style: s,)),
                                        ),
                                        Expanded(flex: 2,child: Center(child: Text(u.pais,style: s,)),),
                                        Expanded(flex: 2,child: Text(u.contacto,style: s,),),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) => Divider(),
                                  itemCount: clientesNacionales.length
                              ),
                            );
                          },
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
                _showCLienteCreate("CREAR CLIENTE","CREAR", true,(){
                  if(!creando && !exist) {
                    if (ecRazonSocial.text.isNotEmpty) {
                      if (ecNit.text.isNotEmpty) {
                        if (ecDireccion.text.isNotEmpty) {
                          if (ecPais.text.isNotEmpty) {
                            if (ecCodigo.text.isNotEmpty) {
                              listRefresh((){
                                creando=true;
                                ModelCliente mc = ModelCliente(
                                    estado: 1,
                                    email: ecCorreo.text.isEmpty ? null : ecCorreo
                                        .text,
                                    codigo: ecCodigo.text.toUpperCase(),
                                    tipo: 2,
                                    c_cargo: ecCCargo.text.isEmpty
                                        ? null
                                        : ecCCargo.text,
                                    c_correo: ecCCorreo.text.isEmpty
                                        ? null
                                        : ecCCorreo.text,
                                    c_direccion: ecCDireccion.text.isEmpty
                                        ? null
                                        : ecCDireccion.text,
                                    c_pais: ecCPais.text.isEmpty ? null : ecCPais
                                        .text,
                                    c_telefono: ecCTelefono.text.isEmpty
                                        ? null
                                        : ecCTelefono.text,
                                    contacto: ecCNombre.text.isEmpty
                                        ? null
                                        : ecCNombre.text,
                                    direccion: ecDireccion.text,
                                    nit: ecNit.text,
                                    pais: ecPais.text,
                                    razonSocial: ecRazonSocial.text,
                                    telf: ecTelefono.text.isEmpty
                                        ? null
                                        : ecTelefono.text
                                );
                                ApiCliente().make(mc).then((val) {
                                  clientesNacionales.add(val);
                                  Toast.show("CLIENTE CREADO CON EXITO", context);
                                  allClear();
                                  listRefresh(() {});
                                  Navigator.of(context).pop();
                                });
                              });
                            } else
                              Toast.show("NECESITA COLOCAR UN CODIGO", context);
                          } else
                            Toast.show("NECESITA COLOCAR UN PAIS", context);
                        } else
                          Toast.show("NECESITA COLOCAR UNA DIRECCION", context);
                      } else
                        Toast.show("NECESITA COLOCAR UN NIT", context);
                    } else
                      Toast.show("NECESITA COLOCAR UNA RAZON SOCIAL", context);
                  }else
                    Toast.show("CODIGO DE CLIENTE YA EXISTE", context);
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

  TextEditingController ecRazonSocial = TextEditingController();
  TextEditingController ecNit = TextEditingController();
  TextEditingController ecDireccion = TextEditingController();
  TextEditingController ecTelefono = TextEditingController();
  TextEditingController ecPais = TextEditingController();
  TextEditingController ecCorreo = TextEditingController();
  TextEditingController ecCodigo = TextEditingController();

  TextEditingController ecCNombre = TextEditingController();
  TextEditingController ecCCargo = TextEditingController();
  TextEditingController ecCDireccion = TextEditingController();
  TextEditingController ecCPais = TextEditingController();
  TextEditingController ecCTelefono = TextEditingController();
  TextEditingController ecCCorreo = TextEditingController();
  TextEditingController ecCAdicional = TextEditingController();

  Future<void> _showCLienteCreate(String titulo, String titleButton, bool enabled, Function func) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle style = TextStyle(color: Colors.white);
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width*0.9,
              child: StatefulBuilder(
                builder: (context, setState) {
                  return ListBody(
                    children: <Widget>[
                      Container(
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.only(left: 3,right: 3,bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          // border: Border.all(color: Colors.black12,width: 1)
                        ),
                        child: Column(
                          children: [
                            Container(
                                width: double.infinity,
                                color: Theme.of(context).secondaryHeaderColor,
                                child: Center(child: Text("DATOS DE LA EMPRESA", style: style,))),
                            TextBoxCustom(hint: "RAZON SOCIAL", controller: ecRazonSocial,onChange: (val){},),
                            TextBoxCustom(hint: "NIT", controller: ecNit,onChange: (val){},),
                            Row(
                              children: [
                                Expanded(flex:1,child: TextBoxCustom(hint: "DIRECCION",controller: ecDireccion,onChange: (val){},)),
                                Expanded(flex:1,child:TextBoxCustom(hint: "PAIS", controller: ecPais,onChange: (val){},)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(flex:1,child:TextBoxCustom(hint: "TELEFONO", controller: ecTelefono,onChange: (val){},)),
                                Expanded(flex:1,child:TextBoxCustom(hint: "CORREO", controller: ecCorreo,onChange: (val){},)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: TextBoxCustom(hint: "CODIGO CLIENTE",
                                    controller: ecCodigo,maxLength: 3,enabled: enabled,
                                    onChange: (val){
                                    setState((){
                                      if(val.length==3){
                                        cliente.forEach((element) {
                                          if(!exist && element.codigo.toUpperCase()==ecCodigo.text.toUpperCase()){
                                            exist=true;
                                          }
                                          if(exist)clienteEstado="CODIGO EXISTENTE";
                                          else clienteEstado="CODIGO LIBRE";
                                        });
                                      }else{ exist=false; clienteEstado="CODIGO INCOMPLETO";}
                                    });
                                  },),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(clienteEstado, style: TextStyle(color: !exist?Colors.green:Colors.red),))
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3,),
                      Container(
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.only(left: 3,right: 3,bottom: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          // border: Border.all(color: Colors.black12,width: 1)
                        ),
                        child: Column(
                          children: [
                            Container(
                                width: double.infinity,
                                color: Theme.of(context).secondaryHeaderColor,
                                child: Center(child: Text("DATOS DE CONTACTO", style: style,))),
                            TextBoxCustom(hint: "NOMBRE", controller: ecCNombre,onChange: (val){},),
                            TextBoxCustom(hint: "CARGO", controller: ecCCargo,onChange: (val){},),
                            Row(
                              children: [
                                Expanded(flex:1,child: TextBoxCustom(hint: "DIRECCION",controller: ecCDireccion,onChange: (val){},)),
                                Expanded(flex:1,child:TextBoxCustom(hint: "PAIS", controller: ecCPais,onChange: (val){},)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(flex:1,child:TextBoxCustom(hint: "TELEFONO", controller: ecCTelefono,onChange: (val){},)),
                                Expanded(flex:1,child:TextBoxCustom(hint: "CORREO", controller: ecCCorreo,onChange: (val){},)),
                              ],
                            ),
                            TextBoxCustom(hint: "DATOS ADICIONALES", controller: ecCAdicional,onChange: (val){},),
                          ],
                        ),
                      )
                    ],
                  );
                },
              )
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(titleButton),
              onPressed: (){
                listRefresh((){
                  func();
                });
              },
            ),Container(),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                allClear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void allClear() {
    creando=false;
    ecRazonSocial.text = "";
    ecNit.text = "";
    ecDireccion.text = "";
    ecTelefono.text = "";
    ecPais.text = "";
    ecCorreo.text = "";
    ecCodigo.text = "";

    ecCNombre.text = "";
    ecCCargo.text = "";
    ecCDireccion.text = "";
    ecCPais.text = "";
    ecCTelefono.text = "";
    ecCCorreo.text = "";
    ecCAdicional.text = "";
  }
  //
  // Future<void> _showDeleteUser(ModelUser u) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // user must tap button!
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("ELIMINAR USUARIO"),
  //         content: SingleChildScrollView(
  //           child: Container(
  //             width: MediaQuery.of(context).size.width*0.6,
  //             child: ListBody(
  //               children: <Widget>[
  //                 Text("SEGURO QUE QUIERE ELIMINAR EL USUARIO: ${u.usuario}?"),
  //                 Text("LOS DATOS SE PERDERAN PERMANENTEMENTE")
  //               ],
  //             ),
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("ACEPTAR"),
  //             onPressed: (){
  //               ApiUsers().delete(u.id).whenComplete((){
  //                 usuarios.removeAt(usuarios.indexOf(u));
  //                 limpiarDatosUsuario();
  //                 Toast.show("USUARIO ELIMINADO CORRECTAMENTE", context);
  //                 setState(() {
  //
  //                 });
  //                 Navigator.of(context).pop();
  //               });
  //             },
  //           ),Container(),
  //           TextButton(
  //             child: Text('CANCELAR'),
  //             onPressed: () {
  //               limpiarDatosUsuario();
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void limpiarDatosUsuario() {
  //   ecNombres.text = "";
  //   ecApPaterno.text = "";
  //   ecApMaterno.text = "";
  //   ecDocID.text = "";
  //   ecCorreo.text = "";
  //   ecUsuario.text = "";
  //   ecConAn.text = "";
  //   ecCargo.text = "";
  // }
  //
  // void cargarDatosUsuario(ModelUser u) {
  //   ecNombres.text = u.nombres;
  //   ecApPaterno.text = u.apPaterno;
  //   ecApMaterno.text = u.apMaterno;
  //   ecDocID.text = u.carnetIdentidad;
  //   ecCorreo.text = u.email;
  //   ecUsuario.text = u.usuario;
  //   ecConAn.text = u.password;
  //   ecCargo.text = u.cargo;
  // }
}
