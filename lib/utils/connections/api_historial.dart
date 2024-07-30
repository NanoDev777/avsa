import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_historial_kardex.dart';
import 'package:andeanvalleysystem/models/model_inv_agrupado.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_registro_ingreso.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
class ApiHistorial{
  String esp ="historial";
  String url = ApiConnections().url;

  Future<List<ModelHistorialKardex>> getHistorial() async{
    try{
      http.Response res = await http.get("$url$esp");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelHistorialKardex> list = body.map((dynamic item) => ModelHistorialKardex.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getLotes::$e");
    }
  }

  Future<ModelHistorialKardex> getLastHistorial(int codAlm, String codProd) async{
    try{
      http.Response res = await http.get("$url$esp/lastDate/$codAlm/$codProd");
      if (res.statusCode == 200) {
        dynamic body = jsonDecode(res.body);
        ModelHistorialKardex list = ModelHistorialKardex.fromJson(body);
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getLotes::$e");
    }
  }

  Future<List<ModelHistorialKardex>> getHistorialKardex(int codAlm, String codProd, String fechaIni, String fechaFin) async{
    try{
      String json = jsonEncode({
        'codAlm': codAlm,
        'codProd': codProd,
        'fechaIni': fechaIni,
        'fechaFin': fechaFin
      });
      print(json);
      http.Response res = await http.post("$url$esp/gethistorial",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelHistorialKardex> list = body.map((dynamic item) => ModelHistorialKardex.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getHistorialKardex::$e");
    }
  }

  Future<bool> createHistorial(List<ModelHistorialKardex> mhk) async{
    try{
      String json = jsonEncode({
        'data': mhk.map((e) => e).toList(),
      });
      print(json);
      http.Response res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }catch(e){
      print("ERR:$esp::$e");
      return false;
    }
  }
}