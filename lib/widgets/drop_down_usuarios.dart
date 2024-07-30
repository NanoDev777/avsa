import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownUsuarios extends StatefulWidget {

  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelUser userSelection;
  bool enabled;
  Function refresh;

  DropDownUsuarios({
    Key key,
    this.label="SELECCIONE UN USUARIOS",
    this.titlePopup="LISTA DE USUARIOS" ,
    this.labelNotData="NO EXISTEN DATOS",
    this.userSelection,
    this.enabled=true,
    this.refresh,
  }):super(key:key);

  @override
  _DropDownUsuariosState createState() => _DropDownUsuariosState();
}

class _DropDownUsuariosState extends State<DropDownUsuarios> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      child: FutureBuilder<List<ModelUser>>(
        future:ApiUsers().get(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            SomethingWentWrongPage();
          if (snapshot.connectionState ==
              ConnectionState.done) {
            List<ModelUser> userList = snapshot.data;
            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelUser>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: userList,
              selectedItem: widget.userSelection,
              onChanged: (value) {
                setState(() {
                  widget.userSelection = value;
                  widget.refresh(value);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilder,
              dropdownBuilder: widget.userSelection != null
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
      BuildContext context, ModelUser item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.name),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.cargo,overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, ModelUser item, bool isSelected) {
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
              Text(item.name),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.cargo),
            ],
          ),
        ));
  }
}
