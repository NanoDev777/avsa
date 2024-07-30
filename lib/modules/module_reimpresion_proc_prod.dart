import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/print_pdf.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:js' as js;

import 'package:toast/toast.dart';

class ModuleReimpresionProcProd extends StatefulWidget {
  @override
  _ModuleReimpresionProcProdState createState() => _ModuleReimpresionProcProdState();
}

class _ModuleReimpresionProcProdState extends State<ModuleReimpresionProcProd> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelProcesoProduccion> provAll = List();
  List<ModelProcesoProduccion> pFilter = List();

  List<ModelReservaItemsProcProd> ingredientes;
  List<ModelReservaItemsProcProd> ingredientesIn = List();
  List<ModelReservaItemsProcProd> ingredientesOut = List();

  TextEditingController ecFecInicio = TextEditingController();
  TextEditingController ecFecFin = TextEditingController();
  String fecIni, fecFin;
  String errorFecInicio;
  String errorFecFin;
  bool habilitado=true;

  int sortFecCulm=1;
  int sortcodProceso=1;
  int sortAlmProc=1;
  int sortCodRec=1;
  int sortCodRecName=1;
  int sortProd=1;
  int sortLoteProd=1;
  int sortLoteVenta=1;
  int sortfecAprob=1;

  Future getData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    if(sp.containsKey("fecIniPP") && sp.containsKey("fecFinPP")){
      fecIni = sp.getString("fecIniPP");
      fecFin = sp.getString("fecFinPP");
      List<String> fecI = fecIni.split("-");
      List<String> fecF = fecFin.split("-");
      ecFecInicio.text = "${fecI[2]}/${fecI[1]}/${fecI[0]}";
      ecFecFin.text ="${fecF[2]}/${fecF[1]}/${fecF[0]}";
    }
    return await ApiProcesosProduccion().getPorFechas(fecIni, fecFin);
  }
  Future clearData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("fecIniI");
    sp.remove("fecFinI");
    sp.remove("fecIniT");
    sp.remove("fecFinT");
    sp.remove("fecIniSB");
    sp.remove("fecFinSB");
  }

  @override
  void initState() {
    clearData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              SomethingWentWrongPage();
            if(snapshot.connectionState==ConnectionState.done){
              provAll = snapshot.data;
              pFilter.addAll(provAll);
              return Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              onTap: () {
                                if (ecFecInicio.text.isEmpty)
                                  _selectDateInicio(context);
                                errorFecInicio = null;
                              },
                              onChanged: (value) {
                                if (value.length == 10) {
                                  errorFecInicio = null;
                                  Toast.show(value, context);
                                  List<String> lt = value.split("/");
                                  String day = lt[0];
                                  String mes = lt[1];
                                  String year = lt[2];
                                  Toast.show("$day::$mes::$year", context);
                                  if (int.parse(year) >= 2020) {
                                    if (int.parse(mes) > 0 &&
                                        int.parse(mes) < 13) {
                                      if (int.parse(mes) == 2) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 30) {
                                          setState(() {
                                            errorFecInicio = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecInicio = "Fecha Invalida";
                                          });
                                        }
                                      } else if (int.parse(mes) % 2 == 0) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 31) {
                                          setState(() {
                                            errorFecInicio = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecInicio = "Fecha Invalida";
                                          });
                                        }
                                      } else {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 32) {
                                          setState(() {
                                            errorFecInicio = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecInicio = "Fecha Invalida";
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        errorFecInicio = "Fecha Invalida";
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      errorFecInicio = "Fecha Invalida";
                                    });
                                  }
                                }
                              },
                              keyboardType: TextInputType.datetime,
                              maxLength: 10,
                              enabled: habilitado,
                              controller: ecFecInicio,
                              decoration: InputDecoration(
                                  errorText: errorFecInicio,
                                  border: OutlineInputBorder(),
                                  labelText: "FECHA DE INICIO",
                                  hintText: "Ejemplo: dd/mm/yyyy",
                                  counterText: ""),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              onTap: () {
                                if (ecFecFin.text.isEmpty)
                                  _selectDateFin(context);
                                errorFecFin = null;
                              },
                              onChanged: (value) {
                                if (value.length == 10) {
                                  errorFecFin = null;
                                  Toast.show(value, context);
                                  List<String> lt = value.split("/");
                                  String day = lt[0];
                                  String mes = lt[1];
                                  String year = lt[2];
                                  Toast.show("$day::$mes::$year", context);
                                  if (int.parse(year) >= 2020) {
                                    if (int.parse(mes) > 0 &&
                                        int.parse(mes) < 13) {
                                      if (int.parse(mes) == 2) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 30) {
                                          setState(() {
                                            errorFecFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecFin = "Fecha Invalida";
                                          });
                                        }
                                      } else if (int.parse(mes) % 2 == 0) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 31) {
                                          setState(() {
                                            errorFecFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecFin = "Fecha Invalida";
                                          });
                                        }
                                      } else {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 32) {
                                          setState(() {
                                            errorFecFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errorFecFin = "Fecha Invalida";
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        errorFecFin = "Fecha Invalida";
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      errorFecFin = "Fecha Invalida";
                                    });
                                  }
                                }
                              },
                              keyboardType: TextInputType.datetime,
                              maxLength: 10,
                              enabled: habilitado,
                              controller: ecFecFin,
                              decoration: InputDecoration(
                                  errorText: errorFecFin,
                                  border: OutlineInputBorder(),
                                  labelText: "FECHA DE FIN",
                                  hintText: "Ejemplo: dd/mm/yyyy",
                                  counterText: ""),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child: TextBoxCustom(
                            hint: "BUSCADOR",
                            controller: ecSearch,
                            onChange: (value){
                              refreshList((){
                                pFilter.clear();
                                print(value);
                                if(value=="") {
                                  print("if::$value");
                                  pFilter.addAll(provAll);
                                }else{
                                  print("else::$value::${pFilter.length}");
                                  provAll.forEach((element) {
                                    if("PP-${element.id.toString().padLeft(5,'0')}".toLowerCase().contains(value.toLowerCase())
                                        || element.codProdRes.toLowerCase().contains(value.toLowerCase())){
                                      pFilter.add(element);
                                    }
                                  });
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(flex:1,child: InkWell(
                            onTap: (){
                              generateExcel("REPORTE-PROCESOS-PRODUCCION-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-PROCESOS-PRODUCCION",
                                  [
                                    'Fecha Inicio',
                                    'Fecha Finalizacion',
                                    'Codigo Proceso',
                                    'cod. Producto',
                                    'Item',
                                    'Unidad',
                                    'Cantidad',
                                    'Costo Unitario [Bs]',
                                    'Costo Total [Bs]',
                                    'Lote Produccion',
                                    'Lote Venta',
                                    'Fecha Vencimiento',
                                    'tipo',
                                    'Almacen de Proceso',
                                    'Realizado Por',
                                    'Linea de Produccion',
                                    'Cliente',
                                  ]);
                            },
                            child: Image.asset("assets/images/exceldown.png", width: 50, height: 50,)))
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                        margin: EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  WidgetHeaderList(text: "FECHA CULMINACION", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortFecCulm==0) {
                                        sortFecCulm=1;
                                        pFilter.sort((a, b) =>
                                            a.fecCulminacion.compareTo(b.fecCulminacion));
                                      }else  if(pFilter!=null){
                                        sortFecCulm=0;
                                        pFilter.sort((a, b) =>
                                            b.fecCulminacion.compareTo(a.fecCulminacion));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "CODIGO PROCESO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortcodProceso==0) {
                                        sortcodProceso=1;
                                        pFilter.sort((a, b) =>
                                            a.id.compareTo(b.id));
                                      }else  if(pFilter!=null){
                                        sortcodProceso=0;
                                        pFilter.sort((a, b) =>
                                            b.id.compareTo(a.id));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "ALMACEN PROCESO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortAlmProc==0) {
                                        sortAlmProc=1;
                                        pFilter.sort((a, b) =>
                                            a.codAlmProd.compareTo(b.codAlmProd));
                                      }else  if(pFilter!=null){
                                        sortAlmProc=0;
                                        pFilter.sort((a, b) =>
                                            b.codAlmProd.compareTo(a.codAlmProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "CODIGO RECETA", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCodRec==0) {
                                        sortCodRec=1;
                                        pFilter.sort((a, b) =>
                                            a.codProdRes.compareTo(b.codProdRes));
                                      }else  if(pFilter!=null){
                                        sortCodRec=0;
                                        pFilter.sort((a, b) =>
                                            b.codProdRes.compareTo(a.codProdRes));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "PRODUCTO", flex: 3,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCodRecName==0) {
                                        sortCodRecName=1;
                                        pFilter.sort((a, b) =>
                                            a.tituloProd.compareTo(b.tituloProd));
                                      }else  if(pFilter!=null){
                                        sortCodRecName=0;
                                        pFilter.sort((a, b) =>
                                            b.tituloProd.compareTo(a.tituloProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "LOTE PRODUCCION", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortLoteProd==0) {
                                        sortLoteProd=1;
                                        pFilter.sort((a, b) =>
                                            a.loteProd.compareTo(b.loteProd));
                                      }else  if(pFilter!=null){
                                        sortLoteProd=0;
                                        pFilter.sort((a, b) =>
                                            b.loteProd.compareTo(a.loteProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "LOTE VENTA", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortLoteVenta==0) {
                                        sortLoteVenta=1;
                                        pFilter.sort((a, b) =>
                                            a.loteVenta.compareTo(b.loteVenta));
                                      }else  if(pFilter!=null){
                                        sortLoteVenta=0;
                                        pFilter.sort((a, b) =>
                                            b.loteVenta.compareTo(a.loteVenta));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "FECHA APROBACION", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortfecAprob==0) {
                                        sortfecAprob=1;
                                        pFilter.sort((a, b) =>
                                            a.fecAprob.compareTo(b.fecAprob));
                                      }else  if(pFilter!=null){
                                        sortfecAprob=0;
                                        pFilter.sort((a, b) =>
                                            b.fecAprob.compareTo(a.fecAprob));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "DESCARGA", flex: 1,),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Scrollbar(
                                  controller: scroll,
                                  isAlwaysShown: true,
                                  child: StatefulBuilder(
                                    builder: (context, setState) {
                                      refreshList = setState;
                                      TextStyle s = TextStyle(fontSize: 12);
                                      return ListView.separated(
                                          controller: scroll,
                                          itemBuilder: (context, index) {
                                            ModelProcesoProduccion m = pFilter[index];
                                            return Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text(m.fecCulminacion!=null?m.fecCulminacion:"",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("PP-${m.id.toString().padLeft(5,'0')}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codAlmProd}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codProdRes}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.tituloProd}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.loteProd}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.loteVenta==null?"":m.loteVenta}",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text(m.fecAprob!=null?m.fecAprob:"",style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: InkWell(
                                                        onTap: (){
                                                          ApiProcesosProduccion().getReservas(m.id).then((value){
                                                            ingredientes = value;
                                                            ingredientes.forEach((element) {
                                                              if (element.tipo == 0) {
                                                                ingredientesIn.add(element);
                                                              } else {
                                                                ingredientesOut.add(element);
                                                              }
                                                            });
                                                            print(
                                                                "PP-${m.id.toString().padLeft(5,'0')}::"
                                                                    "${m.loteProd}::${m.costoReceta}::"
                                                                    "${ m.costoReal}::${m.variacion}"
                                                            );
                                                            PrintPDF.impresionProcesoProduccion(
                                                                "PP-${m.id.toString().padLeft(5,'0')}",
                                                                m.loteProd,
                                                                m.costoReceta,
                                                                m.costoReal,
                                                                m.variacion,
                                                                m,
                                                                ingredientesIn,
                                                                ingredientesOut
                                                            );
                                                          });

                                                        },
                                                        child: Icon(Icons.arrow_circle_down)),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                          separatorBuilder: (context, index) => Divider(),
                                          itemCount: pFilter.length);
                                    },
                                  )
                              ),
                            )
                          ],
                        )
                    ),
                  ),
                ],
              );
            }
            return LoadingPage();
          },
        )
    );
  }
  Future<void> _selectDateInicio(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      ecFecInicio.text = DateFormat("dd/MM/yyyy").format(picked);
      fecIni = DateFormat("yyyy-MM-dd").format(picked);
      sp.setString("fecIniPP", fecIni);
    }
  }
  Future<void> _selectDateFin(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ecFecFin.text = DateFormat("dd/MM/yyyy").format(picked);
        fecFin = DateFormat("yyyy-MM-dd").format(picked);
        sp.setString("fecFinPP", fecFin);
      });
    }
  }
  generateExcel(String title, String nameSheet,List<String> header){
    if(pFilter.length>0){
      ApiProcesosProduccion().getReservasAll().then((value){
        Excel excel = Excel.createExcel();
        Sheet sheetObject = excel[nameSheet];
        excel.delete("Sheet1");

        CellStyle cellStyle = CellStyle(fontFamily : getFontFamily(FontFamily.Calibri),fontSize: 18);
        CellStyle styleHeader = CellStyle(
          fontFamily : getFontFamily(FontFamily.Calibri),
          fontSize: 15,
          backgroundColorHex: "#bfbfbf",
          horizontalAlign: HorizontalAlign.Center,
          verticalAlign: VerticalAlign.Center,
        );

        sheetObject.merge(CellIndex.indexByString("A1"), CellIndex.indexByString("E1"), customValue: "");
        sheetObject.merge(CellIndex.indexByString("A2"), CellIndex.indexByString("E2"), customValue: "");
        sheetObject.merge(CellIndex.indexByString("A3"), CellIndex.indexByString("E3"), customValue: "");

        var cell = sheetObject.cell(CellIndex.indexByString("A1"));
        cell.value = "REPORTE DE PROCESOS DE PRODUCCION"; // dynamic values support provided;
        cell.cellStyle = cellStyle;
        var cell1 = sheetObject.cell(CellIndex.indexByString("A2"));
        cell1.value = "DEL $fecIni"; // dynamic values support provided;
        cell1.cellStyle = cellStyle;
        var cell2 = sheetObject.cell(CellIndex.indexByString("A3"));
        cell2.value = "AL $fecFin"; // dynamic values support provided;
        cell2.cellStyle = cellStyle;

        // sheetObject.appendRow(['CODIGO','DESCRIPCION','UNIDAD','CLIENTE']);
        List<String> abc = ["A","B","C","D","E","F","G","H","I","J","k","L","M","N","O","P","Q","R"];
        sheetObject.appendRow(header);
        for(int i=0;i<header.length;i++){
          sheetObject.cell(CellIndex.indexByString("${abc[i]}4")).style = styleHeader;
        }
        pFilter.forEach((element) {
          value.forEach((element1) {
            if(element.id==element1.idProcProd){
              sheetObject.appendRow([
                element.fecInicio!="null"?element.fecInicio:"",
                element.fecFin!="null"?element.fecFin:"",
                "PP-${element.id.toString().padLeft(5,"0")}",
                element1.codProd!="null"?element1.codProd:"",
                element1.nombreProd!="null"?element1.nombreProd:"",
                element1.unidad!="null"?element1.unidad:"",
                element1.cantidad!="null"?element1.cantidad:"",
                element1.costoUnit!="null"?element1.costoUnit:"",
                element1.cantidad!="null"?element1.cantidad*element1.costoUnit:"",
                element1.lote!="null"?element1.lote:"",
                if(element1.tipo==1)
                  element.loteVenta!="null"?element.loteVenta:""
                else element1.loteVenta!="null"?element1.loteVenta:"",
                element.fecVenc!="null"?element.fecVenc:"",
                element1.tipo!="null"?element1.tipo==0?"INGRESO":"SALIDA":"",
                element.codAlmProd!="null"?element.codAlmProd:"",
                element.usrRegName!="null"?element.usrRegName:"",
                element.linProdName!="null"?element.linProdName:"",
                element.clienteRZ!="null"?element.clienteRZ:"",
              ]);
            }
          });
        });

        excel.encode().then((onValue) {
          js.context['pdfData'] = base64.encode(onValue);
          js.context['filename'] = '$nameSheet.xlsx';
          Timer.run(() {
            js.context.callMethod('download');
          });
        });
      });
    }else{
      Toast.show("NO EXISTE STOCK", context, duration: Toast.LENGTH_LONG);
    }
  }
}
