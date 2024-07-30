import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_despachos.dart';
import 'package:andeanvalleysystem/models/model_despachos_items.dart';
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_proforma.dart';
import 'package:andeanvalleysystem/models/model_proforma_items.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class ApiProformas{
  String esp = "proformas";
  String url = ApiConnections().url;
  Future<List<ModelProforma>> get()async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProforma> list = body.map((dynamic item) => ModelProforma.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProforma>> setMes(int id, String mes)async{
    try{
      http.Response res = await http.get("$url$esp/setMes/$id/$mes");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProforma> list = body.map((dynamic item) => ModelProforma.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProforma>> getMonth(String month)async{
    try{
      http.Response res = await http.get("$url$esp/month/$month");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProforma> list = body.map((dynamic item) => ModelProforma.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<void> getPDF(int id, String codigo)async{
    try{
      print("$url/pdf/generate/$id/$codigo");
      http.Response res = await http.get("${url}pdf/generate/$id/$codigo");
      if (res.statusCode == 200) {
        return true;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<void> getPDFProf(int id, String codigo)async{
    try{
      print("$url/pdf/generate/$id/$codigo");
      http.Response res = await http.get("${url}pdf/generateProf/$id/$codigo");
      if (res.statusCode == 200) {
        return true;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelProforma>> getPedidos()async{
    try{
      http.Response res = await http.get("$url$esp/pedidos");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProforma> list = body.map((dynamic item) => ModelProforma.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<ModelProforma> make(ModelProforma m)async{
    try{
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        return ModelProforma.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<ModelDespachos> despachar(ModelDespachos m)async{
    try{
      print(jsonEncode(m.toJson()));
      final res = await http.post("$url$esp/despachar/${m.idProforma}",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(m.toJson()));
      if(res.statusCode==201){
        print(jsonEncode(res.body));
        return ModelDespachos.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelDespachosItems> despacharItems(List<ModelDespachosItems> o, BuildContext context) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("${url}$esp/despacharitems/${o[0].idDespacho}",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(json));
      return ModelDespachosItems.fromJson(jsonDecode(res.body));
      //Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // if(res.statusCode==201){
      //   Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // }
    }catch(e){
      print("ERR:$esp::despacharItems::$e");
    }
  }

  Future<int> aceptar(ModelProforma m, int id)async{
    try{
      final res = await http.post("$url$esp/aceptar/$id",headers: {
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
  Future<int> cancelar(ModelProforma m, int id)async{
    try{
      final res = await http.post("$url$esp/cancelar/$id",headers: {
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
  Future<int> count()async{
    try{
      http.Response res = await http.get("$url$esp/count");
      if (res.statusCode == 200) {
        return int.parse(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelProformaItems> insertItems(List<ModelProformaItems> o) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("$url$esp/items/add",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(json)
      );
      if(res.statusCode==201){
        ModelProformaItems mri = ModelProformaItems.fromJson(jsonDecode(res.body));
        return mri;
      }
      return null;
    }catch(e){
      print("ERR:$esp::insertItems::$e");
    }
  }
  Future<ModelProforma> update(ModelProforma o, int id) async{
    try{
      print("${jsonEncode(o.toJson())}::$id");
      final res = await http.post("$url$esp/$id",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(o.toJson())
      );
      if(res.statusCode==201){
        ModelProforma mri = ModelProforma.fromJson(jsonDecode(res.body));
        return mri;
      }
      return null;
    }catch(e){
      print("ERR:$esp::update::$e");
    }
  }
  Future<ModelProformaItems> updateItems(List<ModelProformaItems> o, int id) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("$url$esp/items/update/$id",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(json)
      );
      if(res.statusCode==201){
        ModelProformaItems mri = ModelProformaItems.fromJson(jsonDecode(res.body));
        return mri;
      }
      return null;
    }catch(e){
      print("ERR:$esp::insertItems::$e");
    }
  }
  Future<List<ModelProformaItems>> getItems()async{
    try{
      http.Response res = await http.get("$url$esp/items");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelProformaItems> list = body.map((dynamic item) => ModelProformaItems.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
}