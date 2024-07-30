import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'dart:js' as js;
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_proveedores.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:toast/toast.dart';
class ModuleProveedor extends StatefulWidget {
  @override
  _ModuleProveedorState createState() => _ModuleProveedorState();
}

class _ModuleProveedorState extends State<ModuleProveedor> {
  ScrollController scroll = ScrollController();
  TextEditingController ecSearch = TextEditingController();
  StateSetter refreshList;
  List<ModelProveedores> provAll = List();
  List<ModelProveedores> pFilter = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
          future: ApiProveedores().get(),
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
                                    if(element.nombre.toLowerCase().contains(value.toLowerCase())){
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
                              generatePdf("REPORTE-PROVEEDORES-${DateFormat("dd/MM/yyyy").format(DateTime.now())}");
                            },
                            child: Image.asset("assets/images/pdfdown.png", width: 50, height: 50,))),
                        Expanded(flex:1,child: InkWell(
                            onTap: (){
                              generateExcel("REPORTE-PROVEEDORES-${DateFormat("dd/MM/yyyy").format(DateTime.now())}", "REPORTE-PROVEEDORES",
                                  [
                                    'NOMBRE',
                                    'DIRECCION',
                                    'TELEFONO',
                                    'CELULAR',
                                    'PERSONA DE CONTACTO',
                                    'Nº RAU',
                                    'VIGENCIA RAU',
                                    'NOTAS',
                                    'FECHA DE CREACION',

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
                                  WidgetHeaderList(text: "NOMBRE", flex: 3,),
                                  WidgetHeaderList(text: "CONTACTO", flex: 1,),
                                  WidgetHeaderList(text: "TELEFONO", flex: 1,),
                                  WidgetHeaderList(text: "CELULAR", flex: 1,),
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
                                          ModelProveedores m = pFilter[index];
                                          return Row(
                                            children: [
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
                                                  child: Text(m.contacto!=null && m.contacto!="null"?m.contacto:"Sin Contacto"),
                                                ),
                                              ),
                                              Container(width: 2,height: 20,color: Colors.grey,),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2),
                                                  child: Text(m.telefono!=null && m.telefono!="null"?m.telefono:"Sin Celular"),
                                                ),
                                              ),
                                              Container(width: 2,height: 20,color: Colors.grey,),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(2),
                                                  child: Text(m.celular!=null && m.celular!="null"?m.celular:"Sin Celular"),
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
    await MakePdf().head(page, w, h,'REPORTE \nDE PROVEEDORES');
    List<String> title = ["FECHA DE CONSULTA:\t${DateFormat("dd/MM/yyyy").format(DateTime.now())}"];
    List<String> titles2 = [""];
    MakePdf().sector(page, 5, w-5,90,140,true,title,titles2);
    // List<String> title1 = [""];
    // List<String> titles12 = [""];
    // MakePdf().sector(page, 5, w-5,220,310,true,title1,titles12);
    double heightRes = (((h-90)-(310))/2)-10;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 4);
    grid.headers.add(1);
    grid.columns[1].width = 200;
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'NOMBRE';
    header.cells[1].value = 'CONTACTO';
    header.cells[2].value = 'TELEFONO';
    header.cells[3].value = 'CELULAR';

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

    provAll.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.nombre;
      row.cells[1].value = element.contacto;
      row.cells[2].value = element.telefono;
      row.cells[3].value = element.celular;
      grid.rows[provAll.indexOf(element)].height = 23;
    });

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,160,h,"PROVEEDORES",grid);

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }

  generateExcel(String title, String nameSheet,List<String> header){
    if(provAll.length>0){
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
      cell.value = "REPORTE - LISTA DE PROVEEDORES"; // dynamic values support provided;
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
      provAll.forEach((element) {
        print("${element.nombre},${element.contacto},${element.telefono},${element.celular}");
        sheetObject.appendRow([
          element.nombre!="null"?element.nombre:"",
          element.direccion!="null"?element.direccion:"",
          element.telefono!="null"?element.telefono:"",
          element.celular!="null"?element.celular:"",
          element.contacto!="null"?element.contacto:"",
          element.numRAU!="null"?element.numRAU:"",
          element.vigenciaRAU!="null"?element.vigenciaRAU:"",
          element.notas!="null"?element.notas:"",
          element.fecRegistro!="null"?element.fecRegistro:""
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
