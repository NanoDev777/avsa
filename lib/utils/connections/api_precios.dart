
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_cliente.dart';
import 'package:andeanvalleysystem/models/model_precios.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiPrecios{
  String esp = "precios";
  String url = ApiConnections().url;

  Future<List<ModelPrecios>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelPrecios> list = body.map((dynamic item) => ModelPrecios.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<void> habilitar(int guia)async{
    try{
      http.Response res = await http.get("$url$esp/habilitar/$guia");
      if (res.statusCode == 200) {

      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<void> desabilitar(int guia)async{
    try{
      http.Response res = await http.get("$url$esp/deshabilitar/$guia");
      if (res.statusCode == 200) {

      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelPrecios>> getxCliente(int id_cliente)async{
    try{
      http.Response res = await http.get("$url$esp/cliente/${id_cliente}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelPrecios> list = body.map((dynamic item) => ModelPrecios.fromJson(item)).toList();
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

  Future<ModelPrecios> make(List<ModelPrecios> o)async{
    try{
      String json = jsonEncode({
        'data': o.map((e) => e).toList(),
      });
      print(json);
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if(res.statusCode==201){
        return ModelPrecios.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<void> update(List<ModelPrecios> m, String nombreGrupo)async{
    try{
      String json = jsonEncode({
        'data': m.map((e) => e).toList(),
      });
      print(json);
      final res = await http.post("$url$esp/update/$nombreGrupo",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if(res.statusCode==201){
        return int.parse(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<int> count()async {
    try {
      http.Response res = await http.get("$url$esp/count");
      if (res.statusCode == 200) {
        return int.parse(res.body);
      } else {
        throw "Fallo del servidor";
      }
    } catch (e) {
      print("ERR:$esp::$e");
    }
  }
}