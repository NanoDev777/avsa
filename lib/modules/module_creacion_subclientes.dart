import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_subcliente.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_subclientes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_clientes.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
class ModelCreacionSubClientes extends StatefulWidget {
  @override
  _ModelCreacionSubClientesState createState() => _ModelCreacionSubClientesState();
}

class _ModelCreacionSubClientesState extends State<ModelCreacionSubClientes> {
  ScrollController scroll = ScrollController();
  List<ModelSubCliente> subCliente = List();
  List<ModelSubCliente> subClienteAll = List();
  ModelCliente selectCliente;
  StateSetter listRefresh;
  bool exist=false;
  bool ac = false;
  String subClienteEstado="";

  int sortRS=0;
  int sortIC=0;
  int sortCC=0;
  int sortPA=0;
  int sortPC=0;
  bool abCod=true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: ApiSubcliente().getNacional(),
            builder: (context, snapshot) {
              if(snapshot.hasError)
                SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                subClienteAll.clear();
                subCliente.clear();
                subClienteAll = snapshot.data;
                subCliente.addAll(subClienteAll);
                return Column(
                  children: [
                    Expanded(flex: 1,
                      child: Row(
                        children: [
                          WidgetHeaderList(flex: 1,text: "Habilitar",),
                          WidgetHeaderList(flex: 2,text: "RAZON SOCIAL",func: (){
                            listRefresh(() {
                              if (subCliente != null && sortRS == 0) {
                                sortRS = 1;
                                subCliente.sort((a, b) =>
                                    a.razonSocial.toLowerCase().compareTo(b.razonSocial.toLowerCase()));
                              } else if (subCliente != null) {
                                sortRS = 0;
                                subCliente.sort((a, b) =>
                                    b.razonSocial.toLowerCase().compareTo(a.razonSocial.toLowerCase()));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 2,text: "CODIGO SUBCLIENTE",func: (){
                            listRefresh(() {
                              if (subCliente != null && sortIC == 0) {
                                sortIC = 1;
                                subCliente.sort((a, b) =>
                                    a.id.compareTo(b.id));
                              } else if (subCliente != null) {
                                sortIC = 0;
                                subCliente.sort((a, b) =>
                                    b.id.compareTo(a.id));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 4,text: "CLIENTE",func: (){
                            listRefresh(() {
                              if (subCliente != null && sortCC == 0) {
                                sortCC = 1;
                                subCliente.sort((a, b) =>
                                    a.rs.compareTo(b.rs));
                              } else if (subCliente != null) {
                                sortCC = 0;
                                subCliente.sort((a, b) =>
                                    b.rs.compareTo(a.rs));
                              }
                            });
                          }),
                          WidgetHeaderList(flex: 2,text: "PERSONA DE CONTACTO",func: (){
                            listRefresh(() {
                              if (subCliente != null && sortCC == 0) {
                                sortCC = 1;
                                subCliente.sort((a, b) =>
                                    a.c_nombre.compareTo(b.c_nombre));
                              } else if (subCliente != null) {
                                sortCC = 0;
                                subCliente.sort((a, b) =>
                                    b.c_nombre.compareTo(a.c_nombre));
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
                            return Scrollbar(
                              controller: scroll,
                              isAlwaysShown: true,
                              child: ListView.separated(
                                controller: scroll,
                                  itemBuilder: (context, index) {
                                    ModelSubCliente u = subCliente[index];
                                    TextStyle s = TextStyle(fontSize: 12);
                                    return Row(
                                      children: [
                                        Expanded(flex: 1,child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Checkbox(
                                              value: u.estado==0?false:true,
                                              onChanged: (value) {
                                                listRefresh((){
                                                  u.estado=value==true?1:0;
                                                  ApiSubcliente().update(u).whenComplete(() {
                                                    // subCliente.add(u);
                                                    Toast.show("CLIENTE EDITADO CON EXITO", context);
                                                    allClear();
                                                    listRefresh(() {});
                                                  });
                                                });
                                              },
                                            ),
                                            InkWell(
                                              onTap: (){
                                                ac=true;
                                                selectCliente = ModelCliente(
                                                    id: u.id_cliente,
                                                  razonSocial: u.rs,
                                                  codigo: u.c
                                                );
                                                ecRazonSocial.text = u.razonSocial;
                                                ecNit.text = u.nit;
                                                ecDireccion.text = u.direccion;
                                                ecTelefono.text = u.telefono;
                                                ecPais.text = u.pais;
                                                ecCorreo.text = u.correo;
                                                ecCodigo.text = u.codigo;
                                                abCod=false;

                                                ecCNombre.text = u.c_nombre;
                                                ecCCargo.text = u.c_cargo;
                                                ecCDireccion.text = u.c_direccion;
                                                ecCPais.text = u.c_pais;
                                                ecCTelefono.text = u.c_telefono;
                                                ecCCorreo.text = u.c_correo;
                                                // ecCAdicional.text = u.;
                                                _showCLienteCreate("EDITAR CLIENTE","EDITAR", false, (){
                                                  ModelSubCliente mc = ModelSubCliente(
                                                      id: u.id,
                                                      codigo: u.codigo,
                                                      estado: u.estado,
                                                      correo: ecCorreo.text.isEmpty ? null : ecCorreo
                                                          .text,
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
                                                      c_nombre: ecCNombre.text.isEmpty
                                                          ? null
                                                          : ecCNombre.text,
                                                      direccion: ecDireccion.text,
                                                      nit: ecNit.text,
                                                      pais: ecPais.text,
                                                      razonSocial: ecRazonSocial.text,
                                                      telefono: ecTelefono.text.isEmpty
                                                          ? null
                                                          : ecTelefono.text,
                                                    rs: selectCliente.razonSocial,
                                                    id_cliente: selectCliente.id,
                                                    c: selectCliente.codigo
                                                  );
                                                  print(mc.id);
                                                  ApiSubcliente().update(mc).whenComplete(() {
                                                    listRefresh(() {
                                                      subCliente[index]=mc;
                                                      ac=false;
                                                      Toast.show("SUBCLIENTE EDITADO CON EXITO", context);
                                                      allClear();
                                                      Navigator.of(context).pop();
                                                    });

                                                  });
                                                });
                                              },
                                              child: Icon(Icons.edit),
                                            )
                                          ],
                                        )
                                        ),
                                        Expanded(flex: 2,child:
                                        Text("${u.razonSocial}", style: s,),
                                        ),
                                        Expanded(flex: 2,child:
                                        Center(child: Text(u.codigo, style: s,)),
                                        ),
                                        Expanded(flex: 4,child: Text("${u.rs} - ${u.c}", style: s,),),
                                        Expanded(flex: 2,child: Text(u.c_nombre!=null?u.c_nombre:"", style: s,),),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, index) => Divider(),
                                  itemCount: subCliente.length
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
                int cod = subCliente.length+1;
                abCod=true;
                ecCodigo.text="";
                _showCLienteCreate("CREAR SUBCLIENTE","CREAR",true,(){
                  if (ecRazonSocial.text.isNotEmpty) {
                    if (ecNit.text.isNotEmpty) {
                      if (ecDireccion.text.isNotEmpty) {
                        if (ecPais.text.isNotEmpty) {
                          if (ecCodigo.text.isNotEmpty) {
                            ModelSubCliente mc = ModelSubCliente(
                              codigo: ecCodigo.text,
                              razonSocial: ecRazonSocial.text,
                              nit: ecNit.text,
                              direccion: ecDireccion.text,
                              pais: ecPais.text,
                              estado: 1,
                              tipo: selectCliente.tipo,
                              id_cliente: selectCliente.id,
                              telefono: ecTelefono.text.isEmpty?null:ecTelefono.text,
                              correo: ecCorreo.text.isEmpty?null:ecCorreo.text,
                              c_nombre: ecCNombre.text.isEmpty?null:ecCNombre.text,
                              c_cargo: ecCCargo.text.isEmpty?null:ecCCargo.text,
                              c_direccion: ecCDireccion.text.isEmpty?null:ecCDireccion.text,
                              c_pais: ecCPais.text.isEmpty?null:ecCPais.text,
                              c_telefono: ecCTelefono.text.isEmpty?null:ecCTelefono.text,
                              c_correo: ecCCorreo.text.isEmpty?null:ecCCorreo.text,
                              c_adicionales: ecCAdicional.text.isEmpty?null:ecCAdicional.text,
                              rs: selectCliente.razonSocial,
                              c: selectCliente.codigo
                            );
                            ApiSubcliente().make(mc).whenComplete(() {
                              listRefresh(() {
                                subCliente.add(mc);
                                Toast.show("SUBCLIENTE CREADO CON EXITO", context, duration: Toast.LENGTH_LONG);
                                allClear();
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

  Future<void> _showCLienteCreate(String titulo, String titleButton, bool enable, Function func) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle style = TextStyle(color: Colors.white);
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(titulo),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width*0.9,
                child: ListBody(
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
                              child: Center(child: Text("DATOS DEL SUBCLIENTE", style: style,))),
                          DropDownClientes(clienteSelection: selectCliente,refresh: (val,v,ref){
                            setState(() {
                              selectCliente = val;
                            });
                          },),
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
                                child: TextBoxCustom(
                                  hint: "CODIGO SUBCLIENTE",controller: ecCodigo ,maxLength: 4,
                                  enabled: abCod,
                                  onChange: (val){
                                    setState((){
                                      if(val.length==4){
                                        subClienteAll.forEach((element) {
                                          if(!exist && element.codigo.toUpperCase()==ecCodigo.text.toUpperCase()){
                                            exist=true;
                                          }
                                          if(exist)subClienteEstado="CODIGO EXISTENTE";
                                          else subClienteEstado="CODIGO LIBRE";
                                        });
                                      }else{ exist=false; subClienteEstado="CODIGO INCOMPLETO";}
                                    });
                                  },),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Text(subClienteEstado, style: TextStyle(color: !exist?Colors.green:Colors.red),))
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
                  // limpiarDatosUsuario();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },);
      },
    );
  }

  void allClear() {
    abCod=true;
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
}
