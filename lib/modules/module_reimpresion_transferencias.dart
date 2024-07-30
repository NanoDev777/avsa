import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/models/model_transferencia.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/connections/api_transferencias.dart';
import 'package:andeanvalleysystem/utils/print_pdf.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
class ModuleReimpresionTransferencias extends StatefulWidget {
  @override
  _ModuleReimpresionTransferenciasState createState() => _ModuleReimpresionTransferenciasState();
}

class _ModuleReimpresionTransferenciasState extends State<ModuleReimpresionTransferencias> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelTransferencia> provAll = List();
  List<ModelTransferencia> pFilter = List();

  TextEditingController ecFecInicio = TextEditingController();
  TextEditingController ecFecFin = TextEditingController();
  String fecIni, fecFin;
  String errorFecInicio;
  String errorFecFin;
  bool habilitado=true;

  int sortReg=1;
  int sortCodTrans=1;
  int sortCantidad=1;
  int sortItem=1;
  int sortItemName=1;
  int sortLote=1;
  int sortAlmO=1;
  int sortAlmD=1;
  int sortEstado=1;
  int sortFecComp=1;

  Future getData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    if(sp.containsKey("fecIniT") && sp.containsKey("fecFinT")){
      fecIni = sp.getString("fecIniT");
      fecFin = sp.getString("fecFinT");
      List<String> fecI = fecIni.split("-");
      List<String> fecF = fecFin.split("-");
      ecFecInicio.text = "${fecI[2]}/${fecI[1]}/${fecI[0]}";
      ecFecFin.text ="${fecF[2]}/${fecF[1]}/${fecF[0]}";
    }
    return await ApiTransferencias().getTranferenciasPorFechas(fecIni, fecFin);
  }
  Future clearData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("fecIniI");
    sp.remove("fecFinI");
    sp.remove("fecIniPP");
    sp.remove("fecFinPP");
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
    print("$fecIni::$fecFin");
    return Scaffold(
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              SomethingWentWrongPage();
            if(snapshot.connectionState==ConnectionState.done){
              provAll.clear();
              pFilter.clear();
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
                                    if(element.codTransferencia.toLowerCase().contains(value.toLowerCase()) ||
                                        element.codProd.toLowerCase().contains(value.toLowerCase())){
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
                              generateExcel("REPORTE-TRANSFERENCIAS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-TRANSFERENCIAS",
                                  [
                                    'Fecha Registro',
                                    'Codigo Transferencia',
                                    'Almacen Origen',
                                    'Almacen Destino',
                                    'Codigo Producto',
                                    'Producto',
                                    'Unidad',
                                    'Cantidad',
                                    'Costo Unitario [Bs]',
                                    'Costo Total [Bs]',
                                    'Lote',
                                    'Lote Venta',
                                    'Fecha Vencimiento',
                                    'Realizado por',
                                    'Estado',
                                    'Fecha Contraparte'
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
                                  WidgetHeaderList(text: "Fecha registro", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortReg==0) {
                                        sortReg=1;
                                        pFilter.sort((a, b) =>
                                            a.creado_en.compareTo(b.creado_en));
                                      }else if(pFilter!=null){
                                        sortReg=0;
                                        pFilter.sort((a, b) =>
                                            b.creado_en.compareTo(a.creado_en));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Codigo Transferencia", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCodTrans==0) {
                                        sortCodTrans=1;
                                        pFilter.sort((a, b) =>
                                            a.codTransferencia.compareTo(b.codTransferencia));
                                      }else if(pFilter!=null){
                                        sortCodTrans=0;
                                        pFilter.sort((a, b) =>
                                            b.codTransferencia.compareTo(a.codTransferencia));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Item", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortItem==0) {
                                        sortItem=1;
                                        pFilter.sort((a, b) =>
                                            a.codProd.compareTo(b.codProd));
                                      }else if(pFilter!=null){
                                        sortItem=0;
                                        pFilter.sort((a, b) =>
                                            b.codProd.compareTo(a.codProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Nombre", flex: 3,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortItemName==0) {
                                        sortItemName=1;
                                        pFilter.sort((a, b) =>
                                            a.descripcion.compareTo(b.descripcion));
                                      }else if(pFilter!=null){
                                        sortItemName=0;
                                        pFilter.sort((a, b) =>
                                            b.descripcion.compareTo(a.descripcion));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Cantidad", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCantidad==0) {
                                        sortCantidad=1;
                                        pFilter.sort((a, b) =>
                                            a.cantidad.compareTo(b.cantidad));
                                      }else if(pFilter!=null){
                                        sortCantidad=0;
                                        pFilter.sort((a, b) =>
                                            b.cantidad.compareTo(a.cantidad));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Lote", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortLote==0) {
                                        sortLote=1;
                                        pFilter.sort((a, b) =>
                                            a.loteTransferido.compareTo(b.loteTransferido));
                                      }else if(pFilter!=null){
                                        sortLote=0;
                                        pFilter.sort((a, b) =>
                                            b.loteTransferido.compareTo(a.loteTransferido));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Almacen Origen", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortAlmO==0) {
                                        sortAlmO=1;
                                        pFilter.sort((a, b) =>
                                            a.almOrigen.compareTo(b.almOrigen));
                                      }else if(pFilter!=null){
                                        sortAlmO=0;
                                        pFilter.sort((a, b) =>
                                            b.almOrigen.compareTo(a.almOrigen));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Almacen Destino", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortAlmD==0) {
                                        sortAlmD=1;
                                        pFilter.sort((a, b) =>
                                            a.almDestino.compareTo(b.almDestino));
                                      }else if(pFilter!=null){
                                        sortAlmD=0;
                                        pFilter.sort((a, b) =>
                                            b.almDestino.compareTo(a.almDestino));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Estado", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortEstado==0) {
                                        sortEstado=1;
                                        pFilter.sort((a, b) =>
                                            a.estado.compareTo(b.estado));
                                      }else if(pFilter!=null){
                                        sortEstado=0;
                                        pFilter.sort((a, b) =>
                                            b.estado.compareTo(a.estado));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Fecha Contraparte", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortFecComp==0) {
                                        sortFecComp=1;
                                        pFilter.sort((a, b) =>
                                            a.fechaAceptacion.compareTo(b.fechaAceptacion));
                                      }else if(pFilter!=null){
                                        sortFecComp=0;
                                        pFilter.sort((a, b) =>
                                            b.fechaAceptacion.compareTo(a.fechaAceptacion));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Descarga", flex: 1,),
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
                                      return ListView.separated(
                                          controller: scroll,
                                          itemBuilder: (context, index) {
                                            ModelTransferencia m = pFilter[index];
                                            List<String> date = m.creado_en.split('-');
                                            TextStyle t = TextStyle(fontSize: 12);
                                            return Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${date[2]}/${date[1]}/${date[0]}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text(m.codTransferencia,style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codProd}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.descripcion}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.cantidad}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.loteTransferido}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.almOrigen}",style: t,)),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.almDestino}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.estado==0?"EN ESPERA":m.estado==1?"ACEPTADO":"RECHAZADO"}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.fechaAceptacion}",style: t,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                      padding: const EdgeInsets.all(2),
                                                      child: InkWell(
                                                          onTap: (){
                                                            // generateExcel("REPORTE-TRANSFERENCIAS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-TRANSFERENCIAS",
                                                            //     [
                                                            //       'Fecha Registro',
                                                            //       'Codigo Transferencia',
                                                            //       'Almacen Origen',
                                                            //       'Almacen Destino',
                                                            //       'Codigo Producto',
                                                            //       'Producto',
                                                            //       'Unidad',
                                                            //       'Cantidad',
                                                            //       'Costo Unitario [Bs]',
                                                            //       'Costo Total [Bs]',
                                                            //       'Lote',
                                                            //       'Lote Venta',
                                                            //       'Fecha Vencimiento',
                                                            //       'Realizado por',
                                                            //       'Estado',
                                                            //       'Fecha Contraparte'
                                                            //     ]);
                                                          },
                                                          child: Icon(Icons.arrow_circle_down))),
                                                ),

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
      sp.setString("fecIniT", fecIni);
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
        sp.setString("fecFinT", fecFin);
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
      cell.value = "REPORTE DE TRANSFERENCIAS"; // dynamic values support provided;
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
        List<String> dat = element.creado_en.split('-');
        sheetObject.appendRow([
          element.creado_en!="null"?"${dat[2]}/${dat[1]}/${dat[0]}":"",
          element.codTransferencia!="null"?element.codTransferencia:"",
          element.almOrigen!="null"?element.almOrigen:"",
          element.almDestino!="null"?element.almDestino:"",
          element.codProd!="null"?element.codProd:"",
          element.descripcion!="null"?element.descripcion:"",
          element.unidad!="null"?element.unidad:"",
          element.cantidad!="null"?element.cantidad:"",
          element.costoUnitario!="null"?element.costoUnitario:"",
          element.cantidad!="null"?element.cantidad*element.costoUnitario:0,
          element.loteTransferido!="null"?element.loteTransferido:"",
          element.loteVenta!="null"?element.loteVenta:"",
          element.fecVencimiento!="null"?element.fecVencimiento:"",
          element.usuarioTransferencia!="null"?element.usuarioTransferencia:"",
          element.estado!="null"?element.estado==0?"EN ESPERA":element.estado==1?"APROBADO":"RECHAADO":"",
          element.fechaAceptacion!="null"?element.fechaAceptacion:""
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

                     