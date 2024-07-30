import 'package:andeanvalleysystem/models/model_area_solicitante.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_area_solicitante.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ModuleCreacionAreaSolicitud extends StatefulWidget {
  @override
  _ModuleCreacionAreaSolicitudState createState() => _ModuleCreacionAreaSolicitudState();
}

class _ModuleCreacionAreaSolicitudState extends State<ModuleCreacionAreaSolicitud> {

  List<ModelAreaSolicitante> areas = List();
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
                  ModelAreaSolicitante ma = ModelAreaSolicitante(
                    nombre: ecNombre.text,
                    estado: 1,
                    creado_en: DateFormat("dd/MM/yyyy").format(DateTime.now()),
                    idUsr: 1,
                  );
                  ApiAreaSolicitante().make(ma).whenComplete((){
                    setState(() {
                      areas.add(ma);
                      Toast.show("Area Creada con Exito", context);
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
              future: ApiAreaSolicitante().get(),
              builder: (context, snapshot) {
                if(snapshot.hasError) return SomethingWentWrongPage();
                if(snapshot.connectionState == ConnectionState.done){
                  areas = snapshot.data;
                  return ListView.builder(
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          Text(areas[index].nombre)
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
