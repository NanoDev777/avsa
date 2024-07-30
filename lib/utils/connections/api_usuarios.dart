
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_user.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiUsers{
  String esp = "users";
  String url = ApiConnections().url;

  Future<List<ModelUser>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelUser> list = body.map((dynamic item) => ModelUser.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelUser>> crear(ModelUser user)async{
    try{
      print(jsonEncode(user.toJson()));
      http.Response res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(user.toJson()));
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelUser> list = body.map((dynamic item) => ModelUser.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<int> delete(int id)async{
    try{
      http.Response res = await http.get("$url$esp/delete/$id");
      if (res.statusCode == 200) {
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelUser> list = body.map((dynamic item) => ModelUser.fromJson(item)).toList();
        return 1;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future update(int id, ModelUser user)async{
    try{
      print(jsonEncode(user.toJson()));
      http.Response res = await http.post("$url$esp/$id",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(user.toJson()));
      if (res.statusCode == 200) {
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelUser> list = body.map((dynamic item) => ModelUser.fromJson(item)).toList();
        return jsonDecode(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<ModelUser> getUser(int id)async{
    try{
      http.Response res = await http.get("$url$esp/$id");
      if (res.statusCode == 200) {
        // List<dynamic> body = jsonDecode(res.body);
        ModelUser list = ModelUser.fromJson(jsonDecode(res.body));
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
}