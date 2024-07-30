import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_subcliente.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/utils/connections/api_subclientes.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownSubClientes extends StatefulWidget {

  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelSubCliente subclientSelection;
  ModelCliente clientSelect;
  bool enabled;
  Function refresh;
  final int id;
  final int id_cliente;
  final List<ModelSubCliente> listSubCliente;

  DropDownSubClientes({
    Key key,
    this.label="SELECCIONE UN SUBCLIENTE",
    this.titlePopup="LISTA DE SUBCLIENTES" ,
    this.labelNotData="NO EXISTEN DATOS",
    this.subclientSelection,
    this.clientSelect,
    this.enabled=true,
    this.refresh,
    this.listSubCliente,
    this.id,
    this.id_cliente
  }):super(key:key);

  @override
  _DropDownSubClientesState createState() => _DropDownSubClientesState();
}

class _DropDownSubClientesState extends State<DropDownSubClientes> {
  List<ModelSubCliente> userList = List();
  Future getData()async{
    if(widget.listSubCliente==null || widget.listSubCliente.length==0){
      userList = await ApiSubcliente().getxCliente(widget.clientSelect!=null?widget.clientSelect.id:widget.id_cliente!=null?widget.id_cliente:-1);
    }else{
      userList = widget.listSubCliente;
    }
    if(widget.id!=null && userList.length>0){
      userList.forEach((element) {
        if(element.id==widget.id) {
          widget.subclientSelection = element;
        }
      });
      widget.refresh(widget.subclientSelection,false);
    }
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
            // List<ModelSubCliente> userList = snapshot.data;
            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelSubCliente>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: userList,
              selectedItem: widget.subclientSelection,
              onChanged: (value) {
                setState(() {
                  widget.subclientSelection = value;
                  widget.refresh(value,true);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilder,
              dropdownBuilder: widget.subclientSelection != null
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
      BuildContext context, ModelSubCliente item, String itemDesignation) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Text(item.razonSocial),
          SizedBox(
            width: 5,
          ),
          Text("-"),
          SizedBox(
            width: 5,
          ),
          Text(item.codigo,overflow: TextOverflow.ellipsis,),
        ],
      ),
    );
  }

  Widget _customPopupItemBuilder(
      BuildContext context, ModelSubCliente item, bool isSelected) {
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
              Text(item.razonSocial),
              SizedBox(
                width: 5,
              ),
              Text("-"),
              SizedBox(
                width: 5,
              ),
              Text(item.codigo),
            ],
          ),
        ));
  }
}
