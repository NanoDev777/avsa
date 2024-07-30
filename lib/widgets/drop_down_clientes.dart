import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_cliente.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:flutter/material.dart';
class DropDownClientes extends StatefulWidget {

  final String label;
  final String titlePopup;
  final String labelNotData;
  ModelCliente clienteSelection;
  bool enabled;
  Function refresh;
  final int id;
  final List<ModelCliente> listClient;
  final bool all;
  final int tipoCliente;

  DropDownClientes({
    Key key,
    this.label="SELECCIONE UN CLIENTE",
    this.titlePopup="LISTA DE CLIENTES" ,
    this.labelNotData="NO EXISTEN DATOS",
    this.clienteSelection,
    this.enabled=true,
    this.listClient,
    this.refresh(ModelCliente m,List<ModelCliente> listClient, bool ref),
    this.id,
    this.all=false,
    this.tipoCliente
  }):super(key:key);

  @override
  _DropDownClientesState createState() => _DropDownClientesState();
}

class _DropDownClientesState extends State<DropDownClientes> {
  List<ModelCliente> clientesNacionales = List();
  List<ModelCliente> clientesActivos = List();

  Future<bool> getData()async{
    if(widget.listClient==null || widget.listClient.length==0) {
      clientesNacionales.clear();
      clientesActivos.clear();
      if(widget.all)
        clientesNacionales = await ApiCliente().get();
      else if(widget.tipoCliente == 2)
        clientesNacionales = await ApiCliente().getNacional();
      else if(widget.tipoCliente == 1)
        clientesNacionales = await ApiCliente().getExterior();

      clientesNacionales.forEach((element) {
        if (element.estado == 1) clientesActivos.add(element);
        if (widget.clienteSelection != null &&
            element.id == widget.clienteSelection.id)
          widget.clienteSelection = element;
      });
    }else
      clientesActivos.addAll(widget.listClient);
    if (widget.id != null) {
      clientesNacionales.forEach((element) {
        if (element.id == widget.id)
          widget.clienteSelection = element;
      });
      widget.refresh(widget.clienteSelection,clientesActivos,false);
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
            // List<ModelCliente> userList = widget.listClient!=null?widget.listClient:snapshot.data;
            // List<ModelAlmacenes> items = snapshot.data;
            return DropdownSearch<ModelCliente>(
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: Text(widget.labelNotData),
                );
              },
              enabled: widget.enabled,
              items: clientesActivos,
              selectedItem: widget.clienteSelection,
              onChanged: (value) {
                setState(() {
                  widget.clienteSelection = value;
                  widget.refresh(widget.clienteSelection,clientesActivos,true);
                });
              },
              label: widget.label,
              popupTitle: Center(
                  child: Text(widget.titlePopup)),
              popupItemBuilder:
              _customPopupItemBuilder,
              dropdownBuilder: widget.clienteSelection != null
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
      BuildContext context, ModelCliente item, String itemDesignation) {
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
      BuildContext context, ModelCliente item, bool isSelected) {
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
