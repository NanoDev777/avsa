import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/modules/module_creacion_proformas.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_proformas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModulePedidosAbiertos extends StatefulWidget {
  @override
  _ModulePedidosAbiertosState createState() => _ModulePedidosAbiertosState();
}

class _ModulePedidosAbiertosState extends State<ModulePedidosAbiertos> {
  TextEditingController ecSearch = TextEditingController();
  ScrollController scroll = ScrollController();
  StateSetter refreshList;
  List<ModelProforma> proformas;

  List<String> keys = List();
  Map<String, double> costosTotal = Map();

  bool tipoasc=true;
  bool documentoasc=true;
  bool almacenasc=true;
  bool motivoasc=true;
  bool areaSolicitanteasc=true;

  int fechaA = 0;
  int codigoA = 0;
  int clienteA = 0;
  int subClienteA = 0;
  int precioA = 0;
  int tipoPagoA = 0;

  List<ModelProformaItems> itemsList = List();
  Map<int,List<ModelProformaItems>> items = Map();
  Map<int,double> totales = Map();
  Map<int,double> CantidadesTotales = Map();
  Map<int,double> pesoTotal = Map();
  int idUser;
  StateSetter refreshAll;

  Future getData()async{
    // proformas.clear();
    // itemsList.clear();
    items.clear();
    SharedPreferences sp = await SharedPreferences.getInstance();
    idUser = sp.getInt("sessionID");
    proformas = await ApiProformas().getPedidos();
    itemsList = await ApiProformas().getItems();
    itemsList.forEach((element) {
      if(items.containsKey(element.idProforma)){
        items[element.idProforma].add(element);
        totales[element.idProforma] += element.cantidad*element.precio;
        CantidadesTotales[element.idProforma] += element.cantidad;
        pesoTotal[element.idProforma] += element.cantidad*element.pesoNeto;
      }else{
        items[element.idProforma] = List();
        items[element.idProforma].add(element);
        totales[element.idProforma] = element.cantidad*element.precio;
        CantidadesTotales[element.idProforma] = element.cantidad;
        pesoTotal[element.idProforma] = element.cantidad*element.pesoNeto;
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: StatefulBuilder(
          builder: (context, setState) {
            refreshAll = setState;
            return FutureBuilder(
              future: getData(),//ApiProformas().get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return SomethingWentWrongPage();
                if (snapshot.connectionState == ConnectionState.done) {
                  // proformas = snapshot.data;
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          flex: 10,
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  children: [
                                    WidgetHeaderList(text: "FECHA", flex: 1,func:(){
                                      refreshList((){
                                        if(proformas!=null && fechaA==0) {
                                          fechaA=1;
                                          proformas.sort((a, b) =>
                                              a.fec_creacion.compareTo(b.fec_creacion));
                                        }else  if(proformas!=null){
                                          fechaA=0;
                                          proformas.sort((a, b) =>
                                              b.fec_creacion.compareTo(a.fec_creacion));
                                        }
                                      });
                                    }),
                                    WidgetHeaderList(text: "PEDIDO",flex: 1,func: (){
                                      refreshList((){
                                        if(proformas!=null && codigoA==0) {
                                          codigoA=1;
                                          proformas.sort((a, b) =>
                                              a.codigo.compareTo(b.codigo));
                                        }else  if(proformas!=null){
                                          codigoA=0;
                                          proformas.sort((a, b) =>
                                              b.codigo.compareTo(a.codigo));
                                        }
                                      });
                                    },),
                                    WidgetHeaderList(text: "CLIENTE",flex: 2,func: (){
                                      refreshList((){
                                        if(proformas!=null && clienteA==0) {
                                          clienteA=1;
                                          proformas.sort((a, b) =>
                                              a.nombreCliente.compareTo(b.nombreCliente));
                                        }else  if(proformas!=null){
                                          clienteA=0;
                                          proformas.sort((a, b) =>
                                              b.nombreCliente.compareTo(a.nombreCliente));
                                        }
                                      });
                                    },),
                                    WidgetHeaderList(text: "SUBCLIENTE",flex: 2,func: (){
                                      refreshList((){
                                        if(proformas!=null && subClienteA==0) {
                                          subClienteA=1;
                                          proformas.sort((a, b) =>
                                              a.nombreSubCliente.compareTo(b.nombreSubCliente));
                                        }else  if(proformas!=null){
                                          subClienteA=0;
                                          proformas.sort((a, b) =>
                                              b.nombreSubCliente.compareTo(a.nombreSubCliente));
                                        }
                                      });
                                    },),
                                    WidgetHeaderList(text: "CANTIDAD TOTAL\n[KILOGRAMOS]",flex: 2,func: (){},),
                                    WidgetHeaderList(text: "COSTO TOTAL\n[Bs]",flex: 1,func: (){},),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 9,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      refreshList = setState;
                                      return Scrollbar(
                                        controller: scroll,
                                        isAlwaysShown: true,
                                        child: ListView.separated(
                                          controller: scroll,
                                          itemCount: proformas.length,
                                          separatorBuilder: (context, index) => Divider(),
                                          itemBuilder: (context, index) {
                                            ModelProforma p = proformas[index];
                                            List<String> fec = p.fec_aprob.split('-');
                                            return InkWell(
                                              onTap: (){
                                                _showDialog(p);
                                              },
                                              child: Row(
                                                children: [
                                                  Expanded(flex: 1,child: Text("${fec[2]}/${fec[1]}/${fec[0]}")),
                                                  Expanded(flex:1,child: Container(
                                                      padding: EdgeInsets.only(left: 3,right: 3),
                                                      child: Text("${p.codigo}"))
                                                  ),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  Expanded(flex:2,child: Container(
                                                      padding: EdgeInsets.only(left: 3,right: 3),
                                                      child: Column(
                                                        children: [
                                                          Text(p.nombreCliente),
                                                        ],
                                                      ))),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  Expanded(flex:2,child: Container(
                                                      padding: EdgeInsets.only(left: 3,right: 3),
                                                      child: Text(p.nombreSubCliente))),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  Expanded(flex:2,child: Container(
                                                      padding: EdgeInsets.only(left: 3,right: 3),
                                                      child: Column(
                                                        children: [
                                                          Text(NumberFunctions.formatNumber(pesoTotal[p.id], 3)),
                                                        ],
                                                      ))),
                                                  Container(
                                                    width: 1,
                                                    height: 20,
                                                    color: Colors.blueGrey,
                                                  ),
                                                  Expanded(flex:1,child: Container(
                                                      padding: EdgeInsets.only(left: 3,right: 3),
                                                      child: Column(
                                                        children: [
                                                          Text(NumberFunctions.formatNumber(totales[p.id], 3)),
                                                        ],
                                                      ))),
                                                ],
                                              ),
                                            );
                                          },),
                                      );
                                    },
                                  )
                              ),
                            ],
                          )
                      )
                    ],
                  );
                }
                return LoadingPage();
              },
            );
          }
        ));
  }

  double cantidadTotal=0;
  double costoTotal=0;
  Future<void> _showDialog(ModelProforma p) async {
    List<ModelProformaItems> it = items[p.id];
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle style = TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
        TextStyle style1 = TextStyle(fontSize: 10);
        return AlertDialog(
          title: Text('DETALLES'),
          content: Container(
            width: MediaQuery.of(context).size.width*.8,
            height: MediaQuery.of(context).size.height*.8,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("CODIGO: ${p.codigo}", style: style,),
                  Text("CLIENTE: ${p.nombreCliente}", style: style,),
                  Text("SUBCLIENTE: ${p.nombreSubCliente}", style: style,),
                  Text("PRECIO: ${p.nombrePrecio}", style: style,),
                  Text("TIPO PAGO: ${p.id_tipo_pago}", style: style,),
                  Text("OBSERVACIONES: ${p.obs}", style: style,),
                  ListCustom(
                    modelHeaderList: [
                      ModelHeaderList(title: "CODIGO PRODUCTO", flex: 1),
                      ModelHeaderList(title: "PRODUCTO", flex: 2),
                      ModelHeaderList(title: "PRECIO[Bs]", flex: 1),
                      ModelHeaderList(title: "CANTIDAD\n[UNIDADES]", flex: 1),
                      ModelHeaderList(title: "CANTIDAD \n[CAJAS/BOLSAS]", flex: 1),
                      ModelHeaderList(title: "PESO TOTAL\n[KG]", flex: 1),
                      ModelHeaderList(title: "VALOR TOTAL\n[Bs]", flex: 1),
                    ],
                    title: "PRODUCTOS",
                    datos: it.map((e){
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1,child: Text(e.codProd, style: style1,)),
                              Expanded(flex: 2,child: Text(e.nameProd, style: style1,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.precio,3)}", style: style1,textAlign: TextAlign.center,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.cantidad,3)}", style: style1,textAlign: TextAlign.center,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.cantidadCajasBolsas,3)}", style: style1,textAlign: TextAlign.right,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.pesoNeto*e.cantidad,3)}", style: style1,textAlign: TextAlign.right,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.valorTotal,3)}", style: style1,textAlign: TextAlign.right,)),
                            ],
                          ),
                          Container(height: 1,color: Colors.grey,)
                        ],
                      );
                    }).toList(),
                  ),

                  // Container(height: 1,color: Colors.grey,),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         flex: 1,
                  //         child: Text("CANTIDAD TOTAL:", style: style,)),
                  //     Expanded(
                  //         flex: 1,
                  //         child: Text("${NumberFunctions.formatNumber(cantidadTotal,3)}", style: style,)),
                  //   ],
                  // ),
                  // Container(height: 1,color: Colors.grey,),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //         flex: 1,
                  //         child: Text("COSTO TOTAL:", style: style,)),
                  //     Expanded(
                  //         flex: 1,
                  //         child: Text("${NumberFunctions.formatNumber(costoTotal,4)} Bolivianos.", style: style,)),
                  //   ],
                  // ),
                  // Container(height: 1,color: Colors.grey,),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('EDITAR'),
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ModuleCreacionProformas(proforma: p,items: it, refresh: refreshAll,),));
              },
            ),
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                String nameString = p.codigo.replaceAll('/', '-');
                js.context.callMethod('open', ['${ApiConnections().url}pdf/generate/${p.id}/$nameString']);
              },
            ),
            TextButton(
              child: Text('ELIMINAR'),
              onPressed: () {
                p.fec_aprob=DateFormat("yyyy-MM-dd").format(DateTime.now());
                p.id_usuario_aprob = idUser;
                ApiProformas().cancelar(p, p.id).whenComplete((){
                  refreshAll((){
                    Navigator.of(context).pop();
                  });
                });
              },
            ),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void dispose() {
    super.dispose();
  }
}
