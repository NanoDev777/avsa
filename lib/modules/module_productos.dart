import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_productos.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:toast/toast.dart';
class ModuleProductos extends StatefulWidget {
  @override
  _ModuleProductosState createState() => _ModuleProductosState();
}

class _ModuleProductosState extends State<ModuleProductos> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelItem> itemsAll = List();
  List<ModelItem> pFilter = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: ApiProductos().get(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            SomethingWentWrongPage();
          if(snapshot.connectionState==ConnectionState.done){
            itemsAll = snapshot.data;
            pFilter.addAll(itemsAll);
            return Column(
              children: [
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
                                pFilter.addAll(itemsAll);
                              }else{
                                print("else::$value::${pFilter.length}");
                                itemsAll.forEach((element) {
                                  if(element.nombre.toLowerCase().contains(value.toLowerCase()) || element.codigo.contains(value)){
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
                          generatePdf("REPORTE-PRODUCTOS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}");
                        },
                          child: Image.asset("assets/images/pdfdown.png", width: 50, height: 50,))),
                      Expanded(flex:1,child: InkWell(
                        onTap: (){
                          generateExcel("REPORTE-PRODUCTOS-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-PRODUCTOS",
                              [
                                'CODIGO',
                                'DESCRIPCION',
                                'UNIDAD',
                                'CONTROL STOCK',
                                'PRODUCTO SGI',
                                'FACTOR DE EQUIVALENCIA',
                                'PESO NETO',
                                'PESO BRUTO',
                                'CLIENTE',

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
                                WidgetHeaderList(text: "CODIGO", flex: 1,),
                                WidgetHeaderList(text: "DESCRIPCION", flex: 3,),
                                WidgetHeaderList(text: "UNIDAD", flex: 1,),
                                WidgetHeaderList(text: "CLIENTE", flex: 3,),
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
                                        ModelItem m = pFilter[index];
                                        return Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2),
                                                child: Text(m.codigo),
                                              ),
                                            ),
                                            Container(width: 2,height: 20,color: Colors.grey,),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2),
                                                child: Text(m.nombre),
                                              ),
                                            ),
                                            Container(width: 2,height: 20,color: Colors.grey,),
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2),
                                                child: Text(m.titulo),
                                              ),
                                            ),
                                            Container(width: 2,height: 20,color: Colors.grey,),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding: const EdgeInsets.all(2),
                                                child: Text(m.razonSocial!=null&&m.razonSocial!="null"?m.razonSocial:""),
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

  Future generatePdf(String nombre) async {
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 10;
    PdfPage page = document.pages.add();

    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;

    MakePdf().margin(page, w, h);
    await MakePdf().head(page, w, h,'REPORTE \nDE PRODUCTOS');
    List<String> title = ["FECHA DE CONSULTA:\t${DateFormat("dd/MM/yyyy").format(DateTime.now())}"];
    List<String> titles2 = [""];
    MakePdf().sector(page, 5, w-5,90,140,true,title,titles2);
    // List<String> title1 = [""];
    // List<String> titles12 = [""];
    // MakePdf().sector(page, 5, w-5,220,310,true,title1,titles12);
    double heightRes = (((h-90)-(310))/2)-10;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 5);
    grid.headers.add(1);
    grid.columns[1].width = 200;
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'CODIGO';
    header.cells[1].value = 'DESCRIPCION';
    header.cells[2].value = 'UNIDAD';
    header.cells[3].value = 'CLIENTE';
    header.cells[4].value = 'INSTRUCCIONES';

    header.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[1].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[2].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[3].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[4].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    itemsAll.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.codigo;
      row.cells[1].value = element.nombre;
      row.cells[2].value = element.titulo;
      row.cells[3].value = element.razonSocial;
      row.cells[4].value = element.descripcion;
      grid.rows[itemsAll.indexOf(element)].height = 23;
    });

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,160,h,"PRODUCTOS",grid);

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }

  generateExcel(String title, String nameSheet,List<String> header){
    if(itemsAll.length>0){
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

      var cell = sheetObject.cell(CellIndex.indexByString("A1"));
      cell.value = "REPORTES DE ITEMS"; // dynamic values support provided;
      cell.cellStyle = cellStyle;
      var cell1 = sheetObject.cell(CellIndex.indexByString("A2"));
      cell1.value = "${DateFormat("dd/MM/yyyy").format(DateTime.now())}"; // dynamic values support provided;
      cell1.cellStyle = cellStyle;

      // sheetObject.appendRow(['CODIGO','DESCRIPCION','UNIDAD','CLIENTE']);
      List<String> abc = ["A","B","C","D","E","F","G","H","I","J"];
      sheetObject.appendRow(header);
      for(int i=0;i<header.length;i++){
        sheetObject.cell(CellIndex.indexByString("${abc[i]}3")).style = styleHeader;
      }
      itemsAll.forEach((element) {
        print("${element.codigo},${element.nombre},${element.titulo},${element.razonSocial}");
        sheetObject.appendRow([
          element.codigo,
          element.nombre,
          element.titulo,
          "NO",
          element.sgi==0?"NO":"SI",
          element.factor,
          element.pesoNeto,
          element.pesoBruto,
          element.razonSocial!="null"?element.razonSocial:""
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
