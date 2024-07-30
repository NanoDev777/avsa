import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
class UtilsDialog{
  BuildContext context;
  ScrollController scroll;
  ModelInventario modelInventario;

  UtilsDialog({this.modelInventario,this.context, this.scroll});

  List<TextEditingController> listaTextEdditors = List();
  Future<void> showDialog2(ModelInventario modelInventario, int codAlm, String codProd, Function functions(ModelInventario val,
      List<ModelLote> lotes)) async {
    listaTextEdditors.clear();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return FutureBuilder<List<ModelLote>>(
            future: ApiInventory().getLotes(codAlm, codProd),
            builder: (context, snapshot) {
              if(snapshot.hasError)
                return SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                List<ModelLote> lotes = snapshot.data;
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
                                                listaTextEdditors.add(TextEditingController());
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
                                                            NumberFunctions.formatNumber(e.cantidad, 3), //e.cantidad.toStringAsFixed(2),
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
                                                                listaTextEdditors[lotes.indexOf(e)],
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
                                      func: (){
                                        bool correcto=true;
                                        lotes.forEach((element) {
                                          print("${listaTextEdditors[lotes.indexOf(element)].text}<${element.cantidad} && "
                                              "${element.cantidadUsada}>0&&${correcto}&&${element.cantidadUsada.toString()}");
                                          if(listaTextEdditors[lotes.indexOf(element)].text.isNotEmpty){
                                            if(double.parse(listaTextEdditors[lotes.indexOf(element)].text)<=element.cantidad &&
                                                double.parse(listaTextEdditors[lotes.indexOf(element)].text)>0
                                                &&correcto)
                                              correcto=true;
                                            else correcto=false;
                                          }
                                        });
                                        if(correcto){
                                          modelInventario.lotes.clear();
                                          modelInventario.cantidad = 0;
                                          double cantTotal=0;
                                          lotes.forEach((element) {
                                            if (element.cantidadUsada != null &&
                                                element.cantidadUsada > 0) {
                                              modelInventario.lotes.add(element);
                                              cantTotal+=element.cantidadUsada;
                                            }
                                          });
                                          modelInventario.cantidadTotalLotes = cantTotal;
                                          functions(modelInventario,lotes);
                                          Navigator.of(context).pop();
                                        }else Toast.show("ALGUNAS CANTIDADES SON INCORRECTAS", context);
                                      },
                                    ),
                                  ],
                                ))
                          ],
                        );
                      },
                    ));
              }
              return LoadingPage();
            },
          );
        });
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
}
