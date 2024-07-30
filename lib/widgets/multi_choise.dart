import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_productos.dart';
import 'package:flutter/material.dart';
class MultiChoise {
  ScrollController sc = ScrollController();
  List<ModelItem> itemsSelect = List();
  Future<void> ProductMultichoiseXClientes(BuildContext context,ModelCliente cliente, List<ModelItem> itSelect, Function func(List<ModelItem> val))async{
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          if (cliente.id>=55 && cliente.id<=67)
            cliente.id = 1;
          return FutureBuilder<List<ModelItem>>(
            future: ApiProductos().getProdClientes(cliente!=null?cliente.id:-1),
              builder: (context, snapshot) {
                if(snapshot.hasError)SomethingWentWrongPage();
                if(snapshot.connectionState == ConnectionState.done){
                  List<ModelItem> items = snapshot.data;
                  items.forEach((element) {
                    itSelect.forEach((element1) {
                      if(element.codigo == element1.codigo){
                        element.precio = element1.precio;
                        element.cantidad = element1.cantidad;
                        itemsSelect.add(element);
                      }
                    });
                  });
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text("PRODUCTOS PARA ${cliente!=null?cliente.razonSocial:"SIN CLIENTE"}"),
                        content: Container(
                          width: MediaQuery.of(context).size.width*0.80,
                          height: MediaQuery.of(context).size.height*0.80,
                          child: Scrollbar(
                            controller: sc,
                            isAlwaysShown: true,
                            child: items.length>0?ListView.separated(
                              controller: sc,
                                itemBuilder: (context, index) {
                                ModelItem mi = items[index];
                                  return Row(
                                    children: [
                                      Checkbox(value: itemsSelect.contains(mi)?true:false, onChanged: (val){
                                        setState((){
                                          if(val)
                                            itemsSelect.add(mi);
                                          else
                                            itemsSelect.remove(mi);
                                        });
                                      }),
                                      Text("${mi.codigo} - "),
                                      Text(mi.nombre)
                                    ],
                                  );
                                },
                                separatorBuilder: (context, index) => Divider(),
                                itemCount: items.length
                            ):Container(child: Center(child: Text("NO EXISTEN PRODUCTOS PARA ESTE CLIENTE"),),),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('AGREGAR PRODUCTOS'),
                            onPressed: () {
                              func(itemsSelect);
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('CANCELAR'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                }
                return LoadingPage();
              },
          );
        },
    );
  }
}