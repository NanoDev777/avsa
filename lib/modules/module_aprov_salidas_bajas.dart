import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_salidas_bajas.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_salidas_bajas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
class ModuleAprovSalidasBajas extends StatefulWidget {
  @override
  _ModuleAprovSalidasBajasState createState() => _ModuleAprovSalidasBajasState();
}

class _ModuleAprovSalidasBajasState extends State<ModuleAprovSalidasBajas> {
  TextEditingController ecSearch = TextEditingController();
  ScrollController scroll = ScrollController();
  StateSetter refreshList;
  List<ModelSalidasBajas> salidasBajas;
  List<ModelSalidasBajas> salidasBajasFilter = List();

  List<String> keys = List();
  Map<String, List<ModelSalidasBajas>> agrupados = Map();
  Map<String, double> costosTotal = Map();

  bool tipoasc=true;
  bool documentoasc=true;
  bool almacenasc=true;
  bool motivoasc=true;
  bool areaSolicitanteasc=true;

  Future getData()async{
    agrupados.clear();
    keys.clear();
    costosTotal.clear();
    salidasBajas = await ApiSalidasBajas().getPendientes();
    salidasBajas.forEach((element) {
      if(agrupados.containsKey(element.codigoSalida)){
        costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
        agrupados[element.codigoSalida].add(element);
      }else{
        keys.add(element.codigoSalida);
        costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
        agrupados[element.codigoSalida] = List();
        agrupados[element.codigoSalida].add(element);
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return SomethingWentWrongPage();
            if (snapshot.connectionState == ConnectionState.done) {
              // print(snapshot.data.toString());
              // salidasBajas = snapshot.data;
              // salidasBajasFilter.addAll(salidasBajas);
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Expanded(
                  //   flex: 1,
                  //   child: TextBoxCustom(
                  //     hint: "BUSCADOR",
                  //     controller: ecSearch,
                  //     onChange: (value){
                  //       refreshList((){
                  //         salidasBajasFilter.clear();
                  //         print(value);
                  //         if(value=="") {
                  //           print("if::$value");
                  //           salidasBajasFilter.addAll(salidasBajas);
                  //         }else{
                  //           print("else::$value::${salidasBajas.length}");
                  //           salidasBajas.forEach((element) {
                  //             if(element.codProd.contains(value.toLowerCase()) ){
                  //               salidasBajasFilter.add(element);
                  //             }
                  //           });
                  //         }
                  //       });
                  //     },
                  //   ),
                  // ),
                  Expanded(
                      flex: 10,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                WidgetHeaderList(text: "TIPO", flex: 1,func:(){
                                  refreshList((){
                                    agrupados.clear();
                                    keys.clear();
                                    costosTotal.clear();
                                    if(tipoasc){
                                      tipoasc=false;
                                      salidasBajas.sort((a,b)=> a.tipo.compareTo(b.tipo));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }else{
                                      tipoasc=true;
                                      salidasBajas.sort((b,a)=> a.tipo.compareTo(b.tipo));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }
                                  });
                                }),
                                WidgetHeaderList(text: "DOCUMENTO",flex: 1,func: (){
                                  refreshList((){
                                    agrupados.clear();
                                    keys.clear();
                                    costosTotal.clear();
                                    if(documentoasc){
                                      documentoasc=false;
                                      salidasBajas.sort((a,b)=> a.codigoSalida.compareTo(b.codigoSalida));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }else{
                                      documentoasc=true;
                                      salidasBajas.sort((b,a)=> a.codigoSalida.compareTo(b.codigoSalida));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }
                                  });
                                },),
                                WidgetHeaderList(text: "ALMACEN",flex: 1,func: (){
                                  refreshList((){
                                    agrupados.clear();
                                    keys.clear();
                                    costosTotal.clear();
                                    if(almacenasc){
                                      almacenasc=false;
                                      salidasBajas.sort((a,b)=> a.codAlm.compareTo(b.codAlm));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }else{
                                      almacenasc=true;
                                      salidasBajas.sort((b,a)=> a.codAlm.compareTo(b.codAlm));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }
                                  });
                                },),
                                WidgetHeaderList(text: "MOTIVO",flex: 2,func: (){
                                  refreshList((){
                                    agrupados.clear();
                                    keys.clear();
                                    costosTotal.clear();
                                    if(motivoasc){
                                      motivoasc=false;
                                      salidasBajas.sort((a,b)=> a.motivo.compareTo(b.motivo));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }else{
                                      motivoasc=true;
                                      salidasBajas.sort((b,a)=> a.motivo.compareTo(b.motivo));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }
                                  });
                                },),
                                WidgetHeaderList(text: "AREA SOLICITANTE",flex: 2,func: (){
                                  refreshList((){
                                    agrupados.clear();
                                    keys.clear();
                                    costosTotal.clear();
                                    if(areaSolicitanteasc){
                                      areaSolicitanteasc=false;
                                      salidasBajas.sort((a,b)=> a.area.compareTo(b.area));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }else{
                                      areaSolicitanteasc=true;
                                      salidasBajas.sort((b,a)=> a.area.compareTo(b.area));
                                      salidasBajas.forEach((element) {
                                        if(agrupados.containsKey(element.codigoSalida)){
                                          costosTotal[element.codigoSalida] += (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida].add(element);
                                        }else{
                                          keys.add(element.codigoSalida);
                                          costosTotal[element.codigoSalida] = (element.cantidad * element.costoUnit);
                                          agrupados[element.codigoSalida] = List();
                                          agrupados[element.codigoSalida].add(element);
                                        }
                                      });
                                    }
                                  });
                                },),
                                WidgetHeaderList(text: "MONTO TOTAL",flex: 1,),
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
                                      itemCount: agrupados.length,
                                      separatorBuilder: (context, index) => Divider(),
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: (){
                                            _showDialog(agrupados[keys[index]], keys[index], index);
                                          },
                                          child: Row(
                                            children: [
                                              Expanded(flex: 1,child: Text(agrupados[keys[index]][0].tipo)),
                                              Expanded(flex:1,child: Container(
                                                  padding: EdgeInsets.only(left: 3,right: 3),
                                                  child: Text(agrupados[keys[index]][0].codigoSalida))
                                              ),
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color: Colors.blueGrey,
                                              ),
                                              Expanded(flex:1,child: Container(
                                                  padding: EdgeInsets.only(left: 3,right: 3),
                                                  child: Column(
                                                    children: [
                                                      Text("${agrupados[keys[index]][0].codAlm}"),
                                                    ],
                                                  ))),
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color: Colors.blueGrey,
                                              ),
                                              Expanded(flex:2,child: Container(
                                                  padding: EdgeInsets.only(left: 3,right: 3),
                                                  child: Text(agrupados[keys[index]][0].motivo))),
                                              Container(
                                                width: 1,
                                                height: 20,
                                                color: Colors.blueGrey,
                                              ),
                                              Expanded(flex:2,child: Container(
                                                  padding: EdgeInsets.only(left: 3,right: 3),
                                                  child: Column(
                                                    children: [
                                                      Text("${agrupados[keys[index]][0].area}"),
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
                                                      Text("${NumberFunctions.formatNumber(costosTotal[keys[index]],3)} Bs."),
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
        ));
  }

  double cantidadTotal=0;
  double costoTotal=0;
  Future<void> _showDialog(List<ModelSalidasBajas> f, String cod, int index) async {
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
                  Text("CODIGO: ${f[0].codigoSalida}", style: style,),
                  Text("ALMACEN: ${f[0].codAlm} - ${f[0].nameAlmacen}", style: style,),
                  Text("TIPO DE ACCION: ${f[0].tipo}", style: style,),
                  Text("USUARIO DE SOLICITANTE: ${f[0].usuario}", style: style,),
                  Text("AREA SOLICITANTE: ${f[0].area}", style: style,),
                  Text("OBSERVACIONES: ${f[0].observacion}", style: style,),
                  ListCustom(
                    modelHeaderList: [
                      ModelHeaderList(title: "CODIGO", flex: 1),
                      ModelHeaderList(title: "DESCRIPCION", flex: 2),
                      ModelHeaderList(title: "UNIDAD", flex: 1),
                      ModelHeaderList(title: "LOTE", flex: 1),
                      ModelHeaderList(title: "CANTIDAD", flex: 1),
                      ModelHeaderList(title: "COSTO UNITARIO", flex: 1),
                      ModelHeaderList(title: "TOTAL", flex: 1),
                    ],
                    title: "PRODUCTOS",
                    datos: f.map((e){
                      cantidadTotal += e.cantidad;
                      costoTotal += e.cantidad * e.costoUnit;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1,child: Text(e.codProd, style: style1,)),
                              Expanded(flex: 2,child: Text(e.nombreProd, style: style1,)),
                              Expanded(flex: 1,child: Text(e.unidadMedida, style: style1,textAlign: TextAlign.center,)),
                              Expanded(flex: 1,child: Text(e.lote, style: style1,textAlign: TextAlign.center,)),
                              Expanded(flex: 1,child: Text("${e.cantidad}", style: style1,textAlign: TextAlign.right,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.costoUnit,3)}", style: style1,textAlign: TextAlign.right,)),
                              Expanded(flex: 1,child: Text("${NumberFunctions.formatNumber(e.cantidad*e.costoUnit, 3)}", style: style1,textAlign: TextAlign.right,)),
                            ],
                          ),
                          Container(height: 1,color: Colors.grey,)
                        ],
                      );
                    }).toList(),
                  ),

                  Container(height: 1,color: Colors.grey,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                          child: Text("CANTIDAD TOTAL:", style: style,)),
                      Expanded(
                        flex: 1,
                          child: Text("${NumberFunctions.formatNumber(cantidadTotal,3)}", style: style,)),
                    ],
                  ),
                  Container(height: 1,color: Colors.grey,),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                          child: Text("COSTO TOTAL:", style: style,)),
                      Expanded(
                        flex: 1,
                          child: Text("${NumberFunctions.formatNumber(costoTotal,4)} Bolivianos.", style: style,)),
                    ],
                  ),
                  Container(height: 1,color: Colors.grey,),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('APROBAR'),
              onPressed: () {
                ApiSalidasBajas().aprovar(f[0].codigoSalida).whenComplete((){
                  Toast.show("APROBADO CORRECTAMENTE", context);
                  setState(() {
                    // keys.remove(index);
                    // agrupados.remove(f[0].codigoSalida);
                    Navigator.of(context).pop();
                  });
                });
              },
            ),
            TextButton(
              child: Text('RECHAZAR'),
              onPressed: () {
                ApiSalidasBajas().rechazar(f[0].codigoSalida).whenComplete((){
                  List<ModelInventario> mi = List();
                  f.forEach((item) {
                    mi.add(ModelInventario(
                        idCodigo: "R*${item.codigoSalida}",
                        codigo: "R*${item.codigoSalida}",
                        cantidad: item.cantidad,
                        costoUnitario: item.costoUnit,
                        lote: item.lote,
                        loteVenta: "",
                        codAlm: item.codAlm,
                        codProd: item.codProd,
                        factura: "",
                        idProv: 0,
                        fecIngreso: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                        fecVencimiento: item.fecVencimiento,
                        fechaSistema: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                        costo: item.cantidad * item.costoUnit,
                        idLote: item.idLote
                    ));
                  });
                  ApiInventory().insertInventory(mi, context).whenComplete((){
                    Toast.show("RECHAZADO CORRECTAMENTE", context);
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  });
                });;

              },
            ),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text('IMPRIMIR'),
            //   onPressed: () {
            //
            //   },
            // ),
          ],
        );
      },
    );
  }
  void dispose() {
    super.dispose();
  }
}
