
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiCliente{
  String esp = "clientes";
  String url = ApiConnections().url;

  Future<List<ModelCliente>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelCliente>> getNacional()async{
    try{
      http.Response res = await http.get("$url$esp/nacional");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getNacional::$e");
    }
  }
  Future<List<ModelCliente>> getExterior()async{
    try{
      http.Response res = await http.get("$url$esp/exterior");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelCliente>> getID(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelCliente>> activar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/activar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelCliente>> desactivar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/desactivar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelCliente>> borrar(String id)async{
    try{
      http.Response res = await http.get("$url$esp/borrar/$id");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelCliente> list = body.map((dynamic item) => ModelCliente.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelCliente> make(ModelCliente m)async{
    try{
      print(m.toJson());
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return ModelCliente.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<int> update(ModelCliente m)async{
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