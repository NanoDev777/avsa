
import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_parametros.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/modules/module_show_pp.dart';
import 'package:andeanvalleysystem/modules/module_terminar_proc_prod.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_almacen.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/utils/connections/api_formulas.dart';
import 'package:andeanvalleysystem/utils/connections/api_parametros.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/connections/api_productos.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/drop_down_almacenes.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';

class ModuleProcesoProduccion extends StatefulWidget {
  final int selection;


  ModuleProcesoProduccion({Key key,this.selection}):super(key: key);

  @override
  _ModuleProcesoProduccionState createState() =>
      _ModuleProcesoProduccionState();
}

class _ModuleProcesoProduccionState extends State<ModuleProcesoProduccion> {
  List<String> subModule = ["CREAR PROCESO", "TERMINAR PROCESO","APROBACION PROCESOS CON VARIACION"];
  int selection = -1;

  TextEditingController ecLoteProd = TextEditingController();
  String loteProdErr;
  TextEditingController ecLineaProd = TextEditingController();
  String lineaProdErr;
  TextEditingController ecCliente = TextEditingController();
  String clienteErr;
  TextEditingController ecCantidad = TextEditingController();
  String cantidadErr;

  List<ModelCliente> clientes;
  List<ModelFormula> formulas;
  List<ModelParametros> lineaProd;
  List<ModelParametros> unidMedida;
  List<ModelAlmacenes> almacenes;
  ModelFormula selectFormula;
  ModelAlmacenes selectAlmacen;
  int unidadMedida;

  ModelProcesoProduccion pps;

  StateSetter stateList;
  String filter='';
  bool load = false;

  int sortFecReg=0;
  int sortLote=0;
  int sortCantidad=0;
  int sortNameProd=0;
  String tituloCantidad="CANTIDAD A PRODUCIR";

  Future<bool> getData()async{
    if(clientes==null && formulas==null && lineaProd==null && almacenes==null && unidMedida==null) {
      clientes = await ApiCliente().get();
      formulas = await ApiFormulas().get();
      lineaProd = await ApiParametros("linProd").get();
      unidMedida = await ApiParametros("unidMedida").get();
      almacenes = await Constant().getAlmacenes();
      if(almacenes.length == 1)
        selectAlmacen = almacenes[0];
      return true;
    }else{
      if(clientes!=null && formulas!=null && lineaProd!=null && almacenes!=null && unidMedida!=null) {
        return true;
      }else return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //     height: 50,
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceAround,
        //       children: subModule.map((e) {
        //         return Expanded(
        //           child: InkWell(
        //             onTap: () {
        //               setState(() {
        //                 selection = subModule.indexOf(e);
        //               });
        //             },
        //             child: Container(
        //                 margin: EdgeInsets.all(5),
        //                 color: selection == subModule.indexOf(e)
        //                     ? Colors.blue
        //                     : Colors.blueGrey,
        //                 child: Center(
        //                     child: Text(
        //                       e,
        //                       style: TextStyle(color: Colors.white),
        //                     ))),
        //           ),
        //         );
        //       }).toList(),
        //     )),
        widget.selection==0?formularioCrear():Container(),
        widget.selection==1?formularioPendiente():Container(),
        widget.selection==2?formularioVariacion():Container()
      ],
    );
  }
  formularioCrear() {
    return
      //formulas==null || almacenes==null || clientes==null || lineaProd==null || unidMedida==null?
    FutureBuilder<bool>(
      future: getData(),
      builder: (context, snapshot) {
        if(snapshot.hasError)
          return SomethingWentWrongPage();
        if(snapshot.connectionState == ConnectionState.done && snapshot.data){
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
                      "CREAR PROCESO DE PRODUCCION",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    )
                ),
                almacenes.length>1?dropDownSearchAlmacenes("SELECCIONE UN ALMACEN", "Almacenes"):
                Container(),
                textEdit("LOTE DE PRODUCCION",ecLoteProd,loteProdErr,true),
                dropDownSearchFormulas("SELECCIONE UNA FORMULA","LISTA DE FORMULAS"),
                textEdit("LINEA DE PRODUCCION",ecLineaProd,lineaProdErr,false),
                textEdit("CLIENTE",ecCliente,clienteErr,false),
                textEdit(tituloCantidad,ecCantidad,cantidadErr,true),
                // dropDownSearchAlmacenes("SELECCIONE UN ALMACEN","LISTA DE ALMACEN"),
                load?CircularProgressIndicator()
                :WidgetButtons(txt: "GENERAR PROCESO",color1: Colors.green,
                    color2: Colors.lightGreenAccent,colorText: Colors.white, func:(){
                      if(validate() && !load){
                        setState(() {
                          load = true;
                        });
                        ModelParametros u;
                        ApiProductos().getUnidMedida(selectFormula.codProdRes).then((value){
                          unidMedida.forEach((element) {
                            if(element.id == value)
                              u = element;
                          });
                          pps = ModelProcesoProduccion(
                              idFormula: selectFormula.id,
                              codAlmProd: selectAlmacen.codAlm,
                              loteProd: ecLoteProd.text,
                              idLinProd: selectFormula.lineaProduccion,
                              idCliente: selectFormula.cliente,
                              unidad: u.titulo,
                              cantidad: double.parse(ecCantidad.text),
                              usrReg: 1,
                              aprob: 0,
                              estado: 1,
                            fecRegistro: DateFormat("yyyy-MM-dd").format(DateTime.now())
                          );
                          ApiProcesosProduccion().make(pps)
                              .then((value){
                            pps.id = value;
                            _showMyDialog("EXITO",
                                "Se genero correctamente",value);
                            load = false;
                          })
                              .catchError((e){
                            _showMyDialog("ERROR","Ocurrio un error",0);
                            load = false;
                          });
                        });

                      }
                    }),
                SizedBox(height: 10,)
              ],
            ),
          );
        }
        return LoadingPage();
      },
    );
  }

  Future<void> _showMyDialog(String title, String msj, int id) async {
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
            id>0?TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                ApiProcesosProduccion().getID(id).then((value){
                  generatePdf("${ecLoteProd.text}-CP",value[0]);
                });
              },
            ):Container(),
            TextButton(
              child: Text('ACEPTAR'),
              onPressed: () {
                clean();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMyDialogAccion(ModelProcesoProduccion e) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ACCION"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Que deseas Realizar?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('SOLICITAR TRANSFERENCIA'),
              onPressed: () {
                Toast.show("En Construccion", context, duration: Toast.LENGTH_LONG);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('TERMINAR PROCESO'),
              onPressed: () {
                Navigator.of(context).pop();

              },
            ),
          ],
        );
      },
    );
  }
  refresh(){setState(() {
  });}

  StateSetter listRefresh;
  ScrollController scroll = ScrollController();
  ScrollController scroll1 = ScrollController();
  formularioPendiente() {
    return StatefulBuilder(
      builder: (context, setState) {
        listRefresh = setState;
        return FutureBuilder<List<ModelProcesoProduccion>>(
          future: Constant().getProcProdPendientes(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              return SomethingWentWrongPage();
            if(snapshot.connectionState==ConnectionState.done){
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
                          color: Colors.blueGrey,
                          child: Text(
                            "LISTA PROCESO DE PRODUCCION PENDIENTE",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          )
                      ),
                      Container(
                          width: double.infinity,
                          height: 50,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey, width: .5),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                hintText: "Buscar Lote de Produccion"
                            ),
                            onChanged: (value) {
                              stateList(() {
                                ppFilter = pp.where((element) => element.loteProd.contains(value)).toList();
                              });
                            },
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            headerListCustom("Fecha Registro", 1,(){
                              stateList((){
                                if(sortFecReg==0) {
                                  sortFecReg=1;
                                  ppFilter.sort((a, b) =>
                                      a.createAt.compareTo(b.createAt));
                                }else {
                                  sortFecReg=0;
                                  ppFilter.sort((a, b) =>
                                      b.createAt.compareTo(a.createAt));
                                }
                              });
                            }),
                            headerListCustom("Lote Proceso", 1,(){
                              stateList((){
                                if(sortLote==0) {
                                  sortLote=1;
                                  ppFilter.sort((a, b) =>
                                      a.loteProd.compareTo(b.loteProd));
                                }else {
                                  sortLote=0;
                                  ppFilter.sort((a, b) =>
                                      b.loteProd.compareTo(a.loteProd));
                                }
                              });
                            }),
                            headerListCustom("Cantidad", 1,(){
                              stateList((){
                                if(sortCantidad==0) {
                                  sortCantidad=1;
                                  ppFilter.sort((a, b) =>
                                      a.cantidad.compareTo(b.cantidad));
                                }else {
                                  sortCantidad=0;
                                  ppFilter.sort((a, b) =>
                                      b.cantidad.compareTo(a.cantidad));
                                }
                              });
                            }),
                            headerListCustom("Producto", 4,(){
                              stateList((){
                                if(sortNameProd==0) {
                                  sortNameProd=1;
                                  ppFilter.sort((a, b) =>
                                      a.nombreProducto.substring(0,1).compareTo(b.nombreProducto.substring(0,1)));
                                }else {
                                  sortNameProd=0;
                                  ppFilter.sort((a, b) =>
                                      b.nombreProducto.substring(0,1).compareTo(a.nombreProducto.substring(0,1)));
                                }
                              });
                            }),
                            headerListCustom("Acciones", 1,(){})
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8,bottom: 8,right: 8),
                          // height: MediaQuery.of(context).size.height-300,
                          child: Scrollbar(
                            controller: scroll,
                            isAlwaysShown: true,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                stateList = setState;
                                return ListView.builder(
                                  controller: scroll,
                                  itemCount: ppFilter.length,
                                  itemBuilder: (context, index) {
                                    ModelProcesoProduccion e = ppFilter[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ModuleTerminarProcProd(procProd: e,refresh: listRefresh,),));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blueGrey,width: .5)
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      DateFormat("dd/MM/yyyy").format(DateTime.parse(e.createAt)),
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      e.loteProd,
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    e.cantidad.toStringAsFixed(2),
                                                    style: style,
                                                  ),
                                                )),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 4,
                                                child: Center(
                                                    child: Text(
                                                      e.nombreProducto,
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        // InkWell(
                                                        //     onTap: () {
                                                        //     },
                                                        //     child: Icon(Icons.edit)),
                                                        InkWell(
                                                            onTap: () {
                                                              _showDialogDelete(e.loteProd, (){
                                                                ApiProcesosProduccion().borrar(e.id).whenComplete((){
                                                                  stateList((){
                                                                    ppFilter.remove(e);
                                                                    Toast.show("Borrado Correctamente", context, duration: Toast.LENGTH_LONG);
                                                                    Navigator.of(context).pop();
                                                                  });
                                                                });
                                                              });
                                                            },
                                                            child: Icon(Icons.delete_forever)),
                                                        InkWell(
                                                            onTap: () {
                                                              ApiProcesosProduccion().getID(e.id).then((value){
                                                                generatePdf("${value[0].loteProd}-CP", value[0]);
                                                              });
                                                            },
                                                            child: Icon(Icons.arrow_circle_down))
                                                      ],
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
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
          },);
      },
    );
  }

  Future<void> _showDialogDelete(String lote, Function si) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CONFIRMACION'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ESTA SEGURO DE BORRAR EL PROCESO CON LOTE DE PRODUCCION: ${lote.toUpperCase()}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('NO'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SI'),
              onPressed: si,
            ),
          ],
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

  textEdit(String hint, TextEditingController ec, String error, bool enabled) {
    return Container(
      margin: EdgeInsets.all(5),
      child: TextFormField(
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

  dropDownSearchFormulas(String txt,String title) {
    formulas.sort((a,b)=>a.codProdRes.compareTo(b.codProdRes));
    return Container(
      margin: EdgeInsets.all(5),
      child: DropdownSearch<ModelFormula>(
        items: formulas,
        filterFn: (item, filter) {
          if (filter.isEmpty)
            return true;
          else {
            if (item.codProdRes.contains(filter) ||
                item.titulo
                    .toLowerCase()
                    .contains(filter.toLowerCase()))
              return true;
            else
              return false;
          }
        },
        selectedItem: selectFormula,
        onChanged: (value) {
          setState(() {
            selectFormula = value;
            print("IDPPSELECT::${value.id}::${value.lineaProduccion}");
            tituloCantidad = "CANTIDAD A PRODUCIR EN ${value.unidadMedida}";
            lineaProd.forEach((element) {
              if(element.id==selectFormula.lineaProduccion)
                ecLineaProd.text = element.titulo;
            });
            clientes.forEach((element) {
              if(element.id == selectFormula.cliente)
                ecCliente.text = element.razonSocial;
            });
          });
        },
        showSearchBox: true,
        label: txt,
        popupTitle:
        Center(child: Text(title)),
        popupItemBuilder: _customPopupItemBuilderFormula,
        dropdownBuilder: selectFormula != null
            ? _customDropDownFormula
            : null,
      ),
    );
  }
  bool validate(){
    clienteErr=null;
    lineaProdErr=null;
    cantidadErr=null;
    loteProdErr=null;
    if(selectFormula!=null){
        if(ecLoteProd.text.isNotEmpty){
          if(ecCantidad.text.isNotEmpty){
            if(ecLineaProd.text.isNotEmpty){
              return true;
            }else {
              lineaProdErr = "Campo necesario";
              return false;
            }
          }else {
            cantidadErr = "Campo necesario";
            return false;
          }
        }else {
          loteProdErr = "Campo necesario";
          return false;
        }
    }else {
      Toast.show("Selecciona una Formula", context,
          duration: Toast.LENGTH_LONG);
      return false;
    }
  }
  clean(){
    if(this.mounted){
      setState(() {
        selectFormula=null;
        ecCliente.text="";
        ecLineaProd.text="";
        ecCantidad.text="";
        ecLoteProd.text="";
      });
    }
  }
  dropDownSearchAlmacenes(String txt,String title) {
    return Container(
      margin: EdgeInsets.all(5),
      child: DropdownSearch<ModelAlmacenes>(
        emptyBuilder: (context, searchEntry) {
          return Center(
            child: Text("NO EXISTEN DATOS"),
          );
        },
        items: almacenes,
        filterFn: (item, filter) {
          if (filter.isEmpty)
            return true;
          else {
            if (item.codAlm.toString().contains(filter) ||
                item.name
                    .toLowerCase()
                    .contains(filter.toLowerCase()))
              return true;
            else
              return false;
          }
        },
        selectedItem: selectAlmacen,
        onChanged: (value) {
          setState(() {
            selectAlmacen = value;
          });
        },
        showSearchBox: true,
        label: txt,
        popupTitle:
        Center(child: Text(title)),
        popupItemBuilder:
        _customPopupItemBuilderAlm,
        dropdownBuilder: selectAlmacen != null
            ? _customDropDownAlm
            : null,
      ),
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

  Widget _customPopupItemBuilderFormula(
      BuildContext context, ModelFormula item, bool isSelected) {
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
        title: Row(
          children: [
            Text("${item.codProdRes} - ${item.titulo}"),
            Text(item.version>1?" - V${item.version}":"")
          ],
        ),
        subtitle: Row(
          children: [
            Text(item.razonSocial!=null?"${item.razonSocial} -":""),
            Text(item.instruccion!=null?"${item.instruccion}":"")
          ],
        )
      ),
    );
  }

  Widget _customDropDownFormula(
      BuildContext context, ModelFormula item, String itemDesignation) {
    return Container(
      child: ListTile(
          title: Row(
            children: [
              Text("${item.codProdRes} - ${item.titulo}"),
              Text(item.version>1?" - V${item.version}":"")
            ],
          ),
          subtitle: Row(
            children: [
              Text(item.razonSocial!=null?"${item.razonSocial} -":""),
              Text(item.instruccion!=null?"${item.instruccion}":"")
            ],
          )
      ),
    );
  }

  Future generatePdf(String nombre, ModelProcesoProduccion mp) async {
    PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 10;
    PdfPage page = document.pages.add();

    double w = document.pages[0].getClientSize().width;
    double h = document.pages[0].getClientSize().height;
    print("$w::$h");

    print("identificadorEntrante::${mp.id}");
    ModelFormula mf = await ApiFormulas().getId(mp.idFormula);
    print("requestEntrante::${mf.codProdRes}-${mf.titulo}");
    MakePdf().margin(page, w, h);
    await MakePdf().head(page, w, h,'REGISTRO DE PROCESO \nDE PRODUCCION');
    List<String> title = ["PROCESO DE PRODUCCION:\t${mf.codProdRes}-${mf.titulo}",
      "CANTIDAD A PRODUCIR:\t${mp.cantidad} ${mf.unidadMedida}","LINEA DE PRODUCCION:\t${mf.lineaProduccionTitulo}","CLIENTE:\t${mf.razonSocial}"];
    List<String> titles2 = ["",
      "LOTE DE PRODUCCION:\t${mp.loteProd}","",""];
    MakePdf().sector(page, 5, w-5,90,210,true,title,titles2);
    List<String> title1 = ["FECHA DE INICIO:","LOTE DE VENTA:","RESPONSABLE DE ELABORACION:"];
    List<String> titles12 = ["FECHA DE FIN:","FECHA DE VENCIMIENTO:",""];
    MakePdf().sector(page, 5, w-5,220,310,true,title1,titles12);
    double heightRes = (((h-90)-(310))/2)-10;

    PdfGrid grid = PdfGrid();
    grid.columns.add(count: 6);
    grid.headers.add(1);
    grid.columns[1].width = 200;
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'CODIGO';
    header.cells[1].value = 'PRODUCTO';
    header.cells[2].value = 'UNIDAD';
    header.cells[3].value = 'CANTIDAD RECETA';
    header.cells[4].value = 'CANTIDAD UTILIZADA';
    header.cells[5].value = 'LOTE UTILIZADO';

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
    List<ModelIngredientesFormulas> inList = List();
    List<ModelIngredientesFormulas> outList = List();
    print("IDPP::${mp.id}");
    await ApiProcesosProduccion().getIngredientes(mp.id).then((value){
      value.forEach((element) {
        if (element.tipo == 0)
          inList.add(element);
        else
          outList.add(element);
      });
      });
    inList.forEach((element) {
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.codProd;
      row.cells[1].value = element.nombreProd;
      row.cells[2].value = element.unidad;
      row.cells[3].value = ((mp.cantidad*element.cantProd)/outList[0].cantProd).toStringAsFixed(2);
      row.cells[4].value = '';
      row.cells[5].value = '';
      grid.rows[inList.indexOf(element)].height = 23;
    });
    for(int i=inList.length;i<6;i++){
      PdfGridRow row = grid.rows.add();
      row.cells[0].value = '';
      row.cells[1].value = '';
      row.cells[2].value = '';
      row.cells[3].value = '';
      row.cells[4].value = '';
      row.cells[5].value = '';
      grid.rows[i].height = 23;
    }

    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,320,320+heightRes,"UTILIZACION DE MATERIALES",grid);

    PdfGrid grid1 = PdfGrid();
    grid1.columns.add(count: 6);
    grid1.headers.add(1);
    grid1.columns[1].width = 200;
    PdfGridRow header1 = grid1.headers[0];
    header1.cells[0].value = 'CODIGO';
    header1.cells[1].value = 'PRODUCTO';
    header1.cells[2].value = 'UNIDAD';
    header1.cells[3].value = 'CANTIDAD RECETA';
    header1.cells[4].value = 'CANTIDAD OBTENIDA';
    header1.cells[5].value = 'LOTE OBTENIDO';

    header1.cells[0].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);
    header1.cells[1].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);
    header1.cells[2].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);
    header1.cells[3].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);
    header1.cells[4].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);
    header1.cells[5].stringFormat = PdfStringFormat(alignment: PdfTextAlignment.center,lineAlignment: PdfVerticalAlignment.middle);

    print("${outList.length}");
    outList.forEach((element) {
      int index=outList.indexOf(element);
      PdfGridRow row = grid1.rows.add();
      row.cells[0].value = element.codProd;
      row.cells[1].value = element.nombreProd;
      row.cells[2].value = element.unidad;
      print("$index::${outList[0].cantProd}::${mp.cantidad}");
      row.cells[3].value = index==0?mp.cantidad.toStringAsFixed(2):((mp.cantidad*element.cantProd)/outList[0].cantProd).toStringAsFixed(2);
      row.cells[4].value = '';
      row.cells[5].value = '';
      grid1.rows[outList.indexOf(element)].height = 23;
    });
    for(int i=outList.length;i<6;i++){
      PdfGridRow row = grid1.rows.add();
      row.cells[0].value = '';
      row.cells[1].value = '';
      row.cells[2].value = '';
      row.cells[3].value = '';
      row.cells[4].value = '';
      row.cells[5].value = '';
      grid1.rows[i].height = 23;
    }

    grid1.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 3, top: 4, bottom: 5),
        // backgroundBrush: PdfBrushes.blue,
        textBrush: PdfBrushes.black,
        font: PdfStandardFont(PdfFontFamily.timesRoman, 8)
    );
    MakePdf().sectorTables(page, w, h, 5, w-5,330+heightRes,330+(heightRes*2),"PRODUCTO OBTENIDO",grid1);
    MakePdf().sectorObservacion(page, 5, w-5,h-85,h-5,"OBSERVACIONES:","");

    List<int> bytes = document.save();
    document.dispose();

    js.context['pdfData'] = base64.encode(bytes);
    js.context['filename'] = '$nombre.pdf';
    Timer.run(() {
      js.context.callMethod('download');
    });
  }

  formularioVariacion() {
    return StatefulBuilder(
      builder: (context, setState) {
        listRefresh = setState;
        return FutureBuilder<List<ModelProcesoProduccion>>(
          future: ApiProcesosProduccion().getPendientesAprob(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              return SomethingWentWrongPage();
            if(snapshot.connectionState==ConnectionState.done){
              TextStyle style = TextStyle(fontSize: 12);
              print(snapshot.data.map((e) => e.toJson()));
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
                          )
                      ),
                      Container(
                          width: double.infinity,
                          height: 50,
                          padding: EdgeInsets.all(5),
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueGrey, width: .5),
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                hintText: "Buscar Lote de Produccion"
                            ),
                            onChanged: (value) {
                              stateList(() {
                                ppFilter = pp.where((element) => element.loteProd.contains(value)).toList();
                              });
                            },
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            headerListCustom("Fecha Registro", 1,(){
                              stateList((){
                                if(sortFecReg==0) {
                                  sortFecReg=1;
                                  ppFilter.sort((a, b) =>
                                      a.createAt.compareTo(b.createAt));
                                }else {
                                  sortFecReg=0;
                                  ppFilter.sort((a, b) =>
                                      b.createAt.compareTo(a.createAt));
                                }
                              });
                            }),
                            headerListCustom("Lote Proceso", 1,(){
                              stateList((){
                                if(sortLote==0) {
                                  sortLote=1;
                                  ppFilter.sort((a, b) =>
                                      a.loteProd.compareTo(b.loteProd));
                                }else {
                                  sortLote=0;
                                  ppFilter.sort((a, b) =>
                                      b.loteProd.compareTo(a.loteProd));
                                }
                              });
                            }),
                            headerListCustom("Cantidad", 1,(){
                              stateList((){
                                if(sortCantidad==0) {
                                  sortCantidad=1;
                                  ppFilter.sort((a, b) =>
                                      a.cantidad.compareTo(b.cantidad));
                                }else {
                                  sortCantidad=0;
                                  ppFilter.sort((a, b) =>
                                      b.cantidad.compareTo(a.cantidad));
                                }
                              });
                            }),
                            headerListCustom("Producto", 4,(){
                              stateList((){
                                if(sortNameProd==0) {
                                  sortNameProd=1;
                                  ppFilter.sort((a, b) =>
                                      a.nombreProducto.substring(0,1).compareTo(b.nombreProducto.substring(0,1)));
                                }else {
                                  sortNameProd=0;
                                  ppFilter.sort((a, b) =>
                                      b.nombreProducto.substring(0,1).compareTo(a.nombreProducto.substring(0,1)));
                                }
                              });
                            }),
                            headerListCustom("Acciones", 1,(){})
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 8,bottom: 8,right: 8),
                          // height: MediaQuery.of(context).size.height-300,
                          child: Scrollbar(
                            controller: scroll1,
                            isAlwaysShown: true,
                            child: StatefulBuilder(
                              builder: (context, setState) {
                                stateList = setState;
                                return ListView.builder(
                                  controller: scroll1,
                                  itemCount: ppFilter.length,
                                  itemBuilder: (context, index) {
                                    ModelProcesoProduccion e = ppFilter[index];
                                    return InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ModuleShowPP(procProd: e,refresh: listRefresh,),));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(color: Colors.blueGrey,width: .5)
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      DateFormat("dd/MM/yyyy").format(DateTime.parse(e.createAt)),
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Text(
                                                      e.loteProd,
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    e.cantidad.toStringAsFixed(2),
                                                    style: style,
                                                  ),
                                                )),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 4,
                                                child: Center(
                                                    child: Text(
                                                      e.nombreProducto,
                                                      style: style,
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
                                            Expanded(
                                                flex: 1,
                                                child: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        // InkWell(
                                                        //     onTap: () {
                                                        //     },
                                                        //     child: Icon(Icons.edit)),
                                                        InkWell(
                                                            onTap: () {

                                                            },
                                                            child: Icon(Icons.done, color: Colors.green,)),
                                                        InkWell(
                                                            onTap: () {

                                                            },
                                                            child: Icon(Icons.clear, color: Colors.red,))
                                                      ],
                                                    ))),
                                            Container(width: 1,height: 20,color: Colors.blueGrey,),
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
          },);
      },
    );
  }
}
