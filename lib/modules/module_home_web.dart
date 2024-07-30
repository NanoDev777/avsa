import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_message.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_proformas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_http_request.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModuleHomeWeb extends StatefulWidget {
  @override
  _ModuleHomeWebState createState() => _ModuleHomeWebState();
}

class _ModuleHomeWebState extends State<ModuleHomeWeb> {
  List<ModelProformaItems> itemsList = List();
  Map<int,Map<int,List<ModelProformaItems>>> items = Map();
  int idUser;
  List<ModelProforma> proformas=List();
  StateSetter refreshAll;
  Map<int,double> cantidades = Map();
  Map<int,double> montos = Map();


  List<StateSetter> refreshList=List();
  List<int> sortFecha=List();
  List<int> sortProf=List();
  List<int> sortCliente=List();
  List<int> sortSubCliente=List();


  clearShared()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("fecIniI");
    sp.remove("fecFinI");
    sp.remove("fecIniT");
    sp.remove("fecFinT");
    sp.remove("fecIniPP");
    sp.remove("fecFinPP");
    sp.remove("fecIniSB");
    sp.remove("fecFinSB");
  }
  @override
  void initState() {
    clearShared();
    super.initState();
  }

  String converMonth(String month){
    switch(month.toLowerCase()){
      case "january":
        return "ENERO";
      case "february":
        return "FEBRERO";
      case "march":
        return "MARZO";
      case "april":
        return "ABRIL";
      case "may":
        return "MAYO";
      case "june":
        return "JUNIO";
      case "july":
        return "JULIO";
      case "august":
        return "AGOSTO";
      case "september":
        return "SEPTIEMBRE";
      case "october":
        return "OCTUBRE";
      case "november":
        return "NOVIEMBRE";
      case "december":
        return "DICIEMBRE";
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = new DateTime.now();
    DateTime totalDays = DateTime(now.year, now.month+1, 0);
    int d = int.parse(DateFormat("dd").format(DateTime.now()));
    int r = totalDays.day-d;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Image.asset("assets/images/fondo2.png", fit: BoxFit.fill,),
          ),
          Column(
            children: [
              Expanded(
                flex: 5,
                child:  mensajesList(DateFormat.MMMM().format(DateTime.now()),0)
              ),
              Expanded(
                flex: 5,
                  child: mensajesList(DateFormat.MMMM().format(DateTime.now().add(Duration(days: r+1))),1)
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(left: 5,right: 5),
                  child: Column(
                    children: [
                      Text("SISTEMA ERP-AVSA", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.white),),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("DESARROLLADO POR: WALTER VARGAS DE LOS RIOS",style: TextStyle(fontSize: 10, color: Colors.white)),
                          Text("V. 1.0",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12, color: Colors.white)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("PROGRAMADO POR: FERNANDO CRUZ BANEGAS",style: TextStyle(fontSize: 10, color: Colors.white)),
                          Text("11/07/2022",style: TextStyle(fontSize: 10, color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                )
              )
            ],
          ),
        ],
      )
    );
  }

  procPendAprobList() {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, offset: Offset(.5,10), blurRadius: 20)
        ]
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 5,bottom: 5),
            width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text("Procesos Pendientes de aprobacion", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(children: [
              WidgetHeaderList(text: "Codigo"),
              WidgetHeaderList(text: "Almacen"),
              WidgetHeaderList(text: "Variacion")
            ],),
          ),
        ],
      ),
    );
  }

  bool oneEntry = true;
  Future getData(String month, int index)async{
    if(oneEntry){
      if(!items.containsKey(index))
        items[index] = Map();
      SharedPreferences sp = await SharedPreferences.getInstance();
      idUser = sp.getInt("sessionID");
      // proformas = await ApiProformas().getMonth(converMonth(month));
      itemsList = await ApiProformas().getItems();
      itemsList.forEach((element) {
        if (items[index].containsKey(element.idProforma)) {
          items[index][element.idProforma].add(element);
          cantidades[element.idProforma] += element.pesoNeto * element.cantidad;
          montos[element.idProforma] += element.valorTotal;
        } else {
          items[index][element.idProforma] = List();
          items[index][element.idProforma].add(element);
          cantidades[element.idProforma] = element.pesoNeto * element.cantidad;
          montos[element.idProforma] = element.valorTotal;
        }
      });
      oneEntry=false;
    }
    return await ApiProformas().getMonth(converMonth(month));
  }
  mensajesList(String month, int indexIn){
    sortFecha.add(0);
    sortProf.add(0);
    sortCliente.add(0);
    sortSubCliente.add(0);
    return FutureBuilder(
      future: getData(month, indexIn),
      builder: (context, snapshot) {
        if(snapshot.hasError) return SomethingWentWrongPage();
        if(snapshot.connectionState == ConnectionState.done){
          List<ModelProforma> p = snapshot.data;
          return Container(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, offset: Offset(.5,10), blurRadius: 20)
                ]
            ),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                      padding: EdgeInsets.only(top: 5,bottom: 5),
                      width: double.infinity,
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Text("${converMonth(month)}", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
                ),
                SizedBox(height: 10,),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: Row(children: [
                      WidgetHeaderList(text: "Fecha",flex: 1,height: 30,func: (){
                        refreshList[indexIn]((){
                          if(p!=null && sortFecha[indexIn]==0) {
                            sortFecha[indexIn]=1;
                            p.sort((a, b) =>
                                a.fec_aprob.compareTo(b.fec_aprob));
                          }else  if(p!=null){
                            sortFecha[indexIn]=0;
                            p.sort((a, b) =>
                                b.fec_aprob.compareTo(a.fec_aprob));
                          }
                        });
                      },),
                      WidgetHeaderList(text: "PROFORMA", flex: 1,height: 30,func: (){
                        refreshList[indexIn]((){
                          if(p!=null && sortProf[indexIn]==0) {
                            sortProf[indexIn]=1;
                            p.sort((a, b) =>
                                a.codigo.compareTo(b.codigo));
                          }else  if(p!=null){
                            sortProf[indexIn]=0;
                            p.sort((a, b) =>
                                b.codigo.compareTo(a.codigo));
                          }
                        });
                      },),
                      WidgetHeaderList(text: "CLIENTE", flex: 3,height: 30,func: (){
                        refreshList[indexIn]((){
                          if(p!=null && sortCliente[indexIn]==0) {
                            sortCliente[indexIn]=1;
                            p.sort((a, b) =>
                                a.nombreCliente.toLowerCase().compareTo(b.nombreCliente.toLowerCase()));
                          }else  if(p!=null){
                            sortCliente[indexIn]=0;
                            p.sort((a, b) =>
                                b.nombreCliente.toLowerCase().compareTo(a.nombreCliente.toLowerCase()));
                          }
                        });
                      },),
                      WidgetHeaderList(text: "SUBCLIENTE", flex: 3,height: 30,func: (){
                        refreshList[indexIn]((){
                          if(p!=null && sortSubCliente[indexIn]==0) {
                            sortSubCliente[indexIn]=1;
                            p.sort((a, b) =>
                                a.nombreSubCliente.toLowerCase().compareTo(b.nombreSubCliente.toLowerCase()));
                          }else  if(p!=null){
                            sortSubCliente[indexIn]=0;
                            p.sort((a, b) =>
                                b.nombreSubCliente.toLowerCase().compareTo(a.nombreSubCliente.toLowerCase()));
                          }
                        });
                      },),
                      WidgetHeaderList(text: "CANTIDAD TOTAL [Kg]", flex: 1,height: 30,),
                      WidgetHeaderList(text: "MONTO TOTAL [Bs]", flex: 1,height: 30,),
                    ],),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: p.length>0?StatefulBuilder(
                    builder: (context, setState) {
                      refreshList.add(setState);
                      return ListView.separated(
                          itemBuilder: (context, index) {
                            List<String> f = p[index].fec_aprob.split('-');
                            TextStyle s = TextStyle(fontSize: 15);
                            return InkWell(
                              onTap: (){
                                _showDialog(p[index], indexIn);
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 8, right: 8),
                                child: Row(children: [
                                  Expanded(flex: 1,child: Text("${f[2]}/${f[1]}/${f[0]}",style: s,textAlign: TextAlign.center,)),
                                  Expanded(flex: 1,child: Text(p[index].codigo,style: s,textAlign: TextAlign.center,)),
                                  Expanded(flex: 3,child: Text(p[index].nombreCliente,style: s,)),
                                  Expanded(flex: 3,child: Text(p[index].nombreSubCliente,style: s,)),
                                  Expanded(flex: 1,child: Text(NumberFunctions.formatNumber(cantidades[p[index].id], 3),style: s,textAlign: TextAlign.center,)),
                                  Expanded(flex: 1,child: Text(NumberFunctions.formatNumber(montos[p[index].id], 3),style: s,textAlign: TextAlign.center,)),
                                ],),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Divider(),
                          itemCount: p.length
                      );
                    }
                  ):Container(child: Text("NO HAY PEDIDOS"),),
                )
              ],
            ),
          );
        }
        return LoadingPage();
      },
    );
  }

  ingresosPendientesList(){
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, offset: Offset(.5,10), blurRadius: 20)
          ]
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5,bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text("Ingresos Pendientes de aprobacion", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(children: [
              WidgetHeaderList(text: "Codigo"),
              WidgetHeaderList(text: "Almacen"),
              WidgetHeaderList(text: "Cantidad")
            ],),
          ),
        ],
      ),
    );
  }
  bajasPendientesList(){
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black12, offset: Offset(.5,10), blurRadius: 20)
          ]
      ),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5,bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text("Bajas Pendientes de Aprobacion", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),)),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.only(left: 8, right: 8),
            child: Row(children: [
              WidgetHeaderList(text: "Codigo"),
              WidgetHeaderList(text: "Almacen"),
              WidgetHeaderList(text: "Cantidad")
            ],),
          ),
          // FutureBuilder<List<ModelItem>>(
          //   // future: ApiConnections().getItemsBajasAprob(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasError)
          //       return SomethingWentWrongPage(
          //         msj: snapshot.error.toString(),
          //       );
          //     if (snapshot.connectionState == ConnectionState.done) {
          //       return Expanded(
          //         child: Padding(
          //           padding: EdgeInsets.all(8.0),
          //           child: ListView.separated(
          //               itemBuilder: (context, index) {
          //                 return Container(
          //                     padding: EdgeInsets.all(5),
          //                     child: Row(
          //                       children: [
          //                         Expanded(child: Center(child: Text("${snapshot.data[index].codigo}"))),
          //                         Expanded(child: Center(child: Text("${snapshot.data[index].nombre}"))),
          //                         // Expanded(child: Center(child: Text("${snapshot.data[index].cantidad}"))),
          //                       ],
          //                     ));
          //               },
          //               separatorBuilder: (context, index) => Divider(),
          //               itemCount: snapshot.data.length),
          //         ),
          //       );
          //     }
          //     return LoadingPage();
          //   },
          // )
        ],
      ),
    );
  }

  double cantidadTotal=0;
  double costoTotal=0;
  Future<void> _showDialog(ModelProforma p, int index) async {
    List<ModelProformaItems> it = items[index][p.id];
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle style = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
        TextStyle style1 = TextStyle(fontSize: 13);
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
                      ModelHeaderList(title: "PESO NETO[KG]", flex: 1),
                      ModelHeaderList(title: "VALOR TOTAL[Bs]", flex: 1),
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
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.pesoNeto,3)}", style: style1,textAlign: TextAlign.right,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.valorTotal,3)}", style: style1,textAlign: TextAlign.right,)),
                            ],
                          ),
                          Container(height: 1,color: Colors.grey,)
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                js.context.callMethod('open', ['http://testqr.sistema-avsa.com/apiRest/api/pdf/generate/${p.id}/${p.codigo}']);
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
}