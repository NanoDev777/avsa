import 'dart:async';
import 'dart:convert';

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_area_solicitante.dart';
import 'package:andeanvalleysystem/models/model_motivos.dart';
import 'package:andeanvalleysystem/utils/connections/api_area_solicitante.dart';
import 'package:andeanvalleysystem/utils/connections/api_motivos.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'dart:js' as js;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';
import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_salidas_bajas.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/utils/connections/api_historial.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_salidas_bajas.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/drop_down_almacenes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:andeanvalleysystem/widgets/drop_down_usuarios.dart';
import 'package:andeanvalleysystem/widgets/show_dialog_lotes_selection.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';
import 'package:universal_html/html.dart';
class ModuleSalidasBajas extends StatefulWidget {
  @override
  _ModuleSalidasBajasState createState() => _ModuleSalidasBajasState();
}

class _ModuleSalidasBajasState extends State<ModuleSalidasBajas> {
  List<String> tipos = ["SALIDA","BAJA"];
  List<ModelMotivos> motivos = List();
  // [
  //   "Proceso de Produccion - Adicionales",
  //   "Ajustes de Inventario",
  //   "Venta como Merma",
  //   "Limpieza y Desinfeccion",
  //   "Dotacion EPP",
  //   "Dotacion",
  //   "Auspicio",
  //   "Donaciones",
  //   "Muestras",
  //   "Desarrollo de Productos",
  //   "Control de Calidad",
  //   "Uso Personal"
  // ];
  List<ModelAreaSolicitante> areaSolicitud = List();
  // [
  //   "ALMACENES",
  //   "BENEFICIADO",
  //   "COCINA",
  //   "CONTABILIDAD",
  //   "CONTROL DE CALIDAD",
  //   "DEPARTAMENTO AGRICOLA",
  //   "DESARROLLO",
  //   "DESPACHO DE PRODUCTO",
  //   "DISEÑO GRAFICO",
  //   "EXPORTACIONES",
  //   "GERENCIA GENERAL",
  //   "LOGISTICA",
  //   "MANTENIMIENTO",
  //   "MERCADO LOCAL",
  //   "PLANIFICACION",
  //   "PORTERIA",
  //   "SECRETARIA DE PRESIDENCIA",
  //   "VALOR AGREGADO"
  // ];
  String tipoSeleccionado;
  String motivoSeleccionado;
  String areaSeleccionada;
  ModelAlmacenes selectionAlmacen;
  ModelItem selectionItems;
  ModelUser usuarioSelect;
  bool enableDatos = true;
  double cantidadTotal;
  double costoTotal;
  TextEditingController ecObs = TextEditingController();
  ModelInventario mi;
  ScrollController scroll = ScrollController();

  List<ModelItem> itemsSeleccionados = List();
  List<ModelInventario> inventorySelect = List();

  int userId;
  bool firstClick=true;
  String userName;

  Future getUser()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    userId = sp.getInt("sessionID");
    userName = "${sp.getString("nombres")} ${sp.getString("apPaterno")} ${sp.getString("apMAterno")}";
    areaSolicitud = await ApiAreaSolicitante().get();
    motivos = await ApiMotivos().get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getUser(),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    child: DropdownSearch(
                      enabled: enableDatos,
                      hint: "Tipo SALIDA, BAJA",
                      items: tipos,
                      selectedItem: tipoSeleccionado,
                      onChanged: (val){
                        tipoSeleccionado = val;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: DropdownSearch(
                      enabled: enableDatos,
                      hint: "MOTIVO",
                      items: motivos.map((e) => e.nombre).toList(),
                      selectedItem: motivoSeleccionado,
                      onChanged: (val){
                        motivoSeleccionado = val;
                      },
                    ),
                  ),
                  DropDownAlmacenes(
                    enabled: enableDatos,
                    soloPropios: true,
                    selectionAlmacen: selectionAlmacen,
                    refresh: (val){
                      setState(() {
                        selectionAlmacen=val;
                      });
                    },
                  ),
                  DropDownProductos(
                    existentes: true,
                    selectionAlmacen: selectionAlmacen,
                    selectionItem: selectionItems,
                    func: (val){
                      selectionItems = val;
                    },
                  ),
                  DropDownUsuarios(
                    enabled: enableDatos,
                    userSelection: usuarioSelect,
                    label: "USUARIO SOLICITANTE",
                    refresh: (val){
                      usuarioSelect = val;
                    },
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    child: DropdownSearch(
                      enabled: enableDatos,
                      hint: "AREA SOLICITANTE",
                      items: areaSolicitud.map((e) => e.nombre).toList(),
                      selectedItem: areaSeleccionada,
                      onChanged: (val){
                        areaSeleccionada = val;
                      },
                    ),
                  ),
                  TextBoxCustom(
                    hint: "OBSERVACIONES",
                    controller: ecObs,
                    onChange: (val){},
                  ),
                  WidgetButtons(
                    txt: "Agregar Producto",
                    color1: Colors.grey,
                    color2: Colors.black,
                    colorText: Colors.white,
                    func: (){
                      bool noExt = true;
                      bool noExt2 = true;
                      if(selectionAlmacen!=null && tipoSeleccionado.isNotEmpty && motivoSeleccionado.isNotEmpty && selectionItems!=null&&
                          usuarioSelect!=null&&areaSeleccionada!=""){
                        inventorySelect.forEach((element) {
                          if(noExt2 && element.codAlm==selectionItems.codigo)
                            noExt2 = false;
                        });
                        itemsSeleccionados.forEach((element) {
                          if(noExt && element.codigo==selectionItems.codigo)
                            noExt = false;
                        });
                        if(noExt2){
                          setState(() {
                            inventorySelect.add(ModelInventario(
                                codAlm: selectionAlmacen.codAlm,
                                codProd: selectionItems.codigo
                            ));
                          });
                        }
                        if(noExt){
                          setState(() {
                            itemsSeleccionados.add(selectionItems);
                            enableDatos=false;
                            selectionItems = null;
                          });
                        }else Toast.show("ESTE ITEM YA FUE AGREGADO", context);
                      }else{
                        Toast.show("FALTAN DATOS OBLIGATORIOS", context);
                      }
                    },
                  ),
                  listItemsSeleccionados(),
                  WidgetButtons(
                    txt: "Realizar ${tipoSeleccionado}",
                    color1: Colors.grey,
                    color2: Colors.black,
                    colorText: Colors.white,
                    func: (){
                      if(firstClick){
                        firstClick=false;
                        try{
                          ApiSalidasBajas().count().then((value){
                            print(value);
                            int count =value;
                            List<ModelSalidasBajas> lsb = List();
                            List<ModelHistorialKardex> mhk = List();
                            costoTotal=0;
                            inventorySelect.forEach((element) {
                              cantidadTotal=0;
                              String lotes="";
                              element.lotes.forEach((l){
                                if(element.lotes.length-1 == element.lotes.indexOf(l))
                                  lotes += l.lote;
                                else lotes += l.lote + "|";
                                cantidadTotal += l.cantidadUsada;
                                lsb.add(ModelSalidasBajas(
                                    codAlm: selectionAlmacen.codAlm,
                                    motivo: motivoSeleccionado,
                                    tipo: tipoSeleccionado,
                                    codProd: element.codProd,
                                    cantidad: l.cantidadUsada,
                                    costoUnit: l.costoUnit,
                                    aprov: 0,
                                    lote: l.lote,
                                    estado: 1,
                                    idLote: l.id,
                                    observacion: ecObs.text,
                                    solicitante: usuarioSelect.id,
                                    fecReg: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                    area: areaSeleccionada,
                                    usrReg: userId,
                                    codigoSalida: "S-${(count + 1).toString().padLeft(5, '0')}"
                                ));
                                costoTotal += l.cantidadUsada * l.costoUnit;
                              });
                              mhk.add(ModelHistorialKardex(
                                lote: lotes,
                                cantidad: cantidadTotal*(-1),
                                prorrateo: element.lotes[0].costoUnit,
                                idReg: "S-${(count + 1).toString().padLeft(5, '0')}",
                                created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                accion: tipoSeleccionado,
                                costo: (cantidadTotal * element.lotes[0].costoUnit)*(-1),
                                costoUnitario: element.lotes[0].costoUnit,
                                codProd: element.codProd,
                                codAlm: selectionAlmacen.codAlm,//almacenesPropios[0].codAlm,
                                usuario: 1,
                              ));
                              ApiInventory().discountInventory(element.lotes, selectionAlmacen.codAlm, element.codProd);
                            });
                            ApiHistorial().createHistorial(mhk);
                            ApiSalidasBajas().create(lsb, context).whenComplete((){
                              _showDialog("REPORTE_SALIDA_BAJA_${DateFormat("dd/MM/yyyy").format(DateTime.now())}","S-${(count + 1).toString().padLeft(5, '0')}");
                            });
                          });
                        }catch(e){
                          firstClick=true;
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      )
    );
  }

  listItemsSeleccionados() {
    TextStyle te = TextStyle(fontSize: 13);
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Row(
            children: [
              WidgetHeaderList(text: "CODIGO", flex: 2,),
              WidgetHeaderList(text: "PRODUCTO", flex: 5,),
              WidgetHeaderList(text: "UNIDAD", flex: 2,),
              WidgetHeaderList(text: "CANTIDAD", flex: 2,),
              WidgetHeaderList(text: "LOTES", flex: 2,),
              WidgetHeaderList(text: "ACCION", flex: 1,),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5,bottom: 5),
            child: Column(
              children: itemsSeleccionados.map((e){
                return InkWell(
                  onTap: (){
                    UtilsDialog(context: context, scroll: scroll).showDialog2(inventorySelect[itemsSeleccionados.indexOf(e)], selectionAlmacen.codAlm, e.codigo, (val, lotes) {
                      setState(() {
                        inventorySelect[itemsSeleccionados.indexOf(e)] = val;
                      });
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                          child: Text(e.codigo, style: te,textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 5,
                          child: Text(e.nombre, style: te,)
                      ),
                      Expanded(
                          flex: 2,
                          child: Text(e.titulo, style: te,textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 2,
                          child: Text("${inventorySelect[itemsSeleccionados.indexOf(e)].cantidadTotalLotes}", style: te,textAlign: TextAlign.center,)
                      ),
                      Expanded(
                          flex: 2,
                          child: Text("${inventorySelect[itemsSeleccionados.indexOf(e)].lotes.map((e) => "${e.lote}|").toList()}", style: te,)
                      ),
                      Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: (){
                              setState(() {
                                inventorySelect.removeAt(itemsSeleccionados.indexOf(e));
                                itemsSeleccionados.remove(e);
                              });
                            },
                            child: Icon(
                              Icons.delete_forever
                            ),
                          )
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  void allClean() {
    if(this.mounted) {
      setState(() {
        enableDatos = true;
        selectionItems = null;
        selectionAlmacen = null;
        tipoSeleccionado = null;
        areaSeleccionada = null;
        motivoSeleccionado = null;
        usuarioSelect = null;
        ecObs.text = "";
        firstClick = true;
        itemsSeleccionados.clear();
        inventorySelect.clear();
      });
    }
  }

  Future<void> _showDialog(String nombre, String codigo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('EXITO'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('LA SALIDA FUE EXITOSA.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                allClean();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                generatePdf(nombre, codigo);
              },
            ),
          ],
        );
      },
    );
  }

  Future generatePdf(String nombre, String codigo) async {
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 10;
    PdfPage page = document.pages.add();

    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    print("$w::$h");

    MakePdf().margin(page, w, h);
    await MakePdf().head(page, w, h,'REGISTRO DE ${tipoSeleccionado}');
    List<String> title = [
      "Código:\t$codigo",
      "Tipo:\t$tipoSeleccionado",
      "Almacen:\t${selectionAlmacen.codAlm}-${selectionAlmacen.name}",
      "Motivo:\t$motivoSeleccionado",
      "Registro:\t$userName",
      "Solicitante:\t${usuarioSelect.nombres} ${usuarioSelect.apPaterno} ${usuarioSelect.apMaterno}",
      "Area Destino:\t$areaSeleccionada"
    ];
    List<String> titles2 = [
      "Fecha:\t${DateFormat("dd/MM/yyyy").format(DateTime.now())}",
      "","","","","",""];

    MakePdf().sector(page, 5, w-5,90,215,true,title,titles2);
    List<String> titleTotal = [
      "Cantidad Total del egreso:\t${NumberFunctions.formatNumber(cantidadTotal, 2)}.",
      "Valor Total del egreso:\t${NumberFunctions.formatNumber(costoTotal, 3)} Bolivianos.",
      "Observaciones:\t${ecObs.text}"
    ];
    List<String> titles2Total = [
      "",
      "","","","","",""];
    MakePdf().sector(page, 5, w-5,h-145,h-90,true,titleTotal,titles2Total);
    double heightRes = (((h-90)-(310))/2)-10;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 8);
    grid.headers.add(1);
    grid.columns[1].width = 200;
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'CODIGO';
    header.cells[1].value = 'PRODUCTO';
    header.cells[2].value = 'UNIDAD';
    header.cells[3].value = 'CANTIDAD';
    header.cells[4].value = 'LOTE';
    header.cells[5].value = 'FECHA VENCIMIENTO';
    header.cells[6].value = 'COSTO UNITARIO Bs.';
    header.cells[7].value = 'COSTO TOTAL Bs.';

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
    header.cells[5].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[6].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
    header.cells[7].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );

    inventorySelect.forEach((element) {
      element.lotes.forEach((i) {
        PdfGridRow row = grid.rows.add();
        row.cells[0].value = itemsSeleccionados[inventorySelect.indexOf(element)].codigo;
        row.cells[1].value = itemsSeleccionados[inventorySelect.indexOf(element)].nombre;
        row.cells[2].value = itemsSeleccionados[inventorySelect.indexOf(element)].titulo;
        row.cells[3].value = "${i.cantidadUsada}";
        row.cells[4].value = "${i.lote}";
        row.cells[5].value = "${i.fecVencimiento}";
        row.cells[6].value = "${NumberFunctions.formatNumber(i.costoUnit,4)}";
        row.cells[7].value = "${NumberFunctions.formatNumber(i.cantidadUsada*i.costoUnit,4)}";
        grid.rows[inventorySelect.indexOf(element)].height = 23;
      });
    });

    // itemsSeleccionados.forEach((element) {
    //   PdfGridRow row = grid.rows.add();
    //   row.cells[0].value = element.codigo;
    //   row.cells[1].value = element.nombre;
    //   row.cells[2].value = element.titulo;
    //   row.cells[3].value = "${inventorySelect[itemsSeleccionados.indexOf(element)].cantidadTotalLotes}";
    //   row.cells[4].value = "${
    //     inventorySelect[itemsSeleccionados.indexOf(element)]
    //         .lotes
    //         .map((e) => "${e.lote}|")
    //         .toList()
    //   }";
    //   grid.rows[itemsSeleccionados.indexOf(element)].height = 23;
    // });

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,220,h-150,"ITEMS Y CANTIDADES PARA LA $tipoSeleccionado",grid);


    MakePdf().sectorObservacion(page, 5, w/2,h-85,h-5,"Solicitado por:","");
    MakePdf().sectorObservacion(page, w/2, w-5,h-85,h-5,"Realizado por:","");

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }
}
