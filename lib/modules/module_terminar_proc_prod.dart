
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

class ModuleTerminarProcProd extends StatefulWidget {
  final ModelProcesoProduccion procProd;
  final Function refresh;

  ModuleTerminarProcProd({Key key, @required this.procProd, this.refresh}) : super(key: key);

  @override
  _ModuleTerminarProcProdState createState() => _ModuleTerminarProcProdState();
}

class _ModuleTerminarProcProdState extends State<ModuleTerminarProcProd> {
  int myAlm;
  int idUs;
  ModelProcesoProduccion procProd;
  ModelFormula formula;
  List<ModelIngredientesFormulas> ingredientes;
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
  Map<String,List<ModelInventario>> inventario = Map();
  List<String> keys = List();
  ScrollController scroll;
  Map<String, List<ModelInvAgrupado>> inventariosAgrupados = Map();
  Map<String, double> totalesInvAgrupados = Map();

  bool firstClick=false;

  Future getData() async {
    if (formula == null && ingredientes == null && almacenes == null) {
      SharedPreferences sp = await SharedPreferences.getInstance();
      ingredientesIn.clear();
      ingredientesOut.clear();
      formula = await ApiFormulas().getId(procProd.idFormula);
      ingredientes = await ApiProcesosProduccion().getIngredientes(procProd.id);
      almacenes = await Constant().getAlmacenes();
      items = await ApiConnections().getItemsProdPermitidos("1|2");
      myAlm = procProd.codAlmProd;//int.parse(sp.getString("almacenes"));
      idUs = sp.getInt("sessionID");
      List<String> almacenesSep = sp.getString("almacenes").split(',');
      if(almacenesSep.length>1)
        inv = await ApiInventory().getInventarioExistentes(procProd.codAlmProd);
      else
        inv = await ApiInventory().getInventarioExistentes(int.parse(sp.getString("almacenes")));
      inv.forEach((element) {
        if(inventario.containsKey(element.codProd)) {
          inventario[element.codProd].add(element);
          double aux = totalesInvAgrupados[element.codProd];
          totalesInvAgrupados[element.codProd] = aux + element.cantidad;
        }else{
          keys.add(element.codProd);
          inventario[element.codProd] = List();
          inventario[element.codProd].add(element);
          totalesInvAgrupados[element.codProd] = element.cantidad;
        }
      });
      inventario.forEach((key, value) {
        ModelInvAgrupado mia = ModelInvAgrupado(
            prorrateo: value[0].prorrateo,
            cantidad: value[0].cantidad,
            codProd: value[0].codProd,
            codAlm: value[0].codAlm,
            nombre: value[0].nombre,
            unidadMedida: value[0].unidad
        );
        invAgrupados.add(mia);


      });
      ingredientes.forEach((element) {
        if (element.tipo == 0) {
          ingredientesIn.add(ModelReservaItemsProcProd(
              idProcProd: procProd.id,
              codProd: element.codProd,
              cantidadReceta: element.cantProd,
              tipo: element.tipo,
              costoUnit: element.prorrateo != null ? element.prorrateo : 0,
              estado: 1,
              nombreProd: element.nombreProd,
              unidad: element.unidad,
              cantidad: 0));
        } else {
          ingredientesOut.add(ModelReservaItemsProcProd(
              idProcProd: procProd.id,
              codProd: element.codProd,
              cantidadReceta: element.cantProd,
              tipo: element.tipo,
              costoUnit: element.prorrateo != null ? element.prorrateo : 0,
              estado: 1,
              nombreProd: element.nombreProd,
              unidad: element.unidad));
        }
      });
      ingredientesOut[0].cantidad = procProd.cantidad;
    }
    if (formula != null && ingredientes != null && almacenes != null) {
      setState(() {
        ecFormula.text = "${formula.codProdRes} - ${formula.titulo}";
        ecLineaProd.text = "${procProd.lineaProd}";
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
                  ingredientesOut[0].cantidad = procProd.cantidad;
                  return Column(
                    children: [
                      datos(),
                      Container(
                        margin: EdgeInsets.only(left: 30,right: 30),
                        child: DropdownSearch<ModelInvAgrupado>(
                          emptyBuilder: (context, searchEntry) {
                            return Center(
                              child: Text("NO EXISTEN DATOS"),
                            );
                          },
                          items: invAgrupados,
                          filterFn: (item, filter) {
                            if (filter.isEmpty)
                              return true;
                            else {
                              if (item.codProd.contains(filter) ||
                                  item.nombre
                                      .toLowerCase()
                                      .contains(filter.toLowerCase()))
                                return true;
                              else
                                return false;
                            }
                          },
                          selectedItem: selectionItem,
                          onChanged: (value) {
                            ApiInventory().getProrrateo(myAlm, value.codProd).then((i){
                              setState(() {
                                selectionItem = value;
                                bool f = true;
                                ingredientesIn.forEach((element) {
                                  if(element.codProd == value.codProd){
                                    f = false;
                                  }
                                });
                                if(f){
                                  ingredientesIn.add(
                                      ModelReservaItemsProcProd(
                                          nombreProd: value.nombre,
                                          codProd: value.codProd,
                                          idProcProd: procProd.id,
                                          unidad: value.unidadMedida,
                                          costoUnit: i,
                                          cantidadReceta: 0,
                                          cantidad: 0,
                                        tipo: 0,
                                        estado: 1,
                                        adicional: 1
                                      )
                                  );
                                }else Toast.show("YA EXISTE ESTE PRODUCTO EN SU LISTA", context, duration: Toast.LENGTH_LONG);
                              });
                            });
                          },
                          showSearchBox: true,
                          label: "ADICIONAR UN PRODUCTO",
                          popupTitle:
                          Center(child: Text("LISTA DE PRODUCTOS")),
                          popupItemBuilder:
                          _customPopupItemBuilderProductos,
                          dropdownBuilder:
                          selectionItem != null
                              ? _customDropDownProductos
                              : null,
                        )
                      ),
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
                            txt: "TERMINAR PROCESO",
                            color1: Colors.green,
                            color2: Colors.greenAccent,
                            colorText: Colors.white,
                            func: () {
                              if(!firstClick){
                                firstClick=true;
                                  if(ecFecIni.text.isNotEmpty){
                                    if(ecFecFin.text.isNotEmpty){
                                      if(ecFecVenc.text.isNotEmpty){
                                        int aprob=1;
                                        List<ModelHistorialKardex> mhk = List();
                                        if(variacion > 3 || variacion < -3) aprob = 0;
                                        procProd.reservas.clear();
                                        procProd.codAlmDest =
                                            myAlm;
                                        procProd.loteVenta = ecLoteVenta.text;
                                        procProd.estado = 1;
                                        procProd.aprob = aprob;
                                        procProd.fecInicio = ecFecIni.text;
                                        procProd.fecFin = ecFecFin.text;
                                        procProd.fecVenc = ecFecVenc.text;
                                        procProd.fecCulminacion = DateFormat("dd/MM/yyyy")
                                            .format(DateTime.now());
                                        procProd.fecRegistro = DateFormat("yyyy-MM-dd")
                                            .format(DateTime.now());

                                        List<ModelReservaItemsProcProd> mripp = List();

                                        ingredientesIn.forEach((ingrediente) {
                                          ApiInventory().discountInventory(ingrediente.lotes,procProd.codAlmProd,ingrediente.codProd);
                                          String lotesCadena="";
                                          ingrediente.lotes.forEach((lote) {
                                            ModelReservaItemsProcProd m = ModelReservaItemsProcProd.fromJson(ingrediente.toJson());
                                            m.lote = lote.lote;
                                            m.idInventario = lote.id;
                                            m.cantidad = lote.cantidadUsada;
                                            lotesCadena+=lote.lote+"|";
                                            mripp.add(m);
                                          });

                                          mhk.add(ModelHistorialKardex(
                                              idReg: "PP-${procProd.id.toString().padLeft(5,'0')}",
                                              codAlm: myAlm,
                                              codProd: ingrediente.codProd,
                                              cantidad: ingrediente.cantidad*(-1),
                                              lote: procProd.loteProd,
                                              costo: (ingrediente.cantidad*ingrediente.costoUnit)*(-1),
                                              costoUnitario: ingrediente.costoUnit,
                                              prorrateo: ingrediente.costoUnit,
                                              usuario: idUs,
                                              accion: "PROCESO DE PRODUCCION",
                                              created_at: DateFormat("yyyy-MM-dd").format(DateTime.now())
                                          ));
                                        });

                                        ingredientesOut.forEach((element) {
                                          element.lote = ecLoteProd.text;
                                          element.loteVenta = ecLoteVenta.text;
                                          mripp.add(element);
                                          if(aprob==1) {
                                            mhk.add(ModelHistorialKardex(
                                                idReg: "PP-${procProd.id.toString()
                                                    .padLeft(5, '0')}",
                                                codAlm: myAlm,
                                                codProd: element.codProd,
                                                cantidad: element.cantidad,
                                                lote: procProd.loteProd,
                                                costo: (element.cantidad *
                                                    element.costoUnit),
                                                costoUnitario: element.costoUnit,
                                                prorrateo: element.costoUnit,
                                                usuario: idUs,
                                                accion: "PROCESO DE PRODUCCION",
                                                created_at: DateFormat("yyyy-MM-dd")
                                                    .format(DateTime.now())));
                                          }
                                        });
                                        procProd.reservas.addAll(mripp);

                                        print(mhk.map((e) => e.toJson()));
                                        print(procProd.id);

                                        ApiProcesosProduccion().update(procProd).whenComplete((){

                                          ApiHistorial().createHistorial(mhk);
                                          if(aprob==0)
                                            _showMyDialog("Proceso Terminado","Se enviara para aprobacion ya que su variacion fue ${variacion.toStringAsFixed(2)}%.");
                                          else _showMyDialog("Proceso Terminado","Su Proceso termino correctamente.");

                                        });
                                      }else Toast.show("INGRESE UNA FECHA DE VENCIMIENTO", context);
                                    }else Toast.show("INGRESE UNA FECHA DE FINALIZACION", context);
                                  }else Toast.show("INGRESE UNA FECHA DE INICIO", context);
                              }else Toast.show("El Proceso esta cargando...", context, duration: Toast.LENGTH_LONG);
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
                firstClick=false;
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
    colorVariacion = Colors.black;
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
                      "COSTO TOTAL RECETA: ${costoTotalReceta.toStringAsFixed(2)} Bs.",
                  style: style,),
                  Text(
                      "COSTO TOTAL REAL: ${costoTotalReal.toStringAsFixed(2)} Bs.",
                    style: style,),
                  Text("VARIACION: ${variacion.toStringAsFixed(2)} %.",
                    style: TextStyle(
                      fontSize: 18,fontWeight: FontWeight.bold,
                      color: colorVariacion
                    ),)
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
                  print(e.toJson());
                  return StatefulBuilder(
                    builder: (context, setState) {
                      _stateResultado = setState;
                      e.costoUnit = costoTotalReal / e.cantidad;
                      e.costoTotalReal = costoTotalReal;
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
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${(e.costoTotalReal / e.cantidad)}",
                                    child: Center(
                                        child: Text(
                                          (e.costoTotalReal / e.cantidad)
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
                                    message: "${e.costoTotalReal}",
                                    child: Center(
                                        child: Text(
                                          "${e.costoTotalReal.toStringAsFixed(3)}",
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

  List<TextEditingController> tecCostos = List();
  List<TextEditingController> tecCantidades = List();

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
                      tecCostos.add(TextEditingController());
                      tecCantidades.add(TextEditingController());
                      int index = ingredientesOut.indexOf(e);

                      _stateResultado = setState;
                      double costoUnit = 0;
                      double sum = 0;
                      if (index == 0) {
                        for (int i = 0; i < tecCantidades.length; i++) {
                          sum += (tecCantidades[i].text.isNotEmpty
                              ? double.parse(tecCantidades[i].text)
                              : 0) *
                              (tecCostos[i].text.isNotEmpty
                                  ? double.parse(tecCostos[i].text)
                                  : 0);
                        }
                        costoUnit = (costoTotalReal - sum) / e.cantidad;
                        e.costoUnit = costoUnit;
                        e.costoTotalReal = costoTotalReal - sum;
                      } else {
                        ingredientesOut[index].cantidad = double.parse(
                            tecCantidades[index].text.isNotEmpty
                                ? tecCantidades[index].text
                                : "0");
                        ingredientesOut[index].costoUnit = double.parse(
                            tecCostos[index].text.isNotEmpty
                                ? tecCostos[index].text
                                : "0");
                        e.costoTotalReal = (tecCantidades[index].text.isNotEmpty?
                        double.parse(tecCantidades[index].text):0)*
                            (tecCostos[index].text.isNotEmpty?
                        double.parse(tecCostos[index].text):0);
                      }
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
                                  child: index == 0
                                      ? Center(
                                      child: Text(
                                        e.cantidad.toStringAsFixed(2),
                                        style: style,
                                      ))
                                      : Container(
                                    margin: EdgeInsets.all(5),
                                    child: TextFormField(
                                      onChanged: (value) {
                                        e.cantidad = double.parse(value);
                                        refresh();
                                      },
                                      controller: tecCantidades[index],
                                      // enabled: enabled,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        // errorText: error,
                                        border: OutlineInputBorder(),
                                        // labelText: hint,
                                      ),
                                    ),
                                  )),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: index == 0
                                      ? Tooltip(
                                        message: "${e.costoUnit}",
                                        child: Center(
                                        child: Text(
                                          e.costoUnit.toStringAsFixed(3),
                                          style: style,
                                        )),
                                      )
                                      : Container(
                                      margin: EdgeInsets.all(5),
                                      child: Container(
                                        margin: EdgeInsets.all(5),
                                        child: TextFormField(
                                          onChanged: (value) {
                                            e.costoUnit=double.parse(value);
                                            refresh();
                                          },
                                          controller: tecCostos[index],
                                          // enabled: enabled,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            // errorText: error,
                                            border: OutlineInputBorder(),
                                            // labelText: hint,
                                          ),
                                        ),
                                      ))),
                              Container(
                                width: 1,
                                height: 20,
                                color: Colors.blueGrey,
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Tooltip(
                                    message: "${e.costoTotalReal}",
                                    child: Center(
                                        child: Text(
                                          index == 0
                                              ? "${(e.costoTotalReal).toStringAsFixed(3)}"
                                              : "${((tecCantidades[index].text.isNotEmpty ? double.parse(tecCantidades[index].text) : 0) * (tecCostos[index].text.isNotEmpty ? double.parse(tecCostos[index].text) : 0)).toStringAsFixed(2)}",
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
                    children: ingredientesIn.map((e) {
                      _stateIngredientes = setState;
                      double cantReceta =
                      ((procProd.cantidad * e.cantidadReceta) /
                          ingredientesOut[0].cantidadReceta);
                      e.cantidadRequerida = cantReceta;
                      e.costoTotalReceta = e.cantidadRequerida*e.costoUnit;
                      return InkWell(
                        onTap: () {
                          ApiInventory()
                              .getLotes(procProd.codAlmProd, e.codProd)
                              .then((value) {
                                if(value!=null && value.length>0)
                                  _showDialog(e, value);
                                else Toast.show("No Existen Productos En tu Almacen", context, duration:Toast.LENGTH_LONG);
                          });
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
                                      Expanded(
                                        flex: 1,
                                        child: e.adicional==1?InkWell(
                                          onTap: (){setState((){
                                            ingredientesIn.removeAt(ingredientesIn.indexOf(e));
                                          });},
                                          child: Icon(Icons.delete_forever),
                                        ):Container(),
                                      ),

                                      Expanded(
                                        flex:5,
                                        child: Text(
                                          e.codProd,
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
                                    message: "${e.costoUnit}",
                                    child: Center(
                                        child: Text(
                                          e.costoUnit.toStringAsFixed(3),
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
                                          "${(e.cantidad).toStringAsFixed(2)}",
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
                                    message: "${e.cantidad * e.costoUnit}",
                                    child: Container(
                                      height: 30,
                                      color: Colors.blueGrey,
                                      child: Center(
                                          child: Text(
                                            "${(e.cantidad * e.costoUnit).toStringAsFixed(3)}",
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
                                    message: "${e.costoTotalReceta}",
                                    child: Center(
                                        child: Text(
                                          "${e.costoTotalReceta!=null?e.costoTotalReceta.toStringAsFixed(3):0.toStringAsFixed(3)}",
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
                                          "${e.lotes != null ? e.lotes.map((e) => "${e.lote}|") : ""}",
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
                        "LOTE DE VENTA", ecLoteVenta, errLoteVenta, true,(value){}),
                  )
                ],
              ),
              textEdit("CLIENTE", ecCliente, errCliente, false,(value){}),
              Row(
                children: [
                  Expanded(
                    child: textEdit("CANTIDAD", ecCantidad, errCantidad, true,(value){
                      try {
                        procProd.cantidad = double.parse(value);
                        ingredientesOut[0].cantidad = double.parse(value);
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
                            onTap: () {
                              if (ecFecIni.text.isEmpty)
                                _selectDate(context, ecFecIni);
                              errFecIni = null;
                            },
                            onChanged: (value) {
                              if (value.length == 10) {
                                errFecIni = null;
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
                                          errFecIni = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecIni = "Fecha Invalida";
                                        });
                                      }
                                    } else if (int.parse(mes) % 2 == 0) {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 31) {
                                        setState(() {
                                          errFecIni = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecIni = "Fecha Invalida";
                                        });
                                      }
                                    } else {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 32) {
                                        setState(() {
                                          errFecIni = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecIni = "Fecha Invalida";
                                        });
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      errFecIni = "Fecha Invalida";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    errFecIni = "Fecha Invalida";
                                  });
                                }
                              }
                            },
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
                            onTap: () {
                              if (ecFecFin.text.isEmpty)
                                _selectDate(context, ecFecFin);
                              errFecFin = null;
                            },
                            onChanged: (value) {
                              if (value.length == 10) {
                                errFecFin = null;
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
                                          errFecFin = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecFin = "Fecha Invalida";
                                        });
                                      }
                                    } else if (int.parse(mes) % 2 == 0) {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 31) {
                                        setState(() {
                                          errFecFin = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecFin = "Fecha Invalida";
                                        });
                                      }
                                    } else {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 32) {
                                        setState(() {
                                          errFecFin = null;
                                        });
                                      } else {
                                        setState(() {
                                          errFecFin = "Fecha Invalida";
                                        });
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      errFecFin = "Fecha Invalida";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    errFecFin = "Fecha Invalida";
                                  });
                                }
                              }
                            },
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
                      onTap: () {
                        if (ecFecVenc.text.isEmpty)
                          _selectDateVencimiento(context, ecFecVenc);
                        errFecVenc = null;
                      },
                      onChanged: (value) {
                        if (value.length == 10) {
                          errFecVenc = null;
                          List<String> lt = value.split("/");
                          String day = lt[0];
                          String mes = lt[1];
                          String year = lt[2];
                          Toast.show("$day::$mes::$year", context);
                          if (int.parse(year) >= 2020) {
                            if (int.parse(mes) > 0 && int.parse(mes) < 13) {
                              if (int.parse(mes) == 2) {
                                if (int.parse(day) > 0 && int.parse(day) < 30) {
                                  setState(() {
                                    errFecVenc = null;
                                  });
                                } else {
                                  setState(() {
                                    errFecVenc = "Fecha Invalida";
                                  });
                                }
                              } else if (int.parse(mes) % 2 == 0) {
                                if (int.parse(day) > 0 && int.parse(day) < 31) {
                                  setState(() {
                                    errFecVenc = null;
                                  });
                                } else {
                                  setState(() {
                                    errFecVenc = "Fecha Invalida";
                                  });
                                }
                              } else {
                                if (int.parse(day) > 0 && int.parse(day) < 32) {
                                  setState(() {
                                    errFecVenc = null;
                                  });
                                } else {
                                  setState(() {
                                    errFecVenc = "Fecha Invalida";
                                  });
                                }
                              }
                            } else {
                              setState(() {
                                errFecVenc = "Fecha Invalida";
                              });
                            }
                          } else {
                            setState(() {
                              errFecVenc = "Fecha Invalida";
                            });
                          }
                        }
                      },
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
//WidgetButtons(txt: "TERMINAR PROCESO",c