import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiSolicitudTransferencia{
  String esp = "solTransf";
  String url = ApiConnections().url;

  Future<List<ModelSolicitudTransferencia>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List body = jsonDecode(res.body);
        List<ModelSolicitudTransferencia> list = body.map((dynamic item) => ModelSolicitudTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelSolicitudTransferencia>> getPendientes(int usr)async{
    try{
      // String json = jsonEncode({
      //   'data': listAlm.map((e) => e).toList(),
      // });
      // print(json);
      http.Response res = await http.get("$url$esp/pendientes/$usr");

      // http.Response res = await http.post("$url$esp/pendientes",headers: {
      //   HttpHeaders.contentTypeHeader: 'application/json'
      // },body: json);
      if (res.statusCode == 200) {
        List body = jsonDecode(res.body);
        List<ModelSolicitudTransferencia> list = body.map((dynamic item) => ModelSolicitudTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelSolicitudTransferencia>> getPendientesByCodigo(String codigo)async{
    try{
      http.Response res = await http.get("$url$esp/detalle/$codigo");
      if (res.statusCode == 200) {
        List body = jsonDecode(res.body);
        List<ModelSolicitudTransferencia> list = body.map((dynamic item) => ModelSolicitudTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> getUnidMedida(String codProd)async{
    try{
      http.Response res = await http.get("$url$esp/unidadMedida/$codProd");
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelSolicitudTransferencia>> getID(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelSolicitudTransferencia> list = body.map((dynamic item) => ModelSolicitudTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future borrar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/borrar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        return true;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelSolicitudTransferencia> make(List<ModelSolicitudTransferencia> m)async{
    try{
      print("return::${jsonEncode({'data':m.map((e) => e.toJson()).toList()})}");
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode({'data':m.map((e) => e.toJson()).toList()}));
      if(res.statusCode==201){
        return ModelSolicitudTransferencia.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future transferido(String codTransf)async{
    try{
      final res = await http.get("$url$esp/transferido/${codTransf}");
      if(res.statusCode==201){
        return true;
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelSolicitudTransferencia> update(ModelSolicitudTransferencia m)async{
    try{
      final res = await http.post("$url$esp/${m.id}",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return ModelSolicitudTransferencia.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> count () async{
    try{
      http.Response res = await http.get("$url$esp/cant/sol");
      if (res.statusCode == 200) {
        return int.parse(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::count::$e");
    }
  }
}