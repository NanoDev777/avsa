
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiProductos{
  String esp = "productos";
  String url = ApiConnections().url;

  Future<List<ModelItem>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelItem>> getProdClientes(int idCliente)async{
    try{
      http.Response res = await http.get("$url$esp/clientes/$idCliente");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
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
  Future<String> getNameUnidMedida(int unidad)async{
    try{
      http.Response res = await http.get("$url$esp/nameUnidadMedida/$unidad");
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelItem>> getID(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelItem>> activar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/activar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelItem>> desactivar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/desactivar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelItem>> borrar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/borrar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelItem> list = body.map((dynamic item) => ModelItem.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> make(ModelItem m)async{
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
  Future<int> update(ModelItem m)async{
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