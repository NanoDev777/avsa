import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'package:andeanvalleysystem/models/model_registro_ingreso.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/print_pdf.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'dart:js' as js;
class ModuleReimpresionIngresos extends StatefulWidget {
  @override
  _ModuleReimpresionIngresosState createState() => _ModuleReimpresionIngresosState();
}

class _ModuleReimpresionIngresosState extends State<ModuleReimpresionIngresos> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelRegistroIngreso> provAll = List();
  List<ModelRegistroIngreso> pFilter = List();
  TextEditingController ecFecInicio = TextEditingController();
  TextEditingController ecFecFin = TextEditingController();
  Map<String, List<ModelInventario>> itemsCodigo = Map();
  String fecIni="", fecFin="";
  String errorFecInicio;
  String errorFecFin;
  bool habilitado=true;
  int sortReg=1;
  int sortCodIng=1;
  int sortCantidad=1;
  int sortItem=1;
  int sortItemName=1;
  int sortLote=1;
  int sortAlm=1;
  SharedPreferences sp;

  Future getData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    if(sp.containsKey("fecIniI") && sp.containsKey("fecFinI")){
      fecIni = sp.getString("fecIniI");
      fecFin = sp.getString("fecFinI");
      List<String> fecI = fecIni.split("-");
      List<String> fecF = fecFin.split("-");
      ecFecInicio.text = "${fecI[2]}/${fecI[1]}/${fecI[0]}";
      ecFecFin.text ="${fecF[2]}/${fecF[1]}/${fecF[0]}";
    }
    return await ApiInventory().getRegistroDate(fecIni,fecFin);
  }

  Future clearData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.remove("fecIniT");
    sp.remove("fecFinT");
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
  Widget build(BuildContext context){
    return Scaffold(
        body: FutureBuilder(
          future: getData(),//ApiInventory().getRegistroDate(fecIni,fecFin),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              SomethingWentWrongPage();
            if(snapshot.connectionState==ConnectionState.done){
              provAll = snapshot.data;
              pFilter.addAll(provAll);
              provAll.forEach((element) {
                ModelProveedores p= ModelProveedores(
                    nombre: element.provName
                );
                ModelItem prod = ModelItem(
                    nombre: element.nombreProd,
                    titulo: element.unidadMedida
                );
                ModelInventario mi = ModelInventario(
                    codProd: element.codProd,
                    nombre: element.nombreProd,
                    unidad: element.unidadMedida,
                    cantidad: element.cantidad,
                    costoUnitario: element.costoUnitario,
                    lote: element.lote,
                    fecVencimiento: element.fecVencimiento,
                    factura: element.factura,
                    proveedor: p,
                    producto: prod
                );
                if(itemsCodigo.containsKey(element.codigo)){
                  itemsCodigo[element.codigo].add(mi);
                }else{
                  itemsCodigo[element.codigo] = List();
                  itemsCodigo[element.codigo].add(mi);
                }
              });
              // pFilter.forEach((element) {
              //   element.codigo = "IN-${element.id.toString().padLeft(5,'0')}";
              // });
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
                                    if(element.codigo.toLowerCase().contains(value.toLowerCase()) ||
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
                              generateExcel("REPORTE-INGRESOS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-INGRESOS",
                                  [
                                    'Fecha Registro',
                                    'Codigo ingreso',
                                    'Almacen',
                                    'Codigo Producto',
                                    'Producto',
                                    'Unidad',
                                    'Cantidad',
                                    'Costo Unitario [Bs]',
                                    'Costo Total [Bs]',
                                    'Lote',
                                    'Fecha Vencimiento',
                                    'Fecha Llegada',
                                    'Factura',
                                    'Recibo de Compra',
                                    'Proveedor',
                                    'N RAU',
                                    'Vigencia RAU',
                                    'Observaciones',
                                  ]);
                            },
                            child: Image.asset("assets/images/exceldown.png", width: 50, height: 50,)))
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                        margin: EdgeInsets.all(3),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  WidgetHeaderList(text: "Fecha ingreso", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortReg==0) {
                                        sortReg=1;
                                        pFilter.sort((a, b) =>
                                            a.fecRegistro.compareTo(b.fecRegistro));
                                      }else if(pFilter!=null){
                                        sortReg=0;
                                        pFilter.sort((a, b) =>
                                            b.fecRegistro.compareTo(a.fecRegistro));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Codigo Ingreso", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortCodIng==0) {
                                        sortCodIng=1;
                                        pFilter.sort((a, b) =>
                                            a.codigo.compareTo(b.codigo));
                                      }else  if(pFilter!=null){
                                        sortCodIng=0;
                                        pFilter.sort((a, b) =>
                                            b.codigo.compareTo(a.codigo));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Item", flex: 1,func: (){
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
                                  WidgetHeaderList(text: "Nombre Item", flex: 3,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortItemName==0) {
                                        sortItemName=1;
                                        pFilter.sort((a, b) =>
                                            a.nombreProd.compareTo(b.nombreProd));
                                      }else  if(pFilter!=null){
                                        sortItemName=0;
                                        pFilter.sort((a, b) =>
                                            b.nombreProd.compareTo(a.nombreProd));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "Cantidad", flex: 1,func: (){
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
                                  WidgetHeaderList(text: "Lote", flex: 1,func: (){
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
                                  WidgetHeaderList(text: "Almacen Ingreso", flex: 1,func: (){
                                    refreshList((){
                                      if(pFilter!=null && sortAlm==0) {
                                        sortAlm=1;
                                        pFilter.sort((a, b) =>
                                            a.codAlm.compareTo(b.codAlm));
                                      }else  if(pFilter!=null){
                                        sortAlm=0;
                                        pFilter.sort((a, b) =>
                                            b.codAlm.compareTo(a.codAlm));
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
                                      TextStyle s = TextStyle(fontSize: 12);
                                      refreshList = setState;
                                      return ListView.separated(
                                          controller: scroll,
                                          itemBuilder: (context, index) {
                                            ModelRegistroIngreso m = pFilter[index];
                                            List<String> dateSplit = m.fecRegistro.split('-');
                                            return Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${dateSplit[2]}/${dateSplit[1]}/${dateSplit[0]}",
                                                    style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text(m.codigo,
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codProd}",
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.nombreProd}",
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.cantidad}",
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.lote}",
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Center(child: Text("${m.codAlm}",
                                                      style: s,)),
                                                  ),
                                                ),
                                                Container(width: 2,height: 20,color: Colors.grey,),
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: InkWell(
                                                        onTap: (){
                                                          ModelAlmacenes alm = ModelAlmacenes(
                                                              codAlm: m.codAlm,
                                                              name: m.nombreAlm
                                                          );
                                                          PrintPDF.impresionIngresos(
                                                              m.codigo,
                                                              alm,
                                                              m.fecIngreso,
                                                              itemsCodigo[m.codigo]
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
    provAll.clear();
    pFilter.clear();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ecFecInicio.text = DateFormat("dd/MM/yyyy").format(picked);
        fecIni = DateFormat("yyyy-MM-dd").format(picked);
        sp.setString("fecIniI", fecIni);
      });
    }
  }
  Future<void> _selectDateFin(BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    provAll.clear();
    pFilter.clear();
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
        sp.setString("fecFinI", fecFin);
      });
    }
  }

  Future generateExcel(String title, String nameSheet,List<String> header)async{
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
      cell.value = "REPORTE DE INGRESOS"; // dynamic values support provided;
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
        List<String> dat = element.fecRegistro.split('-');
        sheetObject.appendRow([
          element.fecRegistro!="null"?"${dat[2]}/${dat[1]}/${dat[0]}":"",
          element.codigo!="null"?element.codigo:"",
          element.codAlm!="null"?element.codAlm:"",
          element.codProd!="null"?element.codProd:"",
          element.nombreProd!="null"?element.nombreProd:"",
          element.unidadMedida!="null"?element.unidadMedida:"",
          element.cantidad!="null"?element.cantidad:"",
          element.costoUnitario!="null"?element.costoUnitario:"",
          element.costo!="null"?element.costo:"",
          element.lote!="null"?element.lote:"",
          element.fecVencimiento!="null"?element.fecVencimiento:"",
          element.fecIngreso!="null"?element.fecIngreso:"",
          element.factura!="null"?element.factura:"",
          element.recibo!="null"?element.recibo:"",
          element.provName!="null"?element.provName:"",
          element.numRAU!="null"?element.numRAU:"",
          element.vigeniaRau!="null"?element.vigeniaRau:"",
          element.obs!="null"?element.obs:""
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
