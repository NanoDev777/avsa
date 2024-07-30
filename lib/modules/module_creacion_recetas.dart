import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/utils/connections/api_formulas.dart';
import 'package:andeanvalleysystem/utils/connections/api_ingredientes_formula.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down_clientes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_productos.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/show_dialog_lotes_selection.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class ModuleCreacionRecetas extends StatefulWidget {
  @override
  _ModuleCreacionRecetasState createState() => _ModuleCreacionRecetasState();
}

class _ModuleCreacionRecetasState extends State<ModuleCreacionRecetas> {
  List<ModelProformaItems> items=List();
  String lotesUsados = "";
  StateSetter refreshList;
  StateSetter refreshData;
  Map<String,List<ModelLote>> lotesSelect = Map();
  ModelItem selectionItem;
  ModelItem itemEntradaSeleccionado;
  ModelItem itemSalidaSeleccionado;
  ModelCliente clienteSelection;
  int ordenEntrada=0;
  int ordenSalida=0;
  int clienteId=0;
  TextEditingController nombreReceta = TextEditingController();
  bool enabledCliente=true;
  List<ModelIngredientesFormulas> ingredientesEntrada = List();
  List<ModelIngredientesFormulas> ingredientesSalida = List();
  Map<String, TextEditingController> controllersCantidades= Map();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: StatefulBuilder(
            builder: (context, setState) {
              refreshData = setState;
              return Column(
                children: [
                  DropDownProductos(selectionItem: selectionItem,func: (val){
                    refreshData(() {
                      selectionItem = val;
                      nombreReceta.text = selectionItem.nombre;
                      List<String> codData = selectionItem.codigo.split('-');
                      if (codData.length > 1){
                        clienteId = int.parse(codData[1]);
                        enabledCliente=false;
                      }
                      ingredientesSalida.add(ModelIngredientesFormulas(
                        codProd: selectionItem.codigo,
                        estado: 1,
                        nombreProd: selectionItem.nombre,
                        tipo: 1,
                        orden: ordenSalida,
                        usrReg: 6,
                        cantProd: 0,
                        costoAdicional: 0,
                          guidForm: 0,
                        unidad: selectionItem.titulo
                      ));
                      ordenSalida++;
                      controllersCantidades[selectionItem.codigo] = TextEditingController();
                    });
                  },),
                  DropDownClientes(clienteSelection: clienteSelection, id: clienteId, all: true,enabled: enabledCliente,),
                  TextBoxCustom(hint: "NOMBRE DE LA RECETA",controller: nombreReceta,enabled: false,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                          child: DropDownProductos(selectionItem: itemEntradaSeleccionado,func: (val){
                            itemEntradaSeleccionado = val;
                          },label: "SELECCIONAR MATERIA PRIMA",)),
                      Expanded(
                        flex: 2,
                          child: WidgetButtons(txt: "Agregar",func: (){
                            bool ac = true;
                            ingredientesEntrada.forEach((element) {
                              if(element.codProd==itemEntradaSeleccionado.codigo)
                                ac=false;
                            });
                            if(selectionItem!=null){
                              if(ac){
                                refreshData((){
                                  ingredientesEntrada.add(ModelIngredientesFormulas(
                                      codProd: itemEntradaSeleccionado.codigo,
                                      estado: 1,
                                      nombreProd: itemEntradaSeleccionado.nombre,
                                      tipo: 0,
                                      orden: ordenEntrada,
                                      usrReg: 6,
                                      cantProd: 0,
                                      costoAdicional: 0,
                                      guidForm: 0,
                                      unidad: itemEntradaSeleccionado.titulo
                                  ));
                                  ordenEntrada++;
                                  controllersCantidades[itemEntradaSeleccionado.codigo] = TextEditingController();
                                });
                              }else Toast.show("El Producto ya existe", context);
                            }else Toast.show("Necesita un Producto principal", context);
                          },))
                    ],
                  ),
                  listaItemsEntrada(),

                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                          child: DropDownProductos(selectionItem: itemSalidaSeleccionado,func: (val){
                            itemSalidaSeleccionado = val;
                          },label: "SELECCIONAR PRODUCTO DE SALIDA",)),
                      Expanded(
                        flex: 2,
                          child: WidgetButtons(txt: "Agregar",func: (){
                            bool ac = true;
                            ingredientesSalida.forEach((element) {
                              if(element.codProd==itemSalidaSeleccionado.codigo)
                                ac=false;
                            });
                            if(selectionItem!=null){
                              if(ac){
                                refreshData((){
                                  ingredientesSalida.add(ModelIngredientesFormulas(
                                      codProd: itemSalidaSeleccionado.codigo,
                                      estado: 1,
                                      nombreProd: itemSalidaSeleccionado.nombre,
                                      tipo: 1,
                                      orden: ordenSalida,
                                      usrReg: 6,
                                      cantProd: 0,
                                      costoAdicional: 0,
                                      guidForm: 0,
                                      unidad: itemSalidaSeleccionado.titulo
                                  ));
                                  ordenSalida++;
                                  controllersCantidades[itemSalidaSeleccionado.codigo] = TextEditingController();
                                });
                              }else Toast.show("El Producto ya existe", context);
                            }else Toast.show("Necesita un Producto principal", context);
                          },)),
                    ],
                  ),
                  listaItemsSalida(),

                  SizedBox(height: 10,),
                  WidgetButtons(txt: "Crear Receta",func: (){
                    ModelFormula formula = ModelFormula(
                      titulo: selectionItem.nombre,
                      codProdRes: selectionItem.codigo,
                      cantidad: 0,
                      instruccion: "",
                      lineaProduccion: 0,
                      version: 1,
                      cliente: selectionItem.cliente,
                      estado: 1,
                      usrReg: 6
                    );
                    ApiFormulas().make(formula).then((value){
                      ingredientesEntrada.forEach((element) {
                        element.guidForm = value.id;
                        element.cantProd = double.parse(controllersCantidades[element.codProd].text);
                      });
                      ingredientesSalida.forEach((element) {
                        element.guidForm = value.id;
                        element.cantProd = double.parse(controllersCantidades[element.codProd].text);
                      });
                      List<ModelIngredientesFormulas> ingredientes = List();
                      ingredientes.addAll(ingredientesEntrada);
                      ingredientes.addAll(ingredientesSalida);
                      ApiIngredientesFormulas().make(ingredientes).whenComplete((){
                        Toast.show("FORMULA CREADA CORRECTAMENTE", context);
                      });
                    });
                  },)
                ],
              );
            }
          )
        ),
      ),
    );
  }

  listaItemsEntrada() {
    return ListCustom(
      modelHeaderList: [
        ModelHeaderList(title: "CODIGO", flex: 1),
        ModelHeaderList(title: "PRODUCTO", flex: 3),
        ModelHeaderList(title: "UNIDAD", flex: 1),
        ModelHeaderList(title: "CANTIDAD", flex: 1)
      ],
      title: "PRODUCTOS DE ENTRADA",
      datos: ingredientesEntrada.map((e) {
        return Column(
          children: [
            InkWell(
              onTap: () {
              },
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        e.codProd,
                      )),
                  Expanded(
                      flex: 3,
                      child: Text(
                        e.nombreProd,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        e.unidad,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: TextBoxCustom(hint: "Cant.",controller: controllersCantidades[e.codProd]),),
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
  }

  listaItemsSalida() {
    return ListCustom(
      modelHeaderList: [
        ModelHeaderList(title: "CODIGO", flex: 1),
        ModelHeaderList(title: "PRODUCTO", flex: 3),
        ModelHeaderList(title: "UNIDAD", flex: 1),
        ModelHeaderList(title: "CANTIDAD", flex: 1)
      ],
      title: "PRODUCTOS DE SALIDA",
      datos: ingredientesSalida.map((e) {
        return Column(
          children: [
            InkWell(
              onTap: () {
              },
              child: Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Text(
                        e.codProd,
                      )),
                  Expanded(
                      flex: 3,
                      child: Text(
                        e.nombreProd,
                      )),
                  Expanded(
                      flex: 1,
                      child: Text(
                        e.unidad,
                        textAlign: TextAlign.center,
                      )),
                  Expanded(
                      flex: 1,
                      child: TextBoxCustom(hint: "Cant.",controller: controllersCantidades[e.codProd]),),
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
  }
}
