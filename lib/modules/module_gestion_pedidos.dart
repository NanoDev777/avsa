import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/connections/api_proformas.dart';
import 'package:andeanvalleysystem/utils/number_functions.dart';
import 'package:andeanvalleysystem/widgets/drop_down/dropdown_search.dart';
import 'package:andeanvalleysystem/widgets/widget_header_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
class ModuleGestionPedidos extends StatefulWidget {
  @override
  _ModuleGestionPedidosState createState() => _ModuleGestionPedidosState();
}

class _ModuleGestionPedidosState extends State<ModuleGestionPedidos> {

  List<ModelProformaItems> itemsList = List();
  Map<int,List<ModelProformaItems>> items = Map();
  Map<int,double> totales = Map();
  Map<int,double> CantidadesTotales = Map();
  int idUser;
  StateSetter refreshAll;
  StateSetter refreshList;
  List<ModelProforma> proformas=List();

  int fechaA = 0;
  int codigoA = 0;
  int clienteA = 0;
  int subClienteA = 0;
  int precioA = 0;
  int tipoPagoA = 0;
  ScrollController scroll = ScrollController();

  List<String> meses = [
    "ENERO",
    "FEBRERO",
    "MARZO",
    "ABRIL",
    "MAYO",
    "JUNIO",
    "JULIO",
    "AGOSTO",
    "SEPTIEMBRE",
    "OCTUBRE",
    "NOVIEMBRE",
    "DICIEMBRE"
  ];
  List<String> selectMes = List();

  Future getData()async{
    // proformas.clear();
    // itemsList.clear();
    items.clear();
    selectMes.clear();
    SharedPreferences sp = await SharedPreferences.getInstance();
    idUser = sp.getInt("sessionID");
    proformas = await ApiProformas().getPedidos();
    itemsList = await ApiProformas().getItems();
    proformas.forEach((element) {
      selectMes.add(null);
    });
    itemsList.forEach((element) {
      if(items.containsKey(element.idProforma)){
        items[element.idProforma].add(element);
        totales[element.idProforma] += element.cantidad*element.precio;
        CantidadesTotales[element.idProforma] += element.cantidad;
      }else{
        items[element.idProforma] = List();
        items[element.idProforma].add(element);
        totales[element.idProforma] = element.cantidad*element.precio;
        CantidadesTotales[element.idProforma] = element.cantidad;
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StatefulBuilder(
        builder: (context, setState) {
          refreshAll =setState;
          return FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if(snapshot.hasError) return SomethingWentWrongPage();
              if(snapshot.connectionState == ConnectionState.done){
                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        flex: 10,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  WidgetHeaderList(text: "FECHA", flex: 1,func:(){
                                    refreshList((){
                                      if(proformas!=null && fechaA==0) {
                                        fechaA=1;
                                        proformas.sort((a, b) =>
                                            a.fec_creacion.compareTo(b.fec_creacion));
                                      }else  if(proformas!=null){
                                        fechaA=0;
                                        proformas.sort((a, b) =>
                                            b.fec_creacion.compareTo(a.fec_creacion));
                                      }
                                    });
                                  }),
                                  WidgetHeaderList(text: "PEDIDO",flex: 1,func: (){
                                    refreshList((){
                                      if(proformas!=null && codigoA==0) {
                                        codigoA=1;
                                        proformas.sort((a, b) =>
                                            a.codigo.compareTo(b.codigo));
                                      }else  if(proformas!=null){
                                        codigoA=0;
                                        proformas.sort((a, b) =>
                                            b.codigo.compareTo(a.codigo));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "CLIENTE",flex: 2,func: (){
                                    refreshList((){
                                      if(proformas!=null && clienteA==0) {
                                        clienteA=1;
                                        proformas.sort((a, b) =>
                                            a.nombreCliente.compareTo(b.nombreCliente));
                                      }else  if(proformas!=null){
                                        clienteA=0;
                                        proformas.sort((a, b) =>
                                            b.nombreCliente.compareTo(a.nombreCliente));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "SUBCLIENTE",flex: 2,func: (){
                                    refreshList((){
                                      if(proformas!=null && subClienteA==0) {
                                        subClienteA=1;
                                        proformas.sort((a, b) =>
                                            a.nombreSubCliente.compareTo(b.nombreSubCliente));
                                      }else  if(proformas!=null){
                                        subClienteA=0;
                                        proformas.sort((a, b) =>
                                            b.nombreSubCliente.compareTo(a.nombreSubCliente));
                                      }
                                    });
                                  },),
                                  WidgetHeaderList(text: "MES",flex: 2,func: (){},),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 9,
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    refreshList = setState;
                                    return Scrollbar(
                                      controller: scroll,
                                      isAlwaysShown: true,
                                      child: ListView.separated(
                                        controller: scroll,
                                        itemCount: proformas.length,
                                        separatorBuilder: (context, index) => Divider(),
                                        itemBuilder: (context, index) {
                                          ModelProforma p = proformas[index];
                                          List<String> fec = p.fec_aprob.split('-');
                                          meses.forEach((element) {
                                            if(element.toLowerCase() == p.mes.toLowerCase())
                                              selectMes[index] = element;
                                          });
                                          return InkWell(
                                            onTap: (){
                                              // _showDialog(p);
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(flex: 1,child: Text("${fec[2]}/${fec[1]}/${fec[0]}")),
                                                Expanded(flex:1,child: Container(
                                                    padding: EdgeInsets.only(left: 3,right: 3),
                                                    child: Text("${p.codigo}"))
                                                ),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(flex:2,child: Container(
                                                    padding: EdgeInsets.only(left: 3,right: 3),
                                                    child: Column(
                                                      children: [
                                                        Text(p.nombreCliente),
                                                      ],
                                                    ))),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(flex:2,child: Container(
                                                    padding: EdgeInsets.only(left: 3,right: 3),
                                                    child: Text(p.nombreSubCliente))),
                                                Container(
                                                  width: 1,
                                                  height: 20,
                                                  color: Colors.blueGrey,
                                                ),
                                                Expanded(flex:2,child: Container(
                                                    padding: EdgeInsets.only(left: 3,right: 3),
                                                    child: DropdownSearch(
                                                      items: meses,
                                                      selectedItem: selectMes[index],
                                                      hint: "sin mes",
                                                      onChanged: (value) {
                                                        selectMes[index] = value;
                                                        ApiProformas().setMes(p.id, value).whenComplete((){
                                                          Toast.show("MES ASIGNADO", context);
                                                        });
                                                      },
                                                    )
                                                )),
                                              ],
                                            ),
                                          );
                                        },),
                                    );
                                  },
                                )
                            ),
                          ],
                        )
                    )
                  ],
                );
              }
              return LoadingPage();
            },
          );
        }
      ),
    );
  }
}
