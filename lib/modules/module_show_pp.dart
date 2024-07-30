
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'dart:math';
import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_inv_agrupado.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/models/model_reserva_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_almacen.dart';
import 'package:andeanvalleysystem/utils/connections/api_formulas.dart';
import 'package:andeanvalleysystem/utils/connections/api_historial.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';

class ModuleShowPP extends StatefulWidget {
  final ModelProcesoProduccion procProd;
  final Function refresh;

  ModuleShowPP({Key key, @required this.procProd, this.refresh}) : super(key: key);

  @override
  _ModuleShowPPState createState() => _ModuleShowPPState();
}

class _ModuleShowPPState extends State<ModuleShowPP> {
  int myAlm;
  int idUs;
  ModelProcesoProduccion procProd;
  ModelFormula formula;
  List<ModelReservaItemsProcProd> ingredientes;
  List<ModelReservaItemsProcProd> ingredientesIn = List();
  List<ModelReservaItemsProcProd> ingredientesOut = List();

  TextEditingController ecFormula = TextEditingController();
  TextEditingController ecLineaProd = TextEditingController();
  TextEditingController ecCliente = TextEditingController();
  TextEditingController ecLoteProd = TextEditingController();
  TextEditingController ecCantidad = TextEditingController();
  TextEditingController ecLoteVenta = TextEditingController();
  TextEditingController ecAlmProc = TextEditingController();
  TextEditingController ecFecIni = TextEditingController();
  TextEditingController ecFecFin = TextEditingController();
  TextEditingController ecFecVenc = TextEditingController();
  List<TextEditingController> lte = List();
  String errFormula;
  String errLineaProd;
  String errCliente;
  String errLoteProd;
  String errCantidad;
  String errLoteVenta;
  String errAlmProc;
  String errFecIni;
  String errFecFin;
  String errFecVenc;
  ModelAlmacenes selectionalmacenDestino;
  List<ModelAlmacenes> almacenes;

  StateSetter _stateIngredientes;
  StateSetter _stateResultado;
  StateSetter _stateInfoFinal;

  double costoTotalReal = 0;
  double costoTotalReceta = 0;
  double variacion = 0;
  ModelInvAgrupado selectionItem;
  List<ModelItem> items;
  List<ModelInventario> inv = List();
  List<ModelInvAgrupado> invAgrupados = List();
  Map<String,List<ModelReservaItemsProcProd>> mapReservas = Map();
  Map<String,double> mapReservasCostos = Map();
  Map<String,String> mapReservasLotes = Map();
  List<String> keys = List();
  ScrollController scroll;
  Map<String, double> totalesInvAgrupados = Map();

  Future getData() async {
    if (formula == null && ingredientes == null && almacenes == null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      ingredientesIn.clear();
      ingredientesOut.clear();
      formula = await ApiFormulas().getId(procProd.idFormula);
      print("ID::${procProd.id}");
      ingredientes = await ApiProcesosProduccion().getReservas(procProd.id);
      almacenes = await Constant().getAlmacenes();
      items = await ApiConnections().getItemsProdPermitidos("1|2");
      myAlm = procProd.codAlmProd;//int.parse(sp.getString("almacenes"));
      idUs = sp.getInt("sessionID");
      List<String> almacenesSep = sp.getString("almacenes").split(',');
      if(almacenesSep.length>1)
        inv = await ApiInventory().getInventarioExistentes(procProd.codAlmProd);
      else
        inv = await ApiInventory().getInventarioExistentes(int.parse(sp.getString("almacenes")));

      ingredientes.forEach((element) {
        if (element.tipo == 0) {
          ingredientesIn.add(element);
        } else {
          ingredientesOut.add(element);
        }
      });

      ingredientesIn.forEach((element) {
        if(mapReservas.containsKey(element.codProd)){
          mapReservas[element.codProd].add(element);
          mapReservasCostos[element.codProd] += element.cantidad;
          mapReservasLotes[element.codProd] += "|${element.lote}";
        }else{
          mapReservas[element.codProd] = List();
          mapReservasLotes[element.codProd] = "${element.lote}";
          mapReservasCostos[element.codProd] = element.cantidad;
          keys.add(element.codProd);
          mapReservas[element.codProd].add(element);
        }
      });
      ingredientesOut[0].cantidad = procProd.cantidad;
    }
    if (formula != null && ingredientes != null && almacenes != null) {
      setState(() {
        ecFormula.text = "${formula.codProdRes} - ${formula.titulo}";
        ecLineaProd.text = "${procProd.lineaProd}";
        ecLoteVenta.text = procProd.loteVenta!=null?procProd.loteVenta:"";
        ecFecIni.text = procProd.fecInicio;
        ecFecFin.text = procProd.fecFin;
        ecFecVenc.text = procProd.fecVenc;
        ecCliente.text =
        procProd.clienteRZ != null ? procProd.clienteRZ : "n/a";
        ecLoteProd.text = procProd.loteProd;
        ecCantidad.text = procProd.cantidad.toStringAsFixed(2);
        ecAlmProc.text = "${procProd.codAlmProd}";
      });
    }
  }
  close(){Navigator.of(context).pop();}

  @override
  void initState() {
    procProd = widget.procProd;
    print("procprod::${procProd.toJson()}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("${procProd.loteProd}"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return SomethingWentWrongPage();
                if (snapshot.connectionState == ConnectionState.done) {
                  // ingredientesOut[0].cantidad = procProd.cantidad;
                  return Column(
                    children: [
                      datos(),
                      listIngr(),
                      ingredientesOut.length > 1 ? listMultiple() : listUnica(),
                      infoRes(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WidgetButtons(
                            txt: "CANCELAR",
                            color1: Colors.red,
                            color2: Colors.redAccent,
                            colorText: Colors.white,
                            func: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          WidgetButtons(
                            txt: "APROBAR PROCESO",
                            color1: Colors.green,
                            color2: Colors.greenAccent,
                            colorText: Colors.white,
                            func: () {
                              List<ModelInventario> inventarioEnvio = List();
                              procProd.reservas.clear();
                              procProd.reservas.addAll(ingredientesIn);
                              procProd.reservas.addAll(ingredientesOut);
                              procProd.estado = 1;
                              procProd.aprob = 1;
                              procProd.fecAprob = DateFormat("yyyy-MM-dd").format(DateTime.now());

                              ingredientesOut.forEach((element) {
                                inventarioEnvio.add(ModelInventario(
                                  codAlm: procProd.codAlmDest,
                                  codProd: element.codProd,
                                  costoUnitario: element.costoUnit,
                                  cantidad: element.cantidad,
                                  lote: element.lote,
                                  loteVenta: element.loteVenta,
                                  costo: element.cantidad*element.costoUnit,
                                  fecIngreso: DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now()),
                                  fecVencimiento: procProd.fecVenc,
                                  idProv: 0,
                                  factura: "",
                                  codigo: "PP-${procProd.id.toString()
                                      .padLeft(5, '0')}",
                                  idCodigo: "PP-${procProd.id.toString()
                                      .padLeft(5, '0')}",
                                    fechaSistema: DateFormat("yyyy-MM-dd").format(DateTime.now())
                                ));

                              });

                              ApiInventory().insertInventory(inventarioEnvio, context).whenComplete((){
                                widget.refresh((){
                                  Toast.show("EL PROCESO FUE ACEPTADO CORRECTAMENTE", context);
                                  ApiProcesosProduccion().aprovar(procProd.id);
                                  Navigator.of(context).pop();
                                });
                              });
                            },
                          ),
                          WidgetButtons(
                            txt: "RECHAZAR PROCESO",
                            color1: Colors.green,
                            color2: Colors.greenAccent,
                            colorText: Colors.white,
                            func: () {
                              List<ModelInventario> inventarioEnvio = List();
                              procProd.reservas.clear();
                              procProd.reservas.addAll(ingredientesIn);
                              procProd.reservas.addAll(ingredientesOut);
                              procProd.estado = 1;
                              procProd.aprob = 1;

                              ingredientesIn.forEach((element) {
                                inventarioEnvio.add(ModelInventario(
                                  codAlm: procProd.codAlmProd,
                                  codProd: element.codProd,
                                  costoUnitario: element.costoUnit,
                                  cantidad: element.cantidad,
                                  lote: "${element.lote}",
                                  loteVenta: element.loteVenta,
                                  costo: element.cantidad*element.costoUnit,
                                  fecIngreso: DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now()),
                                  fechaSistema: DateFormat("yyyy-MM-dd")
                                      .format(DateTime.now()),
                                  fecVencimiento: procProd.fecVenc,
                                  idProv: 0,
                                  factura: "",
                                  codigo: "R*PP-${procProd.id.toString()
                                      .padLeft(5, '0')}",
                                  idCodigo: "R*PP-${procProd.id.toString()
                                      .padLeft(5, '0')}",

                                ));

                              });

                              ApiInventory().insertInventory(inventarioEnvio, context).whenComplete((){
                                Toast.show("EL PROCESO FUE RECHAZADO CORRECTAMENTE", context);
                                ApiProcesosProduccion().rechazar(procProd.id);
                                Navigator.of(context).pop();
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  );
                }
                return LoadingPage();
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(String titulo,String mensaje) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(mensaje),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                // widget.refresh();
                widget.refresh((){
                  close();
                  Navigator.of(context).pop();
                });
              },
            ),
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                // widget.refresh();
                generatePdf("${procProd.loteProd}");
              },
            ),
          ],
        );
      },
    );
  }

  Color colorVariacion = Colors.red;
  refresh() {
    variacion = 0;
    costoTotalReal = 0;
    costoTotalReceta = 0;
    ingredientesIn.forEach((element) {
      costoTotalReal += element.cantidad * element.costoUnit;
      costoTotalReceta += element.cantidadRequerida *
          (element.costoUnit == null ? 0 : element.costoUnit);
    });

    variacion = ((costoTotalReal - costoTotalReceta) /
        (costoTotalReceta == 0 ? 1 : costoTotalReceta)) *
        100;
    if(variacion < -3) colorVariacion = Colors.yellow;
    if(variacion > 3) colorVariacion = Colors.red;
    ingredientesOut[0].costoTotalReal = costoTotalReal;
    ingredientesOut[0].costoUnit = costoTotalReal/ingredientesOut[0].cantidad;
    procProd.costoReal = costoTotalReal;
    procProd.costoReceta = costoTotalReceta;
    procProd.variacion = variacion;
    _stateIngredientes(() {});
    _stateResultado(() {});
    _stateInfoFinal(() {});
  }

  Future<void> _showDialog(
      ModelReservaItemsProcProd item, List<ModelLote> lotes) async {
    lte.clear();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  //recalcula la cantidad total
                  double cantidadUsada = 0;
                  lotes.forEach((element) {
                    if (element.cantidadUsada != null &&
                        element.cantidadUsada > 0)
                      cantidadUsada += element.cantidadUsada;
                  });
                  return Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * .7,
                        height: MediaQuery.of(context).size.height * .6,
                        child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              padding: EdgeInsets.only(bottom: 50),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Cantidad Necesaria: ${item.cantidadRequerida.toStringAsFixed(2)}"),
                                    Text(
                                        "Cantidad Usada: ${cantidadUsada.toStringAsFixed(2)}"),
                                    Row(
                                      children: [
                                        headerListCustom("Lote", 1),
                                        headerListCustom("Cantidad", 1),
                                        headerListCustom("Usar", 1),
                                      ],
                                    ),
                                    SingleChildScrollView(
                                      controller: scroll,
                                      child: Column(
                                        children: lotes.map((e) {
                                          String err;
                                          lte.add(TextEditingController());
                                          TextStyle style = TextStyle(fontSize: 12);
                                          return Row(children: [
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      e.lote,
                                                      style: style,
                                                    ))),
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: Colors.blueGrey,
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      e.cantidad.toStringAsFixed(2),
                                                      style: style,
                                                    ))),
                                            Container(
                                              width: 1,
                                              height: 20,
                                              color: Colors.blueGrey,
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Container(
                                                        padding: EdgeInsets.only(
                                                            left: 10, right: 10),
                                                        margin: EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                color:
                                                                Colors.blueGrey,
                                                                width: 1),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                        child: TextFormField(
                                                          controller:
                                                          lte[lotes.indexOf(e)],
                                                          decoration:
                                                          InputDecoration(
                                                              border:
                                                              InputBorder
                                                                  .none,
                                                              errorText: err),
                                                          onChanged: (value) {
                                                            if (value.isNotEmpty &&
                                                                double.parse(
                                                                    value) >
                                                                    0 &&
                                                                double.parse(
                                                                    value) <=
                                                                    e.cantidad) {
                                                              setState(() {
                                                                e.cantidadUsada =
                                                                    double.parse(
                                                                        value);
                                                                err = null;
                                                              });
                                                            } else {
                                                              setState(() {
                                                                e.cantidadUsada = 0;
                                                                err =
                                                                "ERROR EN CANTIDAD";
                                                              });
                                                            }
                                                          },
                                                        )))),
                                            // Container(width: 1,height: 20,color: Colors.blueGrey,),
                                          ]);
                                        }).toList(),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )),
                      ),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          child: Row(
                            children: [
                              WidgetButtons(
                                color1: Colors.red,
                                color2: Colors.redAccent,
                                colorText: Colors.white,
                                txt: "CANCELAR",
                                func: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              WidgetButtons(
                                color1: Colors.green,
                                color2: Colors.greenAccent,
                                colorText: Colors.white,
                                txt: "ACEPTAR",
                                func: () {
                                  item.lotes.clear();
                                  item.cantidad = 0;
                                  double cantTotal=0;
                                  lotes.forEach((element) {
                                    if (element.cantidadUsada != null &&
                                        element.cantidadUsada > 0) {
                                      item.lotes.add(element);
                                      cantTotal+=element.cantidadUsada;
                                    }
                                  });
                                  item.cantidad = cantTotal;
                                  item.costoTotalReal=double.parse(cantTotal.toStringAsFixed(2))*
                                      double.parse(item.costoUnit.toStringAsFixed(2));
                                  item.costoTotalReceta=double.parse(item.cantidadRequerida.toStringAsFixed(2))*
                                      double.parse(item.costoUnit.toStringAsFixed(2));
                                  refresh();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ))
                    ],
                  );
                },
              ));
        });
  }

  Widget _customDropDownAlm(
      BuildContext context, ModelAlmacenes item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.codAlm.toString()),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.name),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilderAlm(
      BuildContext context, ModelAlmacenes item, bool isSelected) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        decoration: !isSelected
            ? null
            : BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(item.codAlm.toString()),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.name),
            ],
          ),
        ));
  }

  headerListCustom(String text, int flex) {
    return Expanded(
        flex: flex,
        child: Container(
            margin: EdgeInsets.all(.5),
            width: double.infinity,
            height: 30,
            color: Colors.blueGrey,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width * .01),
              ),
            )));
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController ec) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      ec.text = DateFormat("dd/MM/yyyy").format(picked);
    }
  }
  Future<void> _selectDateVencimiento(BuildContext context, TextEditingController ec) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      DateTime ndt = DateTime(picked.year + 2, picked.month, picked.day);
      ec.text = DateFormat("dd/MM/yyyy").format(ndt);
    }
  }

  textEdit(String hint, TextEditingController ec, String error, bool enabled, Function onChange) {
    return Container(
      margin: EdgeInsets.all(5),
      child: TextFormField(
        // onEditingComplete: onChange,
        onChanged: onChange,
        controller: ec,
        enabled: enabled,
        decoration: InputDecoration(
          errorText: error,
          border: OutlineInputBorder(),
          labelText: hint,
        ),
      ),
    );
  }

  infoRes() {
    return StatefulBuilder(
      builder: (context, setState) {
        TextStyle style = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
        );
        _stateInfoFinal = setState;
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(.5, 10),
                    blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  width: double.infinity,
                  color: Colors.blueGrey,
                  child: Text(
                    "INFORMACION FINAL",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              Column(
                children: [
                  Text(
                    "COSTO TOTAL RECETA: ${procProd.costoReceta.toStringAsFixed(2)} Bs.",
                    style: style,),
                  Text(
                    "COSTO TOTAL REAL: ${procProd.costoReal.toStringAsFixed(2)} Bs.",
                    style: style,),
                  Text("VARIACION: ${procProd.variacion.toStringAsFixed(2)} %.",
                    style: TextStyle(
                        fontSize: 18,fontWeight: FontWeight.bold,
                        color: colorVariacion
                    ),),
                  Text(
                    "QF/QI: ${(ingredientesOut[0].cantidad/mapReservasCostos[ingredientesIn[0].codProd]).toStringAsFixed(2)} %.",
                    style: style,
                    )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  listUnica() {
    return StatefulBuilder(
      builder: (context, setState) {
        TextStyle style = TextStyle(fontSize: 12);
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(.5, 10),
                    blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  width: double.infinity,
                  color: Colors.blueGrey,
                  child: Text(
                    "RESULTADO",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              Row(
                children: [
                  headerListCustom("Codigo", 1),
                  headerListCustom("Ingrediente", 3),
                  headerListCustom("Unidad", 2),
                  headerListCustom("Cantidad Real", 1),
                  headerListCustom("Costo Real Unitario [Bs]", 1),
                  headerListCustom("Costo Total Real [Bs]", 1)
                ],
              ),
              Column(
                children: ingredientesOut.map((e) {
                  print("INGSALIDA::${e.toJson()}");
                  return StatefulBuilder(
                    builder: (context, setState) {
                      _stateResultado = setState;

                      return InkWell(
                        onTap: () {
                          // _showMyDialogAccion(e);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueGrey, width: .5)),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                        e.codProd,
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                      child: Text(
                                        e.nombreProd,
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Align(
                                    child: Text(
                                      e.unidad,
                                      style: style,
                                    ),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                        e.cantidad.toStringAsFixed(2),
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e.costoUnit}",
                                    child: Center(
                                        child: Text(
                                          (e.costoUnit)
                                              .toStringAsFixed(3),
                                          style: style,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e.costoUnit*e.cantidad}",
                                    child: Center(
                                        child: Text(
                                          "${(e.costoUnit*e.cantidad).toStringAsFixed(3)}",
                                          style: style,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            ],
          ),
        );
      },
    );
  }

  listMultiple() {
    return StatefulBuilder(
      builder: (context, setState) {
        TextStyle style = TextStyle(fontSize: 12);
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(.5, 10),
                    blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  width: double.infinity,
                  color: Colors.blueGrey,
                  child: Text(
                    "RESULTADO",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              Row(
                children: [
                  headerListCustom("Codigo", 1),
                  headerListCustom("Ingrediente", 3),
                  headerListCustom("Unidad", 2),
                  headerListCustom("Cantidad Real", 1),
                  headerListCustom("Costo Real Unitario [Bs]", 1),
                  headerListCustom("Costo Total Real [Bs]", 1)
                ],
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: ingredientesOut.map((e) {

                      // _stateResultado = setState;
                      // double costoUnit = 0;
                      // double sum = 0;
                      // for (int i = 0; i < ingredientesOut.length; i++) {
                      //   sum += (ingredientesOut[i].cantidad) *
                      //       (ingredientesOut[i].costoUnit);
                      // }
                      // costoUnit = (costoTotalReal - sum) / e.cantidad;
                      // e.costoUnit = costoUnit;
                      // e.costoTotalReal = costoTotalReal - sum;
                      // itemsPP.forEach((element) {
                      //   if (element.tipo==0)
                      //     costoTotalReal+=element.cantidad*element.costoUnit;
                      // });
                      // print("Costoreal::${costoTotalReal}");
                      return InkWell(
                        onTap: () {
                          // _showMyDialogAccion(e);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueGrey, width: .5)),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                        e.codProd,
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                      child: Text(
                                        e.nombreProd,
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Align(
                                    child: Text(
                                      e.unidad,
                                      style: style,
                                    ),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                        e.cantidad.toStringAsFixed(2),
                                        style: style,
                                      ))
                                       ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e.costoUnit}",
                                    child: Center(
                                        child: Text(
                                          e.costoUnit.toStringAsFixed(3),
                                          style: style,
                                        )),
                                  )
                                       ),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e.cantidad*e.costoUnit}",
                                    child: Center(
                                        child: Text(
                                          "${(e.cantidad*e.costoUnit).toStringAsFixed(3)}"
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  listIngr() {
    return StatefulBuilder(
      builder: (context, setState) {
        TextStyle style = TextStyle(fontSize: 12);
        TextStyle styleUser = TextStyle(fontSize: 12, color: Colors.white);
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(.5, 10),
                    blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  width: double.infinity,
                  color: Colors.blueGrey,
                  child: Text(
                    "INGREDIENTES ENTRANTES",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              Row(
                children: [
                  headerListCustom("Codigo", 1),
                  headerListCustom("Ingrediente", 3),
                  headerListCustom("Unidad", 2),
                  headerListCustom("Cantidad receta", 1),
                  headerListCustom("Precio Unidad", 1),
                  headerListCustom("Cantidad Real", 1),
                  headerListCustom("Costo Total Real [Bs]", 1),
                  headerListCustom("Costo Total Receta [Bs]", 1),
                  headerListCustom("Lotes", 1)
                ],
              ),
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: keys.map((k) {
                      _stateIngredientes = setState;
                      List<ModelReservaItemsProcProd> e = mapReservas[k];
                      double cantReceta =
                      ((procProd.cantidad * e[0].cantidadReceta) /
                          ingredientesOut[0].cantidadReceta);
                      e[0].cantidadRequerida = cantReceta;
                      e[0].costoTotalReceta = e[0].cantidadRequerida*e[0].costoUnit;
                      return InkWell(
                        onTap: () {
                          // ApiInventory()
                          //     .getLotes(procProd.codAlmProd, e.codProd)
                          //     .then((value) {
                          //   if(value!=null && value.length>0)
                          //     _showDialog(e, value);
                          //   else Toast.show("No Existen Productos En tu Almacen", context, duration:Toast.LENGTH_LONG);
                          // });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueGrey, width: .5)),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   flex: 1,
                                      //   child: e.adicional==1?InkWell(
                                      //     onTap: (){setState((){
                                      //       ingredientesIn.removeAt(ingredientesIn.indexOf(e));
                                      //     });},
                                      //     child: Icon(Icons.delete_forever),
                                      //   ):Container(),
                                      // ),

                                      Expanded(
                                        flex:5,
                                        child: Text(
                                          e[0].codProd,
                                          style: style,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 3,
                                  child: Center(
                                      child: Text(
                                        e[0].nombreProd,
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Align(
                                    child: Text(
                                      e[0].unidad,
                                      style: style,
                                    ),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Center(
                                      child: Text(
                                        cantReceta.toStringAsFixed(2),
                                        style: style,
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e[0].costoUnit}",
                                    child: Center(
                                        child: Text(
                                          e[0].costoUnit.toStringAsFixed(3),
                                          style: style,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 30,
                                    color: Colors.blueGrey,
                                    child: Center(
                                        child: Text(
                                          "${(mapReservasCostos[e[0].codProd]).toStringAsFixed(2)}",
                                          style: styleUser,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${mapReservasCostos[e[0].codProd] * e[0].costoUnit}",
                                    child: Container(
                                      height: 30,
                                      color: Colors.blueGrey,
                                      child: Center(
                                          child: Text(
                                            "${(mapReservasCostos[e[0].codProd] * e[0].costoUnit).toStringAsFixed(3)}",
                                            style: styleUser,
                                          )),
                                    ),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e[0].costoTotalReceta}",
                                    child: Center(
                                        child: Text(
                                          "${e[0].costoTotalReceta!=null?e[0].costoTotalReceta.toStringAsFixed(3):0.toStringAsFixed(3)}",
                                          style: style,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 30,
                                    color: Colors.blueGrey,
                                    child: Center(
                                        child: Text(
                                          "${mapReservasLotes[e[0].codProd]}",
                                          style: styleUser,
                                        )),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }

  datos() {
    return StatefulBuilder(
      builder: (context, state) {
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    offset: Offset(.5, 10),
                    blurRadius: 20)
              ]),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  width: double.infinity,
                  color: Colors.blueGrey,
                  child: Text(
                    "LLENAR INFORMACION",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              Row(
                children: [
                  Expanded(
                    child: textEdit("FORMULA", ecFormula, errFormula, false,(value){}),
                  ),
                  Expanded(
                    child: textEdit(
                        "LOTE PRODUCCION", ecLoteProd, errLoteProd, false,(value){}),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: textEdit("LINEA DE PRODUCCION", ecLineaProd,
                        errLineaProd, false,(value){}),
                  ),
                  Expanded(
                    child: textEdit(
                        "LOTE DE VENTA", ecLoteVenta, errLoteVenta, false,(value){}),
                  )
                ],
              ),
              textEdit("CLIENTE", ecCliente, errCliente, false,(value){}),
              Row(
                children: [
                  Expanded(
                    child: textEdit("CANTIDAD", ecCantidad, errCantidad, false,(value){
                      try {
                        procProd.cantidad = double.parse(value);
                        ingredientesOut[0].cantidad = procProd.cantidad;
                        _stateIngredientes(() {
                          _stateResultado(() {});
                        });
                      }catch(e){
                        Toast.show("NUMERO INVALIDO", context);
                      }
                    }),
                  ),
                  Expanded(
                    child: Text(procProd.unidad),
                  )
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Padding(
                          padding: const EdgeInsets.all(5),
                          child: TextFormField(
                            enabled: false,
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            controller: ecFecIni,
                            decoration: InputDecoration(
                                errorText: errFecIni,
                                border: OutlineInputBorder(),
                                labelText: "FECHA DE INICIO",
                                hintText: "Ejemplo: dd/mm/yyyy",
                                counterText: ""),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextFormField(
                            enabled: false,
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            controller: ecFecFin,
                            decoration: InputDecoration(
                                errorText: errFecFin,
                                border: OutlineInputBorder(),
                                labelText: "FECHA DE FINALIZACION",
                                hintText: "Ejemplo: dd/mm/yyyy",
                                counterText: ""),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
              // Padding(
              //   padding: const EdgeInsets.all(5.0),
              //   child: DropdownSearch<ModelAlmacenes>(
              //     emptyBuilder: (context, searchEntry) {
              //       return Center(
              //         child: Text("NO EXISTEN DATOS"),
              //       );
              //     },
              //     items: almacenes,
              //     selectedItem: selectionalmacenDestino,
              //     onChanged: (value) {
              //       setState(() {
              //         selectionalmacenDestino = value;
              //       });
              //     },
              //     label: "SELECCIONE UN ALMACEN DE DESTINO",
              //     popupTitle: Center(child: Text("LISTA DE ALMACENES")),
              //     popupItemBuilder: _customPopupItemBuilderAlm,
              //     dropdownBuilder: selectionalmacenDestino != null
              //         ? _customDropDownAlm
              //         : null,
              //   ),
              // ),
              StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextFormField(
                      enabled: false,
                      keyboardType: TextInputType.datetime,
                      maxLength: 10,
                      controller: ecFecVenc,
                      decoration: InputDecoration(
                          errorText: errFecVenc,
                          border: OutlineInputBorder(),
                          labelText: "FECHA DE VENCIMIENTO",
                          hintText: "Ejemplo: dd/mm/yyyy",
                          counterText: ""),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future generatePdf(String nombre) async {
    PdfDocument document = PdfDocument();
    PdfPage page = document.pages.add();
    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    document.pageSettings.margins.all = 20;
    final ByteData data = await rootBundle.load('assets/images/logo_red.png');
    page.graphics.drawImage(
        PdfBitmap(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)),
        Rect.fromLTWH(10, 20, 120, 40));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 80), Offset(w, 80));
    double w3 = w / 3;
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset(w3 - 30, 0), Offset(w3 - 30, 80));
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, 0), Offset((w3 * 2) + 30, 80));

    page.graphics.drawString(
      'Código:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4)), Offset(w, (80 / 4)));
    page.graphics.drawString(
      'Versión:',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, (80 / 4) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 2), Offset(w, (80 / 4) * 2));
    page.graphics.drawString(
      'Vigente desde: Jul-2020',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 2) + 5, 615, 20),
    );
    page.graphics.drawLine(PdfPen(PdfColor(0, 0, 0), width: .5),
        Offset((w3 * 2) + 30, (80 / 4) * 3), Offset(w, (80 / 4) * 3));
    page.graphics.drawString(
      'Página: 1 de 1',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 3) + 5, 615, 20),
    );

    page.graphics.drawString(
        'REGISTRO DE PROCESO \nDE PRODUCCION',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , 20, w/3, 60),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    // page.graphics.drawString(
    //     'PROCESO ENVIADO A APROBACIÓN \nEN ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
    //     PdfStandardFont(PdfFontFamily.timesRoman, 20),
    //     bounds: Rect.fromLTWH(30, 100, w, 50),
    //     format: PdfStringFormat(alignment: PdfTextAlignment.center),
    //   brush: PdfSolidBrush(PdfColor(255, 25, 25,1))
    // );

    page.graphics.drawString(
        'ID:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 100, 200, 20));
    page.graphics.drawString(
        "${procProd.id}", PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 100, 200, 20));
    page.graphics.drawString(
        'ALMACEN:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 120, 200, 20));
    page.graphics.drawString(
        '${procProd.codAlmProd} - ALMACEN DE PRODUCTO EN PROCESO BENEFICIADO',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 120, 300, 20));
    page.graphics.drawString(
        'GENERADO POR:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 140, 200, 20));
    page.graphics.drawString(
        'USUARIO', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 140, 200, 20));
    page.graphics.drawString(
        'FECHA DE REGISTRO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 160, 200, 20));
    page.graphics.drawString(
        '${DateFormat("dd/MM/yyyy").format(DateTime.now())}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 160, 200, 20));
    page.graphics.drawString(
        'LOTE DE PRODUCCION:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 180, 200, 20));
    page.graphics.drawString(
        '${procProd.loteProd}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 180, 200, 20));

    page.graphics.drawString(
        'Firma Responsable ________________________________',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(w - 450, h - 60, 600, 20));

    PdfGrid inGrid = PdfGrid();
    inGrid.columns.add(count: 7);
    inGrid.headers.add(1);
    PdfGridRow inHeader = inGrid.headers[0];
    inHeader.cells[0].value = 'Codigo';
    inHeader.cells[1].value = 'Descripcion';
    inHeader.cells[2].value = 'Unid.';
    inHeader.cells[3].value = 'Cantidad Real';
    inHeader.cells[4].value = 'Costo Unitario [Bs/u]';
    inHeader.cells[5].value = 'Costo Total Real [Bs]';
    inHeader.cells[6].value = 'Lote Producto';
    inHeader.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );
    inHeader.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    inHeader.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    inHeader.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    page.graphics.drawString(
        'INGREDIENTES',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , 200, w/3, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    ingredientesIn.forEach((element) {
      PdfGridRow inRow = inGrid.rows.add();
      inRow.cells[0].value = '${element.codProd}';
      inRow.cells[1].value = '${element.nombreProd}';
      inRow.cells[2].value = '${element.unidad}';
      inRow.cells[3].value = '${element.cantidad}';
      inRow.cells[4].value = element.costoUnit.toStringAsFixed(3);
      inRow.cells[5].value = (element.cantidad*element.costoUnit).toStringAsFixed(3);
      inRow.cells[6].value = "${element.lotes != null ? element.lotes.map((e) => "${e.lote}|") : ""}";

      inRow.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      inRow.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      if (procProd.reservas.indexOf(element) % 2 == 0) {
        inRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        inRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });

    inGrid.columns[1].width = 120;
    inGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);
    inGrid.draw(page: page, bounds: const Rect.fromLTWH(0, 220, 0, 0));

    PdfGrid outGrid = PdfGrid();
    outGrid.columns.add(count: 7);
    outGrid.headers.add(1);
    PdfGridRow outHeader = outGrid.headers[0];
    outHeader.cells[0].value = 'Codigo';
    outHeader.cells[1].value = 'Descripcion';
    outHeader.cells[2].value = 'Unid.';
    outHeader.cells[3].value = 'Cantidad Real';
    outHeader.cells[4].value = 'Costo Unitario [Bs/u]';
    outHeader.cells[5].value = 'Costo Total Real [Bs]';
    outHeader.cells[6].value = 'Lote Producto';
    outHeader.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );
    outHeader.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    outHeader.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    outHeader.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    double dis = (220+(ingredientesIn.length.toDouble()*50)+50);
    page.graphics.drawString(
        'RESULTADO',
        PdfStandardFont(PdfFontFamily.timesRoman, 15),
        bounds: Rect.fromLTWH(w3 , dis-20, w/3, 30),
        format: PdfStringFormat(alignment: PdfTextAlignment.center)
    );

    ingredientesOut.forEach((salidas) {
      PdfGridRow outRow = outGrid.rows.add();
      outRow.cells[0].value = '${salidas.codProd}';
      outRow.cells[1].value = '${salidas.nombreProd}';
      outRow.cells[2].value = '${salidas.unidad}';
      outRow.cells[3].value = '${salidas.cantidad.toStringAsFixed(3)}';
      outRow.cells[4].value = salidas.costoUnit.toStringAsFixed(3);
      outRow.cells[5].value = (salidas.costoTotalReal).toStringAsFixed(3);
      outRow.cells[6].value = ecLoteProd.text;
      outRow.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      outRow.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      if (procProd.reservas.indexOf(salidas) % 2 == 0) {
        outRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        outRow.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });

    outGrid.columns[1].width = 120;
    outGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);
    outGrid.draw(page: page, bounds: Rect.fromLTWH(0, dis, 0, 0));

    page.graphics.drawString(
        'COSTO TOTAL RECETA: ${costoTotalReceta.toStringAsFixed(3)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+60, w, 20));
    page.graphics.drawString(
        'COSTO TOTAL REAL: ${costoTotalReal.toStringAsFixed(3)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+80, w, 20));
    page.graphics.drawString(
        'VARIACION: ${variacion.toStringAsFixed(2)}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(5, dis+(ingredientesOut.length*35)+100, w, 20));


    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 0), Offset(w, 0));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, 0), Offset(w, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, h), Offset(0, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, h), Offset(0, 0));

    if(variacion<-3 || variacion>3){
      PdfGraphics graphics = page.graphics;
      PdfGraphicsState state = graphics.save();
      graphics.setTransparency(0.25);
      graphics.rotateTransform(-40);
      graphics.drawString('PROCESO ENVIADO A APROBACIÓN \nEN ${DateFormat("dd/MM/yyyy").format(DateTime.now())}',
          PdfStandardFont(PdfFontFamily.helvetica, 30),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
          pen: PdfPens.red,
          brush: PdfBrushes.red,
          bounds: Rect.fromLTWH(-w+480, (h/2)+50, 0, 0));
      graphics.restore(state);
    }

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }
  Future<void> _showDialogTerminar(String title, String msj, int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msj),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                generatePdf(procProd.loteProd);
              },
            ),Container(),
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Widget _customDropDownProductos(
      BuildContext context, ModelInvAgrupado item, String itemDesignation) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(item.codProd),
        subtitle: Text(
          item.nombre.toString(),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderProductos(
      BuildContext context, ModelInvAgrupado item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: ListTile(
        selected: isSelected,
        title: Text("${item.codProd}-${item.nombre}"),
        subtitle: Text("Cantidad Total: ${totalesInvAgrupados[item.codProd].toStringAsFixed(3)} ${item.unidadMedida}"),
      ),
    );
  }
}
//WidgetButtons(txt: "TERMINAR 