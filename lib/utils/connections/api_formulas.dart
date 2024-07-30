
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiFormulas{
  String esp="formulas";
  String url = ApiConnections().url;

  Future<List<ModelFormula>> get()async{
    try{
      http.Response res = await http.get("${url}${esp}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelFormula> list = body.map((dynamic item) => ModelFormula.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelIngredientesFormulas>> getIngredientes(int guidForm)async{
    try{
      http.Response res = await http.get("${url}${esp}/ingredientes/$guidForm");
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

  Future<ModelFormula> getId(int id)async{
    try{
      http.Response res = await http.get("${url}formulas/$id");
      if (res.statusCode == 200) {

        return ModelFormula.fromJson(jsonDecode(res.body));
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelFormula>> getCodProd(String codProd)async{
    try{
      http.Response res = await http.get("${url}formulas/codProd/${codProd}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelFormula> list = body.map((dynamic item) => ModelFormula.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelFormula>> getLineaProd(int linProd)async{
    try{
      http.Response res = await http.get("${url}formulas/lineaProd/${linProd}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelFormula> list = body.map((dynamic item) => ModelFormula.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelFormula>> activar(int id)async{
    try{
      http.Response res = await http.get("${url}formulas/activar/${id}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelFormula> list = body.map((dynamic item) => ModelFormula.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelFormula>> desactivar(int id)async{
    try{
      http.Response res = await http.get("${url}formulas/desactivar/${id}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelFormula> list = body.map((dynamic item) => ModelFormula.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<ModelFormula> make(ModelFormula m)async{
    try{
      final res = await http.post("${url}formulas",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return ModelFormula.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<int> update(ModelFormula m)async{
    try{
      final res = await http.post("${url}formulas/${m.id}",headers: {
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