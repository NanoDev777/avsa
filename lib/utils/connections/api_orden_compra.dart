import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_orden_compra.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;
class ApiOrdenCompra{
  String esp="ordencompra";
  String url = ApiConnections().url;

  Future<List<ModelOrdenCompra>> get()async{
    try{
      http.Response res = await http.get("${url}${esp}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelOrdenCompra> list = body.map((dynamic item) => ModelOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelOrdenCompra>> pendientes(int estado)async{
    try{
      http.Response res = await http.get("${url}${esp}/pendient/$estado");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelOrdenCompra> list = body.map((dynamic item) => ModelOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<ModelOrdenCompra> getId(int id)async{
    try{
      http.Response res = await http.get("${url}${esp}/$id");
      if (res.statusCode == 200) {

        return ModelOrdenCompra.fromJson(jsonDecode(res.body));
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelOrdenCompra>> activar(int id)async{
    try{
      http.Response res = await http.get("${url}${esp}/activar/${id}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelOrdenCompra> list = body.map((dynamic item) => ModelOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelOrdenCompra>> terminar(int id)async{
    try{
      http.Response res = await http.get("${url}${esp}/terminar/${id}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelOrdenCompra> list = body.map((dynamic item) => ModelOrdenCompra.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<int> make(ModelOrdenCompra m)async{
    try{
      final res = await http.post("${url}${esp}",headers: {
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
  Future<int> update(ModelOrdenCompra m)async{
    try{
      final res = await http.post("${url}${esp}/${m.id}",headers: {
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