import 'dart:convert';

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/models/model_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/models/model_transferencia.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_historial.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/connections/api_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/utils/connections/api_transferencias.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/utils/dialogs/select_lotes_dialog.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down_almacenes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:andeanvalleysystem/widgets/drop_down_usuarios.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/show_dialog_lotes_selection.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class ModuleTransferencias extends StatefulWidget {
  final int selection;

  ModuleTransferencias({Key key,this.selection}):super(key: key);

  @override
  _ModuleTransferenciasState createState() => _ModuleTransferenciasState();
}

class _ModuleTransferenciasState extends State<ModuleTransferencias> {
  List<String> subModulos = [
    "REALIZAR TRANSFERENCIA",
    "SOLICITAR TRANSFERENCIA",
    "SOLICITAR TRANSFERENCIA A PARTIR DE PROCESO",
    "TRANSFERENCIA PENDIENTE",
    // "REPORTE TRANSFERENCIA"
  ];
  bool loading = false;
  bool firstClick=false;

  bool reClick = false;
  bool acClick = false;

  int userID;
  List<ModelItem> todosProductos = List();
  List<ModelAlmacenes> todosAlmacenes = List();
  List<ModelAlmacenes> almacenesPropios = List();
  List<ModelAlmacenes> almacenesEnvio = List();
  TextEditingController ecCantidad = TextEditingController();
  TextEditingController ecComentario = TextEditingController();
  int subModuloSeleccion = -1;

  ModelReservaItemsProcProd reservaItems = ModelReservaItemsProcProd();

  List<ModelInventario> listaProductosSeleccionados = List();
  ModelAlmacenes almacenOrigenSeleccionado;
  ModelAlmacenes almacenDestinoSeleccionado;
  ModelUser userSelect;
  ModelItem productoSeleccionado;
  bool seleccionAlmacenActivo = true;
  bool seleccionProductoActivo = true;
  StateSetter refreshProductos;
  StateSetter refreshLista;
  StateSetter refreshDatos;

  String titleButton = "AGREGAR PRODUCTO";

  int indexProductoSeleccionado;

  ScrollController scroll = ScrollController();
  ScrollController scroll2 = ScrollController();
  ScrollController scroll3 = ScrollController();
  StateSetter _listaPendientes;
  StateSetter _refreshAll;

  List<String> almacen=List();

  Future<bool> getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    userID = sp.getInt("sessionID");
    String s;
    s = sp.getString("almacenes");
    almacen = s.split(',').toList();
    todosAlmacenes = await Constant().getAlmacenes();
  }

  Future getInitData()async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    userID = sp.getInt("sessionID");
    String s;
    s = sp.getString("almacenes");
    almacen = s.split(',').toList();
    Constant().getAlmacenes().then((value){
      todosAlmacenes = value;
    });
  }

  @override
  void initState() {
    // getData();


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _refreshAll = setState;
    return Scaffold(
      body: FutureBuilder(
        future: getInitData(),
        builder: (context, snapshot) {
          if(snapshot.hasError)
            return SomethingWentWrongPage();
          if(snapshot.connectionState==ConnectionState.done){
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height,
                  child: Image.asset("assets/images/fondo2.png", fit: BoxFit.fill,),
                ),
                Column(
                  children: [
                    widget.selection == 0
                        ? Expanded(child: realizarTransferencia())
                        : Container(),
                    widget.selection == 1
                        ? Expanded(child: solicitarTransferencia())
                        : Container(),
                    widget.selection == 2
                        ? Expanded(child: solicitarTransferenciaProceso())
                        : Container(),
                    widget.selection == 3
                        ? Expanded(child: transferenciasPendientes())
                        : Container(),
                    // subModuloSeleccion == 4?Expanded(child: realizarTransferencia()):Container()
                  ],
                ),
              ],
            );
          }
          return LoadingPage();
        },
      )
    );
  }

  clear() {
    setState(() {
      if (listaProductosSeleccionados.length > 0)
        seleccionAlmacenActivo = false;
      productoSeleccionado = null;
      ecCantidad.text = "";
      firstClick=false;
      reClick=false;
      acClick=false;
    });
  }

  clearAll() {
    setState(() {
      almacenOrigenSeleccionado = null;
      userSelect = null;
      almacenDestinoSeleccionado = null;
      productoSeleccionado = null;
      ecCantidad.text = "";
      ecComentario.text="";
      seleccionAlmacenActivo = true;
      seleccionProductoActivo = true;
      listaProductosSeleccionados.clear();
      firstClick=false;
      reClick=false;
      acClick=false;
    });
  }

  solicitarTransferencia() {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return SomethingWentWrongPage();
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    refreshDatos = setState;
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.all(10),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              width: double.infinity,
                              color: Theme.of(context).secondaryHeaderColor,
                              child: Text(
                                "SOLICITAR TRANSFERENCIA",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                          DropDownAlmacenes(
                            selectionAlmacen: almacenDestinoSeleccionado,
                            label: "SELECCIONES ALMACEN DE DESTINO",
                            soloPropios: true,
                            enabled: seleccionAlmacenActivo,
                            refresh: (ModelAlmacenes a) {
                              setState(() {
                                almacenDestinoSeleccionado = a;
                              });
                            },
                          ),
                          DropDownUsuarios(
                            userSelection: userSelect,
                            label: "SELECCIONES UN USUARIO",
                            enabled: seleccionAlmacenActivo,
                            refresh: (ModelUser a) {
                              refreshDatos(() {
                                userSelect = a;
                              });
                            },
                          ),
                          DropDownProductos(
                              selectionAlmacen: almacenDestinoSeleccionado,
                              selectionItem: productoSeleccionado,
                              enabled: seleccionProductoActivo,
                              func: (ModelItem i) {
                                refreshDatos(() {
                                  productoSeleccionado = i;
                                });
                              }),
                          // StatefulBuilder(builder: (context, setState) {
                          //   refreshProductos = setState;
                          //   return DropDownProductos(selectionAlmacen: almacenSeleccionado, selectionItem: productoSeleccionado, enabled: seleccionProductoActivo, func: (ModelItem i){
                          //     productoSeleccionado = i;
                          //   });
                          // },),
                          TextBoxCustom(
                              controller: ecCantidad,
                              hint: "CANTIDAD REQUERIDA"),
                          WidgetButtons(
                              txt: titleButton,
                              color1: Colors.green,
                              color2: Colors.lightGreenAccent,
                              colorText: Colors.white,
                              func: () {
                                if (titleButton == "ACTUALIZAR") {
                                  seleccionAlmacenActivo = true;
                                  seleccionProductoActivo = true;
                                  titleButton = "AGREGAR PRODUCTO";
                                  listaProductosSeleccionados[
                                          indexProductoSeleccionado]
                                      .cantidad = double.parse(ecCantidad.text);
                                  clear();
                                } else {
                                  if (almacenDestinoSeleccionado != null) {
                                    if (productoSeleccionado != null) {
                                      if (ecCantidad.text.isNotEmpty) {
                                        bool exist = false;
                                        listaProductosSeleccionados
                                            .forEach((element) {
                                          if (element.codProd ==
                                              productoSeleccionado.codigo)
                                            exist = true;
                                        });
                                        if (!exist) {
                                          listaProductosSeleccionados.add(
                                              ModelInventario(
                                                  codAlm:
                                                      almacenDestinoSeleccionado
                                                          .codAlm,
                                                  codProd: productoSeleccionado
                                                      .codigo,
                                                  nombre: productoSeleccionado
                                                      .nombre,
                                                  cantidad: double.parse(
                                                      ecCantidad.text),
                                                  prodSelect:
                                                      productoSeleccionado
                                              ));
                                          clear();
                                        } else
                                          Toast.show("ESTE PRODUCTO YA EXISTE",
                                              context,
                                              duration: Toast.LENGTH_LONG);
                                      } else
                                        Toast.show(
                                            "SE REQUIERE UNA CANTIDAD", context,
                                            duration: Toast.LENGTH_LONG);
                                    } else
                                      Toast.show(
                                          "SE REQUIERE UN PRODUCTO", context,
                                          duration: Toast.LENGTH_LONG);
                                  } else
                                    Toast.show(
                                        "SE REQUIERE UN ALMACEN", context,
                                        duration: Toast.LENGTH_LONG);
                                }
                              }),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    refreshLista = setState;
                    return ListCustom(
                      modelHeaderList: [
                        ModelHeaderList(title: "Codigo", flex: 1),
                        ModelHeaderList(title: "Producto", flex: 3),
                        ModelHeaderList(title: "Cantidad", flex: 1),
                        ModelHeaderList(title: "Unidad", flex: 1),
                        ModelHeaderList(title: "Acciones", flex: 1),
                      ],
                      title: "PRODUCTOS SOLICITADOS",
                      datos: listaProductosSeleccionados.map((e) {
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
                                    flex: 3,
                                    child: Center(
                                        child: Text(
                                      e.nombre,
                                      style: style,
                                    ))),
                                Expanded(
                                    flex: 1,
                                    child: Center(
                                        child: Text(
                                      "${e.cantidad.toStringAsFixed(3)}",
                                      style: style,
                                    ))),
                                Expanded(
                                    flex: 1,
                                    child: Center(
                                        child: Text(
                                      "${e.prodSelect.titulo}",
                                      style: style,
                                    ))),
                                Expanded(
                                    flex: 1,
                                    child: Center(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              refreshDatos(() {
                                                ecCantidad.text = e.cantidad
                                                    .toStringAsFixed(3);
                                                titleButton = "ACTUALIZAR";
                                                seleccionAlmacenActivo = false;
                                                seleccionProductoActivo = false;
                                                productoSeleccionado =
                                                    e.prodSelect;
                                                indexProductoSeleccionado =
                                                    listaProductosSeleccionados
                                                        .indexOf(e);
                                              });
                                            },
                                            child: Icon(Icons.edit)),
                                        InkWell(
                                            onTap: () {
                                              refreshLista(() {
                                                listaProductosSeleccionados
                                                    .remove(e);
                                              });
                                            },
                                            child: Icon(Icons.delete_forever))
                                      ],
                                    ))),
                              ],
                            ),
                            Divider()
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    refreshDatos = setState;
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.all(10),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              width: double.infinity,
                              color: Theme.of(context).secondaryHeaderColor,
                              child: Text(
                                "COMENTARIO",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                          TextBoxCustom(controller: ecComentario, hint: ""),
                        ],
                      ),
                    );
                  },
                ),
                WidgetButtons(
                    txt: "SOLICITAR TRANSFERENCIA",
                    color1: Colors.green,
                    color2: Colors.lightGreenAccent,
                    colorText: Colors.white,
                    func: () {
                      ApiSolicitudTransferencia().count().then((value) {
                        String codTransfer =
                            "ST-${(value + 1).toString().padLeft(5, '0')}";
                        if (listaProductosSeleccionados.length > 0) {
                          List<ModelSolicitudTransferencia> listMST = List();
                          listaProductosSeleccionados.forEach((element) {
                            listMST.add(ModelSolicitudTransferencia(
                              cantidad: element.cantidad,
                              codProd: element.prodSelect.codigo,
                              estado: 0,
                              usrReg: userID,
                              usrPet: userSelect.id,
                              almDestino: almacenDestinoSeleccionado.codAlm,
                              fechaReg: DateFormat("dd/MM/yyyy")
                                  .format(DateTime.now()),
                              codTransferencia: codTransfer,
                              comentario: ecComentario.text
                            ));
                          });
                          ApiSolicitudTransferencia()
                              .make(listMST)
                              .whenComplete(() {
                            _showDialog(
                                "SE SOLICITARON ${listaProductosSeleccionados.length} PRODUCTOS CORRECTAMENTE.");
                          }).catchError((e) {
                            Toast.show("ERROR EN SOLICITUD", context);
                          });
                        } else
                          Toast.show("NO HAY PRODUCTOS PARA SOLICITAR", context,
                              duration: Toast.LENGTH_LONG);
                      });
                    })
              ],
            );
          }
          return LoadingPage();
        },
      ),
    );
  }

  solicitarTransferenciaProceso() {
    return FutureBuilder<List<ModelProcesoProduccion>>(
      future: Constant().getProcProdPendientes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return SomethingWentWrongPage();
        if (snapshot.connectionState == ConnectionState.done) {
          TextStyle style = TextStyle(fontSize: 12);
          List<ModelProcesoProduccion> pp = snapshot.data;
          List<ModelProcesoProduccion> ppFilter = snapshot.data;
          return Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.all(10),
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
                      color: Theme.of(context).secondaryHeaderColor,
                      child: Text(
                        "LISTA PROCESO DE PRODUCCION PENDIENTE",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )),
                  Container(
                      width: double.infinity,
                      height: 50,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueGrey, width: .5),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                            hintText: "Buscar Lote de Produccion"),
                        onChanged: (value) {
                          // stateList(() {
                          //   ppFilter = pp.where((element) => element.loteProd.contains(value)).toList();
                          // });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        headerListCustom("Fecha Registro", 1, () {}),
                        headerListCustom("Lote Proceso", 1, () {}),
                        headerListCustom("Cantidad", 1, () {}),
                        headerListCustom("Producto", 4, () {}),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 8, bottom: 8, right: 8),
                      // height: MediaQuery.of(context).size.height-300,
                      child: Scrollbar(
                        controller: scroll,
                        isAlwaysShown: true,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            // stateList = setState;
                            return ListView.builder(
                              controller: scroll,
                              itemCount: ppFilter.length,
                              itemBuilder: (context, index) {
                                ModelProcesoProduccion e = ppFilter[index];
                                return InkWell(
                                  onTap: () {
                                    _showDialogIng(e);
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
                                              DateFormat("dd/MM/yyyy").format(
                                                  DateTime.parse(e.createAt)),
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
                                              e.loteProd,
                                              style: style,
                                            ))),
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: Colors.blueGrey,
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                e.cantidad.toStringAsFixed(2),
                                                style: style,
                                              ),
                                            )),
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: Colors.blueGrey,
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: Center(
                                                child: Text(
                                              e.nombreProducto,
                                              style: style,
                                            ))),
                                        Container(
                                          width: 1,
                                          height: 20,
                                          color: Colors.blueGrey,
                                        ),
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
                          },
                        ),
                      ),
                    ),
                  )
                  // SingleChildScrollView(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: Column(
                  //       children: pp.map((e){
                  //
                  //       }).toList(),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          );
        }
        return LoadingPage();
      },
    );
  }

  List<bool> solicitud = List();
  List<TextEditingController> controllers = List();
  List<ModelIngredientesFormulas> inIng = List();
  List<ModelIngredientesFormulas> outIng = List();

  Future<void> _showDialogIng(ModelProcesoProduccion pp) async {
    solicitud.clear();
    controllers.clear();
    inIng.clear();
    outIng.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Detalles Transferencia"),
              content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: FutureBuilder<List<ModelIngredientesFormulas>>(
                    future: ApiProcesosProduccion().getIngredientes(pp.id),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return SomethingWentWrongPage();
                      if (snapshot.connectionState == ConnectionState.done) {
                        List<ModelIngredientesFormulas> invDetalle =
                            snapshot.data;
                        if (inIng.length == 0) {
                          invDetalle.forEach((e) {
                            if (e.tipo == 0) {
                              inIng.add(e);
                            } else {
                              outIng.add(e);
                            }
                          });
                        }
                        if (solicitud.length == 0) {
                          inIng.forEach((e) {
                            solicitud.add(true);
                          });
                        }
                        if (controllers.length == 0) {
                          inIng.forEach((e) {
                            TextEditingController tec = TextEditingController();
                            tec.text = ((pp.cantidad * e.cantProd) /
                                    outIng[0].cantProd)
                                .toStringAsFixed(2);
                            controllers.add(tec);
                          });
                        }
                        return Column(
                          children: [
                            Expanded(flex:2,child: DropDownUsuarios(userSelection: userSelect,refresh: (ModelUser u){
                              userSelect = u;
                            },)),
                            Expanded(
                              flex: 9,
                              child: ListView.separated(
                                itemCount: inIng.length,
                                separatorBuilder: (context, index) => Divider(),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: Checkbox(
                                            value: solicitud[index],
                                            onChanged: (value) {
                                              setState(() {
                                                solicitud[index] = value;
                                              });
                                            },
                                          )),
                                      Expanded(
                                        flex: 7,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${inIng[index].codProd} - ${inIng[index].nombreProd}",
                                              style: TextStyle(
                                                  color: solicitud[index]
                                                      ? Colors.black
                                                      : Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                            child: TextBoxCustom(
                                                hint:
                                                    "Cantidad en ${inIng[index].unidad}",
                                                controller: controllers[index],
                                                enabled: solicitud[index])),
                                      )
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                      return LoadingPage();
                    },
                  )),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                TextButton(
                  child: Text('Solicitar Transferencia'),
                  onPressed: () {
                    ApiSolicitudTransferencia().count().then((value) {
                      String codTransfer =
                          "ST-${(value + 1).toString().padLeft(5, '0')}";
                      if (inIng.length > 0) {
                        List<ModelSolicitudTransferencia> listMST = List();
                        List<ModelInventario> mi = List();
                        List<ModelLote> lml = List();
                        List<ModelHistorialKardex> mhk = List();
                        inIng.forEach((element) {
                          if (solicitud[inIng.indexOf(element)]) {
                            listMST.add(ModelSolicitudTransferencia(
                                cantidad: double.parse(
                                    controllers[inIng.indexOf(element)].text),
                                codProd: element.codProd,
                                estado: 0,
                                usrReg: userID,
                                almDestino: int.parse(almacen[0]),
                                fechaReg: DateFormat("dd/MM/yyyy")
                                    .format(DateTime.now()),
                                usrPet: userSelect.id,
                                codTransferencia: codTransfer));
                            mi.add(ModelInventario(

                            ));
                          }
                        });

                        ApiSolicitudTransferencia()
                            .make(listMST)
                            .whenComplete(() {})
                            .catchError((e) {
                          Toast.show("ERROR EN SOLICITUD", context);
                        });
                      } else
                        Toast.show("NO HAY PRODUCTOS PARA SOLICITAR", context,
                            duration: Toast.LENGTH_LONG);
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // List<bool> solicitud = List();
  // List<TextEditingController> controllers = List();
  // List<ModelIngredientesFormulas> inIng = List();
  // List<ModelIngredientesFormulas> outIng = List();
  List<ModelAlmacenes> selectionAlmacen = List();
  List<double> cantidadUsadaTotal = List();
  Map<String, List<ModelTransferencia>> mTransferencia =
      Map<String, List<ModelTransferencia>>();

  Future<void> _showDialogTranferenciasPendientes(ModelTransferencia ss) async {
    solicitud.clear();
    controllers.clear();
    inIng.clear();
    outIng.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("DETALLE DE TRANSFERENCIA", style: TextStyle(fontWeight: FontWeight.bold),),
              content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 1,
                          child:Row(
                            children: [
                              Expanded(flex:3,child: Text("CODIGO:")),
                              Expanded(flex:8,child: Text("${ss.codTransferencia}"))
                            ],
                          )
                      ),
                      Expanded(
                        flex: 1,
                          child:Row(
                            children: [
                              Expanded(flex:3,child: Text("ALMACEN DE ORIGEN:")),
                              Expanded(flex:8,child: Text("${ss.almOrigen}"))
                            ],
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Row(
                            children: [
                              Expanded(flex:3,child: Text("ALMACEN DE DESTINO:")),
                              Expanded(flex:8,child: Text("${ss.almDestino}"))
                            ],
                          )
                      ),
                      Expanded(
                          flex: 1,
                          child:Row(
                            children: [
                              Expanded(flex:3,child: Text("USUARIO:")),
                              Expanded(flex:8,child: Text("${ss.usuario}"))
                            ],
                          )
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(children: [
                          headerListCustom("Fecha", 1, () {}),
                          headerListCustom("Codigo", 1, () {}),
                          headerListCustom("Descripcion", 2, () {}),
                          headerListCustom("Unidad", 1, () {}),
                          headerListCustom("Cantidad", 1, () {}),
                          headerListCustom("Costo Unitario [Bs.]", 1, () {}),
                          headerListCustom("Lote", 1, () {}),
                          headerListCustom("Lote de Venta", 1, () {}),
                          headerListCustom("Fecha Venc.", 1, () {})
                        ]),
                      ),
                      Expanded(
                        flex: 9,
                        child: ListView.separated(
                          itemCount: transferenciasAgrupadas[ss.codTransferencia].length,
                          separatorBuilder: (context, index) => Divider(),
                          itemBuilder: (context, index) {
                            TextStyle te = TextStyle(fontSize: 10);
                            ModelTransferencia mt=transferenciasAgrupadas[ss.codTransferencia][index];
                            return Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                    child: Text(mt.fechaTransferencia, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(mt.codProd, textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Text(mt.descripcion, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(mt.unidad, textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(NumberFunctions
                                        .formatNumber(
                                        mt.cantidad, 3), textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(NumberFunctions
                                        .formatNumber(
                                        mt.costoUnitario, 4), textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(mt.loteTransferido, textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(mt.loteVenta==null?"":mt.loteVenta, textAlign: TextAlign.center, style: te,)
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.blueGrey,
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Text(mt.fecVencimiento, textAlign: TextAlign.center, style: te,)
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  )),
              actions: <Widget>[
                transferenciasAgrupadas[ss.codTransferencia][0].estado==0?
                TextButton(
                  child: Text('Rechazar Transferencia'),
                  onPressed: () {
                    if(reClick) {
                      return null;
                    } else {
                      reClick=true;
                      List<ModelHistorialKardex>mhk=List();
                      List<ModelInventario>mi=List();
                      transferenciasAgrupadas[ss.codTransferencia].forEach((element) {
                        mi.add(ModelInventario(
                            idCodigo: "R*${ss.codTransferencia}",
                            codigo: "R*${ss.codTransferencia}",
                            cantidad: element.cantidad,
                            costoUnitario: element.costoUnitario,
                            lote: element.loteTransferido,
                            loteVenta: element.loteVenta,
                            codAlm: element.almOrigen,
                            codProd: element.codProd,
                            factura: "",
                            idProv: 0,
                            fecIngreso: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                            fecVencimiento: element.fecVencimiento,
                            fechaSistema: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                            costo: element.cantidad * element.costoUnitario,
                          idLote: element.idLote
                        ));
                        mhk.add(ModelHistorialKardex(
                          lote: element.loteTransferido,
                          cantidad: element.cantidad,
                          prorrateo: element.costoUnitario,
                          idReg: "R*${element.codTransferencia}",
                          created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                          accion: "TRANSFERENCIA",
                          costo: (element.cantidad *element.costoUnitario),
                          costoUnitario: element.costoUnitario,
                          codProd: element.codProd,
                          codAlm: element.almOrigen,//almacenesPropios[0].codAlm,
                          usuario: userID,
                        ));
                      });
                      print(json);
                      ApiInventory().insertInventory(mi,context).whenComplete((){
                        ApiTransferencias().getRechazar(ss.codTransferencia);
                        // ApiHistorial().createHistorial(mhk);
                        Toast.show("SU TRANSFERENCIA FUE RECHAZADA", context);
                        // refreshPendientes((){});
                        Navigator.pop(context);
                        _refreshAll((){});
                      });
                    }
                  },
                ):Container(),
                SizedBox(
                  width: 20,
                ),
                transferenciasAgrupadas[ss.codTransferencia][0].estado==0?
                TextButton(
                  child: Text('Aceptar Transferencia'),
                  onPressed: () {
                    if(acClick) {
                      return null;
                    } else {
                      acClick=true;
                      List<ModelInventario>mi=List();
                      List<ModelLote>ml =List();
                      List<ModelHistorialKardex>mhk=List();
                      transferenciasAgrupadas[ss.codTransferencia].forEach((element) {
                        print("${element.cantidad}::${element.costoUnitario}");
                        mi.add(ModelInventario(
                          idCodigo: element.codTransferencia,
                          codigo: element.codTransferencia,
                          cantidad: element.cantidad,
                          costoUnitario: element.costoUnitario,
                          lote: element.loteTransferido,
                          loteVenta: element.loteVenta,
                          codAlm: element.almDestino,
                          codProd: element.codProd,
                          factura: "",
                          idProv: 0,
                          fecIngreso: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                          fecVencimiento: element.fecVencimiento,
                          costo: element.cantidad * element.costoUnitario,
                            fechaSistema: DateFormat("yyyy-MM-dd").format(DateTime.now())
                        ));
                        ml.add(ModelLote(
                          cantidad: element.cantidad,
                          lote: element.loteTransferido,
                          fecVencimiento: element.fecVencimiento,
                          costoUnit: element.costoUnitario,
                          cantidadUsada: element.cantidad,
                          id: element.idLote
                        ));
                        // mhk.add(ModelHistorialKardex(
                        //   lote: element.loteTransferido,
                        //   cantidad: element.cantidad*(-1),
                        //   prorrateo: element.prorrateo,
                        //   idReg: element.codTransferencia,
                        //   created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                        //   accion: "TRANSFERENCIA",
                        //   costo: (element.cantidad *element.prorrateo)*(-1),
                        //   costoUnitario: element.prorrateo,
                        //   codProd: element.codProd,
                        //   codAlm: element.almOrigen,//almacenesPropios[0].codAlm,
                        //   usuario: userID,
                        // ));
                      });
                      // ApiHistorial().createHistorial(mhk);
                      ApiInventory().insertInventory(mi, context).whenComplete((){
                        ApiTransferencias().aceptar(ss.codTransferencia);
                        Toast.show("SU TRANSFERENCIA FUE ACEPTADA", context);
                        // refreshPendientes((){});
                        Navigator.pop(context);
                        _refreshAll((){});
                        clear();
                      });
                    }
                  },
                ):Container(),
                SizedBox(
                  width: 20,
                ),
                TextButton(
                  child: Text('Salir'),
                  onPressed: () {Navigator.pop(context);},
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDialogPendientes(ModelSolicitudTransferencia ss) async {
    solicitud.clear();
    controllers.clear();
    inIng.clear();
    outIng.clear();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("DETALLE DE TRANSFERENCIA", style: TextStyle(fontWeight: FontWeight.bold),),
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(flex: 1,child: Text("SOLICITANTE:")),
                      Expanded(flex: 2,child: Text("${ss.nombres} ${ss.apPaterno} ${ss.apMaterno!=null?ss.apMaterno:""}")),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(flex: 1,child: Text("ALMACEN SOLICITANTE:")),
                      Expanded(flex: 2,child: Text("${ss.almDestino}-${ss.name}")),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(flex: 1,child: Text("COMENTARIO:")),
                      Expanded(flex: 2,child: Text("${ss.comentario}")),
                    ],
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: FutureBuilder<List<ModelSolicitudTransferencia>>(
                        future: ApiSolicitudTransferencia()
                            .getPendientesByCodigo(ss.codTransferencia),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return SomethingWentWrongPage();
                          if (snapshot.connectionState == ConnectionState.done) {
                            print(ss.codTransferencia);
                            List<ModelSolicitudTransferencia> invDetalle =
                                snapshot.data;
                            invDetalle.forEach((element) {
                              selectionAlmacen.add(null);
                              cantidadUsadaTotal.add(0);
                            });
                            if (solicitud.length == 0) {
                              invDetalle.forEach((e) {
                                solicitud.add(true);
                              });
                            }
                            if (controllers.length == 0) {
                              invDetalle.forEach((e) {
                                TextEditingController tec = TextEditingController();
                                tec.text = (e.cantidad).toStringAsFixed(2);
                                controllers.add(tec);
                              });
                            }
                            return ListView.separated(
                              itemCount: invDetalle.length,
                              separatorBuilder: (context, index) => Divider(),
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Center(
                                        child: DropDownAlmacenes(
                                            selectionAlmacen:
                                                selectionAlmacen[index],
                                            soloPropios: true,
                                            refresh: (val) {
                                              selectionAlmacen[index] = val;
                                            })),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Checkbox(
                                              value: solicitud[index],
                                              onChanged: (value) {
                                                setState(() {
                                                  solicitud[index] = value;
                                                });
                                              },
                                            )),
                                        Expanded(
                                          flex: 5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${invDetalle[index].codProd} - ${invDetalle[index].nombre}",
                                                style: TextStyle(
                                                    color: solicitud[index]
                                                        ? Colors.black
                                                        : Colors.grey),
                                              ),
                                              Text(
                                                  "Cantidad Solicitada: ${invDetalle[index].cantidad}"),
                                              Text(
                                                  "Cantidad Usada: ${cantidadUsadaTotal[index]}")
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Center(
                                              child: WidgetButtons(
                                            txt: "Lotes",
                                            colorText: Colors.white,
                                            color1: Colors.green,
                                            color2: Colors.greenAccent,
                                            func: () {
                                              if (selectionAlmacen[index] != null) {
                                                SelectLotesDialog(
                                                        context: context,
                                                        func: (List<ModelLote> lotes) {
                                                          if (mTransferencia
                                                              .containsKey(
                                                                  invDetalle[index]
                                                                      .codProd)) {
                                                            mTransferencia.remove(
                                                                invDetalle[index]
                                                                    .codProd);
                                                          }
                                                          List<ModelTransferencia>
                                                              listTransferencias =
                                                              List();
                                                          double total = 0;
                                                          lotes.forEach((element) {
                                                            if (element.cantidadUsada !=
                                                                    null &&
                                                                element.cantidadUsada >
                                                                    0) {
                                                              listTransferencias.add(ModelTransferencia(
                                                                  codTransferencia:
                                                                      invDetalle[index]
                                                                          .codTransferencia,
                                                                  almDestino:
                                                                      invDetalle[index]
                                                                          .almDestino,
                                                                  almOrigen:
                                                                      selectionAlmacen[index]
                                                                          .codAlm,
                                                                  estado: 1,
                                                                  codProd:
                                                                      invDetalle[index]
                                                                          .codProd,
                                                                  cantidad: element
                                                                      .cantidadUsada,
                                                                  fechaAceptacion:
                                                                      DateFormat("dd/MM/yyyy")
                                                                          .format(DateTime
                                                                              .now()),
                                                                  fechaTransferencia:
                                                                      DateFormat("dd/MM/yyyy")
                                                                          .format(DateTime.now()),
                                                                  loteTransferido: element.lote,
                                                                  usrTransferencia: 2,
                                                                  usrAceptacion: 1,
                                                                  idLote: element.id,
                                                                  costoUnitario: element.costoUnit,
                                                                  fecVencimiento: element.fecVencimiento));
                                                              setState(() {
                                                                print(
                                                                    "${element.lote}::${element.cantidadUsada}");
                                                                total += element
                                                                    .cantidadUsada;
                                                                cantidadUsadaTotal[
                                                                    index] = total;
                                                              });
                                                            }
                                                          });
                                                          mTransferencia[
                                                                  invDetalle[index]
                                                                      .codProd] =
                                                              listTransferencias;
                                                        })
                                                    .generateDialog(
                                                        invDetalle[index],
                                                        selectionAlmacen[index]
                                                            .codAlm,
                                                        invDetalle[index].codProd);
                                              } else
                                                Toast.show(
                                                    "NO HAY ALMACEN SELECCIONADO",
                                                    context,
                                                    duration: Toast.LENGTH_LONG);
                                            },
                                          )),
                                        ),
                                        // Expanded(
                                        //   flex: 3,
                                        //   child: Center(
                                        //       child: WidgetButtons(txt: "Lotes",colorText: Colors.white,color1: Colors.green,color2: Colors.greenAccent,func: (){
                                        //         SelectLotesDialog(context: context).generateDialog(101, '1100001');
                                        //       },)
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return LoadingPage();
                        },
                      )),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  width: 20,
                ),
                TextButton(
                  child: Text('Transferir Solicitud'),
                  onPressed: () {
                    List<ModelInventario> mi = List();
                    List<ModelLote> ml = List();
                    List<ModelHistorialKardex> mhk = List();
                    int index=0;
                    mTransferencia.forEach((key, value) {
                      value.forEach((element) {
                        mi.add(ModelInventario(
                            idCodigo: element.codTransferencia,
                            codAlm: element.almDestino,
                            codProd: element.codProd,
                            codigo: element.codTransferencia,
                            cantidad: element.cantidad,
                            costoUnitario: element.costoUnitario,
                            costo: element.cantidad * element.costoUnitario,
                            lote: element.loteTransferido,
                            fechaSistema: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                            fecIngreso:
                                DateFormat("dd/MM/yyyy").format(DateTime.now()),
                            fecVencimiento: element.fecVencimiento));
                        ml.add(
                          ModelLote(
                            id: element.idLote,
                            cantidad: element.cantidad,
                            cantidadUsada: element.cantidad,
                            costoUnit: element.prorrateo,
                            fecVencimiento: element.fecVencimiento,
                            lote: element.loteTransferido
                          )
                        );
                        mhk.add(ModelHistorialKardex(
                          lote: element.loteTransferido,
                          costo: (element.cantidad * element.costoUnitario)*(-1),
                          codAlm: element.almOrigen,
                          cantidad: element.cantidad*(-1),
                          prorrateo: element.costoUnitario,
                          accion: "TRANSFERENCIA",
                          codProd: element.codProd,
                          costoUnitario: element.costoUnitario,
                          usuario: userID,
                          idReg: element.codTransferencia,
                          created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                          updated_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                        ));
                        // mhk.add(ModelHistorialKardex(
                        //     lote: element.loteTransferido,
                        //     costo: element.cantidad * element.costoUnitario,
                        //     codAlm: element.almDestino,
                        //     cantidad: element.cantidad,
                        //     accion: "TRANSFERENCIA",
                        //     codProd: element.codProd,
                        //     costoUnitario: element.costoUnitario,
                        //     usuario: userID,
                        //     idReg: element.codTransferencia,
                        //     created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                        //   prorrateo: element.costoUnitario
                        // ));
                        ApiInventory().discountInventory(ml, selectionAlmacen[index].codAlm, value[0].codProd);
                      });
                    });
                    ApiHistorial().createHistorial(mhk);
                    ApiInventory()
                        .insertInventory(mi, context)
                        .whenComplete(() {
                      print("idSolTransf::${ss.codTransferencia}");
                      ApiSolicitudTransferencia()
                          .transferido(ss.codTransferencia)
                          .whenComplete(() {
                        _listaPendientes(() {
                          ppFilterSolicitud.remove(ss);
                          Navigator.pop(context);
                          Toast.show("Transferencia Realizada", context,
                              duration: Toast.LENGTH_LONG);
                        });
                      });
                    }).catchError((e) {
                      Toast.show(
                          "No se realizo la transferencia ERR::${e.toString()}",
                          context,
                          duration: Toast.LENGTH_LONG);
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
                Text(nombre),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                clearAll();
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text('IMPRIMIR'),
            //   onPressed: () {
            //
            //   },
            // ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogPendiente(ModelProcesoProduccion mpp) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('EXITO'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'SE SOLICITARON ${listaProductosSeleccionados.length} PRODUCTOS CORRECTAMENTE.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                clearAll();
                Navigator.of(context).pop();
              },
            ),
            // TextButton(
            //   child: Text('IMPRIMIR'),
            //   onPressed: () {
            //
            //   },
            // ),
          ],
        );
      },
    );
  }

  List<ModelSolicitudTransferencia> ppFilterSolicitud = List();
  List<ModelTransferencia> ppFilterTransf = List();

  List<ModelSolicitudTransferencia> solicitudesPendientes = List();
  List<ModelTransferencia> transferenciasPendientesAlm = List();
  Map<String, List<ModelTransferencia>> transferenciasAgrupadas = Map();
  List<String> keys = List();

  Future getPendientes() async {
    keys.clear();
    transferenciasAgrupadas.clear();
    solicitudesPendientes.clear();
    transferenciasPendientesAlm.clear();
    print("usuario $userID");
    solicitudesPendientes = await ApiSolicitudTransferencia().getPendientes(userID);
    transferenciasPendientesAlm = await Constant().getTransferPendientesAlm();

    await transferenciasPendientesAlm.forEach((element) {
      if (transferenciasAgrupadas.containsKey(element.codTransferencia)) {
        transferenciasAgrupadas[element.codTransferencia].add(element);
      } else {
        keys.add(element.codTransferencia);
        transferenciasAgrupadas[element.codTransferencia] = List();
        transferenciasAgrupadas[element.codTransferencia].add(element);
      }
    });
  }

  StateSetter refreshPendientes;
  transferenciasPendientes() {
    return FutureBuilder(
      future: getPendientes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return SomethingWentWrongPage();
        if (snapshot.connectionState == ConnectionState.done) {
          TextStyle styleTransferencias =
          TextStyle(fontSize: 12, color: Colors.white);
          TextStyle styleSolicitudes = TextStyle(fontSize: 12);
          ppFilterSolicitud = solicitudesPendientes;
          ppFilterTransf = transferenciasPendientesAlm;

          return StatefulBuilder(
            builder: (context, state) {
              refreshPendientes = state;
              return Container(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.all(10),
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
                    Expanded(
                      flex: 1,
                      child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5),
                          width: double.infinity,
                          color: Theme.of(context).secondaryHeaderColor,
                          child: Text(
                            "LISTA TRANSFERENCIAS PENDIENTES",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                                width: double.infinity,
                                height: 50,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blueGrey, width: .5),
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextField(
                                  decoration: InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                      hintText: "Buscar Transferencia"),
                                  onChanged: (value) {
                                    // stateList(() {
                                    //   ppFilter = pp.where((element) => element.loteProd.contains(value)).toList();
                                    // });
                                  },
                                )),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: Container(
                          //       width: double.infinity,
                          //       height: 50,
                          //       padding: EdgeInsets.all(5),
                          //       margin: EdgeInsets.all(2),
                          //       decoration: BoxDecoration(
                          //         // border: Border.all(color: Colors.blueGrey, width: .5),
                          //           borderRadius: BorderRadius.circular(10)),
                          //       child: Column(
                          //         mainAxisAlignment: MainAxisAlignment.start,
                          //         children: [
                          //           Text("ACEPTADOS",
                          //               style: TextStyle(
                          //                   color: Colors.green, fontSize: 10)),
                          //           Text("PENDIENTES",
                          //               style: TextStyle(
                          //                   color: Colors.amber, fontSize: 10)),
                          //           Text("RECHAZADOS",
                          //               style: TextStyle(
                          //                   color: Colors.red, fontSize: 10)),
                          //         ],
                          //       )),
                          // ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  headerListCustom(
                                      "Transferencias Recibidas", 1, () {})
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: [
                                  headerListCustom(
                                      "Transferencias Solicitadas", 1, () {}),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  headerListCustom("Fecha", 1, () {}),
                                  headerListCustom("Codigo", 1, () {}),
                                  headerListCustom("Almacen Origen", 1, () {}),
                                  headerListCustom("Almacen Destino", 1, () {}),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  headerListCustom("Fecha", 1, () {}),
                                  headerListCustom("Codigo", 1, () {}),
                                  headerListCustom(
                                      "Almacen Solicitante", 1, () {}),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding:
                              EdgeInsets.only(left: 8, bottom: 8, right: 8),
                              // height: MediaQuery.of(context).size.height-300,
                              child: Scrollbar(
                                controller: scroll2,
                                isAlwaysShown: true,
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    _listaPendientes = setState;
                                    return ListView.builder(
                                      controller: scroll2,
                                      itemCount: keys.length,
                                      itemBuilder: (context, index) {
                                        ModelTransferencia e =
                                        transferenciasAgrupadas[keys[index]][0];
                                        return InkWell(
                                          onTap: () {
                                            selectionAlmacen.clear();
                                            cantidadUsadaTotal.clear();
                                            _showDialogTranferenciasPendientes(
                                                e);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                    color: Colors.blueGrey,
                                                    width: .5)),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Center(
                                                        child: Text(
                                                          e.fechaTransferencia,
                                                          style: e.estado == 0
                                                              ? styleSolicitudes
                                                              : styleTransferencias,
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
                                                          e.codTransferencia,
                                                          style: e.estado == 0
                                                              ? styleSolicitudes
                                                              : styleTransferencias,
                                                        ))),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      child: Text(
                                                        e.almOrigen.toString(),
                                                        style: e.estado == 0
                                                            ? styleSolicitudes
                                                            : styleTransferencias,
                                                      ),
                                                    )),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      child: Text(
                                                          e.almDestino
                                                              .toString(),
                                                          style: e.estado == 0
                                                              ? styleSolicitudes
                                                              : styleTransferencias
                                                      ),
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
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding:
                              EdgeInsets.only(left: 8, bottom: 8, right: 8),
                              // height: MediaQuery.of(context).size.height-300,
                              child: Scrollbar(
                                controller: scroll3,
                                isAlwaysShown: true,
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    _listaPendientes = setState;
                                    return ListView.builder(
                                      controller: scroll3,
                                      itemCount: ppFilterSolicitud.length,
                                      itemBuilder: (context, index) {
                                        ModelSolicitudTransferencia e =
                                        ppFilterSolicitud[index];
                                        return InkWell(
                                          onTap: () {
                                            selectionAlmacen.clear();
                                            cantidadUsadaTotal.clear();
                                            _showDialogPendientes(e);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.blueGrey,
                                                    width: .5)),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: Center(
                                                        child: Text(
                                                          e.fechaReg,
                                                          style: styleSolicitudes,
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
                                                          e.codTransferencia,
                                                          style: styleSolicitudes,
                                                        ))),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(
                                                    flex: 1,
                                                    child: Align(
                                                      alignment:
                                                      Alignment.centerRight,
                                                      child: Text(
                                                        e.almDestino.toString(),
                                                        style: styleSolicitudes,
                                                      ),
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
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    // SingleChildScrollView(
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(8.0),
                    //     child: Column(
                    //       children: pp.map((e){
                    //
                    //       }).toList(),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              );
            },
          );
        }
        return LoadingPage();
      },
    );
  }

  realizarTransferencia() {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return SomethingWentWrongPage();
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    refreshDatos = setState;
                    return Container(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.all(10),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                              padding: EdgeInsets.only(top: 5, bottom: 5),
                              width: double.infinity,
                              color: Theme.of(context).secondaryHeaderColor,
                              child: Text(
                                "TRANSFERENCIA",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                          DropDownAlmacenes(
                            selectionAlmacen: almacenOrigenSeleccionado,
                            label: "SELECCIONES ALMACEN DE ORIGEN",
                            soloPropios: true,
                            enabled: seleccionAlmacenActivo,
                            refresh: (ModelAlmacenes a) {
                              refreshDatos(() {
                                almacenOrigenSeleccionado = a;
                              });
                            },
                          ),
                          // DropDownUsuarios(userSelection: userSelection,enabled: true, refresh: (val){
                          //   setState((){
                          //     userSelection = val;
                          //   });
                          // },),
                          DropDownAlmacenes(
                            selectionAlmacen: almacenDestinoSeleccionado,
                            label: "SELECCIONES ALMACEN DE DESTINO",
                            enabled: seleccionAlmacenActivo,
                            refresh: (ModelAlmacenes a) {
                              refreshDatos(() {
                                almacenDestinoSeleccionado = a;
                              });
                            },
                          ),
                          DropDownProductos(
                              selectionAlmacen: almacenOrigenSeleccionado,
                              selectionItem: productoSeleccionado,
                              enabled: seleccionProductoActivo,
                              func: (ModelItem i) {
                                refreshDatos(() {
                                  productoSeleccionado = i;
                                });
                              }),
                          // StatefulBuilder(builder: (context, setState) {
                          //   refreshProductos = setState;
                          //   return DropDownProductos(selectionAlmacen: almacenSeleccionado, selectionItem: productoSeleccionado, enabled: seleccionProductoActivo, func: (ModelItem i){
                          //     productoSeleccionado = i;
                          //   });
                          // },),
                          // TextBoxCustom(controller: ecCantidad,hint: "CANTIDAD REQUERIDA"),
                          WidgetButtons(
                              txt: titleButton,
                              color1: Colors.green,
                              color2: Colors.lightGreenAccent,
                              colorText: Colors.white,
                              func: () {
                                if(!firstClick){
                                  firstClick=true;
                                  if (titleButton == "ACTUALIZAR") {
                                    seleccionAlmacenActivo = true;
                                    seleccionProductoActivo = true;
                                    titleButton = "AGREGAR PRODUCTO";
                                    listaProductosSeleccionados[
                                    indexProductoSeleccionado]
                                        .cantidad = double.parse(ecCantidad.text);
                                    clear();
                                  } else {
                                    if (almacenOrigenSeleccionado != null) {
                                      if (almacenDestinoSeleccionado != null) {
                                        if (productoSeleccionado != null) {
                                          bool exist = false;
                                          listaProductosSeleccionados
                                              .forEach((element) {
                                            if (element.codProd ==
                                                productoSeleccionado.codigo)
                                              exist = true;
                                          });
                                          if (!exist) {
                                            print(
                                                "${almacenOrigenSeleccionado.codAlm}");
                                            listaProductosSeleccionados.add(
                                                ModelInventario(
                                                    codAlm: almacenOrigenSeleccionado
                                                        .codAlm,
                                                    codProd: productoSeleccionado
                                                        .codigo,
                                                    nombre: productoSeleccionado
                                                        .nombre,
                                                    cantidad: 0,
                                                    unidad: productoSeleccionado
                                                        .titulo));
                                            clear();
                                          } else
                                            Toast.show("ESTE PRODUCTO YA EXISTE",
                                                context,
                                                duration: Toast.LENGTH_LONG);
                                        } else
                                          Toast.show(
                                              "SE REQUIERE UN PRODUCTO", context,
                                              duration: Toast.LENGTH_LONG);
                                      } else
                                        Toast.show(
                                            "SE REQUIERE UN ALMACEN DE DESTINO",
                                            context,
                                            duration: Toast.LENGTH_LONG);
                                    } else
                                      Toast.show(
                                          "SE REQUIERE UN ALMACEN DE ORIGEN",
                                          context,
                                          duration: Toast.LENGTH_LONG);
                                  }
                                }
                              }),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    );
                  },
                ),
                StatefulBuilder(
                  builder: (context, setState) {
                    refreshLista = setState;
                    return ListCustom(
                      modelHeaderList: [
                        ModelHeaderList(title: "Codigo", flex: 1),
                        ModelHeaderList(title: "Descripcion", flex: 3),
                        ModelHeaderList(title: "Unidad", flex: 1),
                        ModelHeaderList(title: "Cantidad", flex: 1),
                        ModelHeaderList(title: "Lotes", flex: 1),
                        ModelHeaderList(title: "Acciones", flex: 1),
                      ],
                      title: "PRODUCTOS",
                      datos: listaProductosSeleccionados.map((e) {
                        TextStyle style = TextStyle(fontSize: 12);
                        return Column(
                          children: [
                            InkWell(
                              onTap: () {
                                UtilsDialog(context: context, scroll: scroll3)
                                    .showDialog2(
                                        listaProductosSeleccionados[
                                            listaProductosSeleccionados
                                                .indexOf(e)],
                                        listaProductosSeleccionados[
                                                listaProductosSeleccionados
                                                    .indexOf(e)]
                                            .codAlm,
                                        listaProductosSeleccionados[
                                                listaProductosSeleccionados
                                                    .indexOf(e)]
                                            .codProd, (val, lotes) {
                                  setState(() {
                                    listaProductosSeleccionados[
                                            listaProductosSeleccionados
                                                .indexOf(e)]
                                        .lotes = val.lotes;
                                    listaProductosSeleccionados[
                                                listaProductosSeleccionados
                                                    .indexOf(e)]
                                            .cantidadTotalLotes =
                                        val.cantidadTotalLotes;
                                  });
                                });
                              },
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text(
                                        e.codProd,
                                        style: style,
                                      ))),
                                  Expanded(
                                      flex: 3,
                                      child: Center(
                                          child: Text(
                                        e.nombre,
                                        style: style,
                                      ))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text(
                                        "${listaProductosSeleccionados[listaProductosSeleccionados.indexOf(e)].unidad}",
                                        style: style,
                                      ))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text(
                                        "${e.cantidadTotalLotes}",
                                        style: style,
                                      ))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Text(
                                        "${listaProductosSeleccionados[listaProductosSeleccionados.indexOf(e)].lotes.map((e) => "${e.lote}|")}",
                                        style: style,
                                      ))),
                                  Expanded(
                                      flex: 1,
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // InkWell(
                                          //     onTap: () {
                                          //       refreshDatos(() {
                                          //         ecCantidad.text = e.cantidad
                                          //             .toStringAsFixed(3);
                                          //         titleButton = "ACTUALIZAR";
                                          //         seleccionAlmacenActivo =
                                          //             false;
                                          //         seleccionProductoActivo =
                                          //             false;
                                          //         productoSeleccionado =
                                          //             e.prodSelect;
                                          //         indexProductoSeleccionado =
                                          //             listaProductosSeleccionados
                                          //                 .indexOf(e);
                                          //       });
                                          //     },
                                          //     child: Icon(Icons.edit)),
                                          InkWell(
                                              onTap: () {
                                                refreshLista(() {
                                                  listaProductosSeleccionados
                                                      .remove(e);
                                                });
                                              },
                                              child: Icon(Icons.delete_forever))
                                        ],
                                      ))),
                                ],
                              ),
                            ),
                            Divider()
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
                WidgetButtons(
                    txt: loading ? "CARGANDO..." : "REALIZAR TRANSFERENCIA",
                    color1: Colors.green,
                    color2: Colors.lightGreenAccent,
                    colorText: Colors.white,
                    func: loading
                        ? () {}
                        : () {
                            if(!firstClick){
                              firstClick=true;
                              setState(() {
                                bool permitido=true;
                                listaProductosSeleccionados.forEach((element) {
                                  if(permitido&&element.cantidadTotalLotes<=0)
                                    permitido=false;
                                });
                                if(permitido){
                                  if (!loading) {
                                    loading = true;
                                    List<ModelLote> listLotes = List();
                                    ApiTransferencias().count().then((value) {
                                      String lotes="";
                                      double cantidadTotal=0;
                                      double costoUnit=0;
                                      String codTransfer =
                                          "T-${(value + 1).toString().padLeft(5, '0')}";
                                      if (listaProductosSeleccionados.length > 0) {
                                        List<ModelHistorialKardex> mhk = List();
                                        List<ModelTransferencia> listMST = List();
                                        listaProductosSeleccionados
                                            .forEach((element) {
                                          cantidadTotal=0;
                                          element.lotes.forEach((item) {
                                            listMST.add(ModelTransferencia(
                                                codTransferencia: codTransfer,
                                                almOrigen: almacenOrigenSeleccionado
                                                    .codAlm,
                                                almDestino:
                                                almacenDestinoSeleccionado
                                                    .codAlm,
                                                codProd: element.codProd,
                                                cantidad: item.cantidadUsada,
                                                estado: 0,
                                                creado_en: DateFormat(
                                                    "yyyy-MM-dd")
                                                    .format(DateTime.now()),
                                                fechaTransferencia: DateFormat(
                                                    "dd/MM/yyyy HH:mm:ss")
                                                    .format(DateTime.now()),
                                                usrTransferencia: userID,
                                                fecVencimiento: item.fecVencimiento,
                                                idLote: item.id,
                                                usrAceptacion: 0,
                                                fechaAceptacion: DateFormat(
                                                    "dd/MM/yyyy HH:mm:ss")
                                                    .format(DateTime.now()),
                                                loteTransferido: item.lote,
                                                costoUnitario: item.costoUnit));
                                            item.codProd=element.codProd;
                                            listLotes.add(item);

                                            print("${item.lote}::${item.cantidadUsada*(-1)}::"
                                                "${element.prorrateo}::R*${codTransfer}::"
                                                "${element.codProd}::${element.codAlm}");

                                            lotes+="${item.lote}|";
                                            cantidadTotal+=item.cantidadUsada;
                                            costoUnit=item.costoUnit;

                                          });

                                          print("${cantidadTotal}::${cantidadTotal*costoUnit}");
                                          mhk.add(ModelHistorialKardex(
                                            lote: lotes,
                                            cantidad: cantidadTotal*(-1),
                                            prorrateo: costoUnit,
                                            idReg: "$codTransfer",
                                            created_at: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                                            accion: "TRANSFERENCIA",
                                            costo: (cantidadTotal *costoUnit)*(-1),
                                            costoUnitario: costoUnit,
                                            codProd: element.codProd,
                                            codAlm: element.codAlm,//almacenesPropios[0].codAlm,
                                            usuario: userID,
                                          ));

                                        });

                                        ApiInventory().discountInventory(
                                            listLotes,
                                            almacenOrigenSeleccionado.codAlm,
                                            listLotes[0].codProd).whenComplete((){

                                          ApiHistorial().createHistorial(mhk);
                                          print(listMST
                                              .map((e) => e.toJson())
                                              .toList());
                                          loading = false;
                                          ApiTransferencias()
                                              .make(listMST)
                                              .whenComplete(() {
                                            loading = false;
                                            _showDialog(
                                                "SE TRANSFIRIERON ${listaProductosSeleccionados.length} PRODUCTOS CORRECTAMENTE.");
                                          }).catchError((e) {
                                            loading = false;
                                            Toast.show(
                                                "ERROR EN TRANSFERENCIA", context);
                                          });
                                        });

                                      } else {
                                        loading = false;
                                        Toast.show(
                                            "NO HAY PRODUCTOS PARA TRANSFERIR",
                                            context,
                                            duration: Toast.LENGTH_LONG);
                                      }
                                    });
                                  }
                                }else Toast.show("NO PUEDE TRANSFERER CANTIDAD 0", context);
                              });
                            }
                          })
              ],
            );
          }
          return LoadingPage();
        },
      ),
    );
  }
}
