import 'package:andeanvalleysystem/models/model_area_solicitante.dart';
import 'package:andeanvalleysystem/models/model_motivos.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_area_solicitante.dart';
import 'package:andeanvalleysystem/utils/connections/api_motivos.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ModuleCreacionMotivo extends StatefulWidget {
  @override
  _ModuleCreacionMotivoState createState() => _ModuleCreacionMotivoState();
}

class _ModuleCreacionMotivoState extends State<ModuleCreacionMotivo> {

  List<ModelMotivos> motivo = List();
  TextEditingController ecNombre = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Expanded(flex: 9,child: TextBoxCustom(hint: "NOMBRE",controller: ecNombre)),
                Expanded(flex: 1,child: WidgetButtons(txt: "AGREGAR",func: (){
                  ModelMotivos ma = ModelMotivos(
                    nombre: ecNombre.text,
                    estado: 1,
                    creado_en: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                    idUsr: 1,
                  );
                  ApiMotivos().make(ma).whenComplete((){
                    setState(() {
                      motivo.add(ma);
                      Toast.show("Motivo Creada con Exito", context);
                      ecNombre.text="";
                    });
                  });
                },))
              ],
            ),
          ),
          Expanded(
              flex: 9,
              child: FutureBuilder(
                future: ApiMotivos().get(),
                builder: (context, snapshot) {
                  if(snapshot.hasError) return SomethingWentWrongPage();
                  if(snapshot.connectionState == ConnectionState.done){
                    motivo = snapshot.data;
                    return ListView.builder(
                      itemCount: motivo.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Text(motivo[index].nombre)
                          ],
                        );
                      },);
                  }
                  return LoadingPage();
                },
              )
          )
        ],
      ),
    );
  }
}
