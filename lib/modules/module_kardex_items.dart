import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_formulas.dart';
import 'package:andeanvalleysystem/utils/connections/api_historial.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_productos.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down_almacenes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ModuleKardexItems extends StatefulWidget {
  @override
  _ModuleKardexItemsState createState() => _ModuleKardexItemsState();
}

class _ModuleKardexItemsState extends State<ModuleKardexItems> {
  ModelAlmacenes almacenSelection;
  ModelItem selectionItem;
  String fechaIniMandar;
  String fechaFinMandar;
  TextEditingController ecFechaIni = TextEditingController();
  TextEditingController ecFechaFin = TextEditingController();
  String errFechaIni = null;
  String errFechaFin = null;
  bool habilitado = true;
  ScrollController scroll = ScrollController();
  List<ModelHistorialKardex> listaHistorialKardex=List();
  ModelHistorialKardex lastHistorialKardex;


  Future<void> getData() async{
    listaHistorialKardex = await ApiHistorial().getHistorialKardex(
        almacenSelection.codAlm,
        selectionItem.codigo,
        fechaIniMandar,
        fechaFinMandar);
    lastHistorialKardex = await ApiHistorial().getLastHistorial(almacenSelection.codAlm, selectionItem.codigo);
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
                  child: DropDownAlmacenes(
                    selectionAlmacen: almacenSelection,
                    refresh: (val) {
                      setState(() {
                        almacenSelection = val;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: DropDownProductos(
                    selectionAlmacen: almacenSelection,
                    selectionItem: selectionItem,
                    func: (val) {
                      setState(() {
                        selectionItem = val;
                      });
                    },
                  ),
                ),
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Expanded(
                          flex: 1,
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
                                  labelText: "DESDE FECHA",
                                  hintText: "Ejemplo: dd/mm/yyyy",
                                  counterText: ""),
                            ),
                          ),
                        );
                      },
                    ),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.all(2),
                            child: TextFormField(
                              onTap: () {
                                if (ecFechaFin.text.isEmpty)
                                  _selectDateFin(context);
                                errFechaFin = null;
                              },
                              onChanged: (value) {
                                if (value.length == 10) {
                                  errFechaFin = null;
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
                                            errFechaFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaFin = "Fecha Invalida";
                                          });
                                        }
                                      } else if (int.parse(mes) % 2 == 0) {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 31) {
                                          setState(() {
                                            errFechaFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaFin = "Fecha Invalida";
                                          });
                                        }
                                      } else {
                                        if (int.parse(day) > 0 &&
                                            int.parse(day) < 32) {
                                          setState(() {
                                            errFechaFin = null;
                                          });
                                        } else {
                                          setState(() {
                                            errFechaFin = "Fecha Invalida";
                                          });
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        errFechaFin = "Fecha Invalida";
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      errFechaFin = "Fecha Invalida";
                                    });
                                  }
                                }
                              },
                              keyboardType: TextInputType.datetime,
                              maxLength: 10,
                              enabled: habilitado,
                              controller: ecFechaFin,
                              decoration: InputDecoration(
                                  errorText: errFechaFin,
                                  border: OutlineInputBorder(),
                                  labelText: "HASTA FECHA",
                                  hintText: "Ejemplo: dd/mm/yyyy",
                                  counterText: ""),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Expanded(
                  flex: 10,
                  child: almacenSelection != null &&
                          selectionItem != null &&
                          ecFechaIni.text.isNotEmpty &&
                          ecFechaFin.text.isNotEmpty
                      ? Container(color: Colors.white,
                        child: FutureBuilder(
                            future: getData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError)
                                return SomethingWentWrongPage();
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                List<ModelHistorialKardex> mhk = listaHistorialKardex;
                                if (mhk.length != 0) {
                                  if (mhk[0].lote.toLowerCase() == "masivo") {
                                    mhk.insert(
                                        0,
                                        ModelHistorialKardex(
                                            idReg: "",
                                            lote: "SALDO INICIAL",
                                            saldo: 0,
                                            prorrateo: 0,
                                            cantidad: 0,
                                            codProd: selectionItem.codigo,
                                            codAlm: almacenSelection.codAlm,
                                            created_at: ecFechaIni.text,
                                            costoUnitario: mhk[0].costoUnitario,
                                            accion: "",
                                            costo: 0,
                                            saldoCosto: 0,
                                            usuario: 0));
                                  } else {
                                    print("saldos::${mhk[0].cantidad}::${mhk[0].saldoCosto}::${mhk[0].costo}");
                                    mhk.insert(
                                        0,
                                        ModelHistorialKardex(
                                            idReg: "",
                                            lote: "SALDO INICIAL",
                                            saldo: mhk[0].cantidad > 0
                                                ? mhk[0].saldo - mhk[0].cantidad
                                                : mhk[0].saldo +
                                                    (mhk[0].cantidad * -1),
                                            prorrateo: mhk[0].prorrateo,
                                            cantidad: 0,
                                            codProd: selectionItem.codigo,
                                            codAlm: almacenSelection.codAlm,
                                            created_at: ecFechaIni.text,
                                            costoUnitario: mhk[0].costoUnitario,
                                            accion: "",
                                            costo: 0,
                                            saldoCosto: mhk[0].cantidad > 0
                                                ? mhk[0].saldoCosto - mhk[0].costo
                                                : mhk[0].saldoCosto + (mhk[0].costo*-1),
                                            usuario: 0));
                                  }
                                  print("lenght::${mhk.length}");
                                  mhk.insert(
                                      mhk.length,
                                      ModelHistorialKardex(
                                          idReg: "",
                                          lote: "SALDO FINAL",
                                          saldo: mhk[mhk.length - 1].saldo,
                                          prorrateo: mhk[mhk.length - 1].prorrateo,
                                          cantidad: 0,
                                          codProd: selectionItem.codigo,
                                          codAlm: almacenSelection.codAlm,
                                          created_at:
                                              mhk[mhk.length - 1].created_at,
                                          costoUnitario:
                                              mhk[mhk.length - 1].costoUnitario,
                                          accion: "",
                                          costo: 0,
                                          saldoCosto:
                                              mhk[mhk.length - 1].saldoCosto,
                                          usuario: 0));
                                } else {
                                  mhk.add(ModelHistorialKardex(
                                      idReg: "",
                                      lote: "SALDO INICIAL",
                                      saldo: lastHistorialKardex.saldo,
                                      prorrateo: 0,
                                      cantidad: 0,
                                      codProd: selectionItem.codigo,
                                      codAlm: almacenSelection.codAlm,
                                      created_at: ecFechaIni.text,
                                      costoUnitario: 0,
                                      accion: "",
                                      costo: 0,
                                      saldoCosto: lastHistorialKardex.saldoCosto,
                                      usuario: 0));
                                  print("lenght::${mhk.length}");
                                  mhk.add(ModelHistorialKardex(
                                      idReg: "",
                                      lote: "SALDO FINAL",
                                      saldo: lastHistorialKardex.saldo,
                                      prorrateo: 0,
                                      cantidad: 0,
                                      codProd: selectionItem.codigo,
                                      codAlm: almacenSelection.codAlm,
                                      created_at: ecFechaFin.text,
                                      costoUnitario: 0,
                                      accion: "",
                                      costo: 0,
                                      saldoCosto: lastHistorialKardex.saldoCosto,
                                      usuario: 0));
                                }
                                print(mhk.map((e) => e.toJson()).toList());
                                return mhk.length > 0
                                    ? Column(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                headerListCustom(
                                                    "UNIDAD: ${selectionItem.titulo}",
                                                    2,
                                                    () {}),
                                                headerListCustom(
                                                    "INGRESO", 3, () {}),
                                                headerListCustom(
                                                    "SALIDA", 3, () {}),
                                                headerListCustom("SALDO", 3, () {}),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Row(
                                              children: [
                                                headerListCustom("FECHA", 1, () {}),
                                                headerListCustom(
                                                    "DESCRIPCION", 1, () {}),
                                                headerListCustom(
                                                    "CANTIDAD", 1, () {}),
                                                headerListCustom(
                                                    "COSTO \nTOTAL [Bs]", 1, () {}),
                                                headerListCustom(
                                                    "COSTO \nUNITARIO [Bs]",
                                                    1,
                                                    () {}),
                                                headerListCustom(
                                                    "CANTIDAD", 1, () {}),
                                                headerListCustom(
                                                    "COSTO \nTOTAL [Bs]", 1, () {}),
                                                headerListCustom(
                                                    "COSTO \nUNITARIO [Bs]",
                                                    1,
                                                    () {}),
                                                headerListCustom(
                                                    "CANTIDAD", 1, () {}),
                                                headerListCustom(
                                                    "COSTO TOTAL [Bs]", 1, () {}),
                                                headerListCustom(
                                                    "COSTO UNITARIO [Bs]",
                                                    1,
                                                    () {}),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Scrollbar(
                                              controller: scroll,
                                              child: ListView(
                                                controller: scroll,
                                                children: mhk.map((e) {
                                                  List<String> listLote = e.lote.split('|');
                                                  return Row(
                                                    children: [
                                                      dataListCustom(
                                                          e.created_at.toString(),"","",
                                                          1,false),
                                                      dataListCustom(listLote.length>1?"Varios Lotes":e.lote,e.lote,e.idReg, 1,true),
                                                      dataListCustom(
                                                          e.cantidad > 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.cantidad, 2)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          e.cantidad > 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.costo, 3)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          e.cantidad > 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.costoUnitario,
                                                                      3)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          e.cantidad < 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.cantidad, 2)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          e.cantidad < 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.costo, 3)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          e.cantidad < 0
                                                              ? NumberFunctions
                                                                  .formatNumber(
                                                                      e.costoUnitario,
                                                                      3)
                                                              : "-","","",
                                                          1,false),
                                                      dataListCustom(
                                                          NumberFunctions
                                                              .formatNumber(
                                                                  e.saldo, 2),"","",
                                                          1,false),
                                                      dataListCustom(
                                                          NumberFunctions
                                                              .formatNumber(
                                                                  e.saldoCosto, 3),"","",
                                                          1,false),
                                                      dataListCustom(
                                                          NumberFunctions
                                                              .formatNumber(
                                                                  e.saldoCosto /
                                                                      e.saldo,
                                                                  3),"","",
                                                          1,false),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                        ],
                                      )
                                    : Center(
                                        child: Container(
                                        child: Text("NO HAY DATOS"),
                                      ));
                              }
                              return LoadingPage();
                            },
                          ),
                      )
                      : Center(
                          child: Container(
                          child: Text("NO HAY DATOS"),
                        )),
                )
              ],
            ),
          )
        ],
      ),
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
      });
    }
  }

  Future<void> _selectDateFin(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ecFechaFin.text = DateFormat("dd/MM/yyyy").format(picked);
        fechaFinMandar = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  headerListCustom(String text, int flex, Function func) {
    return Expanded(
        flex: flex,
        child: InkWell(
          onTap: func,
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
              )),
        ));
  }

  dataListCustom(String text, String msgToolTip, String subtitle, int flex, bool subtitleActive) {
    return Expanded(
        flex: flex,
        child: msgToolTip.isNotEmpty?Tooltip(
          message: msgToolTip,
          child: Container(
              margin: EdgeInsets.all(.5),
              width: double.infinity,
              height: 30,
              // color: Colors.blueGrey,
              child: Center(
                child: !subtitleActive
                    ? Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 10),
                      )
                    : Column(
                        children: [
                          Text(
                            text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9),
                          ),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 9),
                          )
                        ],
                      ),
              )),
        ):Container(
            margin: EdgeInsets.all(.5),
            width: double.infinity,
            height: 30,
            // color: Colors.blueGrey,
            child: Center(
              child: !subtitleActive
                  ? Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * .01),
              )
                  : Column(
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * .01),
                  ),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * .007),
                  )
                ],
              ),
            )),);
  }
}
