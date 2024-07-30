import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_precios.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_precios.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownPrecios extends StatefulWidget {

  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelCliente clientSelect;
  ModelPrecios precios;
  bool enabled;
  Function refresh;
  final int id;
  final int id_cliente;
  List<ModelPrecios> listPrecios;

  DropDownPrecios({
    Key key,
    this.label="SELECCIONE UNA LISTA DE PRECIOS",
    this.titlePopup="LISTA DE PRECIOS",
    this.labelNotData="NO EXISTEN DATOS",
    this.precios,
    this.clientSelect,
    this.enabled=true,
    this.refresh(List<ModelPrecios> p, ModelPrecios precio,bool ref),
    this.listPrecios,
    this.id,
    this.id_cliente
  }):super(key:key);

  @override
  _DropDownPreciosState createState() => _DropDownPreciosState();
}

class _DropDownPreciosState extends State<DropDownPrecios> {
  List<ModelPrecios> userList = List();
  Map<String,List<ModelPrecios>> agrupados = Map();
  List<String> keys=List();
  List<ModelPrecios> filter = List();

  Future getData()async{
    if(widget.listPrecios==null || widget.listPrecios.length==0){
      userList = await ApiPrecios().getxCliente(widget.clientSelect!=null?widget.clientSelect.id:widget.id_cliente!=null?widget.id_cliente:-1);
    }else {
      userList = widget.listPrecios;
    }

    userList.forEach((element) {
      if(element.guia == widget.id)
        widget.precios = element;

      if(agrupados.containsKey(element.nombre_grupo)) {
        agrupados[element.nombre_grupo].add(element);
      }else{
        agrupados[element.nombre_grupo] = List();
        agrupados[element.nombre_grupo].add(element);
        filter.add(element);
        keys.add(element.nombre_grupo);
      }
    });
    widget.refresh(userList, widget.precios, false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            SomethingWentWrongPage();
          if (snapshot.connectionState ==
              ConnectionState.done) {

            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelPrecios>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: filter,
              selectedItem: widget.precios,
              onChanged: (value) {
                List<ModelPrecios> mp = List();
                userList.forEach((element) {
                  if(element.nombre_grupo == value.nombre_grupo) {
                    print("${element.nombre_grupo} == ${value.nombre_grupo}");
                    mp.add(element);
                  }
                });
                print("${mp.length}");
                setState(() {
                  widget.precios = value;
                  widget.refresh(mp, value, true);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilder,
              dropdownBuilder: widget.precios != null
                  ? _customDropDown
                  : null,
            );
          }
          return LoadingPage();
        },
      ),
    );
  }

  Widget _customDropDown(
      BuildContext context, ModelPrecios item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.nombre_grupo),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.nombre_cliente,overflow: TextOverflow.ellipsis,),
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
              Text(item.nombre_grupo),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.nombre_cliente),
            ],
          ),
        ));
  }
}
