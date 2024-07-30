import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_salidas_bajas.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_salidas_bajas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/utils/print_pdf.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:js' as js;

class ModuleReimpresionSalidasBajas extends StatefulWidget {
  @override
  _ModuleReimpresionSalidasBajasState createState() => _ModuleReimpresionSalidasBajasState();
}

class _ModuleReimpresionSalidasBajasState extends State<ModuleReimpresionSalidasBajas> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelSalidasBajas> provAll = List();
  List<ModelSalidasBajas> pFilter = List();

  TextEditingController ecFecInicio = TextEditingController();
  TextEditingController ecFecFin = TextEditingController();
  String fecIni, fecFin;
  String errorFecInicio;
  String errorFecFin;
  bool habilitado=true;

  int sortFecReg=1;
  int sortTipo=1;
  int sortCodigo=1;
  int sortItem=1;
  int sortDescripcion=1;
  int sortCantidad=1;
  int sortLote=1;
  int sortAlmacen=1;
  int sortEstado=1;
  int sortFecAprobacion=1;

  Future getData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    if(sp.containsKey("fecIniSB") && sp.containsKey("fecFinSB")){
      fecIni = sp.getString("fecIniSB");
      fecFin = sp.getString("fecFinSB");
      List<String> fecI = fecIni.split("-");
      List<String> fecF = fecFin.split("-");
      ecFecInicio.text = "${fecI[2]}/${fecI[1]}/${fecI[0]}";
      ecFecFin.text ="${fecF[2]}/${fecF[1]}/${fecF[0]}";
    }
    return await ApiSalidasBajas().getPorFechas(fecIni, fecFin);
  }
  Future clearData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("fecIniI");
    sp.remove("fecFinI");
    sp.remove("fecIniPP");
    sp.remove("fecFinPP");
    sp.remove("fecIniPP");
    sp.remove("fecFinPP");
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
              Map<String, List<ModelSalidasBajas>> agrupados = Map();
              Map<String, double> cantidadTotales = Map();
              Map<String, double> costosTotales = Map();
              List<String> keys = List();
              provAll.forEach((element) {
                if(agrupados.containsKey(element.codigoSalida)){
                  agrupados[element.codigoSalida].add(element);
                  costosTotales[element.codigoSalida] += element.cantidad * element.costoUnit;
                  cantidadTotales[element.codigoSalida] += element.cantidad;
                }else{
                  keys.add(element.codigoSalida);
                  agrupados[element.codigoSalida] = List();
                  agrupados[element.codigoSalida].add(element);
                  cantidadTotales[element.codigoSalida] = element.cantidad;
                  costosTotales[element.codigoSalida] = element.cantidad * element.costoUnit;
                }
              });
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
                                  pFilter.addAll(provAll);
                                }else{
                                  provAll.forEach((element) {
                                    if(element.codigoSalida.toLowerCase().contains(value.toLowerCase())
                                        || element.codProd.toLowerCase().contains(value.toLowerCase())){
                                      print("else::$value::${element.codigoSalida}::${element.codProd}");
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
                              generateExcel("REPORTE-SALIDAS-BAJAS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-SALIDAS-BAJAS",
                                  [
                                    'Fecha Registro',
                                    'Tipo',
                                    'Codigo Transferencia',
                                    'Almacen',
                                    'Codigo Producto',
                                    'Producto',
                                    'Unidad',
                                    'Cantidad',
                                    'Costo Unitario[Bs]',
                                    'Costo Total[Bs]',
                                    'Lote',
                                    'Lote Venta',
                                    'Fecha Vencimiento',
                                    'Estado',
                                    'Fecha Aprobacion',
                                    'Realizado Por',
                                    'Solicitante',
                                    'Area Solicitante',
                                    'Observaciones'
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
                                  WidgetHeaderList(text: "FECHA REGISTRO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortFecReg==0) {
                                        sortFecReg=1;
                                        pFilter.sort((a, b) =>
                                            a.fecReg.compareTo(b.fecReg));
                                      }else  if(pFilter!=null){
                                        sortFecReg=0;
                                        pFilter.sort((a, b) =>
                                            b.fecReg.compareTo(a.fecReg));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "TIPO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortTipo==0) {
                                        sortTipo=1;
                                        pFilter.sort((a, b) =>
                                            a.tipo.compareTo(b.tipo));
                                      }else  if(pFilter!=null){
                                        sortTipo=0;
                                        pFilter.sort((a, b) =>
                                            b.tipo.compareTo(a.tipo));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "CODIGO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCodigo==0) {
                                        sortCodigo=1;
                                        pFilter.sort((a, b) =>
                                            a.codigoSalida.compareTo(b.codigoSalida));
                                      }else  if(pFilter!=null){
                                        sortCodigo=0;
                                        pFilter.sort((a, b) =>
                                            b.codigoSalida.compareTo(a.codigoSalida));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "ITEM", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortItem==0) {
                                        sortItem=1;
                                        pFilter.sort((a, b) =>
                                            a.codProd.compareTo(b.codProd));
                                      }else  if(pFilter!=null){
                                        sortItem=0;
                                        pFilter.sort((a, b) =>
                                            b.codProd.compareTo(a.codProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "DESCRIPCION", flex: 3,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortDescripcion==0) {
                                        sortDescripcion=1;
                                        pFilter.sort((a, b) =>
                                            a.nombreProd.compareTo(b.nombreProd));
                                      }else  if(pFilter!=null){
                                        sortDescripcion=0;
                                        pFilter.sort((a, b) =>
                                            b.nombreProd.compareTo(a.nombreProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "CANTIDAD", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCantidad==0) {
                                        sortCantidad=1;
                                        pFilter.sort((a, b) =>
                                            a.cantidad.compareTo(b.cantidad));
                                      }else  if(pFilter!=null){
                                        sortCantidad=0;
                                        pFilter.sort((a, b) =>
                                            b.cantidad.compareTo(a.cantidad));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "LOTE", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortLote==0) {
                                        sortLote=1;
                                        pFilter.sort((a, b) =>
                                            a.lote.compareTo(b.lote));
                                      }else  if(pFilter!=null){
                                        sortLote=0;
                                        pFilter.sort((a, b) =>
                                            b.lote.compareTo(a.lote));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "ALMACEN", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortAlmacen==0) {
                                        sortAlmacen=1;
                                        pFilter.sort((a, b) =>
                                            a.codAlm.compareTo(b.codAlm));
                                      }else  if(pFilter!=null){
                                        sortAlmacen=0;
                                        pFilter.sort((a, b) =>
                                            b.codAlm.compareTo(a.codAlm));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "ESTADO", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortEstado==0) {
                                        sortEstado=1;
                                        pFilter.sort((a, b) =>
                                            a.estado.compareTo(b.estado));
                                      }else  if(pFilter!=null){
                                        sortEstado=0;
                                        pFilter.sort((a, b) =>
                                            b.estado.compareTo(a.estado));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "FECHA APROBACION", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortFecAprobacion==0) {
                                        sortFecAprobacion=1;
                                        pFilter.sort((a, b) =>
                                            a.fecAprov.compareTo(b.fecAprov));
                                      }else  if(pFilter!=null){
                                        sortFecAprobacion=0;
                                        pFilter.sort((a, b) =>
                                            b.fecAprov.compareTo(a.fecAprov));
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
                                      TextStyle s = TextStyle(fontSize: 12);
                                      refreshList = setState;
                                      return ListView.separated(
                                          controller: scroll,
                                          itemBuilder: (context, index) {
                                            ModelSalidasBajas m = pFilter[index];
                                            List<String> dat = m.fecReg.split('-');
                                            return Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${dat[2]}/${dat[1]}/${dat[0]}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.tipo}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codigoSalida}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codProd}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(3),
                                                    child: Center(child: Text("${m.nombreProd}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${NumberFunctions.formatNumber(m.cantidad,3)}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.lote}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codAlm}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.aprov==0?"EN ESPERA":m.aprov==1?"ACEPTADO":"REPROBADO"}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.fecAprov}", style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: InkWell(
                                                        onTap: (){
                                                          PrintPDF.impresionSalidaBaja(
                                                              m.codigoSalida,
                                                              cantidadTotales[m.codigoSalida],
                                                              costosTotales[m.codigoSalida],
                                                              m,
                                                              agrupados[m.codigoSalida]
                                                          );
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
      sp.setString("fecIniSB", fecIni);
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
        sp.setString("fecFinSB", fecFin);
      });
    }
  }
  generateExcel(String title, String nameSheet,List<String> header){
    if(pFilter.length>0){
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
      cell.value = "REPORTE DE SALIDAS BAJAS"; // dynamic values support provided;
      cell.cellStyle = cellStyle;
      var cell1 = sheetObject.cell(CellIndex.indexByString("A2"));
      cell1.value = "DEL $fecIni"; // dynamic values support provided;
      cell1.cellStyle = cellStyle;
      var cell2 = sheetObject.cell(CellIndex.indexByString("A3"));
      cell2.value = "AL $fecFin"; // dynamic values support provided;
      cell2.cellStyle = cellStyle;

      // sheetObject.appendRow(['CODIGO','DESCRIPCION','UNIDAD','CLIENTE']);
      List<String> abc = ["A","B","C","D","E","F","G","H","I","J","k","L","M","N","O","P","Q","R","S"];
      sheetObject.appendRow(header);
      for(int i=0;i<header.length;i++){
        sheetObject.cell(CellIndex.indexByString("${abc[i]}4")).style = styleHeader;
      }
      pFilter.forEach((element) {
        List<String> dat = element.fecReg.split('-');
        sheetObject.appendRow([
          element.fecReg!="null"?"${dat[2]}/${dat[1]}/${dat[0]}":"",
          element.tipo!="null"?element.tipo:"",
          element.codigoSalida!="null"?element.codigoSalida:"",
          element.codAlm!="null"?element.codAlm:"",
          element.codProd!="null"?element.codProd:"",
          element.nombreProd!="null"?element.nombreProd:"",
          element.unidadMedida!="null"?element.unidadMedida:"",
          element.cantidad!="null"?element.cantidad:"",
          element.costoUnit!="null"?element.costoUnit:"",
          element.cantidad!="null"?element.cantidad*element.costoUnit:"",
          element.lote!="null"?element.lote:"",
          element.loteVenta!="null"?element.loteVenta:"",
          element.fecVencimiento!="null"?element.fecVencimiento:"",
          element.aprov!="null"?element.aprov==0?"EN ESPERA":element.aprov==1?"APROBADO":"REPROBADO":"",
          element.fecAprov!="null"?element.fecAprov:"",
          element.usuario!="null"?element.usuario:"",
          element.solicitanteName!="null"?element.solicitanteName:"",
          element.area!="null"?element.area:"",
          element.observacion!="null"?element.observacion:""
        ]);
      });

      excel.encode().then((onValue) {
        js.context['pdfData'] = base64.encode(onValue);
        js.context['filename'] = '$nameSheet.xlsx';
        Timer.run(() {
          js.context.callMethod('download');
        });
      });
    }else{
      Toast.show("NO EXISTE STOCK", context, duration: Toast.LENGTH_LONG);
    }
  }
}
