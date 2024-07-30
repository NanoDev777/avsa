
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_reserva_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_message.dart';
import 'package:andeanvalleysystem/models/model_module.dart';
import 'package:andeanvalleysystem/models/model_orden_compra.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/utils/db_variables.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class ApiConnections{

  //ACTUALIZAR END POINTS
  // final String url="http://andeanvalley.tech/apiRest/public/api/";
  // final String url="http://sistema-avsa.com/apiRest/api/";
  // final String url="http://testqr.sistema-avsa.com/apiRest/api/";
  // final String url="http://127.0.0.1:8000/api/";http://apirest.test/
  final String url="http://apirest.test/api/";

  Future<ModelUser> loginUser(String usuario, String password) async{
    var response = await http.get("${url}login/$usuario/$password");
    print(response.body);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return ModelUser.fromJson(jsonDecode(response.body));
    } else {
      return null;
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future getUser() async{
    var response = await http.get("${url}usuarios");
    print(response.body);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var itemCount = jsonResponse['totalItems'];
      print('Number of books about http: $itemCount.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Map<String,List<ModelModule>> modulos = Map();
  Future<Map<String,List<ModelModule>>> getModules(int usrID)async{
    List<ModelModule> lmm = List();
    await lmm.add(ModelModule(id: 1,name: "Inicio",icon: "assets/images/inicio-04.png"));
    await lmm.add(ModelModule(id: 3,name: "Modulo de Compra",icon: "assets/images/compras-04.png"));
    await lmm.add(ModelModule(id: 2,name: "Modulo Almacenes",icon: "assets/images/almacenes-04.png"));
    await lmm.add(ModelModule(id: 4,name: "Modulo Contabilidad",icon: "assets/images/contabilidad-04.png"));
    await lmm.add(ModelModule(id: 5,name: "Modulo Produccion",icon: "assets/images/produccion-04.png"));
    await lmm.add(ModelModule(id: 6,name: "Modulo Gerencia de Produccion",icon: "assets/images/gerenciaproduccion-04.png"));
    await lmm.add(ModelModule(id: 7,name: "Modulo Transferencia",icon: "assets/images/trasnferencia-04.png"));
    await lmm.add(ModelModule(id: 8,name: "Modulo Venta Exportacion",icon: "assets/images/ventasexportacion-04.png"));
    await lmm.add(ModelModule(id: 9,name: "Modulo Venta Nacionales",icon: "assets/images/ventasnacionales-04.png"));
    await lmm.add(ModelModule(id: 11,name: "Modulo Reporte",icon: "assets/images/moduloreporte-04.png"));
    await lmm.add(ModelModule(id: 12,name: "Reimpresion de documentos",icon: "assets/images/reimpresiondocs-04.png"));
    await lmm.add(ModelModule(id: 13,name: "Configuracion",icon: "assets/images/produccion-04.png"));
    await lmm.add(ModelModule(id: 10,name: "Parametros del Sistema",icon: "assets/images/parametrossistema-04.png"));
    //submodulos
    List<ModelModule> subModulos = List();
    subModulos.add(ModelModule(id: 1, patern: 3, name: "Ordenes de Compra"));
    subModulos.add(ModelModule(id: 2, patern: 2, name: "Ingreso de Items"));
    subModulos.add(ModelModule(id: 3, patern: 2, name: "Salidas y Bajas"));
    subModulos.add(ModelModule(id: 4, patern: 2, name: "Alertas de Stock"));
    subModulos.add(ModelModule(id: 5, patern: 2, name: "Despachos de Pedidos"));
    subModulos.add(ModelModule(id: 6, patern: 4, name: "Aprobar Ingreso"));
    subModulos.add(ModelModule(id: 7, patern: 4, name: "Aprobar Salidas/Bajas"));
    subModulos.add(ModelModule(id: 8, patern: 4, name: "Reporte de Ingresos Aprobados"));
    subModulos.add(ModelModule(id: 9, patern: 5, name: "Crear Procesos"));
    subModulos.add(ModelModule(id: 10, patern: 5, name: "Terminar Procesos"));
    subModulos.add(ModelModule(id: 11, patern: 5, name: "Recetas"));
    //gerencia de produccion
    subModulos.add(ModelModule(id: 12, patern: 6, name: "Aprobar Ingresos"));
    subModulos.add(ModelModule(id: 13, patern: 6, name: "Aprobar Procesos"));
    subModulos.add(ModelModule(id: 14, patern: 6, name: "Aprobar Salidas/Bajas"));
    subModulos.add(ModelModule(id: 41, patern: 6, name: "Gestion Pedidos"));

    subModulos.add(ModelModule(id: 15, patern: 7, name: "Realizar Transferencia"));
    subModulos.add(ModelModule(id: 16, patern: 7, name: "Solicitar Transferencia"));
    subModulos.add(ModelModule(id: 17, patern: 7, name: "Solicitar Transferencia por Proceso"));
    subModulos.add(ModelModule(id: 18, patern: 7, name: "Estado de solicitud"));
    subModulos.add(ModelModule(id: 20, patern: 7, name: "Reporte de Transferencias"));
    subModulos.add(ModelModule(id: 21, patern: 11, name: "Reporte de Inventario"));
    subModulos.add(ModelModule(id: 22, patern: 11, name: "Kardex de Items"));
    subModulos.add(ModelModule(id: 23, patern: 11, name: "Reporte de Despacho"));
    subModulos.add(ModelModule(id: 24, patern: 11, name: "Margen MP-ENV"));
    subModulos.add(ModelModule(id: 25, patern: 13, name: "Accesos de Usuarios"));
    subModulos.add(ModelModule(id: 26, patern: 11, name: "Items/Productos"));
    subModulos.add(ModelModule(id: 27, patern: 11, name: "Proveedores"));
    subModulos.add(ModelModule(id: 28, patern: 10, name: "Usuarios"));
    subModulos.add(ModelModule(id: 29, patern: 10, name: "Area Solicitante"));
    subModulos.add(ModelModule(id: 30, patern: 10, name: "Motivos"));
    subModulos.add(ModelModule(id: 42, patern: 10, name: "Crear Producto"));
    subModulos.add(ModelModule(id: 43, patern: 10, name: "Crear Receta"));
    //ventas internacionales
    subModulos.add(ModelModule(id: 44, patern: 8, name: "Registro de Clientes Int."));
    subModulos.add(ModelModule(id: 45, patern: 8, name: "Creacion de Pedidos Int."));
    subModulos.add(ModelModule(id: 46, patern: 8, name: "Pedidos Abiertos Int."));
    subModulos.add(ModelModule(id: 47, patern: 8, name: "Lista de Precios Int."));
    //ventas nacionales
    subModulos.add(ModelModule(id: 31, patern: 9, name: "Registro de Clientes"));
    subModulos.add(ModelModule(id: 32, patern: 9, name: "Registro de SubClientes"));
    subModulos.add(ModelModule(id: 33, patern: 9, name: "Creacion de Proformas"));
    subModulos.add(ModelModule(id: 34, patern: 9, name: "Proformas Abiertas"));
    subModulos.add(ModelModule(id: 35, patern: 9, name: "Pedidos Abiertos"));
    subModulos.add(ModelModule(id: 36, patern: 9, name: "Lista de Precios"));
    //reimpresiones
    subModulos.add(ModelModule(id: 37, patern: 12, name: "Ingresos"));
    subModulos.add(ModelModule(id: 38, patern: 12, name: "Transferencias"));
    subModulos.add(ModelModule(id: 39, patern: 12, name: "Procesos de Produccion"));
    subModulos.add(ModelModule(id: 40, patern: 12, name: "Salidas/Bajas"));



    modulos["modulos"]=lmm;
    modulos["submodulos"]=subModulos;

    return modulos;
  }

  Future<List<ModelProcesoProduccion>> getProcesosPendientes()async{
    List<ModelProcesoProduccion> lmpp = List();
    await lmpp.add(ModelProcesoProduccion(id: 1,cantidad: 200,codAlmProd: 201,variacion: 4));
    await lmpp.add(ModelProcesoProduccion(id: 2,cantidad: 300,codAlmProd: 202,variacion: -10));
    await lmpp.add(ModelProcesoProduccion(id: 3,cantidad: 10000,codAlmProd: 201,variacion: 10));
    return lmpp;
  }

  Future<List<ModelMessage>> getMensajes()async{
    List<ModelMessage> lm = List();
    await lm.add(ModelMessage(id: 1,asunto: "Necesito Aprobacion",remitente: "Admin", fecha: DateTime.now()));
    await lm.add(ModelMessage(id: 2,asunto: "Necesito Comprobacion",remitente: "Sergio", fecha: DateTime.now()));
    await lm.add(ModelMessage(id: 3,asunto: "Factura Rechazada", remitente: "Rosa", fecha: DateTime.now()));
    return lm;
  }

  Future<List<ModelItem>> getItemsPendienteAprob()async{
    // List<ModelItem> lmi = List();
    // await lmi.add(ModelItem(id: 1, codigo: "I-1542", cantidad: 1000, codAlm: 101));
    // await lmi.add(ModelItem(id: 1, codigo: "I-345", cantidad: 600, codAlm: 102));
    // await lmi.add(ModelItem(id: 1, codigo: "I-1656", cantidad: 200, codAlm: 103));
    // return lmi;
  }

  Future<List<ModelItem>> getItemsBajasAprob()async{
    // List<ModelItem> lmi = List();
    // await lmi.add(ModelItem(id: 1, codigo: "B-1542", cantidad: 5, codAlm: 101));
    // await lmi.add(ModelItem(id: 1, codigo: "B-345", cantidad: 1, codAlm: 102));
    // await lmi.add(ModelItem(id: 1, codigo: "B-1656", cantidad: 2, codAlm: 103));
    // return lmi;
  }

  Future<List<ModelAlmacenes>> getAlmacenesPermitidos(List<int> almacenes)async{
    try{
      String json = jsonEncode({
        'data': almacenes.map((e) => e).toList(),
      });
      http.Response res = await http.post("${url}almacenes/i",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 201) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelAlmacenes> list = body.map((dynamic item) => ModelAlmacenes.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR::$e");
    }
  }

  Future<List<ModelItem>> getItemsProdPermitidos(String permisos)async{
    try{
      List<String> p = permisos.split('|');
      String json = jsonEncode({
        'indices': p.map((e) => int.parse(e)).toList(),
      });
      print(json);
      final res = await http.post("${url}productos/permitidos",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if(res.statusCode==200){
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      }
      return null;
    }catch(e){
      print("ERR-getItemsProdPermitidos::$e");
    }
  }
  Future<List<ModelItem>> getItemsProdPermitidosExistentes(int codAlm)async{
    try{
      final res = await http.get("${url}productos/permitidos/existentes/$codAlm");
      if(res.statusCode==200){
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      }
      return null;
    }catch(e){
      print("ERR-getItemsProdPermitidos::$e");
    }
  }

  Future<ModelItem> getItemsProdCodProd(String codProd)async{
    try{
      http.Response res = await http.get("${url}productos/$codProd");
      if (res.statusCode == 200) {
        List m = jsonDecode(res.body);
        return ModelItem.fromJson(m[0]);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR::$e");
    }
  }

  Future<List<ModelProveedores>> getProveedores()async{
    try{
      http.Response res = await http.get("${url}proveedores");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR::$e");
    }
  }

  Future<void> getCambioEstadoOrdenCompra(int id)async{
    try{
      http.Response res = await http.get("${url}ordencompra/terminar/$id");
    }catch(e){
      print("ERR::$e");
    }
  }

  Future<List<ModelInventario>> getInventarioByAlmacen(int codAlm)async{
    try{
      http.Response res = await http.get("${url}inventario/almacen/$codAlm");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR::$e");
    }
  }

  Future<List<ModelOrdenCompra>> getOrdenCompra()async{
    try{
      http.Response res = await http.get("${url}ordencompra");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelOrdenCompra> list = body.map((dynamic item) => ModelOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR-getOrdenCompra::$e");
    }
  }
  Future<List<ModelReservaOrdenCompra>> getItemsOrdenCompra(int id)async{
    try{
      http.Response res = await http.get("${url}itemsordencompra/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelReservaOrdenCompra> list = body.map((dynamic item) => ModelReservaOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR-getOrdenCompra::$e");
    }
  }
  Future<int> enviarOrdenCompra(ModelOrdenCompra m)async{
    try{
      final res = await http.post("${url}ordencompra",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR-enviarOrdenCompra::$e");
    }
  }

}