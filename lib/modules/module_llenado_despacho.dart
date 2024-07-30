import 'package:andeanvalleysystem/models/model_despachos.dart';
import 'package:andeanvalleysystem/models/model_despachos_items.dart';
import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_historial.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_proformas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/show_dialog_lotes_selection.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ModuleLlenadoDespachos extends StatefulWidget {
  final ModelProforma proforma;
  final List<ModelProformaItems> items;
  final int idUser;
  final Function refreshAll;

  ModuleLlenadoDespachos(
      {Key key, this.proforma, this.items, this.idUser, this.refreshAll})
      : super(key: key);

  @override
  _ModuleLlenadoDespachosState createState() => _ModuleLlenadoDespachosState();
}

class _ModuleLlenadoDespachosState extends State<ModuleLlenadoDespachos> {
  TextEditingController ecFecSalida = TextEditingController();
  TextEditingController ecHrCarguio = TextEditingController();
  TextEditingController ecHrFinCarguio = TextEditingController();
  TextEditingController ecNFactura = TextEditingController();
  TextEditingController ecPlacaVehiculo = TextEditingController();
  TextEditingController ecTipoTransporte = TextEditingController();
  TextEditingController ecRespEntrega = TextEditingController();
  TextEditingController ecRespRecepcion = TextEditingController();
  TextEditingController ecObs = TextEditingController();
  TextEditingController ecFechaSalida = TextEditingController();
  String errFechaSalida=null;
  String fechaIniMandar="";
  double cantidadUsada = 0;
  String lotesUsados = "";
  StateSetter refreshList;
  Map<String,List<ModelLote>> lotesSelect = Map();
  List<ModelDespachosItems> itemsDespacho = List();

  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
    TextStyle style1 = TextStyle(fontSize: 13);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(widget.proforma.codigo),
      ),
      body: SingleChildScrollView(
        child: Container(
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
                    "DESPACHO",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  )),
              SizedBox(
                height: 10,
              ),
              Text("PEDIDO: ${widget.proforma.codigo}"),
              Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: TextFormField(
                        onTap: () {
                          if (ecFechaSalida.text.isEmpty)
                            _selectDateSalida(context);
                          errFechaSalida = null;
                        },
                        onChanged: (value) {
                          if (value.length == 10) {
                            errFechaSalida = null;
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
                                      errFechaSalida = null;
                                    });
                                  } else {
                                    setState(() {
                                      errFechaSalida = "Fecha Invalida";
                                    });
                                  }
                                } else if (int.parse(mes) % 2 == 0) {
                                  if (int.parse(day) > 0 &&
                                      int.parse(day) < 31) {
                                    setState(() {
                                      errFechaSalida = null;
                                    });
                                  } else {
                                    setState(() {
                                      errFechaSalida = "Fecha Invalida";
                                    });
                                  }
                                } else {
                                  if (int.parse(day) > 0 &&
                                      int.parse(day) < 32) {
                                    setState(() {
                                      errFechaSalida = null;
                                    });
                                  } else {
                                    setState(() {
                                      errFechaSalida = "Fecha Invalida";
                                    });
                                  }
                                }
                              } else {
                                setState(() {
                                  errFechaSalida = "Fecha Invalida";
                                });
                              }
                            } else {
                              setState(() {
                                errFechaSalida = "Fecha Invalida";
                              });
                            }
                          }
                        },
                        keyboardType: TextInputType.datetime,
                        maxLength: 10,
                        enabled: true,
                        controller: ecFechaSalida,
                        decoration: InputDecoration(
                            errorText: errFechaSalida,
                            border: OutlineInputBorder(),
                            labelText: "FECHA SALIDA",
                            hintText: "Ejemplo: dd/mm/yyyy",
                            counterText: ""),
                      )),
                  Expanded(
                      flex: 1,
                      child: TextBoxCustom(
                        hint: "HORA INICIO DE CARGUIO",
                        controller: ecHrCarguio,
                        onChange: (val){},
                      )),
                  Expanded(
                      flex: 1,
                      child: TextBoxCustom(
                        hint: "HORA FIN DE CARGUIO",
                        controller: ecHrFinCarguio,
                        onChange: (val){},
                      )),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextBoxCustom(
                      hint: "NUMERO DE FACTURA",
                      controller: ecNFactura,
                      onChange: (val){},
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextBoxCustom(
                      hint: "PLACA DE VEHICULO",
                      controller: ecPlacaVehiculo,
                      onChange: (val){},
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextBoxCustom(
                      hint: "TIPO DE TRANSPORTE",
                      controller: ecTipoTransporte,
                      onChange: (val){},
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextBoxCustom(
                      hint: "RESPONSABLE DE ENTREGA",
                      controller: ecRespEntrega,
                      onChange: (val){},
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextBoxCustom(
                      hint: "RESPONSABLE DE RECEPCION",
                      controller: ecRespRecepcion,
                      onChange: (val){},
                    ),
                  ),
                ],
              ),
              TextBoxCustom(
                hint: "OBSERVACIONES",
                controller: ecObs,
                onChange: (val){},
              ),
              SizedBox(
                height: 10,
              ),
              StatefulBuilder(builder: (context, setState) {
                refreshList = setState;
                return ListCustom(
                  modelHeaderList: [
                    ModelHeaderList(title: "CODIGO", flex: 1),
                    ModelHeaderList(title: "PRODUCTO", flex: 3),
                    ModelHeaderList(title: "UNIDAD", flex: 1),
                    ModelHeaderList(title: "CANTIDAD PEDIDO", flex: 1),
                    ModelHeaderList(title: "CANTIDAD USADA", flex: 1),
                    ModelHeaderList(title: "LOTE", flex: 1),
                    ModelHeaderList(title: "FEC. VENC.", flex: 1),
                  ],
                  title: "PRODUCTOS",
                  datos: widget.items.map((e) {
                    return Column(
                      children: [
                        InkWell(
                          onTap: () {
                            ModelInventario mi =
                                ModelInventario(codProd: e.codProd);
                            UtilsDialog(context: context)
                                // ignore: missing_return
                                .showDialog2(mi, 401, e.codProd, (val, lotes) {
                              refreshList(() {
                                e.lotesUsados = "";
                                e.cantidadUsada = 0;
                                if(lotesSelect.containsKey(val.codProd))
                                  lotesSelect[val.codProd].clear();
                                else lotesSelect[val.codProd] = List();
                                lotes.forEach((element) {
                                  if(element.cantidadUsada!=null && element.cantidadUsada>0){
                                    e.cantidadUsada = val.cantidadTotalLotes;
                                    e.lotesUsados += "${element.lote},";
                                    e.fecVenc = element.fecVencimiento;
                                    lotesSelect[val.codProd].add(element);
                                  }
                                });
                                print("size loteselect::${lotesSelect.length}");
                              });
                            });
                          },
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.codProd,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Text(
                                    e.nameProd,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.unidad,
                                    textAlign: TextAlign.center,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    NumberFunctions.formatNumber(e.cantidad, 3),
                                    textAlign: TextAlign.center,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    NumberFunctions.formatNumber(
                                        e.cantidadUsada, 2),
                                    textAlign: TextAlign.center,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.lotesUsados,
                                    style: style1,
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    e.fecVenc,
                                    style: style1,
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          height: 1,
                          color: Colors.grey,
                        )
                      ],
                    );
                  }).toList(),
                );
              }),
              WidgetButtons(
                txt: "ENTREGAR",
                colorText: Colors.white,
                func: () {
                  bool act = true;
                  widget.items.forEach((element) {
                    if (element.cantidadUsada != element.cantidad) act = false;
                  });

                  if (ecFechaSalida.text.isNotEmpty) {
                    if (ecHrCarguio.text.isNotEmpty) {
                      if (ecPlacaVehiculo.text.isNotEmpty) {
                        if (ecRespEntrega.text.isNotEmpty) {
                          if (ecRespRecepcion.text.isNotEmpty) {
                            if (act) {
                              double cant = 0;
                              double mont = 0;
                              String cantUs = "";
                              String lotesUs = "";
                              widget.items.forEach((element) {
                                cant += element.cantidad;
                                mont += element.cantidad * element.precio;
                                cantUs += "${element.cantidadUsada},";
                                lotesUs += "${element.lotesUsados}";
                              });
                              ModelDespachos md = ModelDespachos(
                                  idProforma: widget.proforma.id,
                                  codigo: widget.proforma.codigo,
                                  cliente: widget.proforma.id_cliente,
                                  subCliente: widget.proforma.id_subcliente,
                                  cantidad: cant,
                                  costoTotal: mont,
                                  idUsr: widget.idUser,
                                  fecDespacho: DateFormat('yyyy-MM-dd')
                                      .format(DateTime.now()),
                                  lote: widget.proforma.codigo,
                                  obs: ecObs.text,
                                  fecSalida: ecFechaSalida.text,
                                  hrCarguio: ecHrCarguio.text,
                                  hrCarguioFin: ecHrFinCarguio.text,
                                  numFactura: ecNFactura.text,
                                  placaVehiculo: ecPlacaVehiculo.text,
                                  tipoTransporte: ecTipoTransporte.text,
                                  respEntrega: ecRespEntrega.text,
                                  respRecepcion: ecRespRecepcion.text,
                                  cantUsada: cantUs,
                                  lotes: lotesUs);
                              ApiProformas().despachar(md).then((despacho){
                                int desId = despacho.id;
                                widget.items.map((e){
                                  lotesSelect[e.codProd].forEach((v){
                                    itemsDespacho.add(ModelDespachosItems(
                                      idDespacho: despacho.id,
                                      codProd: e.codProd,
                                      producto: e.nameProd,
                                      cantidad: v.cantidadUsada,
                                      costoProd: v.costoUnit,
                                      costoTotal: v.cantidadUsada * v.costoUnit,
                                      fechaVencimiento: v.fecVencimiento,
                                      idUnidad: e.unidad,
                                      loteProd: v.lote,
                                      loteVent: despacho.lote,
                                      pesoNetoTotal: e.pesoNeto * v.cantidadUsada
                                    ));
                                  });
                                }).toList();
                                print("itemsDespacho::${itemsDespacho.map((e) => e.toJson()).toList()}");
                                ApiProformas().despacharItems(itemsDespacho, context).whenComplete((){
                                  List<ModelHistorialKardex> mhk = List();
                                  // ignore: missing_return
                                  widget.items.map((value){
                                    print(lotesSelect[value.codProd].map((e) => e.toJson()).toList());
                                    ApiInventory().discountInventory(lotesSelect[value.codProd], 401, value.codProd);
                                    lotesSelect[value.codProd].forEach((element) {
                                      mhk.add(ModelHistorialKardex(
                                          idReg: widget.proforma.codigo,
                                          codProd: value.codProd,
                                          lote: element.lote,
                                          cantidad: value.cantidadUsada * (-1),
                                          costo: (value.cantidadUsada *
                                              element.costoUnit) * (-1),
                                          usuario: widget.idUser,
                                          codAlm: 401,
                                          costoUnitario: element.costoUnit,
                                          accion: "DESPACHO",
                                          prorrateo: element.costoUnit,
                                          saldo: 0,
                                          saldoCosto: 0,
                                          created_at: DateFormat("yyyy-MM-dd")
                                              .format(DateTime.now())
                                      ));
                                    });
                                  }).toList();
                                  print("datos historial::${mhk.map((e) => e.toJson()).toList()}");
                                  ApiHistorial().createHistorial(mhk).whenComplete((){
                                    widget.refreshAll(() {
                                      String nameString = widget.proforma.codigo.replaceAll('/', '-');
                                      js.context.callMethod('open', ['${ApiConnections().url}pdf/generateDespacho/${desId}/$nameString']);
                                      Toast.show("PEDIDO DESPACHADO", context);
                                      Navigator.of(context).pop();
                                    });
                                  });
                                });
                              });
                            } else
                              Toast.show("CANTIDADES NO COINCIDEN", context);
                          } else
                            Toast.show(
                                "NECESITA RESPONSABLE DE RECEPCION", context);
                        } else
                          Toast.show("NECESITA RESPONSABLE DE ENTREGA", context);
                      } else
                        Toast.show("NECESITA PLACA DE VEHICULO", context);
                    } else
                      Toast.show("NECESITA HORA DE SALIDA", context);
                  }
                  else
                    Toast.show("NECESITA FECHA DE SALIDA", context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateSalida(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: new DateTime(2020),
      lastDate: new DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ecFechaSalida.text = DateFormat("dd/MM/yyyy").format(picked);
        fechaIniMandar = DateFormat("yyyy-MM-dd").format(picked);
      });
    }
  }

  tapExecute(ModelProforma p, List<ModelProformaItems> items) {}
}
