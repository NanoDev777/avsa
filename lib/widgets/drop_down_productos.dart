import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_productos.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownProductos extends StatefulWidget {
  final String label;
  final String titlePopup;
  final String labelNotData;
  final ModelAlmacenes selectionAlmacen;
  ModelItem selectionItem;
  final Function func;
  final bool enabled;
  final bool existentes;
  final bool soloCliente;
  final int idCliente;

  DropDownProductos({
    Key key,
    this.label="SELECCIONE UN PRODUCTO",
    this.titlePopup="LISTA DE PRODUCTOS",
    this.labelNotData="NO EXISTEN DATOS",
    this.selectionAlmacen,
    this.selectionItem,
    this.func,
    this.enabled=true,
    this.existentes=false,
    this.soloCliente=false,
    this.idCliente=0
  }):super(key:key);

  @override
  _DropDownProductosState createState() => _DropDownProductosState();
}

class _DropDownProductosState extends State<DropDownProductos> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: FutureBuilder<List<ModelItem>>(
        future: widget.existentes?ApiConnections().getItemsProdPermitidosExistentes(
            widget.selectionAlmacen!=null?widget.selectionAlmacen.codAlm:0):
        widget.soloCliente?ApiProductos().getProdClientes(widget.idCliente):
        ApiConnections().getItemsProdPermitidos(
            widget.selectionAlmacen != null
                ? widget.selectionAlmacen.ProdPermitidos
                : "1|2|3|4|6|7"),
        builder: (context, snapshot) {
          if (snapshot.hasError) SomethingWentWrongPage();
          if (snapshot.connectionState ==
              ConnectionState.done) {
            List<ModelItem> items = snapshot.data;
            return DropdownSearch<ModelItem>(
              autoFocusSearchBox: true,
              enabled: widget.enabled,
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              items: items,
              filterFn: (item, filter) {
                if (filter.isEmpty)
                  return true;
                else {
                  if (item.codigo.contains(filter) ||
                      item.nombre
                          .toLowerCase()
                          .contains(filter.toLowerCase()))
                    return true;
                  else
                    return false;
                }
              },
              selectedItem: widget.selectionItem,
              onChanged: (value) {
                setState(() {
                  widget.selectionItem = value;
                  widget.func(value);
                });
              },
              showSearchBox: true,
              label: widget.label,
              popupTitle:
              Center(child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilderProductos,
              dropdownBuilder: widget.selectionItem != null
                  ? _customDropDownProductos
                  : null,
            );
          }
          return LoadingPage();
        },
      ),
    );
  }
  Widget _customDropDownProductos(
      BuildContext context, ModelItem item, String itemDesignation) {
    return Container(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Text("${item.codigo} - ${item.nombre.toString()}",overflow: TextOverflow.ellipsis),
        // subtitle: Text(
        //   item.nombre.toString(),
        // ),
      ),
    );
  }

  Widget _customPopupItemBuilderProductos(
      BuildContext context, ModelItem item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: ListTile(
        selected: isSelected,
        title: Text(item.codigo),
        subtitle: item.razonSocial!=null && item.razonSocial!="null"?Text("${item.nombre.toString()} - CLIENTE: ${item.razonSocial}"):Text(item.nombre.toString()),
      ),
    );
  }
}
