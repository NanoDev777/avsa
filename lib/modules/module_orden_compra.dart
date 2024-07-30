
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_reserva_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';

class ModuleOrdenCompra extends StatefulWidget {
  @override
  _ModuleOrdenCompraState createState() => _ModuleOrdenCompraState();
}

class _ModuleOrdenCompraState extends State<ModuleOrdenCompra> {
  TextEditingController ecCantidad = TextEditingController();
  TextEditingController ecCostoTotal = TextEditingController();
  TextEditingController ecLote = TextEditingController();
  TextEditingController ecFactComp = TextEditingController();
  TextEditingController ecProv = TextEditingController();
  TextEditingController ecFecVenc = TextEditingController();
  TextEditingController ecFecIngreso = TextEditingController();
  TextEditingController ecCodigo = TextEditingController();
  bool habilitado = true;
  bool edit = false;
  bool isProcessing = false;
  ModelItem selectionItem;
  ModelAlmacenes selectionAlmacen;
  ModelProveedores selectionProveedor;

  List<ModelProveedores> provList = List();
  List<ModelItem> prodList = List();
  List<ModelAlmacenes> almList = List();
  List<ModelReservaOrdenCompra> resList = List();

  String errTxtCantidad = null;
  String errTxtCostoTotal = null;
  String errTxtLote = null;
  String errTxtFactura = null;
  String errorFecIngreso = null;
  String errorFecVencimiento = null;
  ModelReservaOrdenCompra selectedEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            fillingData(),
            sectorData(),
            WidgetButtons(
              color1: Colors.greenAccent,
              color2: Colors.green,
              colorText: Colors.white,
              txt: "GENERAR ORDEN",
              func: !isProcessing ? () {
                setState(() {
                  isProcessing = true;
                  ModelOrdenCompra m = ModelOrdenCompra(
                    codigo: ecCodigo.text,
                    codAlm: selectionAlmacen.codAlm,
                    usrReg: 10,
                    fecIngreso: ecFecIngreso.text,
                    estado: 0,
                    fecReg: DateFormat('dd/MM/yyyy')
                        .format(DateTime.now())
                        .toString(),
                    inventario: resList);
                  ApiConnections().enviarOrdenCompra(m).then((value) {
                    if (value!=null) {
                      _showMyDialog(value, ecCodigo.text);
                      clean();
                    }
                  });
                });
              } : null,
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  void clean() {
    setState(() {
      ecCodigo.text = "";
      ecCantidad.text = "";
      ecCostoTotal.text = "";
      ecLote.text = "";
      ecFactComp.text = "";
      ecProv.text = "";
      ecFecVenc.text = "";
      ecFecIngreso.text = "";
      errTxtCantidad = null;
      selectionItem = null;
      selectionAlmacen = null;
      selectionProveedor = null;
      habilitado = true;
      resList.clear();
      edit = false;
      isProcessing = false;
      provList.clear();
      prodList.clear();
      almList.clear();
    });
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
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextFormField(
                      enabled: habilitado,
                      controller: ecCodigo,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "REFERENCIA",
                          hintText: "REFERENCIA",
                          counterText: ""),
                    );
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Column(
                  children: [
                    almList.length < 1
                        ? FutureBuilder<List<ModelAlmacenes>>(
                            future: Constant().getAlmacenes(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) SomethingWentWrongPage();
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                almList = snapshot.data;
                                if(almList.length==1)
                                  selectionAlmacen=almList[0];
                                // List<ModelAlmacenes> items = snapshot.data;
                                return DropdownSearch<ModelAlmacenes>(
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
                                );
                              }
                              return LoadingPage();
                            },
                          )
                        : DropdownSearch<ModelAlmacenes>(
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
                        if (snapshot.connectionState == ConnectionState.done) {
                          prodList = snapshot.data;
                          List<ModelItem> items = snapshot.data;
                          return DropdownSearch<ModelItem>(
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
                            popupItemBuilder: _customPopupItemBuilderProductos,
                            dropdownBuilder: selectionItem != null
                                ? _customDropDownProductos
                                : null,
                          );
                        }
                        return LoadingPage();
                      },
                    ),
                  ],
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
                      width: 20,
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
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
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
                          // clean();
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
                                resList.add(ModelReservaOrdenCompra(
                                    codProd: selectionItem.codigo,
                                    cantidad: double.parse(ecCantidad.text),
                                    costoTotal: double.parse(ecCostoTotal.text),
                                    proveedor: selectionProveedor.id,
                                    item: selectionItem,
                                    prov: selectionProveedor));
                                setState(() {
                                  ecCantidad.text = "";
                                  ecCostoTotal.text = "";
                                  ecLote.text = "";
                                  ecFactComp.text = "";
                                  ecProv.text = "";
                                  ecFecVenc.text = "";
                                  errTxtCantidad = null;
                                  selectionItem = null;
                                  selectionProveedor = null;
                                  habilitado = false;
                                  provList.clear();
                                });
                              },
                            )
                          : WidgetButtons(
                              color1: Colors.greenAccent,
                              color2: Colors.green,
                              colorText: Colors.white,
                              txt: "EDITAR",
                              func: () {
                                if (validate()) {
                                  resList[resList.indexOf(selectedEdit)] =
                                      ModelReservaOrdenCompra(
                                          codProd: selectionItem.codigo,
                                          cantidad:
                                              double.parse(ecCantidad.text),
                                          costoTotal:
                                              double.parse(ecCostoTotal.text),
                                          proveedor: selectionProveedor.id,
                                          item: selectionItem,
                                          prov: selectionProveedor);
                                  setState(() {
                                    edit = false;
                                    ecCantidad.text = "";
                                    ecCostoTotal.text = "";
                                    ecProv.text = "";
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
          ),
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
              if (selectionProveedor != null) {
                return true;
              } else {
                Toast.show("Seleccione un Proveedor".toUpperCase(), context,
                    duration: Toast.LENGTH_LONG);
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
              headerListCustom("Proveedor", 2),
              headerListCustom("Acciones", 1)
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: resList.map((e) {
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
                              e.item.nombre,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "Kg",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "n/a",
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
                              "${(e.costoTotal / e.cantidad).toStringAsFixed(2)}",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "${e.costoTotal.toStringAsFixed(2)}",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "n/a",
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Text(
                              "n/a",
                              style: style,
                            ))),
                        Expanded(
                            flex: 2,
                            child: Center(
                                child: Text(
                              e.prov.nombre,
                              style: style,
                            ))),
                        Expanded(
                            flex: 1,
                            child: Center(
                                child: Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedEdit = e;
                                        edit = true;
                                        selectionItem = e.item;
                                        selectionProveedor = e.prov;
                                        ecCantidad.text =
                                            e.cantidad.toStringAsFixed(2);
                                        ecCostoTotal.text =
                                            e.costoTotal.toStringAsFixed(2);
                                      });
                                    },
                                    child: Icon(Icons.edit)),
                                InkWell(
                                    onTap: () {
                                      setState(() {
                                        resList.remove(e);
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

  Future generatePdf() async {
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;
    PdfPage page = document.pages.add();
    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
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
      'Página: 1 de 1',
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
        'IN-0025', PdfStandardFont(PdfFontFamily.timesRoman, 11),
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
    page.graphics.drawString(
        '20/01/2021', PdfStandardFont(PdfFontFamily.timesRoman, 11),
        bounds: Rect.fromLTWH(200, 180, 200, 20));

    PdfGrid grid = PdfGrid();

//Add the columns to the grid
    grid.columns.add(count: 9);

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

    resList.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = '${element.codProd}';
      row.cells[1].value = '${element.item.nombre}';
      row.cells[2].value = 'Kg';
      row.cells[3].value = '${element.cantidad.toStringAsFixed(2)}';
      row.cells[4].value =
          '${(element.costoTotal * element.cantidad).toStringAsFixed(2)}';
      row.cells[5].value = 'n/a';
      row.cells[6].value = '${element.prov.nombre}';
      row.cells[7].value = 'n/a';
      row.cells[8].value = 'n/a';

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

      if (resList.indexOf(element) % 2 == 0) {
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
    js.context['filename'] = 'Output.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });

    // clean();

    // html.AnchorElement(
    //     href:
    //     "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
    //   ..setAttribute("download", "output.pdf")
    //   ..click();
  }

  headerListCustom(String text, int flex) {
    return Expanded(
        flex: flex,
        child: Container(
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
            )));
  }
  Future<void> _showMyDialog(int id, String codigo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Se creo la Orden de Compra Nº $id'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ref:$codigo.'),
              ],
            ),
          ),
          actions: <Widget>[
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
}
