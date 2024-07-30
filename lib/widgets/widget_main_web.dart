
import 'package:andeanvalleysystem/models/model_module.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/modules/module_accesos_usuarios.dart';
import 'package:andeanvalleysystem/modules/module_aprov_salidas_bajas.dart';
import 'package:andeanvalleysystem/modules/module_creacion_area_solicitud.dart';
import 'package:andeanvalleysystem/modules/module_creacion_clientes.dart';
import 'package:andeanvalleysystem/modules/module_creacion_motivo.dart';
import 'package:andeanvalleysystem/modules/module_creacion_precios.dart';
import 'package:andeanvalleysystem/modules/module_creacion_producto.dart';
import 'package:andeanvalleysystem/modules/module_creacion_proformas.dart';
import 'package:andeanvalleysystem/modules/module_creacion_recetas.dart';
import 'package:andeanvalleysystem/modules/module_creacion_subclientes.dart';
import 'package:andeanvalleysystem/modules/module_despacho_pedidos.dart';
import 'package:andeanvalleysystem/modules/module_gestion_pedidos.dart';
import 'package:andeanvalleysystem/modules/module_home_web.dart';
import 'package:andeanvalleysystem/modules/module_ingreso_item.dart';
import 'package:andeanvalleysystem/modules/module_kardex_items.dart';
import 'package:andeanvalleysystem/modules/module_orden_compra.dart';
import 'package:andeanvalleysystem/modules/module_pedidos_abiertos.dart';
import 'package:andeanvalleysystem/modules/module_proceso_produccion.dart';
import 'package:andeanvalleysystem/modules/module_productos.dart';
import 'package:andeanvalleysystem/modules/module_proformas_abiertas.dart';
import 'package:andeanvalleysystem/modules/module_proveedor.dart';
import 'package:andeanvalleysystem/modules/module_reimpresion_ingresos.dart';
import 'package:andeanvalleysystem/modules/module_reimpresion_proc_prod.dart';
import 'package:andeanvalleysystem/modules/module_reimpresion_slidas_bajas.dart';
import 'package:andeanvalleysystem/modules/module_reimpresion_transferencias.dart';
import 'package:andeanvalleysystem/modules/module_reporte_almacenes.dart';
import 'package:andeanvalleysystem/modules/module_salidas_bajas.dart';
import 'package:andeanvalleysystem/modules/module_transferencias.dart';
import 'package:andeanvalleysystem/modules/module_usuarios.dart';
import 'package:andeanvalleysystem/modules/module_view_recetas.dart';
import 'package:andeanvalleysystem/pages/LoginPage.dart';
import 'package:andeanvalleysystem/pages/loading_page.dart';
import 'package:andeanvalleysystem/pages/something_went_wrong.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_usuarios.dart';
import 'package:andeanvalleysystem/utils/constants.dart';
import 'package:andeanvalleysystem/widgets/textbox_custom.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class WidgetMainPage extends StatefulWidget {
  @override
  _WidgetMainPageState createState() => _WidgetMainPageState();
}

class _WidgetMainPageState extends State<WidgetMainPage> {
  int moduleId = 0;
  String userName;
  List<String> almacenes = List();
  List<ModelModule> modulos = List();
  List<ModelModule> subMenu = List();
  List<String> modulosServer;
  String moduleSelected="";

  TextEditingController ecNombres = TextEditingController();
  TextEditingController ecApPaterno = TextEditingController();
  TextEditingController ecApMaterno = TextEditingController();
  TextEditingController ecDocID = TextEditingController();
  TextEditingController ecCorreo = TextEditingController();
  TextEditingController ecConAn = TextEditingController();
  TextEditingController ecConN = TextEditingController();
  TextEditingController ecConRN = TextEditingController();
  String pass;
  int userID;
  String modulosUsuario;

  Future getData()async{
    try{
      SharedPreferences sp = await SharedPreferences.getInstance();
      userID = sp.getInt("sessionID");
      userName = sp.getString("userName");
      if(sp.getString("almacenes")!=null && sp.getString("almacenes").isNotEmpty)
        almacenes = sp.getString("almacenes").split(',');
      if(sp.getString("modulos")!=null) {
        modulosServer = sp.getString("modulos").split(',');
        modulosUsuario = sp.getString("modulos");
      }

      ecNombres.text = sp.getString("nombres");
      ecApPaterno.text = sp.getString("apPaterno");
      ecApMaterno.text = sp.getString("apMAterno");
      ecDocID.text = sp.getString("carnetIdentidad");
      ecCorreo.text = sp.getString("email");
      pass = sp.getString("password");
    }catch(e){
      print(e.toString());
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if(snapshot.hasError)
              return SomethingWentWrongPage();
            if(snapshot.connectionState == ConnectionState.done){
              return Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height,
                    child: Image.asset("assets/images/fondo2.png", fit: BoxFit.fill,),
                  ),
                  Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          height: 80,
                          decoration: BoxDecoration(
                            // color: Colors.teal,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(30),bottomRight: Radius.circular(30))
                          ),
                          child: Row(
                            children: [
                              Expanded(flex:2, child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(30))
                                ),
                                child: Container(
                                    margin: EdgeInsets.all(10),
                                    child: Image.asset("assets/images/logo_red.png",width: 5,height: 5,
                                    )),
                              )),
                              Expanded(flex:9,child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(30))
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 8,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin:EdgeInsets.all(5),
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50),
                                                color: Colors.red
                                            ),
                                            child: Icon(Icons.person, color: Colors.white,),
                                          ),
                                          SizedBox(width: 5,),
                                          Text(userName, style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),),
                                          SizedBox(width: 5,),
                                          InkWell(
                                              onTap: (){
                                                _showUserConfig();
                                              },
                                              child: Icon(Icons.edit, color: Colors.white,))
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: (){
                                        SharedPreferences.getInstance().then((value) {
                                          value.clear();
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage(),));
                                        });
                                      },
                                      child: Container(
                                        // width: 40,
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(10)
                                        ),
                                        child: Text("Cerrar Sesion",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: FutureBuilder<Map<String,List<ModelModule>>>(
                          future: ApiConnections().getModules(1),
                          builder: (context, snapshot) {
                            if (snapshot.hasError)
                              return SomethingWentWrongPage(msj: snapshot.error,);
                            if (snapshot.connectionState == ConnectionState.done){
                              Map<String,List<ModelModule>> map = snapshot.data;
                              modulos = map["modulos"];
                              subMenu = map["submodulos"];
                              List<ModelModule> m = List();
                              // subMenu.forEach((element) {
                              //   modulosServer.forEach((ms) {
                              //     if(element.name == ms)
                              //       m.add(element);
                              //   });
                              // });
                              // modulos.clear();
                              // modulos.addAll(m);
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                            ),
                                            child: ListView.separated(
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if(moduleId!=index) {
                                                          moduleId = index;
                                                          moduleSelected = "";
                                                        }else{
                                                          moduleId = -1;
                                                          moduleSelected = "";
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: index==moduleId?Color.fromRGBO(209, 60, 49, 1):Colors.grey,
                                                          borderRadius: BorderRadius.circular(20)
                                                      ),
                                                      padding: EdgeInsets.all(1),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Image.asset(modulos[index].icon,width: 35,height: 35,),
                                                              Container(
                                                                width: MediaQuery.of(context).size.width*0.14,
                                                                child: Text(modulos[index].name,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: TextStyle(color: Colors.white,fontSize: 15),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          moduleId==index?Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.max,
                                                            children: subMenu.map((e) {
                                                              if(modulosServer!=null && e.patern==modulos[index].id&&modulosServer.contains(e.name))
                                                                return InkWell(
                                                                    onTap: (){
                                                                      setState((){
                                                                        moduleSelected = e.name;
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      width: 200,
                                                                      margin: EdgeInsets.only(left: 10,right: 2,top: 2,bottom: 2),
                                                                      padding: EdgeInsets.fromLTRB(5,2,2,2),
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          color: Colors.grey
                                                                      ),
                                                                      child: Text(e.name,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        maxLines: 1,
                                                                        style: TextStyle(color: Colors.white),
                                                                        textAlign: TextAlign.left,
                                                                      ),
                                                                    )
                                                                );
                                                              else return Container();
                                                            }).toList(),
                                                          ):Container()
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                separatorBuilder: (context, index) => Divider(height: 5,),
                                                itemCount: modulos.length),
                                          )
                                      ),
                                      Expanded(
                                          flex: 9,
                                          child: ModuleContainer()
                                      )
                                    ],
                                  );
                                },
                              );
                            }
                            return LoadingPage();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return LoadingPage();
          },
        )
    );
  }

  ModuleContainer() {
    switch(moduleSelected){
      case "":
        return ModuleHomeWeb();
        break;
      case "Ordenes de Compra":
        return ModuleOrdenCompra();
        break;
      case "Ingreso de Items":
        return ModuleIngresoItems();
        break;
      case "Crear Procesos":
        return ModuleProcesoProduccion(selection: 0,);
        break;
      case "Terminar Procesos":
        return ModuleProcesoProduccion(selection: 1,);
        break;
      case "Realizar Transferencia":
        return ModuleTransferencias(selection: 0,);
        break;
      case "Solicitar Transferencia":
        return ModuleTransferencias(selection: 1,);
        break;
      case "Solicitar Transferencia por Proceso":
        return ModuleTransferencias(selection: 2,);
        break;
      case "Estado de solicitud":
        return ModuleTransferencias(selection: 3,);
        break;
      case "Reporte de Inventario":
        return ModuleReporteAlmacenes();
        break;
      case "Kardex de Items":
        return ModuleKardexItems();
        break;
      case "Accesos de Usuarios":
        return ModuleAccesosUsuarios();
        break;
      case "Aprobar Procesos":
        return ModuleProcesoProduccion(selection: 2,);
        break;
      case "Recetas":
        return ModuleViewRecetas();
        break;
      case "Items/Productos":
        return ModuleProductos();
        break;
      case "Proveedores":
        return ModuleProveedor();
        break;
      case "Usuarios":
        return ModuleUsuarios();
        break;
      case "Salidas y Bajas":
        return ModuleSalidasBajas();
        break;
      case "Aprobar Salidas/Bajas":
        return ModuleAprovSalidasBajas();
        break;
      case "Registro de Clientes":
        return ModuleCracionClientes(tipoCliente: 2,);
        break;
      case "Registro de SubClientes":
        return ModelCreacionSubClientes();
        break;
      case "Lista de Precios":
        return ModuleCreacionPrecios(tipoCliente: 2,);
        break;
      case "Creacion de Proformas":
        return ModuleCreacionProformas(tipoCliente: 2,);
        break;
      case "Transferencias":
        return ModuleReimpresionTransferencias();
        break;
      case "Procesos de Produccion":
        return ModuleReimpresionProcProd();
        break;
      case "Ingresos":
        return ModuleReimpresionIngresos();
        break;
      case "Salidas/Bajas":
        return ModuleReimpresionSalidasBajas();
        break;
      case "Area Solicitante":
        return ModuleCreacionAreaSolicitud();
        break;
      case "Motivos":
        return ModuleCreacionMotivo();
        break;
      case "Proformas Abiertas":
        return ModuleProformasAbiertas();
        break;
      case "Pedidos Abiertos":
        return ModulePedidosAbiertos();
        break;
      case "Despachos de Pedidos":
        return ModuleDespachoPedidos();
        break;
      case "Gestion Pedidos":
        return ModuleGestionPedidos();
        break;
      case "Crear Receta":
        return ModuleCreacionRecetas();
        break;
      case "Crear Producto":
        return ModuleCreacionProductos();
        break;
      case "Registro de Clientes Int.":
        return ModuleCracionClientes(tipoCliente: 1,);
        break;
      case "Creacion de Pedidos Int.":
        return ModuleCreacionProformas(tipoCliente: 1,);
        break;
      case "Pedidos Abiertos Int.":
        return ModulePedidosAbiertos();
        break;
      case "Lista de Precios Int.":
        return ModuleCreacionPrecios(tipoCliente: 1,);
        break;
      default:
        return SomethingWentWrongPage();
        break;
    }
  }

  Future<void> _showUserConfig() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("CONFIGURACION DE USUARIO"),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width*0.6,
              child: ListBody(
                children: <Widget>[
                  TextBoxCustom(hint: "NOMBRES", controller: ecNombres,),
                  TextBoxCustom(hint: "APELLIDO PATERNO", controller: ecApPaterno,),
                  TextBoxCustom(hint: "APELLIDO MATERNO",controller: ecApMaterno,),
                  TextBoxCustom(hint: "DOCUMENTO DE IDENTIDAD", controller: ecDocID,),
                  TextBoxCustom(hint: "CORREO", controller: ecCorreo,),
                  Row(
                    children: [
                      Expanded(child: TextBoxCustom(hint: "NUEVA CONTRASEÑA", controller: ecConN,obscure: true)),
                      Expanded(child: TextBoxCustom(hint: "REESCRIBE NUEVA CONTRASEÑA", controller:  ecConRN,obscure: true)),
                    ],
                  ),
                  TextBoxCustom(hint: "INGRESE SU CONTRASEÑA PARA GUARDAR CAMBIOS", controller: ecConAn,obscure: true,),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('GUARDAR CAMBIOS'),
              onPressed: () {
                ModelUser newUser = ModelUser(
                  nombres: ecNombres.text,
                  apPaterno: ecApPaterno.text,
                  apMaterno: ecApMaterno.text,
                  carnetIdentidad: ecDocID.text,
                  email: ecCorreo.text,
                  password: pass,
                  modulos: modulosUsuario
                );
                if(ecConN.text.isNotEmpty && ecConRN.text.isNotEmpty){
                  if(ecConN.text == ecConRN.text){
                    newUser.password = ecConN.text;
                  }
                }
                if(ecConAn.text == pass){
                  ApiUsers().update(userID, newUser).whenComplete((){
                    Toast.show("CAMBIOS CORRECTOS", context, duration: Toast.LENGTH_LONG);
                    ecConAn.text="";
                    Navigator.of(context).pop();
                  });
                }else{
                  Toast.show("CONTRASEÑA INCORRECTA NO SE GUARDARON CAMBIOS", context, duration: Toast.LENGTH_LONG);
                }
              },
            ),Container(),
            TextButton(
              child: Text('CANCELAR'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
