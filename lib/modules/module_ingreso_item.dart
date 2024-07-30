import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'package:andeanvalleysystem/models/model_registro_ingreso.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_orden_compra.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';

class ModuleIngresoItems extends StatefulWidget {
  @override
  _ModuleIngresoItemsState createState() => _ModuleIngresoItemsState();
}

class _ModuleIngresoItemsState extends State<ModuleIngresoItems> {
  bool expand = false;
  TextEditingController ecCantidad = TextEditingController();
  TextEditingController ecCostoTotal = TextEditingController();
  TextEditingController ecLote = TextEditingController();
  TextEditingController ecFactComp = TextEditingController();
  TextEditingController ecProv = TextEditingController();
  TextEditingController ecFecVenc = TextEditingController();
  TextEditingController ecFecIngreso = TextEditingController();
  TextEditingController ecRecibo = TextEditingController();
  TextEditingController ecObs = TextEditingController();

  //edicion
  TextEditingController ecCantidadEdit = TextEditingController();
  TextEditingController ecCostoTotalEdit = TextEditingController();
  TextEditingController ecLoteEdit = TextEditingController();
  TextEditingController ecFacturaEdit = TextEditingController();
  ModelItem selectionItemEdit;
  ModelProveedores selectionProveedorEdit;

  bool habilitado = true;
  bool edit = false;

  ModelItem selectionItem;
  ModelAlmacenes selectionAlmacen;
  ModelOrdenCompra selectionOC;
  ModelProveedores selectionProveedor;
  List<ModelInventario> inventarioSelected = List();
  List<ModelProveedores> provList = List();
  List<ModelItem> prodList = List();
  List<ModelAlmacenes> almList = List();
  List<ModelOrdenCompra> orCoList = List();
  ModelInventario selectedEdit;

  String errTxtCantidad = null;
  String errTxtCostoTotal = null;
  String errTxtLote = null;
  String errTxtFactura = null;
  String errorFecIngreso = null;
  String errorFecVencimiento = null;
  String errorRecibo = null;
  String errorObs = null;

  //NUEVO 
  bool acClick = false; //PREVENIR DOBLE CLICK EN GENERAR INGRESO

  void clean() {
    if (this.mounted) {
      setState(() {
        expand = false;
        ecCantidad.text = "";
        ecCostoTotal.text = "";
        ecLote.text = "";
        ecFactComp.text = "";
        ecProv.text = "";
        ecFecVenc.text = "";
        ecFecIngreso.text = "";
        selectionOC = null;
        errTxtCantidad = null;
        selectionItem = null;
        selectionAlmacen = null;
        selectionProveedor = null;
        habilitado = true;
        inventarioSelected.clear();
        edit = false;
        acClick = false; //NUEVO
        provList.clear();
        prodList.clear();
        almList.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ordenCompraList(),
            fillingData(),
            sectorData(),
            WidgetButtons(
              color1: Colors.greenAccent,
              color2: Colors.green,
              colorText: Colors.white,
              txt: "GENERAR INGRESO",
              func: () {
                if(acClick) {
                  return null;
                } else {
                  acClick = true;
                  bool f = true;
                  inventarioSelected.forEach((element) {
                    if (element.lote != null &&
                        element.lote.isNotEmpty &&
                        element.fecVencimiento != null &&
                        element.fecVencimiento.isNotEmpty &&
                        ((element.factura != null &&
                                element.factura.isNotEmpty) ||
                            (element.recibo != null &&
                                element.recibo.isNotEmpty)) &&
                        f) {
                      f = true;
                    } else {
                      f = false;
                    }
                  });
                  if (f) {
                    if (inventarioSelected.length > 0) {
                      if (selectionOC != null)
                        ApiConnections()
                            .getCambioEstadoOrdenCompra(selectionOC.id)
                            .whenComplete(() {
                          setIngresoPostProcess();
                        });
                      else {
                        setIngresoPostProcess();
                      }
                    } else
                      Toast.show("No Existe una Lista", context);
                  } else
                    Toast.show(
                        "Se requiere datos importantes ('lote','fecha vencimiento','factura')",
                        context,
                        duration: Toast.LENGTH_LONG);
                }
              },
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Future<int> setIngresoPostProcess() async {
    List<ModelRegistroIngreso> mri = List();
    ApiInventory().getRegistroIngresosCount().then((value) {
      int cont = value + 1;
      inventarioSelected.forEach((element) {
        element.idCodigo = "IN-${cont.toString().padLeft(5, '0')}";
        element.fechaSistema = DateFormat("yyyy-MM-dd").format(DateTime.now());
        mri.add(ModelRegistroIngreso(
            factura: element.factura,
            fecVencimiento: element.fecVencimiento,
            lote: element.lote,
            costoUnitario: element.costoUnitario,
            cantidad: element.cantidad,
            codProd: element.codProd,
            codAlm: element.codAlm,
            codigo: "IN-${cont.toString().padLeft(5, '0')}",
            fecIngreso: element.fecIngreso,
            usuario: element.usuario,
            costo: element.costo,
            loteVenta: element.loteVenta,
            aprobConta: 0,
            aprobCalida: 0,
            idProv: element.idProv,
            fecRegistro: DateFormat("yyyy-MM-dd").format(DateTime.now()),
            recibo: ecRecibo.text,
            obs: ecObs.text));
      });
      ApiInventory().insertRegistroIngreso(mri);
      ApiInventory()
          .insertInventory(inventarioSelected, context)
          .whenComplete(() {
        _showDialog("IN-${cont.toString().padLeft(5, '0')}");
      });
    });
    // inventarioSelected.forEach((element) {
    //   element.fechaSistema = DateFormat("yyyy-MM-dd").format(DateTime.now());
    // });
  }

  fillingData() {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(.5, 10), blurRadius: 20)
          ]),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text(
                "LLENAR INFORMACION",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        almList.length < 1
                            ? FutureBuilder<List<ModelAlmacenes>>(
                                future: Constant().getAlmacenes(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    SomethingWentWrongPage();
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    almList = snapshot.data;
                                    if (almList.length == 1)
                                      selectionAlmacen = almList[0];
                                    // List<ModelAlmacenes> items = snapshot.data;
                                    return DropdownSearch<ModelAlmacenes>(
                                      emptyBuilder: (context, searchEntry) {
                                        return Center(
                                          child: Text("NO EXISTEN DATOS"),
                                        );
                                      },
                                      enabled: habilitado,
                                      items: almList,
                                      selectedItem: selectionAlmacen,
                                      onChanged: (value) {
                                        setState(() {
                                          selectionAlmacen = value;
                                          selectionItem = null;
                                        });
                                      },
                                      label: "SELECCIONE UN ALMACEN",
                                      popupTitle: Center(
                                          child: Text("LISTA DE ALMACENES")),
                                      popupItemBuilder:
                                          _customPopupItemBuilderAlm,
                                      dropdownBuilder: selectionAlmacen != null
                                          ? _customDropDownAlm
                                          : null,
                                    );
                                  }
                                  return LoadingPage();
                                },
                              )
                            : DropdownSearch<ModelAlmacenes>(
                                emptyBuilder: (context, searchEntry) {
                                  return Center(
                                    child: Text("NO EXISTEN DATOS"),
                                  );
                                },
                                enabled: habilitado,
                                items: almList,
                                selectedItem: selectionAlmacen,
                                onChanged: (value) {
                                  setState(() {
                                    selectionAlmacen = value;
                                    selectionItem = null;
                                  });
                                },
                                label: "SELECCIONE UN ALMACEN",
                                popupTitle:
                                    Center(child: Text("LISTA DE ALMACENES")),
                                popupItemBuilder: _customPopupItemBuilderAlm,
                                dropdownBuilder: selectionAlmacen != null
                                    ? _customDropDownAlm
                                    : null,
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        FutureBuilder<List<ModelItem>>(
                          future: ApiConnections().getItemsProdPermitidos(
                              selectionAlmacen != null
                                  ? selectionAlmacen.ProdPermitidos
                                  : ""),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) SomethingWentWrongPage();
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              prodList = snapshot.data;
                              List<ModelItem> items = snapshot.data;
                              return DropdownSearch<ModelItem>(
                                emptyBuilder: (context, searchEntry) {
                                  return Center(
                                    child: Text("NO EXISTEN DATOS"),
                                  );
                                },
                                items: items,
                                filterFn: (item, filter) {
                                  if (filter.isEmpty)
                                    return true;
                                  else {
                                    if (item.codigo.contains(filter) ||
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
                                  setState(() {
                                    selectionItem = value;
                                  });
                                },
                                showSearchBox: true,
                                label: "SELECCIONE UN PRODUCTO",
                                popupTitle:
                                    Center(child: Text("LISTA DE PRODUCTOS")),
                                popupItemBuilder:
                                    _customPopupItemBuilderProductos,
                                dropdownBuilder: selectionItem != null
                                    ? _customDropDownProductos
                                    : null,
                              );
                            }
                            return LoadingPage();
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        return Expanded(
                          flex: 10,
                          child: TextFormField(
                            onTap: () {
                              if (ecFecIngreso.text.isEmpty)
                                _selectDateIngreso(context);
                              errorFecIngreso = null;
                            },
                            onChanged: (value) {
                              if (value.length == 10) {
                                errorFecIngreso = null;
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
                                          errorFecIngreso = null;
                                        });
                                      } else {
                                        setState(() {
                                          errorFecIngreso = "Fecha Invalida";
                                        });
                                      }
                                    } else if (int.parse(mes) % 2 == 0) {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 31) {
                                        setState(() {
                                          errorFecIngreso = null;
                                        });
                                      } else {
                                        setState(() {
                                          errorFecIngreso = "Fecha Invalida";
                                        });
                                      }
                                    } else {
                                      if (int.parse(day) > 0 &&
                                          int.parse(day) < 32) {
                                        setState(() {
                                          errorFecIngreso = null;
                                        });
                                      } else {
                                        setState(() {
                                          errorFecIngreso = "Fecha Invalida";
                                        });
                                      }
                                    }
                                  } else {
                                    setState(() {
                                      errorFecIngreso = "Fecha Invalida";
                                    });
                                  }
                                } else {
                                  setState(() {
                                    errorFecIngreso = "Fecha Invalida";
                                  });
                                }
                              }
                            },
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            enabled: habilitado,
                            controller: ecFecIngreso,
                            decoration: InputDecoration(
                                errorText: errorFecIngreso,
                                border: OutlineInputBorder(),
                                labelText: "FECHA DE INGRESO",
                                hintText: "Ejemplo: dd/mm/yyyy",
                                counterText: ""),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      flex: 1,
                      child: InkWell(
                        onTap: () {
                          if (habilitado) _selectDateIngreso(context);
                        },
                        child: Icon(Icons.date_range),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(child: StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          onTap: () {
                            errTxtCantidad = null;
                          },
                          controller: ecCantidad,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "CANTIDAD",
                              errorText: errTxtCantidad,
                              errorStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      .006)),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              try {
                                double.parse(value);
                                if (errTxtCantidad != null) {
                                  setState(() {
                                    errTxtCantidad = null;
                                  });
                                }
                              } catch (e) {
                                if (errTxtCantidad == null) {
                                  setState(() {
                                    errTxtCantidad = "SOLO SE PERMITE NUMEROS";
                                  });
                                }
                              }
                            } else {
                              setState(() {
                                errTxtCantidad = null;
                              });
                            }
                          },
                        );
                      },
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(child: StatefulBuilder(
                      builder: (context, setState) {
                        return TextFormField(
                          onTap: () {
                            errTxtCostoTotal = null;
                          },
                          controller: ecCostoTotal,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "COSTO TOTAL",
                              errorText: errTxtCostoTotal,
                              errorStyle: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width *
                                      .006)),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              try {
                                double.parse(value);
                                if (errTxtCostoTotal != null) {
                                  setState(() {
                                    errTxtCostoTotal = null;
                                  });
                                }
                              } catch (e) {
                                if (errTxtCostoTotal == null) {
                                  setState(() {
                                    errTxtCostoTotal =
                                        "SOLO SE PERMITE NUMEROS";
                                  });
                                }
                              }
                            } else {
                              setState(() {
                                errTxtCostoTotal = null;
                              });
                            }
                          },
                        );
                      },
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: TextFormField(
                      onTap: () {
                        errTxtLote = null;
                      },
                      onChanged: (value) {
                        errTxtLote = null;
                      },
                      controller: ecLote,
                      decoration: InputDecoration(
                        errorText: errTxtLote,
                        border: OutlineInputBorder(),
                        labelText: "LOTE",
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: TextFormField(
                      onTap: () {
                        errTxtFactura = null;
                      },
                      onChanged: (value) {
                        errTxtFactura = null;
                      },
                      controller: ecFactComp,
                      decoration: InputDecoration(
                        errorText: errTxtFactura,
                        border: OutlineInputBorder(),
                        labelText: "FACTURA",
                      ),
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: TextFormField(
                      onTap: () {
                        errorRecibo = null;
                      },
                      onChanged: (value) {
                        errorRecibo = null;
                      },
                      controller: ecRecibo,
                      decoration: InputDecoration(
                        errorText: errorRecibo,
                        border: OutlineInputBorder(),
                        labelText: "RECIBO DE COMPRA",
                      ),
                    )),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(child: StatefulBuilder(
                      builder: (context, setState) {
                        return provList.length < 1
                            ? FutureBuilder<List<ModelProveedores>>(
                                future: ApiConnections().getProveedores(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError)
                                    SomethingWentWrongPage();
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    provList = snapshot.data;
                                    // List<ModelProveedores> items = snapshot.data;
                                    return DropdownSearch<ModelProveedores>(
                                      emptyBuilder: (context, searchEntry) {
                                        return Center(
                                          child: Text("NO EXISTEN DATOS"),
                                        );
                                      },
                                      items: provList,
                                      filterFn: (item, filter) {
                                        if (filter.isEmpty)
                                          return true;
                                        else {
                                          if (item.nombre
                                              .toLowerCase()
                                              .contains(filter.toLowerCase()))
                                            return true;
                                          else
                                            return false;
                                        }
                                      },
                                      selectedItem: selectionProveedor,
                                      onChanged: (value) {
                                        setState(() {
                                          selectionProveedor = value;
                                        });
                                      },
                                      showSearchBox: true,
                                      label: "SELECCIONE UN PROVEEDOR",
                                      popupTitle: Center(
                                          child: Text("LISTA DE PROVEEDORES")),
                                      popupItemBuilder:
                                          _customPopupItemBuilderProveedores,
                                      dropdownBuilder:
                                          selectionProveedor != null
                                              ? _customDropDownProveedores
                                              : null,
                                    );
                                  }
                                  return LoadingPage();
                                },
                              )
                            : DropdownSearch<ModelProveedores>(
                                emptyBuilder: (context, searchEntry) {
                                  return Center(
                                    child: Text("NO EXISTEN DATOS"),
                                  );
                                },
                                items: provList,
                                filterFn: (item, filter) {
                                  if (filter.isEmpty)
                                    return true;
                                  else {
                                    if (item.nombre
                                        .toLowerCase()
                                        .contains(filter.toLowerCase()))
                                      return true;
                                    else
                                      return false;
                                  }
                                },
                                selectedItem: selectionProveedor,
                                onChanged: (value) {
                                  setState(() {
                                    selectionProveedor = value;
                                  });
                                },
                                showSearchBox: true,
                                label: "SELECCIONE UN PROVEEDOR",
                                popupTitle:
                                    Center(child: Text("LISTA DE PROVEEDORES")),
                                popupItemBuilder:
                                    _customPopupItemBuilderProveedores,
                                dropdownBuilder: selectionProveedor != null
                                    ? _customDropDownProveedores
                                    : null,
                              );
                      },
                    ))
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Expanded(
                              flex: 10,
                              child: TextFormField(
                                onTap: () {
                                  if (ecFecVenc.text.isEmpty)
                                    _selectDateVencimiento(context);
                                  errorFecVencimiento = null;
                                },
                                onChanged: (value) {
                                  if (value.length == 10) {
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
                                              errorFecVencimiento = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorFecVencimiento =
                                                  "Fecha Invalida";
                                            });
                                          }
                                        } else if (int.parse(mes) % 2 == 0) {
                                          if (int.parse(day) > 0 &&
                                              int.parse(day) < 31) {
                                            setState(() {
                                              errorFecVencimiento = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorFecVencimiento =
                                                  "Fecha Invalida";
                                            });
                                          }
                                        } else {
                                          if (int.parse(day) > 0 &&
                                              int.parse(day) < 32) {
                                            setState(() {
                                              errorFecVencimiento = null;
                                            });
                                          } else {
                                            setState(() {
                                              errorFecVencimiento =
                                                  "Fecha Invalida";
                                            });
                                          }
                                        }
                                      } else {
                                        setState(() {
                                          errorFecVencimiento =
                                              "Fecha Invalida";
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        errorFecVencimiento = "Fecha Invalida";
                                      });
                                    }
                                  }
                                },
                                maxLength: 10,
                                controller: ecFecVenc,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "FECHA DE VENCIMIENTO",
                                    hintText: "Ejemplo: dd/mm/yyyy",
                                    counterText: "",
                                    errorText: errorFecVencimiento),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          flex: 1,
                          child: InkWell(
                            onTap: () {
                              _selectDateVencimiento(context);
                            },
                            child: Icon(Icons.date_range),
                          ),
                        )
                      ],
                    )),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                TextFormField(
                  onTap: () {
                    errorObs = null;
                  },
                  controller: ecObs,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "OBSERVACIONES",
                      errorText: errorObs,
                      errorStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * .006)),
                  onChanged: (value) {},
                ),
                SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      WidgetButtons(
                        color1: Colors.amberAccent,
                        color2: Colors.amber,
                        colorText: Colors.white,
                        txt: edit ? "CANCELAR" : "LIMPIAR",
                        func: () {
                          clean();
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      !edit
                          ? WidgetButtons(
                              color1: Colors.greenAccent,
                              color2: Colors.green,
                              colorText: Colors.white,
                              txt: "AGREGAR",
                              func: () {
                                if (validate()) {
                                  inventarioSelected.add(ModelInventario(
                                      cantidad: double.parse(ecCantidad.text),
                                      costo: double.parse(ecCostoTotal.text),
                                      costoUnitario:
                                          (double.parse(ecCostoTotal.text) /
                                              double.parse(ecCantidad.text)),
                                      factura: ecFactComp.text,
                                      lote: ecLote.text,
                                      codAlm: selectionAlmacen.codAlm,
                                      codProd: selectionItem.codigo,
                                      fecIngreso: ecFecIngreso.text,
                                      fecVencimiento: ecFecVenc.text,
                                      idProv: selectionProveedor.id,
                                      producto: selectionItem,
                                      proveedor: selectionProveedor,
                                      codigo: "in-000001",
                                      usuario: 1,
                                      unidad: selectionItem.titulo,
                                      fechaSistema:
                                          DateFormat("dd/MM/yyyy HH:mm")
                                              .format(DateTime.now()),
                                      recibo: ecRecibo.text,
                                      obs: ecObs.text));
                                  setState(() {
                                    expand = false;
                                    ecCantidad.text = "";
                                    ecCostoTotal.text = "";
                                    ecLote.text = "";
                                    ecFactComp.text = "";
                                    ecProv.text = "";
                                    ecFecVenc.text = "";
                                    // ecFecIngreso.text = "";
                                    errTxtCantidad = null;
                                    selectionItem = null;
                                    selectionProveedor = null;
                                    habilitado = false;
                                    provList.clear();
                                  });
                                }
                              },
                            )
                          : WidgetButtons(
                              color1: Colors.greenAccent,
                              color2: Colors.green,
                              colorText: Colors.white,
                              txt: "EDITAR",
                              func: () {
                                if (validate()) {
                                  inventarioSelected[
                                      inventarioSelected.indexOf(
                                          selectedEdit)] = ModelInventario(
                                      cantidad: double.parse(ecCantidad.text),
                                      costo: double.parse(ecCostoTotal.text),
                                      costoUnitario:
                                          (double.parse(ecCostoTotal.text) /
                                              double.parse(ecCantidad.text)),
                                      factura: ecFactComp.text,
                                      lote: ecLote.text,
                                      codAlm: selectionAlmacen.codAlm,
                                      codProd: selectionItem.codigo,
                                      fecIngreso: ecFecIngreso.text,
                                      fecVencimiento: ecFecVenc.text,
                                      idProv: selectionProveedor.id,
                                      producto: selectionItem,
                                      proveedor: selectionProveedor);
                                  setState(() {
                                    edit = false;
                                    expand = false;
                                    ecCantidad.text = "";
                                    ecCostoTotal.text = "";
                                    ecLote.text = "";
                                    ecFactComp.text = "";
                                    ecProv.text = "";
                                    ecFecVenc.text = "";
                                    // ecFecIngreso.text = "";
                                    errTxtCantidad = null;
                                    selectionItem = null;
                                    selectionProveedor = null;
                                    habilitado = false;
                                    provList.clear();
                                  });
                                }
                              },
                            ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool validate() {
    if (selectionAlmacen != null) {
      if (selectionItem != null) {
        if (ecFecIngreso.text.isNotEmpty && errorFecIngreso == null) {
          setState(() {
            errorFecIngreso = null;
          });
          if (ecCantidad.text.isNotEmpty && errTxtCantidad == null) {
            setState(() {
              errTxtCantidad = null;
            });
            if (ecCostoTotal.text.isNotEmpty && errTxtCostoTotal == null) {
              setState(() {
                errTxtCostoTotal = null;
              });
              if (ecLote.text.isNotEmpty && errTxtLote == null) {
                setState(() {
                  errTxtLote = null;
                });
                if (ecFactComp.text.isNotEmpty && errTxtFactura == null ||
                    ecRecibo.text.isNotEmpty) {
                  setState(() {
                    Toast.show("Requiere Una factura o Recibo", context,
                        duration: Toast.LENGTH_LONG);
                  });
                  if (selectionProveedor != null) {
                    if (ecFecVenc.text.isNotEmpty &&
                        errorFecVencimiento == null) {
                      return true;
                    } else {
                      setState(() {
                        errorFecVencimiento = "CAMPO REQUERIDO";
                      });
                      return false;
                    }
                  } else {
                    Toast.show("Seleccione un Proveedor".toUpperCase(), context,
                        duration: Toast.LENGTH_LONG);
                    return false;
                  }
                } else {
                  Toast.show("Requiere Una factura o Recibo", context,
                      duration: Toast.LENGTH_LONG);
                  return false;
                }
              } else {
                setState(() {
                  errTxtLote = "CAMPO REQUERIDO";
                });
                return false;
              }
            } else {
              setState(() {
                errTxtCostoTotal = "CAMPO REQUERIDO";
              });
              return false;
            }
          } else {
            setState(() {
              errTxtCantidad = "CAMPO REQUERIDO";
            });
            return false;
          }
        } else {
          setState(() {
            errorFecIngreso = "CAMPO REQUERIDO";
          });
          return false;
        }
      } else {
        Toast.show("Seleccione un Producto".toUpperCase(), context,
            duration: Toast.LENGTH_LONG);
        return false;
      }
    } else {
      Toast.show("Seleccione un Almacen".toUpperCase(), context,
          duration: Toast.LENGTH_LONG);
      return false;
    }
  }

  Future<void> _selectDateVencimiento(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      DateTime ndt = DateTime(picked.year + 2, picked.month, picked.day);
      ecFecVenc.text = DateFormat("dd/MM/yyyy").format(ndt);
    }
  }

  Future<void> _selectDateIngreso(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      ecFecIngreso.text = DateFormat("dd/MM/yyyy").format(picked);
    }
  }

  Widget _customDropDownProductos(
      BuildContext context, ModelItem item, String itemDesignation) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text(item.codigo),
        subtitle: Text(
          item.nombre.toString(),
        ),
      ),
    );
  }

  Widget _customPopupItemBuilderProductos(
      BuildContext context, ModelItem item, bool isSelected) {
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
        title: Text(item.codigo),
        subtitle: Text(item.nombre.toString()),
      ),
    );
  }

  Widget _customDropDownProveedores(
      BuildContext context, ModelProveedores item, String itemDesignation) {
    return Container(
      child: Text(item.nombre),
    );
  }

  Widget _customPopupItemBuilderProveedores(
      BuildContext context, ModelProveedores item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: Text(item.nombre),
    );
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

  Widget _customDropDownOC(
      BuildContext context, ModelOrdenCompra item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: item.codigo == null || item.codigo == ""
          ? Row(
              children: [
                Text("${item.id.toString()}"),
                SizedBox(
                  width: 5,
                ),
                Text("-"),
                SizedBox(
                  width: 5,
                ),
                Text("${item.codAlm}"),
                SizedBox(
                  width: 5,
                ),
                Text("-"),
                SizedBox(
                  width: 5,
                ),
                Text("${item.fecIngreso}"),
              ],
            )
          : Row(
              children: [
                Text("${item.codigo.toString()}"),
              ],
            ),
    );
  }

  Widget _customPopupItemBuilderOC(
      BuildContext context, ModelOrdenCompra item, bool isSelected) {
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
          child: item.codigo == null || item.codigo == ""
              ? Row(
                  children: [
                    Text("${item.id.toString()}"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("-"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("${item.codAlm}"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("-"),
                    SizedBox(
                      width: 5,
                    ),
                    Text("${item.fecIngreso}"),
                  ],
                )
              : Row(
                  children: [
                    Text("${item.codigo.toString()}"),
                  ],
                ),
        ));
  }

  sectorData() {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(.5, 10), blurRadius: 20)
          ]),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text(
                "LISTA DE PRODUCTOS",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              headerListCustom("Codigo", 1),
              headerListCustom("Producto", 2),
              headerListCustom("Unidad", 1),
              headerListCustom("lote", 1),
              headerListCustom("Cantidad", 1),
              headerListCustom("Costo Unitario [Bs/u]", 1),
              headerListCustom("Costo Total [Bs]", 1),
              headerListCustom("Vencimiento", 1),
              headerListCustom("Factura", 1),
              headerListCustom("Recibo", 1),
              headerListCustom("Proveedor", 2),
              headerListCustom("Acciones", 1)
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: inventarioSelected.map((e) {
                TextStyle style = TextStyle(fontSize: 12);
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              e.codProd,
                              style: style,
                            ))),
                        Expanded(
                            flex: 2,
                            child: Center(
                                child: Text(
                              e.producto.nombre,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              e.unidad,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              e.lote,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "${e.cantidad.toStringAsFixed(2)}",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "${e.costoUnitario.toStringAsFixed(2)}",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "${e.costo.toStringAsFixed(2)}",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              e.fecVencimiento,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              e.factura,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                                  e.recibo,
                                  style: style,
                                ))),
                        Expanded(
                            flex: 2,
                            child: Center(
                                child: Text(
                              e.proveedor.nombre,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      print(
                                          "${e.producto.toJson()}::${e.proveedor.toJson()}::${e.cantidad}::${e.costo}::${e.lote}"
                                          "::${e.factura}::${e.fecVencimiento}::${e.toJson()}");
                                      setState(() {
                                        provList.clear();
                                        selectionItem = e.producto;
                                        selectionProveedor = e.proveedor;
                                        // ecFecIngreso.text = e.fecIngreso;
                                        ecCantidad.text =
                                            e.cantidad.toStringAsFixed(2);
                                        ecCostoTotal.text =
                                            e.costo.toStringAsFixed(2);
                                        ecLote.text = e.lote;
                                        ecFactComp.text = e.factura;
                                        ecFecVenc.text = e.fecVencimiento;
                                        selectedEdit = e;
                                        edit = true;
                                      });
                                    },
                                    child: Icon(Icons.edit)),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        inventarioSelected.remove(e);
                                      });
                                    },
                                    child: Icon(Icons.delete_forever))
                              ],
                            )))
                      ],
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
            ),
          )
        ],
      ),
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
        Rect.fromLTWH(20, 20, 120, 40));

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
      'PÃ¡gina: 1 de 1',
      PdfStandardFont(PdfFontFamily.timesRoman, 10),
      bounds: Rect.fromLTWH((w3 * 2) + 35, ((80 / 4) * 3) + 5, 615, 20),
    );

    page.graphics.drawString(
      'COMPROBANTE DE INGRESO',
      PdfStandardFont(PdfFontFamily.timesRoman, 15),
      bounds: Rect.fromLTWH(w3 - 15, 40, 615, 20),
    );

    page.graphics.drawString(
        'CODIGO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 100, 200, 20));
    page.graphics.drawString(
        nombre, PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 100, 200, 20));
    page.graphics.drawString(
        'ALMACEN:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 120, 200, 20));
    page.graphics.drawString(
        '${selectionAlmacen.codAlm} - ${selectionAlmacen.name}',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 120, 200, 20));
    page.graphics.drawString(
        'GENERADO POR:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 140, 200, 20));
    page.graphics.drawString(
        'VICTOR MAMANI', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 140, 200, 20));
    page.graphics.drawString(
        'FECHA DE LLEGADA:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 160, 200, 20));
    page.graphics.drawString(
        '${ecFecIngreso.text}', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 160, 200, 20));
    page.graphics.drawString(
        'FECHA DE REGISTRO:', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(40, 180, 200, 20));
    page.graphics.drawString(DateFormat("dd/MM/yyyy").format(DateTime.now()),
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 180, 200, 20));

    page.graphics.drawString(
        'Firma Responsable de ingreso ________________________________',
        PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(w - 450, h - 60, 600, 20));

    PdfGrid grid = PdfGrid();

//Add the columns to the grid
    grid.columns.add(count: 10);

//Add header to the grid
    grid.headers.add(1);

//Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Codigo';
    header.cells[1].value = 'Descripcion';
    header.cells[2].value = 'Unid.';
    header.cells[3].value = 'Cantidad';
    header.cells[4].value = 'Costo Unitario [Bs/u]';
    header.cells[5].value = 'Lote';
    header.cells[6].value = 'Proveedor';
    header.cells[7].value = 'Venc.';
    header.cells[8].value = 'Nº Factura';
    header.cells[9].value = 'Nº Recibo';
    header.style = PdfGridRowStyle(
      backgroundBrush: PdfBrushes.cornflowerBlue,
      textBrush: PdfBrushes.white,
    );

    header.cells[0].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
    );
    header.cells[1].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[2].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[3].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[4].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[5].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[6].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[7].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[8].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);
    header.cells[9].stringFormat =
        PdfStringFormat(alignment: PdfTextAlignment.center);

    inventarioSelected.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = '${element.codProd}';
      row.cells[1].value = '${element.producto.nombre}';
      row.cells[2].value = '${element.unidad}';
      row.cells[3].value = '${element.cantidad.toStringAsFixed(2)}';
      row.cells[4].value = '${element.costoUnitario.toStringAsFixed(2)}';
      row.cells[5].value = '${element.lote}';
      row.cells[6].value = '${element.proveedor.nombre}';
      row.cells[7].value = '${element.fecVencimiento}';
      row.cells[8].value = '${element.factura}';
      row.cells[9].value = '${element.recibo}';

      row.cells[0].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[2].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[3].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[4].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[5].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[7].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[8].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);
      row.cells[9].stringFormat =
          PdfStringFormat(alignment: PdfTextAlignment.center);

      if (inventarioSelected.indexOf(element) % 2 == 0) {
        row.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.aliceBlue);
      } else {
        row.style = PdfGridRowStyle(backgroundBrush: PdfBrushes.white);
      }
    });
    grid.columns[1].width = 120;
    grid.columns[6].width = 100;

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 2, bottom: 1),
        backgroundBrush: PdfBrushes.aliceBlue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
        borderOverlapStyle: PdfBorderOverlapStyle.inside);

    grid.draw(page: page, bounds: const Rect.fromLTWH(0, 220, 0, 0));

    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, 0), Offset(w, 0));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, 0), Offset(w, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(w, h), Offset(0, h));
    page.graphics.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: .5), Offset(0, h), Offset(0, 0));

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() async {
      js.context.callMethod('download');
    });
  }

  void dispose() {
    super.dispose();
  }

  headerListCustom(String text, int flex) {
    return Expanded(
        flex: flex,
        child: Container(
            width: double.infinity,
            height: 50,
            color: Colors.black54,
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

  ordenCompraList() {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(.5, 10), blurRadius: 20)
          ]),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text(
                "ORDENES DE COMPRA",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )),
          FutureBuilder(
            future: ApiOrdenCompra().pendientes(0),
            builder: (context, snapshot) {
              if (snapshot.hasError) return SomethingWentWrongPage();
              if (snapshot.connectionState == ConnectionState.done) {
                orCoList = snapshot.data;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownSearch<ModelOrdenCompra>(
                    emptyBuilder: (context, searchEntry) {
                      return Center(
                        child: Text("NO EXISTEN DATOS"),
                      );
                    },
                    // enabled: habilitado,
                    items: orCoList,
                    selectedItem: selectionOC,
                    onChanged: (value) {
                      if (inventarioSelected.length > 0)
                        inventarioSelected.clear();
                      setState(() {
                        selectionOC = value;
                        habilitado = false;
                        almList.forEach((element) {
                          if (element.codAlm == value.codAlm)
                            selectionAlmacen = element;
                        });
                        List<ModelItem> prod = List();
                        ecFecIngreso.text = value.fecIngreso;
                        int id = value.id;
                        String fecIng = value.fecIngreso;
                        print(selectionAlmacen.ProdPermitidos);
                        ApiConnections().getItemsOrdenCompra(id).then((val) {
                          val.forEach((element1) {
                            print(element1.toJson());
                            ModelItem i;
                            ApiConnections()
                                .getItemsProdCodProd(element1.codProd)
                                .then((value) {
                              print(value.toJson());

                              ModelProveedores p;
                              provList.forEach((element) {
                                if (element.id == element1.proveedor) {
                                  p = element;
                                }
                              });
                              setState(() {
                                inventarioSelected.add(ModelInventario(
                                    producto: value,
                                    proveedor: p,
                                    fecIngreso: fecIng,
                                    codAlm: selectionAlmacen.codAlm,
                                    codigo: "",
                                    cantidad: element1.cantidad,
                                    codProd: element1.codProd,
                                    idProv: p.id,
                                    fecVencimiento: "",
                                    lote: "",
                                    factura: "",
                                    costoUnitario:
                                        element1.costoTotal / element1.cantidad,
                                    costo: element1.costoTotal,
                                    loteVenta: "",
                                    prorrateo: 0));
                              });
                            });
                          });
                          inventarioSelected.forEach((element) {
                            print(element.producto.toJson());
                          });
                        });
                      });
                    },
                    label: "SELECCIONE ORDEN",
                    popupTitle: Center(child: Text("LISTA DE ORDENES")),
                    popupItemBuilder: _customPopupItemBuilderOC,
                    dropdownBuilder:
                        selectionOC != null ? _customDropDownOC : null,
                  ),
                );
              }
              return LoadingPage();
            },
          )
        ],
      ),
    );
  }

  Future<void> _showDialog(String nombre) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('EXITO'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('EL INGRESO SE GENERO CORRECTAMENTE.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                clean();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                generatePdf(nombre);
              },
            ),
          ],
        );
      },
    );
  }
}
