import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/utils/connections/api_inventario.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class SelectLotesDialog{
  final BuildContext context;
  List<TextEditingController> lte = List();
  Function func;

  SelectLotesDialog({this.context,this.func});

  generateDialog(ModelSolicitudTransferencia m,int codAlm, String codProd){
    ApiInventory()
        .getLotes(codAlm, codProd)
        .then((value) {
      if(value!=null && value.length>0)
        _showDialog(value,m);
      else Toast.show("No Existen Productos En tu Almacen", context, duration:Toast.LENGTH_LONG);
    });
  }

  Future<void> _showDialog(List<ModelLote> lotes, ModelSolicitudTransferencia m) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
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
                                    Text("${m.codProd} - ${m.nombre}"),
                                    Text("Cantidad Solicitada: ${m.cantidad}"),
                                    Row(
                                      children: [
                                        headerListCustom("Lote", 1),
                                        headerListCustom("Cantidad", 1),
                                        headerListCustom("Usar", 1),
                                      ],
                                    ),
                                    Column(
                                      children: lotes.map((e) {
                                        String err;
                                        lte.add(TextEditingController());
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
                                                    e.cantidad.toStringAsFixed(2),
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
                                                        lte[lotes.indexOf(e)],
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
                                  func(lotes);
                                  Navigator.of(context).pop();
                                }//() {
                                  // item.lotes.clear();
                                  // item.cantidad = 0;
                                  // double cantTotal=0;
                                  // lotes.forEach((element) {
                                  //   if (element.cantidadUsada != null &&
                                  //       element.cantidadUsada > 0) {
                                  //     item.lotes.add(element);
                                  //     cantTotal+=element.cantidadUsada;
                                  //   }
                                  // });
                                  // item.cantidad = cantTotal;
                                  // item.costoTotalReal=double.parse(cantTotal.toStringAsFixed(2))*
                                  //     double.parse(item.costoUnit.toStringAsFixed(2));
                                  // item.costoTotalReceta=double.parse(item.cantidadRequerida.toStringAsFixed(2))*
                                  //     double.parse(item.costoUnit.toStringAsFixed(2));
                                  // refresh();
                                  //Navigator.of(context).pop();
                                //},
                              ),
                            ],
                          ))
                    ],
                  );
                },
              ));
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