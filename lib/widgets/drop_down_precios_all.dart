import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_precios.dart';
import 'package:andeanvalleysystem/models/model_subcliente.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/utils/connections/api_precios.dart';
import 'package:andeanvalleysystem/utils/connections/api_subclientes.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';

class DropDownPreciosAll extends StatefulWidget {
  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelCliente clientSelect;
  ModelPrecios precios;
  List<ModelPrecios> listPrices = List();
  bool enabled;
  Function refresh;

  DropDownPreciosAll({
    Key key,
    this.label = "SELECCIONE UN PRODUCTO",
    this.titlePopup = "LISTA DE RODUCTOS",
    this.labelNotData = "NO EXISTEN DATOS",
    this.precios,
    this.clientSelect,
    this.enabled = true,
    this.refresh(ModelPrecios p),
    this.listPrices
  }) : super(key: key);

  @override
  _DropDownPreciosAllState createState() => _DropDownPreciosAllState();
}

class _DropDownPreciosAllState extends State<DropDownPreciosAll> {
  List<ModelPrecios> userList = List();
  Future getData()async{
    userList.clear();
    return userList.addAll(widget.listPrices);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              return SomethingWentWrongPage();
            if(snapshot.connectionState == ConnectionState.done){
              return DropdownSearch<ModelPrecios>(
                emptyBuilder: (context, searchEntry) {
                  return Center(
                    child: Text(widget.labelNotData),
                  );
                },
                enabled: widget.enabled,
                items: userList,
                selectedItem: widget.precios,
                onChanged: (value) {
                  setState(() {
                    widget.precios = value;
                    widget.refresh(value);
                  });
                },
                label: widget.label,
                popupTitle: Center(child: Text(widget.titlePopup)),
                popupItemBuilder: _customPopupItemBuilder,
                dropdownBuilder: widget.precios != null ? _customDropDown : null,
              );
            }
            return LoadingPage();
          },
        ));
  }

  Widget _customDropDown(
      BuildContext context, ModelPrecios item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.codProd),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(
            item.nombre,
            overflow: TextOverflow.ellipsis,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(
            "Precio unitario:${item.precio_unitario}",
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, ModelPrecios item, bool isSelected) {
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
              Text(item.codProd),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.nombre),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(
                "Precio unitario:${item.precio_unitario}",
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ));
  }
}
