import 'package:andeanvalleysystem/models/model_parametros.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_parametros.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownUnidadMedida extends StatefulWidget {
  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelParametros selectionUnidadMedida;
  bool enabled;
  Function refresh;

  DropDownUnidadMedida({
    Key key,
    this.label="SELECCIONE UNA UNIDAD DE MEDIDA",
    this.titlePopup="LISTA UNIDADES DE MEDIDA" ,
    this.labelNotData="NO EXISTEN DATOS",
    this.selectionUnidadMedida,
    this.enabled=true,
    this.refresh,
  }):super(key:key);

  @override
  _DropDownUnidadMedidaState createState() => _DropDownUnidadMedidaState();
}

class _DropDownUnidadMedidaState extends State<DropDownUnidadMedida> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: FutureBuilder<List<ModelParametros>>(
        future:
        ApiParametros("unidMedida").get(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            SomethingWentWrongPage();
          if (snapshot.connectionState ==
              ConnectionState.done) {
            List<ModelParametros> almList = snapshot.data;
            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelParametros>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: almList,
              selectedItem: widget.selectionUnidadMedida,
              onChanged: (value) {
                setState(() {
                  widget.selectionUnidadMedida = value;
                  widget.refresh(value);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilderUnidMed,
              dropdownBuilder: widget.selectionUnidadMedida != null
                  ? _customDropDownUnidMed
                  : null,
            );
          }
          return LoadingPage();
        },
      ),
    );
  }

  Widget _customDropDownUnidMed(
      BuildContext context, ModelParametros item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.id.toString()),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.titulo,overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilderUnidMed(
      BuildContext context, ModelParametros item, bool isSelected) {
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
              Text(item.id.toString()),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.titulo),
            ],
          ),
        ));
  }
}
