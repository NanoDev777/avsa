import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_proveedores.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiProveedores{
  String esp = "proveedores";
  String url = ApiConnections().url;

  Future<List<ModelProveedores>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelProveedores>> getID(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProveedores>> activar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/activar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProveedores>> desactivar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/desactivar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProveedores>> borrar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/borrar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProveedores> list = body.map((dynamic item) => ModelProveedores.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> make(ModelProveedores m)async{
    try{
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
  Future<int> update(ModelProveedores m)async{
    try{
      final res = await http.post("$url$esp/${m.id}",headers: {
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