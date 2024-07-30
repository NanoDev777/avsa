import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:js' as js;

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_inv_agrupado.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down_almacenes.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';
import 'package:universal_html/html.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ModuleReporteAlmacenes extends StatefulWidget {
  @override
  _ModuleReporteAlmacenesState createState() => _ModuleReporteAlmacenesState();
}

class _ModuleReporteAlmacenesState extends State<ModuleReporteAlmacenes> {
  int codAlm = 0;
  List<ModelInventario> inv = List();
  Map<String, List<ModelInventario>> inventario = Map();
  List<String> keys = List();
  ModelAlmacenes selectionAlm;
  StateSetter refreshLista;
  
  String fechaIniMandar;
  TextEditingController ecFechaIni = TextEditingController();
  String errFechaIni = null;
  bool habilitado = true;

  bool sortCodigo=false;
  bool sortDescripcion=true;
  bool sortUnidad=true;
  bool sortCantidad=true;
  bool sortCostoUnit=true;
  bool sortDLote=false;
  bool sortDLoteVenta=true;
  bool sortDUnidad=true;
  bool sortDCantidad=true;
  bool sortDCostoUnit=true;
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final now  = DateTime.now();
    ecFechaIni=TextEditingController(text: DateFormat("dd/MM/yyyy").format(now));
    fechaIniMandar = DateFormat("yyyy-MM-dd").format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: Image.asset("assets/images/fondo2.png", fit: BoxFit.fill,),
            ),
            Container(
              color: Colors.white,
              child: Column(
      children: [
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 11,
                        child: Container(
                            margin: EdgeInsets.all(2),
                            child: TextFormField(
                              onTap: () {
                                if (ecFechaIni.text.isEmpty)
                                  _selectDateIni(context);
                                errFechaIni = null;
                              },
                              onChanged: (value) {
                                if (value.length == 10) {
                                  errFechaIni = null;
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
                                            errFechaIni = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaIni = "Fecha Invalida";
                                          });
                                        }
                                      } else if (int.parse(mes) % 2 == 0) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 31) {
                                          setState(() {
                                            errFechaIni = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaIni = "Fecha Invalida";
                                          });
                                        }
                                      } else {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 32) {
                                          setState(() {
                                            errFechaIni = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaIni = "Fecha Invalida";
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        errFechaIni = "Fecha Invalida";
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      errFechaIni = "Fecha Invalida";
                                    });
                                  }
                                }
                              },
                              keyboardType: TextInputType.datetime,
                              maxLength: 10,
                              enabled: habilitado,
                              controller: ecFechaIni,
                              decoration: InputDecoration(
                                  errorText: errFechaIni,
                                  border: OutlineInputBorder(),
                                  labelText: "FECHA",
                                  hintText: "Ejemplo: dd/mm/yyyy",
                                  counterText: ""),
                            ),
                          ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: () {
                            _selectDateIni(context);
                            getData();
                          },
                          child: Icon(Icons.date_range),
                        ),
                      ),
                      Expanded(
                        flex: 12,
                        child: DropDownAlmacenes(
                            selectionAlmacen: selectionAlm,
                            refresh: (val) {
                              setState(() {
                                inventario.clear();
                                keys.clear();
                                selectionAlm = val;
                                codAlm = selectionAlm.codAlm;
                              });
                            }),
                      ),
                      Expanded(
                          flex: 1,
                          child: Tooltip(
                              message: "Exportar Stock a Excel",
                              child: InkWell(
                                onTap: (){
                                  generateExcel(1,"REPORTE DE STOCK AL ${DateFormat("dd/MM/yyyy").format(DateTime.now())}","REPORTE_DE_STOCK_${DateFormat("ddMMyyyy").format(DateTime.now())}-${selectionAlm.codAlm}",['Codigo','Descripcion','Unidad','Cantidad','Costo Unitario [Bs/u]']);
                                },//${DateFormat("dd/MM/yyyy").format(DateTime.now())}
                                  child: Image.asset("assets/images/exceldown.png",width: 50,height: 50,)
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Tooltip(
                              message: "Exportar Stock a PDF",
                              child: InkWell(
                                onTap: (){
                                  if(inv.length>0)
                                    generatePdf(1,"REPORTE DE STOCK\nPOR ALMACEN","REPORTE_DE_STOCK_${DateFormat("ddMMyyyy").format(DateTime.now())}--${selectionAlm.codAlm}",['Codigo','Descripcion','Unidad','Cantidad','Costo Unitario [Bs/u]']);
                                  else Toast.show("NO EXISTE STOCK", context, duration: Toast.LENGTH_LONG);
                                },
                                  child: Image.asset("assets/images/pdfdown.png",width: 50,height: 50,)
                              )
                          )
                      )
                    ],
                  )),
              Expanded(
                flex: 9,
                child: Container(
                  color: Colors.white,
                  child: FutureBuilder(
                    future: getData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return SomethingWentWrongPage();
                      if (snapshot.connectionState == ConnectionState.done) {
                        // inv = snapshot.data;
                        if (inventario.length > 0) {
                          return StatefulBuilder(builder: (context, setState) {
                            refreshLista = setState;
                            return Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      headerListCustom("Codigo", 1, (){
                                        refreshLista((){
                                          if(sortCodigo) {
                                            sortCodigo = !sortCodigo;
                                            inv.sort((a, b) =>
                                                a.codProd.compareTo(b.codProd));
                                          }else{
                                            sortCodigo = !sortCodigo;
                                            inv.sort((a, b) =>
                                                b.codProd.compareTo(a.codProd));
                                          }
                                        });
                                      }),
                                      headerListCustom("Descripcion", 2, (){
                                        refreshLista((){
                                          if(sortDescripcion) {
                                            sortDescripcion = !sortDescripcion;
                                            inv.sort((a, b) =>
                                                a.nombre.compareTo(b.nombre));
                                          }else{
                                            sortDescripcion = !sortDescripcion;
                                            inv.sort((a, b) =>
                                                b.nombre.compareTo(a.nombre));
                                          }
                                        });
                                      }),
                                      headerListCustom("Unidad", 1, (){
                                        refreshLista((){
                                          if(sortUnidad) {
                                            sortUnidad = !sortUnidad;
                                            inv.sort((a, b) =>
                                                a.unidad.compareTo(b.unidad));
                                          }else{
                                            sortUnidad = !sortUnidad;
                                            inv.sort((a, b) =>
                                                b.unidad.compareTo(a.unidad));
                                          }
                                        });
                                      }),
                                      headerListCustom("Cantidad", 1, (){
                                        refreshLista((){
                                          if(sortCantidad) {
                                            sortCantidad = !sortCantidad;
                                            inv.sort((a, b) =>
                                                a.cantidad.compareTo(b.cantidad));
                                          }else{
                                            sortCantidad = !sortCantidad;
                                            inv.sort((a, b) =>
                                                b.cantidad.compareTo(a.cantidad));
                                          }
                                        });
                                      }),
                                      headerListCustom("Costo Unitario [Bs/u]", 1, (){
                                        refreshLista((){
                                          if(sortCostoUnit) {
                                            sortCostoUnit = !sortCostoUnit;
                                            inv.sort((a, b) =>
                                                a.prorrateo.compareTo(b.prorrateo));
                                          }else{
                                            sortCostoUnit = !sortCostoUnit;
                                            inv.sort((a, b) =>
                                                b.prorrateo.compareTo(a.prorrateo));
                                          }
                                        });
                                      }),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(10),
                                    child: Scrollbar(
                                      isAlwaysShown: true,
                                      controller: scroll,
                                      child: ListView.separated(
                                        controller: scroll,
                                        itemCount: keys.length,
                                        separatorBuilder: (context, index) => Divider(),
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              _showDialog(keys[index],
                                                  inventario[keys[index]][0].nombre==null?"sin nombre":inventario[keys[index]][0].nombre);
                                            },
                                            child: Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    inventario[keys[index]][0].codProd,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(inventario[keys[index]][0].nombre==null?"sin nombre":inventario[keys[index]][0].nombre),
                                                      Text("Cantidad de lotes: ${inventario[keys[index]].length}", style: TextStyle(color: Colors.grey),)
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    inventario[keys[index]][0].unidad==null?"sin unidad":inventario[keys[index]][0].unidad,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    "${NumberFunctions.formatNumber(inventario[keys[index]][0].cantidadTotalLotes,2)}",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    "${NumberFunctions.formatNumber(inventario[keys[index]][0].prorrateo,3)}",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },);
                        } else {
                          return Center(
                            child: Container(
                              child: Text("NO EXISTEN PRODUCTOS"),
                            ),
                          );
                        }
                      }
                      return LoadingPage();
                    },
                  ),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Tooltip(
                              message: "Exportar Stock+Lotes a Excel",
                              child: InkWell(
                                  onTap: (){
                                    generateExcel(3,"REPORTE DE STOCK+LOTES AL ${DateFormat("dd/MM/yyyy").format(DateTime.now())}","REPORTE_DE_STOCK_LOTES_${DateFormat("ddMMyyyy").format(DateTime.now())}-${selectionAlm.codAlm}",['Codigo','Descripcion','Lote','Lote de Venta','Unidad','Cantidad','Costo Unitario [Bs/u]', 'Vencimiento']);
                                  },
                                  child: Image.asset("assets/images/exceldown.png",width: 50,height: 50,)
                              )
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child: Tooltip(
                              message: "Exportar Stock+Lotes a PDF",
                              child: InkWell(
                                onTap: (){
                                  generatePdf(3,"REPORTE STOCK LOTES\nPOR ALMACEN","REPORTE_DE_STOCK_LOTES_${DateFormat("ddMMyyyy").format(DateTime.now())}-${selectionAlm.codAlm}",['Codigo','Descripcion','Lote','Lote de Venta','Unidad','Cantidad','Costo Unitario [Bs/u]']);
                                },
                                  child: Image.asset("assets/images/pdfdown.png",width: 50,height: 50,)
                              )
                          )
                      )
                    ],
                  )),
      ],
    ),
            ),
          ],
        ));
  }

  generateExcel(int tipo,String title, String nameSheet,List<String> header){
    if(inv.length>0){
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
      cell.value = title; // dynamic values support provided;
      cell.cellStyle = cellStyle;
      var cell1 = sheetObject.cell(CellIndex.indexByString("A2"));
      cell1.value = "Almacen: ${selectionAlm.codAlm} - ${selectionAlm.name}";
      cell1.cellStyle = cellStyle;
      var cell3 = sheetObject.cell(CellIndex.indexByString("A3"));
      cell3.cellStyle = cellStyle;
      if(tipo==2)
        cell3.value = "Producto: ${invDetalle[0].codProd} - ${invDetalle[0].nombre}";


      // sheetObject.appendRow(['Codigo','Descripcion','Unidad','Cantidad','Costo Unitario']);
      List<String> abc = ["A","B","C","D","E","F","G","H","I","J"];
      sheetObject.appendRow(header);
      for(int i=0;i<header.length;i++){
        sheetObject.cell(CellIndex.indexByString("${abc[i]}4")).style = styleHeader;
      }
      switch(tipo){
        case 1:
          inventario.forEach((key, element) {
            print("${element[0].codProd},${element[0].nombre},${element[0].unidad},${element[0].cantidadTotalLotes},${element[0].prorrateo}");
            sheetObject.appendRow([element[0].codProd,element[0].nombre,element[0].unidad,element[0].cantidadTotalLotes,
              element[0].prorrateo]);
          });
          break;
        case 2:
          invDetalle.forEach((element) {
            print(element.costoUnitario);
            sheetObject.appendRow([element.lote,element.loteVenta!=null?element.loteVenta:"",element.unidad,element.cantidad,
            element.costoUnitario]);
          });
          break;
        case 3:
          int neg=5;
          inventario.forEach((key, element) {
            sheetObject.appendRow([element[0].codProd,element[0].nombre,"","","","",""]);
            sheetObject.cell(CellIndex.indexByString("A$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("B$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("C$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("D$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("E$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("F$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("G$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            sheetObject.cell(CellIndex.indexByString("H$neg")).style = CellStyle(bold: true,backgroundColorHex: "#d9d9d9");
            double cantTotal=0;
            element.forEach((e) {
              print("${e.lote},${e.loteVenta},${e.unidad},${e.cantidad},${e.prorrateo}");
              sheetObject.appendRow(["","",e.lote,e.loteVenta!=null?e.loteVenta:"",e.unidad,e.cantidad,
                e.prorrateo,e.fecVencimiento]);
              cantTotal += e.cantidad;
              sheetObject.cell(CellIndex.indexByString("F$neg")).value = cantTotal;
            });
            neg += 1+element.length;
          });
          break;
      }

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

  Future generatePdf(int tipo,String titulo, String nombreFile,List<String> headersList) async {
    if(inv.length>0){
      PdfDocument document = PdfDocument();
      document.pageSettings.margins.all = 10;
      PdfPage page = document.pages.add();

      double w = document.pages[0].getClientSize().width;
      double h = document.pages[0].getClientSize().height;

      MakePdf().margin(page, w, h);
      await MakePdf().head(page, w, h, titulo);
      List<String> title = ["ALMACEN: ${selectionAlm.codAlm} - ${selectionAlm.name}",
        tipo==2?"PRODUCTO: ${invDetalle[0].codProd} - ${invDetalle[0].nombre}":"","AL ${DateFormat("dd/MM/yyyy").format(DateTime.now())}"];
      List<String> titles2 = [];
      MakePdf().sector(page, 5, w-5,90,150,true,title,titles2);
      double heightRes = (((h-90)-(125))/2)-10;

      PdfGrid grid = PdfGrid();
      grid.columns.add(count: headersList.length);
      grid.headers.add(1);
      if(tipo!=2)
        grid.columns[1].width = 200;
      PdfGridRow header = grid.headers[0];
      for(int i=0;i<headersList.length;i++){
        header.cells[i].value = headersList[i];

        header.cells[i].stringFormat = PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        );
      }
      switch(tipo){
        case 1:
          inventario.forEach((key, element) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value = element[0].codProd;
            row.cells[1].value = element[0].nombre;
            row.cells[2].value = element[0].unidad;
            row.cells[3].value = NumberFunctions.formatNumber(element[0].cantidadTotalLotes,2);
            row.cells[4].value = NumberFunctions.formatNumber(element[0].prorrateo,3);
            // grid.rows[inventario.indexOf(element)].height = 23;
          });
          break;
        case 2:
          invDetalle.forEach((element) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value = element.lote;
            row.cells[1].value = element.loteVenta!=null?element.loteVenta:"";
            row.cells[2].value = element.unidad;
            row.cells[3].value = NumberFunctions.formatNumber(element.cantidad,2);
            row.cells[4].value = NumberFunctions.formatNumber(element.prorrateo,3);
            grid.rows[invDetalle.indexOf(element)].height = 23;
          });
          break;
        case 3:
          inventario.forEach((key, element) {
            PdfGridRow row = grid.rows.add();
            row.cells[0].value = element[0].codProd;
            row.cells[1].value = element[0].nombre;
            row.cells[2].value = "-------";
            row.cells[3].value = "-------";
            row.cells[4].value = "-------";
            row.cells[6].value = "-------";
            double cantTotal=0;
            element.forEach((i) {
              PdfGridRow row1 = grid.rows.add();
              row1.cells[2].value = i.lote;
              row1.cells[3].value = i.loteVenta!=null?i.loteVenta:"";
              row1.cells[4].value = i.unidad;
              row1.cells[5].value = NumberFunctions.formatNumber(i.cantidad,2);
              row1.cells[6].value = NumberFunctions.formatNumber(i.prorrateo,3);
              cantTotal += i.cantidad;
              row.cells[5].value = NumberFunctions.formatNumber(cantTotal,2);
              grid.rows[inv.indexOf(i)].height = 23;
            });
          });
          break;
      }
      grid.style = PdfGridStyle(
          cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
          // backgroundBrush: PdfBrushes.blue,
          textBrush: PdfBrushes.black,
          font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
      );
      MakePdf().sectorTables(page, w, h, 5, w-5,155,h-5,"STOCK",grid);

      List<int> bytes = document.save();
      document.dispose();

      js.context['pdfData'] = base64.encode(bytes);
      js.context['filename'] = '$nombreFile.pdf';
      Timer.run(() {
        js.context.callMethod('download');
      });
    }else Toast.show("NO EXISTE STOCK", context, duration: Toast.LENGTH_LONG);
  }

  headerListCustom(String text, int flex, Function func) {
    return Expanded(
        flex: flex,
        child: InkWell(
          onTap: func,
          child: Container(
              margin: EdgeInsets.all(1),
              width: double.infinity,
              height: 50,
              color: Colors.blueGrey,
              child: Center(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * .01),
                ),
              )),
        ));
  }
  List<ModelInventario> invDetalle=List();
  Future<void> _showDialog(String codProd, String name) async {
    invDetalle = inventario[codProd];
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:Row(
            children: [
              Expanded(flex: 12,child: Text("Detalles Lotes $codProd - $name")),
              Expanded(
                  flex: 1,
                  child: Tooltip(
                      message: "Exportar a Excel",
                      child: InkWell(
                        onTap: (){
                          generateExcel(2,"REPORTES DE LOTES AL ${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTES_DE_LOTES_${DateFormat("ddMMyyyy").format(DateTime.now())}-${selectionAlm.codAlm}", ["Lote","Lote de Venta","Unidad","Cantidad","Costo Unitario[Bs/u]"]);
                        },
                          child: Image.asset("assets/images/exceldown.png",width: 50,height: 50,)))),
              Expanded(
                  flex: 1,
                  child: Tooltip(
                      message: "Exportar a PDF",
                      child: InkWell(
                        onTap: (){
                          generatePdf(2,"REPORTE DE LOTES\nPOR ALMACEN","REPORTE_LOTES_${DateFormat("ddMMyyyy").format(DateTime.now())}-${selectionAlm.codAlm}",["Lote","Lote de Venta","Unidad","Cantidad","Costo Unitario[Bs/u]"]);
                        },
                          child: Image.asset("assets/images/pdfdown.png",width: 50,height: 50,)
                      )
                  )
              )
            ],
          ),
          content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.8,
              child: StatefulBuilder(builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          headerListCustom("Lote", 1, (){
                            setState((){
                              if(sortDLote) {
                                sortDLote = !sortDLote;
                                invDetalle.sort((a, b) =>
                                    a.lote.compareTo(b.lote));
                              }else{
                                sortDLote = !sortDLote;
                                invDetalle.sort((a, b) =>
                                    b.lote.compareTo(a.lote));
                              }
                            });
                          }),
                          headerListCustom("Lote de Venta", 1, (){
                            setState((){
                              if(sortDLoteVenta) {
                                sortDLoteVenta = !sortDLoteVenta;
                                invDetalle.sort((a, b) =>
                                    a.loteVenta.compareTo(b.loteVenta));
                              }else{
                                sortDLoteVenta = !sortDLoteVenta;
                                invDetalle.sort((a, b) =>
                                    b.loteVenta.compareTo(a.loteVenta));
                              }
                            });
                          }),
                          headerListCustom("Unidad", 1, (){
                            setState((){
                              if(sortDUnidad) {
                                sortDUnidad = !sortDUnidad;
                                invDetalle.sort((a, b) =>
                                    a.unidad.compareTo(b.unidad));
                              }else{
                                sortDUnidad = !sortDUnidad;
                                invDetalle.sort((a, b) =>
                                    b.unidad.compareTo(a.unidad));
                              }
                            });
                          }),
                          headerListCustom("Cantidad", 1, (){
                            setState((){
                              if(sortDCantidad) {
                                sortDCantidad = !sortDCantidad;
                                invDetalle.sort((a, b) =>
                                    a.cantidad.compareTo(b.cantidad));
                              }else{
                                sortDCantidad = !sortDCantidad;
                                invDetalle.sort((a, b) =>
                                    b.cantidad.compareTo(a.cantidad));
                              }
                            });
                          }),
                          headerListCustom("Costo Unitario [Bs/u]", 1, (){
                            setState((){
                              if(sortDCostoUnit) {
                                sortDCostoUnit = !sortDCostoUnit;
                                invDetalle.sort((a, b) =>
                                    a.prorrateo.compareTo(b.prorrateo));
                              }else{
                                sortDCostoUnit = !sortDCostoUnit;
                                invDetalle.sort((a, b) =>
                                    b.prorrateo.compareTo(a.prorrateo));
                              }
                            });
                          }),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(10),
                        child: ListView.separated(
                          itemCount: invDetalle.length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {

                              },
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      invDetalle[index].lote==null?"":invDetalle[index].lote,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(invDetalle[index].loteVenta!=null?invDetalle[index].loteVenta:"",
                                      textAlign: TextAlign.center,),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      invDetalle[index].unidad==null?"sin unidad":invDetalle[index].unidad,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${NumberFunctions.formatNumber(invDetalle[index].cantidad,2)}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${NumberFunctions.formatNumber(invDetalle[index].prorrateo,3)}",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                );
              },)),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _selectDateIni(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ecFechaIni.text = DateFormat("dd/MM/yyyy").format(picked);
        fechaIniMandar = DateFormat("yyyy-MM-dd").format(picked);
        inventario.clear();
        keys.clear();
      });
    }
  }

  Future<bool> getData() async{
    // if(inventario == null || inventario.length == 0) {
    //   inv = await ApiInventory().getInventarioExistentes(codAlm);
    //   inv.forEach((element) {
    //     if (inventario.containsKey(element.codProd)) {
    //       inventario[element.codProd].add(element);
    //       inventario[element.codProd].first.cantidadTotalLotes += element.cantidad;
    //     }else {
    //       keys.add(element.codProd);
    //       inventario[element.codProd] = List();
    //       inventario[element.codProd].add(element);
    //       inventario[element.codProd].first.cantidadTotalLotes += element.cantidad;
    //     }
    //   });
    //   return true;
    // }else print("salio por else");

    if(inventario == null || inventario.length == 0) {
      inv = await ApiInventory().getInventarioFecha(codAlm, fechaIniMandar);
      inv.forEach((element) {
        if (inventario.containsKey(element.codProd)) {
          inventario[element.codProd].add(element);
          inventario[element.codProd].first.cantidadTotalLotes += element.cantidad;
        }else {
          keys.add(element.codProd);
          inventario[element.codProd] = List();
          inventario[element.codProd].add(element);
          inventario[element.codProd].first.cantidadTotalLotes += element.cantidad;
        }
      });
      return true;
    }else print("salio por else");
  }
}
