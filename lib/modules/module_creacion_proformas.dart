import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;

import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_precios.dart';
import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/models/model_subcliente.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/utils/connections/api_precios.dart';
import 'package:andeanvalleysystem/utils/connections/api_proformas.dart';
import 'package:andeanvalleysystem/utils/connections/api_subclientes.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/utils/make_pdf.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/drop_down_clientes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_precios.dart';
import 'package:andeanvalleysystem/widgets/drop_down_precios_all.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:andeanvalleysystem/widgets/drop_down_subclientes.dart';
import 'package:andeanvalleysystem/widgets/multi_choise.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toast/toast.dart';
class ModuleCreacionProformas extends StatefulWidget {
  final ModelProforma proforma;
  final List<ModelProformaItems> items;
  final StateSetter refresh;
  final int tipoCliente;
  ModuleCreacionProformas({Key key,this.proforma,this.items, this.refresh,this.tipoCliente}):super(key:key);
  @override
  _ModuleCreacionProformasState createState() => _ModuleCreacionProformasState();
}

class _ModuleCreacionProformasState extends State<ModuleCreacionProformas> {
  ModelCliente clientSelect;
  ModelSubCliente subClientSelect;
  ModelPrecios priceSelect;
  ModelItem productSelect;
  TextEditingController tipoPagoSelect= TextEditingController();
  List<ModelPrecios> listPrices = List();
  ModelPrecios precioUnitarioSelect;
  TextEditingController ecCantidad = TextEditingController();
  TextEditingController ecObs = TextEditingController();
  TextEditingController ecCodigo = TextEditingController();
  List<ModelPrecios> listSelectPrecios = List();
  
  List<TextEditingController> ecPrecios = List();
  List<TextEditingController> ecCantidades = List();
  List<ModelItem> itemsSeleccionadosDialog = List();

  StateSetter refreshList;
  bool activo = true;
  bool load=false;

  String codProforma;
  ModelItem selectionItem;
  ScrollController scroll = ScrollController();
  StateSetter refresList;
  StateSetter refresDropDownProd;

  clear(){
    selectionItem = null;
    ecCantidad.text = "";
  }
  clearAll(){
    if(this.mounted){
      setState(() {
        load=false;
        activo=true;
        ecCodigo.text="";
        clientSelect=null;
        subClientSelect=null;
        priceSelect=null;
        selectionItem=null;
        ecCantidad=null;
        listSelectPrecios.clear();
      });
    }
  }
  List<ModelCliente> listClient=List();
  List<ModelSubCliente> listSubClient=List();
  List<ModelPrecios> listPrecios=List();

  Future getData()async{
    if(listClient.length==0){
      if(widget.tipoCliente==2){
        List<ModelCliente> listClientNac = List();
        listClientNac = await ApiCliente().getNacional();
        listClientNac.forEach((element) {
          if(element.estado==1)listClient.add(element);
        });
      }else if(widget.tipoCliente==1){
        List<ModelCliente> listClientNac = List();
        listClientNac = await ApiCliente().getExterior();
        listClientNac.forEach((element) {
          if(element.estado==1)listClient.add(element);
        });
      }
    }
    print("${clientSelect.id}");
    if(clientSelect!=null){
      listSubClient = await ApiSubcliente().getxCliente(clientSelect!=null?clientSelect.id:-1);
    }
    if(clientSelect!=null){
      listPrecios = await ApiPrecios().getxCliente(clientSelect!=null?clientSelect.id:-1);
    }

    int n = await ApiProformas().count();
    n+=1;
    codProforma = "Prof-${n.toString().padLeft(4,'0')}";
    return true;
  }
  Future getDataEdit()async{
    if(listSelectPrecios.length==0){
      activo=false;
      ecCodigo.text = widget.proforma.codigo;
      widget.items.forEach((element) {
        listSelectPrecios.add(ModelPrecios(
            pesoNeto: element.pesoNeto,
            factor: 1,
            cod_cliente: "",
            precio_unitario: element.precio,
            codProd: element.codProd,
            nombre_grupo: "",
            estado: 1,
            id_cliente: widget.proforma.id_cliente,
            nombre: element.nameProd,
            nombre_cliente: widget.proforma.nombreCliente,
            cantidad: element.cantidad
        ));
        tipoPagoSelect.text = widget.proforma.id_tipo_pago;
        ecObs.text = widget.proforma.obs;
        TextEditingController e = TextEditingController();
        e.text = element.cantidad.toString();
        ecCantidades.add(e);
        TextEditingController p = TextEditingController();
        p.text = element.precio.toString();
        ecPrecios.add(p);
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle s = TextStyle(fontSize: 12);
    return Scaffold(
      body: Stack(
        children: [
          load?Container(
            color: Colors.black12,
            child: CircularProgressIndicator(
              color: Colors.red,

            ),
          ):Container(),
          FutureBuilder(
            future: widget.proforma!=null?getDataEdit():getData(),
            builder: (context, snapshot) {
              if(snapshot.hasError) SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                return Scrollbar(
                  controller: scroll,
                  isAlwaysShown: true,
                  child: SingleChildScrollView(
                    controller: scroll,
                    child: Column(
                      children: [
                        widget.tipoCliente==2?TextBoxCustom(
                          hint: "CODIGO PROFORMA",
                          controller: ecCodigo,
                          onChange: (val){

                          },
                        ):Container(),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropDownClientes(
                                id: widget.proforma!=null?widget.proforma.id_cliente:null,
                                listClient: listClient,
                                enabled: activo,
                                clienteSelection: clientSelect,
                                refresh: (val,v,ref){
                                  if(ref){
                                    setState(() {
                                      listClient.clear();
                                      listClient.addAll(v);
                                      subClientSelect=null;
                                      precioUnitarioSelect=null;
                                      productSelect=null;
                                      priceSelect=null;
                                      ecCantidad.text="";
                                      listPrices.clear();
                                      clientSelect = val;
                                    });
                                  }else{
                                    listClient.clear();
                                    listClient.addAll(v);
                                    subClientSelect=null;
                                    precioUnitarioSelect=null;
                                    productSelect=null;
                                    priceSelect=null;
                                    ecCantidad.text="";
                                    listPrices.clear();
                                    clientSelect = val;
                                  }
                                },
                              ),
                            ),
                            widget.tipoCliente==2?Expanded(
                              flex: 1,
                              child: DropDownSubClientes(
                                listSubCliente: listSubClient,
                                id: widget.proforma!=null?widget.proforma.id_subcliente:null,
                                id_cliente: widget.proforma!=null?widget.proforma.id_cliente:null,
                                enabled: activo,
                                clientSelect: clientSelect,
                                subclientSelection: subClientSelect,
                                refresh: (val,ref){
                                  if(ref){
                                    setState(() {
                                      subClientSelect = val;
                                    });
                                  }else subClientSelect = val;
                                },
                              ),
                            ):Container()
                          ],
                        ),
                        widget.tipoCliente==1?
                        Row(
                          children: [
                            Expanded(
                              flex:2,
                              child: TextBoxCustom(
                                hint: "LOTE DE VENTA",
                                controller: ecCodigo,
                                onChange: (val){

                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                                child: Text(" - ${clientSelect!=null?clientSelect.codigo:""}"))
                          ],
                        ):Container(),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropDownPrecios(
                                listPrecios: listPrecios,
                                id: widget.proforma!=null?widget.proforma.id_precio:null,
                                id_cliente: widget.proforma!=null?widget.proforma.id_cliente:null,
                                enabled: activo,
                                clientSelect: clientSelect,
                                precios: priceSelect,
                                refresh: (val,precio,ref){
                                  if (ref){
                                    setState(() {
                                      listPrices.clear();
                                      precioUnitarioSelect=null;
                                      priceSelect = precio;
                                      listPrices.addAll(val);
                                    });
                                  }else{
                                    listPrices.clear();
                                    precioUnitarioSelect=null;
                                    priceSelect = precio;
                                    listPrices.addAll(val);
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child:Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1,color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(flex:9,child:
                                        TextField(
                                          controller: tipoPagoSelect,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "TIPO DE PAGO",
                                            contentPadding: EdgeInsets.all(5)
                                          ),
                                        )
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: InkWell(
                                          onTap: (){
                                            _showDialogSelectTipoPago();
                                          },
                                          child: Icon(Icons.arrow_drop_down),
                                        ),
                                      )
                                    ],                                  
                                  ),
                                )
                                // DropdownSearch<String>(
                                //   selectedItem: tipoPagoSelect,
                                //   hint: "FORMA DE PAGO",
                                //
                                //   items: [
                                //     "EFECTIVO",
                                //     "TARJETA"
                                //   ],
                                //   onChanged: (v){
                                //     tipoPagoSelect=v;
                                //   },
                                // ),
                              ),
                            ),
                          ],
                        ),
                        // DropDownProductos(
                        //   soloCliente: true,
                        //   idCliente: clientSelect!=null?clientSelect.id:widget.proforma!=null?widget.proforma.id_cliente:-1,
                        //   selectionItem: selectionItem,
                        //   func: (val){
                        //     setState(() {
                        //       selectionItem=val;
                        //     });
                        //   },
                        // ),
                        Row(
                          children: [
                            // Expanded(
                            //   flex: 1,
                            //   child: TextBoxCustom(
                            //     hint: "CANTIDAD",
                            //     controller: ecCantidad,
                            //     onChange: (val){
                            //
                            //     },
                            //   ),
                            // ),
                            Expanded(
                              flex: 1,
                              child: TextBoxCustom(
                                hint: "OBSERVACIONES",
                                controller: ecObs,
                                onChange: (val){

                                },
                              ),
                            ),
                          ],
                        ),
                        WidgetButtons(txt: "ESCOGER PRODUCTOS", colorText: Colors.white,func: (){
                          itemsSeleccionadosDialog.clear();
                          listSelectPrecios.forEach((element) {
                            ModelItem mi = ModelItem(
                              codigo: element.codProd,
                            );
                            mi.cantidad = element.cantidad;
                            mi.precio = element.precio_unitario;
                            itemsSeleccionadosDialog.add(mi);
                          });
                          // ignore: missing_return
                          MultiChoise().ProductMultichoiseXClientes(context,clientSelect,itemsSeleccionadosDialog,(val){
                            setState(() {
                              listSelectPrecios.clear();
                              ecPrecios.clear();
                              ecCantidades.clear();
                              print("${val.length}");
                              itemsSeleccionadosDialog = val;
                              val.forEach((el) {
                                TextEditingController cant = TextEditingController();
                                TextEditingController pre = TextEditingController();
                                print("${el.precio}::${el.cantidad}");
                                double precio = el.precio!=null?el.precio:0;
                                double cantidad = el.cantidad!=null?el.cantidad:0;
                                pre.text = precio.toString();
                                listPrices.forEach((element) {
                                  if(element.codProd == el.codigo){
                                    pre.text = element.precio_unitario.toString();
                                  }
                                });
                                cant.text = cantidad.toString();
                                ecPrecios.add(pre);
                                ecCantidades.add(cant);

                                ModelPrecios mp = ModelPrecios(
                                    pesoNeto: el.pesoNeto,
                                    factor: el.factor,
                                    cod_cliente: clientSelect.codigo,
                                    precio_unitario: precio,
                                    codProd: el.codigo,
                                    nombre_grupo: "",
                                    estado: 1,
                                    id_cliente: clientSelect.id,
                                    nombre: el.nombre,
                                    nombre_cliente: clientSelect.razonSocial,
                                    cantidad: cantidad
                                );
                                listSelectPrecios.add(mp);
                              });
                              listSelectPrecios.sort((a,b)=>a.codProd.compareTo(b.codProd));
                              ecPrecios.clear();
                              ecCantidades.clear();
                              listSelectPrecios.forEach((element) {
                                TextEditingController ecp = TextEditingController();
                                TextEditingController ecc = TextEditingController();
                                ecp.text = element.precio_unitario.toString();
                                ecc.text = element.cantidad.toString();
                                ecPrecios.add(ecp);
                                ecCantidades.add(ecc);
                              });
                            });
                          });
                        },),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            WidgetHeaderList(text:"",flex: 1,height: 40,),
                            WidgetHeaderList(text:"CODIGO",flex: 1,height: 40,),
                            WidgetHeaderList(text:"PRODUCTO",flex: 3,height: 40,),
                            widget.tipoCliente==2?WidgetHeaderList(text:"PRECIO\n[Bs]",flex: 1,height: 40,):
                            WidgetHeaderList(text:"PRECIO\n[\u0024us/Tn]",flex: 1,height: 40,),
                            WidgetHeaderList(text:"CANTIDAD\n[UNIDADES]",flex: 1,height: 40,),
                            WidgetHeaderList(text:"CANTIDAD\n[CAJA/BOLSAS]",flex: 1,height: 40,),
                            WidgetHeaderList(text:"PESO TOTAL\n[KG]",flex: 1,height: 40,),
                            widget.tipoCliente==2?WidgetHeaderList(text:"VALOR TOTAL\n[Bs]",flex: 1,height: 40,):
                            WidgetHeaderList(text:"VALOR TOTAL\n[\u0024us]",flex: 1,height: 40,),
                          ],
                        ),
                        StatefulBuilder(
                            builder: (context, setState) {
                              // refreshList=setState;
                              return Container(
                                height: listSelectPrecios.length*60.0,
                                child: ListView.builder(
                                  itemCount: listSelectPrecios.length,
                                  itemBuilder: (context, index) {
                                    ModelPrecios e = listSelectPrecios[index];
                                    return Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: InkWell(
                                              onTap: (){
                                                setState((){
                                                  ecPrecios.removeAt(listSelectPrecios.indexOf(e));
                                                  ecCantidades.removeAt(listSelectPrecios.indexOf(e));
                                                  listSelectPrecios.remove(e);
                                                });
                                              },
                                              child: Icon(Icons.delete_forever),
                                            )
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Text(e.codProd, style: s,)
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Text(e.nombre, style: s,)
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Center(child: TextBoxCustom(
                                              controller: ecPrecios[index],
                                              hint: "Precio",
                                              onChange: (val){
                                                try{
                                                  double d = double.parse(val);
                                                  if(val.isNotEmpty){
                                                    setState((){
                                                      print("entro");
                                                      itemsSeleccionadosDialog[index].precio = d;
                                                      listSelectPrecios[index].precio_unitario = d;
                                                      // ecPrecios[listSelectPrecios.indexOf(e)].text = val;
                                                    });
                                                  }
                                                }catch(e){
                                                  Toast.show("Numero incorrecto", context);
                                                }
                                              },
                                            ))
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Center(child: TextBoxCustom(
                                              controller: ecCantidades[index],
                                              hint: "Cantidad",
                                              onChange: (val){
                                                try{
                                                  double d = double.parse(val);
                                                  if(val.isNotEmpty){
                                                    setState((){
                                                      print("entro");
                                                      itemsSeleccionadosDialog[index].cantidad = d;
                                                      listSelectPrecios[index].cantidad = d;
                                                      // ecCantidades[listSelectPrecios.indexOf(e)].text = val;
                                                    });
                                                  }
                                                }catch(e){
                                                  Toast.show("Numero incorrecto", context);
                                                }
                                              },
                                            ))
                                        ),
                                        Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: StatefulBuilder(
                                                builder: (context, setState) {
                                                  refreshList = setState;
                                                  print("${ecCantidades[index].text}::${ecPrecios[index].text}");
                                                  return Container(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                            flex: 1,
                                                            child: Center(child: Text("${NumberFunctions.formatNumber(double.parse(ecCantidades[index].text)/e.factor,3)}", style: s,))
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child: Center(child: Text(
                                                              "${NumberFunctions.formatNumber(e.pesoNeto*double.parse(ecCantidades[index].text),3)}", style: s,))
                                                        ),
                                                        Expanded(
                                                            flex: 1,
                                                            child: Center(child: widget.tipoCliente==2?
                                                            Text("${NumberFunctions.formatNumber(double.parse(ecCantidades[index].text)*
                                                                double.parse(ecPrecios[index].text),3)}", style: s,):

                                                            Text("${(double.parse(ecPrecios[index].text)/1000)*(e.pesoNeto*double.parse(ecCantidades[index].text))}", style: s,))
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ))
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
                        ),
                        SizedBox(height: 10,),
                        WidgetButtons(
                          colorText: Colors.white,
                          txt: widget.proforma!=null?"EDITAR PROFORMA":"CREAR PROFORMA",
                          func: (){
                            // impresionPDF("nombreDoc");
                            bool act=true;
                            ecPrecios.forEach((element) {
                              print(element.text);
                              if(double.parse(element.text)<=0)
                                act=false;
                            });
                            ecCantidades.forEach((element) {
                              print(element.text);
                              if(double.parse(element.text)<=0)
                                act=false;
                            });
                            if(act){
                              print("${ecCodigo.text.isNotEmpty}::${subClientSelect != null}::${clientSelect != null}::${tipoPagoSelect != null}::");
                              if (widget.proforma!=null || (ecCodigo.text.isNotEmpty && subClientSelect != null && clientSelect != null && tipoPagoSelect != null &&
                                  listSelectPrecios.length > 0)) {
                                if (widget.proforma == null) {
                                  ApiProformas().count().then((value) {
                                    SharedPreferences.getInstance().then((sp) {
                                      int c = value + 1;
                                      String codigo = "Prof-${c
                                          .toString()
                                          .padLeft(4, '0')}";
                                      ModelProforma prof = ModelProforma(
                                        codProf: widget.proforma!=null?widget.proforma.codProf:codigo,
                                          codigo: ecCodigo.text,
                                          id_cliente: widget.proforma!=null?widget.proforma.id_cliente:clientSelect.id,
                                          id_subcliente: widget.proforma!=null?widget.proforma.id_subcliente:subClientSelect.id,
                                          id_precio: widget.proforma!=null?widget.proforma.id_precio:priceSelect!=null?priceSelect.guia:0,
                                          id_tipo_pago: widget.proforma!=null?widget.proforma.id_tipo_pago:tipoPagoSelect.text,
                                          obs: widget.proforma!=null?widget.proforma.obs:ecObs.text,
                                          estado: widget.proforma!=null?widget.proforma.estado:0,
                                          fec_creacion: widget.proforma!=null?widget.proforma.fec_creacion:DateFormat("yyyy-MM-dd")
                                              .format(DateTime.now()),
                                          id_usuario: sp.getInt("sessionID")
                                      );
                                      ApiProformas().make(prof).then((value) {
                                        List<ModelProformaItems> mp = List();
                                        listSelectPrecios.forEach((element) {
                                          mp.add(ModelProformaItems(
                                              codProd: element.codProd,
                                              nameProd: element.nombre,
                                              cantidad: double.parse(
                                                  ecCantidades[listSelectPrecios
                                                      .indexOf(element)].text),
                                              idProforma: value.id,
                                              precio: double.parse(
                                                  ecPrecios[listSelectPrecios
                                                      .indexOf(element)].text),
                                              pesoNeto: element.pesoNeto,
                                              cantidadCajasBolsas: double.parse(
                                                  ecCantidades[listSelectPrecios
                                                      .indexOf(element)].text) /
                                                  element.factor,
                                              valorTotal: double.parse(
                                                  ecCantidades[listSelectPrecios
                                                      .indexOf(element)].text) *
                                                  double.parse(
                                                      ecPrecios[listSelectPrecios
                                                          .indexOf(element)]
                                                          .text)
                                          ));
                                        });
                                        ApiProformas()
                                            .insertItems(mp)
                                            .whenComplete(() {
                                          // Toast.show("PROFORMA CREADA", context);
                                          setState(() {
                                            load = true;
                                            _showDialog(value.id, value.codigo);
                                          });
                                        });
                                      });
                                    });
                                  });
                                } else {
                                  List<ModelProformaItems> mp = List();
                                  listSelectPrecios.forEach((element) {
                                    mp.add(ModelProformaItems(
                                        codProd: element.codProd,
                                        nameProd: element.nombre,
                                        cantidad: double.parse(
                                            ecCantidades[listSelectPrecios
                                                .indexOf(element)].text),
                                        idProforma: widget.proforma.id,
                                        precio: double.parse(
                                            ecPrecios[listSelectPrecios
                                                .indexOf(element)].text),
                                        pesoNeto: element.pesoNeto,
                                        cantidadCajasBolsas: double.parse(
                                            ecCantidades[listSelectPrecios
                                                .indexOf(element)].text) /
                                            element.factor,
                                        valorTotal: double.parse(
                                            ecCantidades[listSelectPrecios
                                                .indexOf(element)].text) *
                                            double.parse(
                                                ecPrecios[listSelectPrecios
                                                    .indexOf(element)].text)
                                    ));
                                  });
                                  widget.proforma.obs = ecObs.text;
                                  widget.proforma.id_tipo_pago = tipoPagoSelect.text;
                                  widget.proforma.codigo = ecCodigo.text;
                                  ApiProformas().update(widget.proforma, widget.proforma.id).whenComplete((){
                                    ApiProformas()
                                        .updateItems(mp, widget.proforma.id)
                                        .whenComplete(() {

                                      widget.refresh(() {Toast.show(
                                          "PROFORMA ACTUALIZADA", context);
                                      clearAll();
                                      Navigator.of(context).pop();
                                      });

                                    });
                                  });
                                }
                              } else
                                Toast.show("Faltan Datos Importantes", context);
                            }else Toast.show("HAY PRECIOS O CANTIDADES EN 0", context);
                          },
                        )
                      ],
                    ),
                  ),
                );
              }
              return LoadingPage();
            },
          )
        ],
      )
    );
  }
  Future<void> _showDialog(int id, String codigo) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('EXITO'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('LA PROFORMA SE GENERO CORRECTAMENTE.'),
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
            TextButton(
              child: Text('IMPRIMIR'),
              onPressed: () {
                String nameString = codigo.replaceAll('/', '-');
                js.context.callMethod('open', ['${ApiConnections().url}pdf/generateProf/$id/$nameString']);
                // ApiProformas().getPDF(id,codigo);
              },
            ),
          ],
        );
      },
    );
  }
  List<String> tiposDePago = [
    "EFECTIVO",
        "TARJETA"
  ];
  Future<void> _showDialogSelectTipoPago() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('TIPO DE PAGO'),
          content: Container(
            width: MediaQuery.of(context).size.width*.8,
            height: MediaQuery.of(context).size.height*.8,
            child: ListView.builder(
              itemCount: tiposDePago.length,
                itemBuilder: (context, index) {
                  String t = tiposDePago[index];
                  return Padding(
                    padding: EdgeInsets.all(5),
                    child: InkWell(
                      onTap: (){
                        setState(() {
                          tipoPagoSelect.text = t;
                          Navigator.of(context).pop();
                        });
                      },
                        child: Text(t)),
                  );
                },
            ),
          ),
        );
      },
    );
  }
}
