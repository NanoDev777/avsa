import 'package:andeanvalleysystem/models/model_header_list.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:flutter/material.dart';
class ListCustom extends StatefulWidget {
  final String title;
  final List<ModelHeaderList> modelHeaderList;
  final List<ModelInventario> inventarioSelected;
  final List<Widget> datos;
  final Function func;
  final bool edit;
  final bool delete;

  ListCustom({Key key, this.title, this.modelHeaderList, this.inventarioSelected, this.datos, this.func, this.edit, this.delete}):super(key:key);

  @override
  _ListCustomState createState() => _ListCustomState();
}

class _ListCustomState extends State<ListCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, offset: Offset(.5, 10), blurRadius: 20)
          ]),
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: double.infinity,
              color: Theme.of(context).secondaryHeaderColor,
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 12),
              )),
          SizedBox(
            height: 10,
          ),
          Row(
            children: widget.modelHeaderList.map((e){
              return headerListCustom(e.title, e.flex);
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: widget.datos
            ),
          )
        ],
      ),
    );
  }
  Widget headerListCustom(String text, int flex) {
    return Expanded(
        flex: flex,
        child: Container(
            width: double.infinity,
            height: 30,
            color: Colors.blueGrey,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12),
              ),
            )));
  }
}
