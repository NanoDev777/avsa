import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_precios.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_precios.dart';
import 'package:andeanvalleysystem/widgets/drop_down_clientes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:andeanvalleysystem/widgets/multi_choise.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:universal_html/html.dart';
class ModuleCreacionPrecios extends StatefulWidget {
  final int tipoCliente;

  ModuleCreacionPrecios({this.tipoCliente});

  @override
  _ModuleCreacionPreciosState createState() => _ModuleCreacionPreciosState();
}

class _ModuleCreacionPreciosState extends State<ModuleCreacionPrecios> {
  ScrollController scroll = ScrollController();
  List<ModelPrecios> precios = List();
  StateSetter listRefresh;
  StateSetter refreshAll;
  bool exist=false;
  List<ModelPrecios> listPrecios = List();
  bool active=true;

  List<String> keys = List();
  List<int> guias = List();
  Map<String,List<ModelPrecios>> agrupados = Map();
  List<ModelItem> itemsSeleccionadosDialog = List();
  Map<String,ModelPrecios> preciosSeleccionados = Map();

  int sortNombreList = 0;
  int sortCliente = 0;
  int sortCodigo = 0;

  clearAll(){
    listPrecios.clear();
    active=true;
    ecNombreLista.text="";
    ecPrecioUnitario.text="";
    selectClient=null;
    controllers.clear();
  }

  Future getData()async{
    precios.clear();
    agrupados.clear();
    keys.clear();
    listPrecios.clear();
    precios = await ApiPrecios().get();
    precios.forEach((element) {
      if(agrupados.containsKey(element.nombre_grupo)){
        agrupados[element.nombre_grupo].add(element);
      }else{
        agrupados[element.nombre_grupo] = List();
        keys.add(element.nombre_grupo);
        guias.add(element.guia);
        agrupados[element.nombre_grupo].add(element);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              refreshAll = setState;
              return FutureBuilder(
                future: getData(),
                builder: (context, snapshot) {
                  if(snapshot.hasError)
                    SomethingWentWrongPage();
                  if(snapshot.connectionState == ConnectionState.done){
                    print(snapshot.data.toString());
                    return Column(
                      children: [
                        Expanded(flex: 1,
                          child: Row(
                            children: [
                              WidgetHeaderList(flex: 1,text: "HABILITAR"),
                              WidgetHeaderList(flex: 3,text: "NOMBRE LISTA",func: (){
                                listRefresh(() {
                                  if (precios != null && sortNombreList == 0) {
                                    sortNombreList = 1;
                                    precios.sort((a, b) =>
                                        a.nombre_grupo.toLowerCase().compareTo(b.nombre_grupo.toLowerCase()));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  } else if (precios != null) {
                                    sortNombreList = 0;
                                    precios.sort((a, b) =>
                                        b.nombre_grupo.toLowerCase().compareTo(a.nombre_grupo.toLowerCase()));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  }
                                });
                              },),
                              WidgetHeaderList(flex: 3,text: "CLIENTE",func: (){
                                listRefresh(() {
                                  if (precios != null && sortCliente == 0) {
                                    sortCliente = 1;
                                    precios.sort((a, b) =>
                                        a.nombre_cliente.toLowerCase().compareTo(b.nombre_cliente.toLowerCase()));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  } else if (precios != null) {
                                    sortCliente = 0;
                                    precios.sort((a, b) =>
                                        b.nombre_cliente.toLowerCase().compareTo(a.nombre_cliente.toLowerCase()));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  }
                                });
                              },),
                              WidgetHeaderList(flex: 2,text: "CODIGO",func: (){
                                listRefresh(() {
                                  if (precios != null && sortCodigo == 0) {
                                    sortCodigo = 1;
                                    precios.sort((a, b) =>
                                        a.cod_cliente.compareTo(b.cod_cliente));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  } else if (precios != null) {
                                    sortCodigo = 0;
                                    precios.sort((a, b) =>
                                        b.cod_cliente.compareTo(a.cod_cliente));
                                    keys.clear();
                                    for(int i=0;i<precios.length;i++){
                                      keys.add(precios[i].nombre_grupo);
                                    }
                                  }
                                });
                              },),
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
                                        return Row(
                                          children: [
                                            Expanded(flex: 1,child:
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: agrupados[keys[index]][0].estado==0?false:true,
                                                      onChanged: (value) {
                                                        listRefresh((){
                                                          agrupados[keys[index]][0].estado=value==true?1:0;
                                                          if(value) {
                                                            ApiPrecios()
                                                                .habilitar(agrupados[keys[index]][0].guia)
                                                                .whenComplete(() {
                                                              // subCliente.add(u);
                                                              Toast.show(
                                                                  "EDITADO CON EXITO",
                                                                  context);
                                                              clearAll();
                                                              listRefresh(() {});
                                                            });
                                                          }else{
                                                            ApiPrecios()
                                                                .desabilitar(agrupados[keys[index]][0].guia)
                                                                .whenComplete(() {
                                                              // subCliente.add(u);
                                                              Toast.show(
                                                                  "EDITADO CON EXITO",
                                                                  context);
                                                              clearAll();
                                                              listRefresh(() {});
                                                            });
                                                          }
                                                        });
                                                      },
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        active=false;
                                                        listPrecios.clear();
                                                        agrupados[keys[index]].forEach((value) {
                                                          ModelPrecios m = ModelPrecios(
                                                              guia: value.guia,
                                                              id_cliente: value.id_cliente,
                                                              estado: value.estado,
                                                              nombre_grupo: value.nombre_grupo,
                                                              codProd: value.codProd,
                                                              nombre: value.nombre,
                                                              nombre_cliente: value.nombre_cliente,
                                                              precio_unitario: value.precio_unitario,
                                                              cod_cliente: value.cod_cliente
                                                          );
                                                          listPrecios.add(m);
                                                          controllers.add(TextEditingController());
                                                          controllers[listPrecios.indexOf(m)].text = value.precio_unitario.toString();
                                                        });
                                                        ecNombreLista.text = agrupados[keys[index]][0].nombre_grupo;

                                                        _showPrecioCreate("EDITAR", "EDITAR",agrupados[keys[index]][0], (){
                                                          listPrecios.forEach((element) {
                                                            element.precio_unitario = double.parse(controllers[listPrecios.indexOf(element)].text);

                                                          });
                                                          ApiPrecios().update(listPrecios,listPrecios[0].nombre_grupo).whenComplete((){
                                                            refreshAll((){
                                                              Toast.show("EDITADO CON EXITO", context);
                                                              Navigator.of(context).pop();
                                                            });
                                                          });
                                                        });
                                                      },
                                                      child: Icon(Icons.edit),
                                                    )
                                                  ],
                                                )
                                              ],
                                            )
                                            ),
                                            Expanded(flex: 3,child:
                                            Text("${agrupados[keys[index]][0].nombre_grupo}",style: s,),
                                            ),
                                            Expanded(flex: 3,child:
                                            Text("${agrupados[keys[index]][0].nombre_cliente}",style: s,),
                                            ),
                                            Expanded(flex: 2,child: Center(child: Text("${agrupados[keys[index]][0].cod_cliente}",style: s,)),),
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) => Divider(),
                                      itemCount: keys.length
                                  ),
                                );
                              },
                            ))
                      ],
                    );
                  }
                  return LoadingPage();
                },
              );
            }
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: InkWell(
              onTap: (){
                _showPrecioCreate("CREAR LISTA DE PRECIOS", "CREAR", null, (){
                  ApiPrecios().count().then((value){
                    int i = value;
                    i+=1;

                    listPrecios.forEach((element) {
                      element.precio_unitario = double.parse(controllers[listPrecios.indexOf(element)].text);
                      element.guia = i;
                    });
                    ApiPrecios().make(listPrecios).whenComplete((){
                      refreshAll((){
                        Toast.show("Lista Agregada Correctamete", context);
                        Navigator.of(context).pop();
                      });
                    });
                  });
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

  TextEditingController ecNombreLista = TextEditingController();
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
  TextEditingController ecPrecioUnitario = TextEditingController();
  ModelCliente selectClient;
  ModelItem selectItem;

  List<TextEditingController> controllers = List();
  Future<void> _showPrecioCreate(String titulo, String titleButton, ModelPrecios mp, Function func) async {
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
                              child: Center(child: Text("DATOS DE LA LISTA", style: style,))),
                          DropDownClientes(tipoCliente: widget.tipoCliente, clienteSelection: selectClient,
                            listClient: null,
                            id: mp!=null?mp.id_cliente:null,
                            enabled: active,
                            refresh: (val,v,ref){
                              selectClient = val;
                            // setState(() {
                            // });
                          },),
                          TextBoxCustom(hint: "NOMBRE DE LA LISTA", controller: ecNombreLista,
                            enabled: active
                            ,onChange: (val){},),
                          // DropDownProductos(
                          //   selectionItem: selectItem,
                          //   idCliente: selectClient!=null?selectClient.id:mp!=null?mp.id_cliente:-1,
                          //   soloCliente: true,
                          //   func: (val){
                          //     setState((){
                          //       selectItem = val;
                          //     });
                          //   },
                          // ),
                          WidgetButtons(txt: "ESCOGER PRODUCTOS", colorText: Colors.white,func: (){
                            itemsSeleccionadosDialog.clear();
                            listPrecios.forEach((element) {
                              ModelItem mi = ModelItem(
                                codigo: element.codProd,
                              );
                              mi.cantidad = element.cantidad;
                              mi.precio = element.precio_unitario!=null?element.precio_unitario:0;
                              itemsSeleccionadosDialog.add(mi);
                            });
                            // ignore: missing_return
                            MultiChoise().ProductMultichoiseXClientes(context,selectClient, itemsSeleccionadosDialog,(val){
                              listPrecios.clear();
                              controllers.clear();
                              Map<String,ModelPrecios> aux = preciosSeleccionados;
                              preciosSeleccionados.clear();
                              setState(() {
                                val.forEach((element) {
                                  if(aux.containsKey(element.codigo)){
                                    preciosSeleccionados[element.codigo]=aux[element.codigo];
                                    listPrecios.add(aux[element.codigo]);
                                    TextEditingController t = TextEditingController();
                                    t.text = aux[element.codigo].precio_unitario!=null?aux[element.codigo].precio_unitario.toString():"0";
                                    controllers.add(t);
                                    selectItem=null;
                                    ecPrecioUnitario.text=aux[element.codigo].precio_unitario!=null?aux[element.codigo].precio_unitario.toString():"0";
                                  }else{
                                    ModelPrecios m = ModelPrecios(
                                        id_cliente: selectClient!=null?selectClient.id:mp.id_cliente,
                                        estado: 1,
                                        nombre_grupo: ecNombreLista.text,
                                        codProd: element.codigo,
                                        nombre: element.nombre,
                                        nombre_cliente: selectClient!=null?selectClient.razonSocial:mp.nombre_cliente,
                                        precio_unitario: element.precio!=null?element.precio:0,
                                        cod_cliente: selectClient!=null?selectClient.codigo:"",
                                        guia: mp!=null?mp.guia:0
                                    );
                                    preciosSeleccionados[element.codigo]=m;
                                    listPrecios.add(m);
                                    TextEditingController t = TextEditingController();
                                    t.text = m.precio_unitario!=null?m.precio_unitario.toString():"0";
                                    controllers.add(t);
                                    selectItem=null;
                                    ecPrecioUnitario.text = m.precio_unitario!=null?m.precio_unitario.toString():"0";
                                  }
                                  // ModelPrecios m = ModelPrecios(
                                  //     id_cliente: selectClient!=null?selectClient.id:mp.id_cliente,
                                  //     estado: 1,
                                  //     nombre_grupo: ecNombreLista.text,
                                  //     codProd: element.codigo,
                                  //     nombre: element.nombre,
                                  //     nombre_cliente: selectClient!=null?selectClient.razonSocial:mp.nombre_cliente,
                                  //     precio_unitario: 0,
                                  //     cod_cliente: selectClient!=null?selectClient.codigo:"",
                                  //     guia: mp!=null?mp.guia:0
                                  // );

                                });
                              });
                            });
                          },),
                          // TextBoxCustom(hint: "PRECIO (BS/U)", controller: ecPrecioUnitario,onChange: (val){},),
                          // WidgetButtons(txt: "AGREGAR PRECIO",colorText: Colors.white,func: (){
                          //   bool exist=false;
                          //   listPrecios.forEach((element) {
                          //     if(!exist && element.codProd==selectItem.codigo)
                          //       exist=true;
                          //   });
                          //   if(!exist){
                          //     active=false;
                          //     ModelPrecios m = ModelPrecios(
                          //         id_cliente: selectClient!=null?selectClient.id:mp.id_cliente,
                          //         estado: 1,
                          //         nombre_grupo: ecNombreLista.text,
                          //         codProd: selectItem.codigo,
                          //         nombre: selectItem.nombre,
                          //         nombre_cliente: selectClient!=null?selectClient.razonSocial:mp.nombre_cliente,
                          //         precio_unitario: double.parse(ecPrecioUnitario.text),
                          //         cod_cliente: selectClient!=null?selectClient.codigo:"",
                          //       guia: mp.guia
                          //     );
                          //
                          //     setState((){
                          //       listPrecios.add(m);
                          //       controllers.add(TextEditingController());
                          //       controllers[listPrecios.indexOf(m)].text = ecPrecioUnitario.text;
                          //       selectItem=null;
                          //       ecPrecioUnitario.text="";
                          //     });
                          //   }else Toast.show("ESTE PRODUCTO YA EXISTE", context);
                          // },)
                        ],
                      ),
                    ),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        WidgetHeaderList(flex: 1,text: "",),
                        WidgetHeaderList(flex: 3,text: "CODIGO",),
                        WidgetHeaderList(flex: 4,text: "DESCRIPCION",),
                        WidgetHeaderList(flex: 3,text: "PRECIO [Bs/u]",),
                      ],
                    ),
                    Container(
                      clipBehavior: Clip.antiAlias,
                      padding: EdgeInsets.only(left: 3,right: 3,bottom: 3),
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(20),
                        // border: Border.all(color: Colors.black12,width: 1)
                      ),
                      child: Column(
                        children: [
                          Column(
                            children: listPrecios.map((e){
                              TextStyle ts = TextStyle(fontSize: 12);
                              return Row(
                                children: [
                                  Expanded(
                                      flex:1,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          // InkWell(
                                          //   onTap: (){
                                          //
                                          //   },
                                          //     child: Icon(Icons.edit)),
                                          InkWell(
                                            onTap: (){
                                              setState((){
                                                print("${listPrecios.indexOf(e)}");
                                                controllers.removeAt(listPrecios.indexOf(e));
                                                listPrecios.removeAt(listPrecios.indexOf(e));
                                              });
                                            },
                                              child: Icon(Icons.delete_forever)),
                                        ],
                                      )
                                  ),
                                  Expanded(
                                    flex:3,
                                      child: Text(e.codProd,style: ts,)),
                                  Expanded(
                                      flex:4,
                                      child: Text(e.nombre,style: ts,)),
                                  Expanded(
                                      flex:3,
                                      child: Center(child: TextBoxCustom(
                                        controller: controllers[listPrecios.indexOf(e)],
                                        hint: "Precio",
                                        onChange: (val){
                                          try{
                                            double d = double.parse(val);
                                            if(val.isNotEmpty){
                                              setState((){
                                                print("entro");
                                                itemsSeleccionadosDialog[listPrecios.indexOf(e)].precio = d;
                                                listPrecios[listPrecios.indexOf(e)].precio_unitario = d;
                                                // ecPrecios[listSelectPrecios.indexOf(e)].text = val;
                                              });
                                            }
                                          }catch(e){
                                            Toast.show("Numero incorrecto", context);
                                          }
                                        },
                                      ))
                                  )
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      )
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
                  clearAll();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },);
      },
    );
  }

  Future<void> _showPrecioEdit(String titulo, String titleButton, List<ModelPrecios> p, Function func) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle style = TextStyle(color: Colors.white);
        return StatefulBuilder(builder: (context, setState) {
          ecNombreLista.text = p[0].nombre_grupo;
          controllers.clear();
          int c=0;
          p.forEach((element) {
            controllers.add(TextEditingController());
            controllers[c].text = "${p[c].precio_unitario}";
            c++;
          });
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
                              child: Center(child: Text("DATOS DE LA LISTA", style: style,))),
                          Text("CLIENTE: ${p[0].nombre_cliente}"),
                          TextBoxCustom(hint: "NOMBRE DE LA LISTA", controller: ecNombreLista,
                            enabled: active
                            ,onChange: (val){},),
                        ],
                      ),
                    ),
                    SizedBox(height: 3,),
                    Row(
                      children: [
                        WidgetHeaderList(flex: 1,text: "",),
                        WidgetHeaderList(flex: 3,text: "CODIGO",),
                        WidgetHeaderList(flex: 4,text: "DESCRIPCION",),
                        WidgetHeaderList(flex: 3,text: "PRECIO [Bs/u]",),
                      ],
                    ),
                    Container(
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.only(left: 3,right: 3,bottom: 3),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(20),
                          // border: Border.all(color: Colors.black12,width: 1)
                        ),
                        child: Column(
                          children: [
                            Column(
                              children: p.map((e){
                                TextStyle ts = TextStyle(fontSize: 12);
                                return Row(
                                  children: [
                                    Expanded(
                                        flex:1,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            // InkWell(
                                            //     onTap: (){
                                            //       setState((){
                                            //         print("${p.indexOf(e)}");
                                            //         controllers.removeAt(p.indexOf(e));
                                            //         // p.removeAt(p.indexOf(e));
                                            //         p[p.indexOf(e)].accion = 1;
                                            //       });
                                            //     },
                                            //     child: Icon(Icons.delete_forever)),
                                          ],
                                        )
                                    ),
                                    Expanded(
                                        flex:3,
                                        child: Text(e.codProd,style: ts,)),
                                    Expanded(
                                        flex:4,
                                        child: Text(e.nombre,style: ts,)),
                                    Expanded(
                                        flex:3,
                                        child: TextFormField(
                                          controller: controllers[p.indexOf(e)],
                                        )
                                    )
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        )
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
                  clearAll();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },);
      },
    );
  }
  //
  // void allClear() {
  //   ecRazonSocial.text = "";
  //   ecNit.text = "";
  //   ecDireccion.text = "";
  //   ecTelefono.text = "";
  //   ecPais.text = "";
  //   ecCorreo.text = "";
  //   ecCodigo.text = "";
  //
  //   ecCNombre.text = "";
  //   ecCCargo.text = "";
  //   ecCDireccion.text = "";
  //   ecCPais.text = "";
  //   ecCTelefono.text = "";
  //   ecCCorreo.text = "";
  //   ecCAdicional.text = "";
  // }
}
