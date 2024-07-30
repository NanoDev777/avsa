
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiProcesosProduccion{
  String esp = "regProcProd";
  String url = ApiConnections().url;

  Future<List<ModelProcesoProduccion>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> transferenciaSolicitada(int idProcProd)async{
    try{
      http.Response res = await http.get("$url$esp/solicitarTransferencia/$idProcProd");
      if (res.statusCode == 200) {
        return int.parse(jsonDecode(res.body));
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::transferenciaSolicitada::$e");
    }
  }

  Future<List<ModelReservaItemsProcProd>> getReservasAll()async{
    try{
      http.Response res = await http.get("$url$esp/reservas/all");
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        List<dynamic> body = jsonDecode(res.body);
        List<ModelReservaItemsProcProd> list = body.map((dynamic item) => ModelReservaItemsProcProd.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::transferenciaSolicitada::$e");
    }
  }

  Future<List<ModelReservaItemsProcProd>> getReservas(int id)async{
    try{
      http.Response res = await http.get("$url$esp/reserva/$id");
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        List<dynamic> body = jsonDecode(res.body);
        List<ModelReservaItemsProcProd> list = body.map((dynamic item) => ModelReservaItemsProcProd.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::transferenciaSolicitada::$e");
    }
  }

  Future<List<ModelProcesoProduccion>> getPendientes(List<int> almacenes)async{
    try{
      String json = jsonEncode({
        'data': almacenes.map((e) => e).toList(),
      });
      print (json);
      http.Response res = await http.post("$url$esp/pendientes",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelProcesoProduccion>> getPendientesSolicitud()async{
    try{
      http.Response res = await http.get("$url$esp/pendientes/solicitud");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelProcesoProduccion>> getID(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProcesoProduccion>> aprovar(int id)async{
    try{
      String json = jsonEncode({
        'aprob':1,
        'fecAprob': DateFormat("dd/MM/yyyy").format(DateTime.now())
      });
      http.Response res = await http.post("$url$esp/aprobar/$id",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },
        body: json
      );
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProcesoProduccion>> rechazar(int id)async{
    try{
      String json = jsonEncode({
        'aprob':2,
        'fecAprob': DateFormat("yyyy-MM-dd").format(DateTime.now())
      });
      http.Response res = await http.post("$url$esp/rechazar/$id",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: json
      );
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProcesoProduccion>> cancelar(int id)async{
    try{
      http.Response res = await http.get("$url$esp/cancelar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProcesoProduccion>> borrar(int id)async{
    try{
      http.Response res = await http.get("$url$esp/borrar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelIngredientesFormulas>> getIngredientes(int id)async{
    try{
      http.Response res = await http.get("${url}${esp}/ing/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelIngredientesFormulas> list = body.map((dynamic item) => ModelIngredientesFormulas.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> make(ModelProcesoProduccion m)async{
    try{
      print(jsonEncode(m.toJson()));
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelProcesoProduccion>> getPorFechas(String fecIni, String fecFin)async{
    try{
      String json = jsonEncode({
        'dateIni': fecIni,
        'dateFin': fecFin
      });
      http.Response res = await http.post("$url$esp/get/date",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);

      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }


  Future<List<ModelProcesoProduccion>> getPendientesAprob() async{
    try{
      http.Response res = await http.get("${url}${esp}/variacion/pendientes");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProcesoProduccion> list = body.map((dynamic item) => ModelProcesoProduccion.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> update(ModelProcesoProduccion m)async{
    try{
      print(jsonEncode(m.toJson()));
      final res = await http.post("$url${esp}/${m.id}",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
}