import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_parametros.dart';
import 'package:andeanvalleysystem/widgets/drop_down_clientes.dart';
import 'package:andeanvalleysystem/widgets/drop_down_unidad_medida.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:andeanvalleysystem/widgets/widget_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModuleCreacionProductos extends StatefulWidget {
  @override
  _ModuleCreacionProductosState createState() => _ModuleCreacionProductosState();
}

class _ModuleCreacionProductosState extends State<ModuleCreacionProductos> {
  TextEditingController codigoController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController factorController = TextEditingController();
  TextEditingController pesoNetoController = TextEditingController();
  TextEditingController pesoBrutoController = TextEditingController();
  ModelParametros parametrosSeleccionado;
  ModelCliente clienteSelect;
  List<String> categorias = [
    "MATERIA PRIMA",
    "INSUMOS E INGREDIENTES",
    "ENVASES Y EMBALAJES",
    "MATERIALES DE SOPORTE",
    "MANTENIMIENTO",
    "PT DE STOCK",
    "PRODUCTOS TERMINADOS"
  ];
  List<String> subCategoria_1 = [
    "QUINUA BRUTA",
    "OTRAS MATERIAS PRIMAS"
    "SUBPRODUCTOS",
    "MATERIAS PRIMAS PROCESADAS"
  ];
  List<String> subCategoria_2 = [
    "FRUTAS FRESCAS Y DESHIDRATADAS",
    "CONDIMENTOS, VERDURAS FRESCAS Y DEHIDRATADAS",
    "INSUMOS PROCESADOS",
    "PRODUCTOS INTERMEDIOS"
  ];
  List<String> subCategoria_3 = [
    "ENVASES KRAFT",
    "ENVASES PLASTICOS Y BOBINAS",
    "CAJAS CARTULINA",
    "CAJAS CARTON CORRUGADO",
    "STICKERS Y ETIQUETAS",
    "MATERIALES DE EMBALAJES"
  ];
  List<String> subCategoria_4 = [
    "MATERIAL DE LIMPIEZA",
    "MATERIALES DE SEGURIDAD INDUSTRIAL",
    "MATERIAL DE ESCRITORIO",
    "SUSTANCIAS QUIMICAS",
    "MATERIAL PUBLICITARIO Y DE APOYO"
  ];
  List<String> subCategoria_5 = [
    "REPUESTO Y EQUIPOS",
    "SERVICIOS"
  ];
  List<String> subCategoria_6 = [
    "PRODUCTOS SIN ASIGNACION"
  ];
  List<String> subCategoria_7 = [
    "BULK 100% QUINUA",
    "BULK PREMEZCLA",
    "BULK PASTAS",
    "RETAIL 100% QUINUA",
    "RETAIL PREMEZCLA",
    "RETAIL PASTAS",
    "READY TO EAT",
    "BABYFOODS"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextBoxCustom(hint: "CODIGO DEL PRODUCTO",controller: codigoController),
            TextBoxCustom(hint: "NOMBRE DEL PRODUCTO",controller: nombreController),
            DropDownUnidadMedida(selectionUnidadMedida: parametrosSeleccionado,refresh: (val){
              parametrosSeleccionado = val;
            },),
            selectionSgi(),
            TextBoxCustom(hint: "DESCRIPCION",controller: descripcionController),
            sectorDatosNumericos(),
            DropDownClientes(clienteSelection: clienteSelect, refresh: (v1,v2,v3){
              clienteSelect = v1;
            },),
            WidgetButtons(txt: "Crear Producto",func: (){
            },)
          ],
        ),
      ),
    );
  }

  int value = 1;
  selectionSgi() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Es Producto SGI?"),
              Row(
                children: [
                  Text("SI"),
                  Radio(value: 1, groupValue: value, onChanged: (val){
                    setState(() {
                      value = val;
                    });
                  }),
                  Text("NO"),
                  Radio(value: 2, groupValue: value, onChanged: (val){
                    setState(() {
                      value = val;
                    });
                  })
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  sectorDatosNumericos() {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex:1, child: TextBoxCustom(hint: "STOCK",controller: stockController)),
              Expanded(flex:1, child: TextBoxCustom(hint: "FACTOR",controller: factorController)),
            ],
          ),
          Row(
            children: [
              Expanded(flex:1, child:  TextBoxCustom(hint: "PESO NETO",controller: pesoNetoController)),
              Expanded(flex:1, child:  TextBoxCustom(hint: "PESO BRUTO",controller: pesoBrutoController)),
            ],
          ),
        ],
      ),
    );
  }
}
