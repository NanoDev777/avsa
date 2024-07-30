import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownAlmacenes extends StatefulWidget {

  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelAlmacenes selectionAlmacen;
  bool enabled;
  Function refresh;
  bool soloPropios;

  DropDownAlmacenes({
    Key key, 
    this.label="SELECCIONE UN ALMACEN", 
    this.titlePopup="LISTA DE ALMACENES" ,
    this.labelNotData="NO EXISTEN DATOS",
    this.selectionAlmacen, 
    this.enabled=true, 
    this.refresh,
    this.soloPropios=false
  }):super(key:key);

  @override
  _DropDownAlmacenesState createState() => _DropDownAlmacenesState();
}

class _DropDownAlmacenesState extends State<DropDownAlmacenes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: FutureBuilder<List<ModelAlmacenes>>(
        future:
        widget.soloPropios?Constant().getAlmacenes():ApiConnections().getAlmacenesPermitidos([101,102,103,104,105,201,202,301,401]),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            SomethingWentWrongPage();
          if (snapshot.connectionState ==
              ConnectionState.done) {
            List<ModelAlmacenes> almList = snapshot.data;
            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelAlmacenes>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: almList,
              selectedItem: widget.selectionAlmacen,
              onChanged: (value) {
                setState(() {
                  widget.selectionAlmacen = value;
                  widget.refresh(value);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilderAlm,
              dropdownBuilder: widget.selectionAlmacen != null
                  ? _customDropDownAlm
                  : null,
            );
          }
          return LoadingPage();
        },
      ),
    );
  }

  Widget _customDropDownAlm(
      BuildContext context, ModelAlmacenes item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.codAlm.toString()),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.name,overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilderAlm(
      BuildContext context, ModelAlmacenes item, bool isSelected) {
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
              Text(item.codAlm.toString()),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.name),
            ],
          ),
        ));
  }
}
