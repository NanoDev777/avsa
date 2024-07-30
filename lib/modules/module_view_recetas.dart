import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_formulas.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/widgets/listas_custom.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ModuleViewRecetas extends StatefulWidget {
  @override
  _ModuleViewRecetasState createState() => _ModuleViewRecetasState();
}

class _ModuleViewRecetasState extends State<ModuleViewRecetas> {
  TextEditingController ecSearch = TextEditingController();
  ScrollController scroll = ScrollController();
  StateSetter refreshList;
  List<ModelFormula> formula;
  List<ModelFormula> formulaFilter = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: ApiFormulas().get(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return SomethingWentWrongPage();
            if (snapshot.connectionState == ConnectionState.done) {
              formula = snapshot.data;
              formulaFilter.addAll(formula);
              return Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    flex: 1,
                    child: TextBoxCustom(
                      hint: "BUSCADOR",
                      controller: ecSearch,
                      onChange: (value){
                        refreshList((){
                          formulaFilter.clear();
                          print(value);
                          if(value=="") {
                            print("if::$value");
                            formulaFilter.addAll(formula);
                          }else{
                            print("else::$value::${formula.length}");
                            formula.forEach((element) {
                              if(element.titulo.toLowerCase().contains(value.toLowerCase()) || element.codProdRes.contains(value)){
                                formulaFilter.add(element);
                              }
                            });
                          }
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Row(
                            children: [
                              WidgetHeaderList(text: "CODIGO",flex: 1,),
                              WidgetHeaderList(text: "FORMULA",flex: 3,),
                              WidgetHeaderList(text: "INSTRUCCION",flex: 3,),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: StatefulBuilder(
                            builder: (context, setState) {
                              refreshList = setState;
                              return Scrollbar(
                                controller: scroll,
                                isAlwaysShown: true,
                                child: ListView.separated(
                                  controller: scroll,
                                  itemCount: formulaFilter.length,
                                  separatorBuilder: (context, index) => Divider(),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: (){
                                        _showDialog(formulaFilter[index]);
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(flex:1,child: Container(
                                              padding: EdgeInsets.only(left: 3,right: 3),
                                              child: Text(formulaFilter[index].codProdRes))
                                          ),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.blueGrey,
                                          ),
                                          Expanded(flex:3,child: Container(
                                              padding: EdgeInsets.only(left: 3,right: 3),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(formulaFilter[index].titulo, textAlign: TextAlign.left,),
                                                  Text(formulaFilter[index].razonSocial!=null?formulaFilter[index].razonSocial:"",
                                                  style: TextStyle(fontSize: 10), textAlign: TextAlign.left,),
                                                ],
                                              ))),
                                          Container(
                                            width: 1,
                                            height: 20,
                                            color: Colors.blueGrey,
                                          ),
                                          Expanded(flex:3,child: Container(
                                              padding: EdgeInsets.only(left: 3,right: 3),
                                              child: Text(formulaFilter[index].instruccion))),
                                        ],
                                      ),
                                    );
                                  },),
                              );
                            },
                          )
                        ),
                      ],
                    )
                  )
                ],
              );
            }
            return LoadingPage();
          },
        ));
  }
  Future<void> _showDialog(ModelFormula f) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return FutureBuilder(
          future: ApiFormulas().getIngredientes(f.guidForm),
            builder:(context, snapshot) {
              if(snapshot.hasError)
                return SomethingWentWrongPage();
              if(snapshot.connectionState==ConnectionState.done){
                List<ModelIngredientesFormulas> ing = snapshot.data;
                List<ModelIngredientesFormulas> inIng = List();
                List<ModelIngredientesFormulas> outIng = List();
                ing.forEach((element) {
                  if(element.tipo==0)
                    inIng.add(element);
                  else outIng.add(element);
                });
                TextStyle style = TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

                return AlertDialog(
                  title: Text('DETALLES RECETA'),
                  content: Container(
                    width: MediaQuery.of(context).size.width*.8,
                    height: MediaQuery.of(context).size.height*.8,
                    child: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text("TITULO FORMULA: ${f.titulo}", style: style,),
                          Text("PRODUCTO TERMINADO: ${f.codProdRes}-${f.titulo}", style: style,),
                          ListCustom(
                            modelHeaderList: [
                              ModelHeaderList(title: "CODIGO", flex: 1),
                              ModelHeaderList(title: "DESCRIPCION", flex: 2),
                              ModelHeaderList(title: "UNIDAD", flex: 1),
                            ],
                            title: "INGREDIENTES ENTRANTES",
                          datos: inIng.map((e){
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        flex:1,
                                        child: Text(e.codProd)),
                                    Expanded(
                                        flex: 2,
                                        child: Text(e.nombreProd)),
                                    Expanded(
                                        flex: 1,
                                        child: Text(e.unidad)),
                                  ],
                                ),
                                Container(height: 1,color: Colors.grey,)
                              ],
                            );
                          }).toList(),
                          ),
                          ListCustom(
                            modelHeaderList: [
                              ModelHeaderList(title: "CODIGO", flex: 1),
                              ModelHeaderList(title: "DESCRIPCION", flex: 2),
                              ModelHeaderList(title: "UNIDAD", flex: 1),
                            ],
                            title: "PRODUCTO OBTENIDO",
                            datos: outIng.map((e){
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex:1,
                                          child: Text(e.codProd)),
                                      Expanded(
                                        flex: 2,
                                          child: Text(e.nombreProd)),
                                      Expanded(
                                        flex: 1,
                                          child: Text(e.unidad)),
                                    ],
                                  ),
                                  Container(height: 1,color: Colors.grey,)
                                ],
                              );
                            }).toList(),),
                          Text("INSTRUCCIONES: ${f.instruccion!=null||f.instruccion.isNotEmpty?f.instruccion:"SIN INSTRUCCIONES"}", style: style,)
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('ACEPTAR'),
                      onPressed: () {
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
              }
              return LoadingPage();
            },
        );
      },
    );
  }
}
