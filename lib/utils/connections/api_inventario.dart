
import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_inv_agrupado.dart';
import 'package:andeanvalleysystem/models/model_inventario.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_registro_ingreso.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class ApiInventory{
  String esp ="inventario";
  String url = ApiConnections().url;

  Future<ModelRegistroIngreso> insertRegistroIngreso(List<ModelRegistroIngreso> o) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("${url}inventario/registro",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(json)
      );
      if(res.statusCode==201){
        ModelRegistroIngreso mri = ModelRegistroIngreso.fromJson(jsonDecode(res.body));
        return mri;
      }
      return null;
    }catch(e){
      print("ERR:$esp::insertRegistroIngreso::$e");
    }
  }

  Future<double> getProrrateo(int codAlm, String codProd)async{
    try{
      http.Response res = await http.get("${url}${esp}/prorrateo/$codAlm/$codProd");
      Map m;
      if(res!=null && res.body.isNotEmpty) {
        m = jsonDecode(res.body);
        if (res.statusCode == 200) {
          return double.parse(m['prorrateo']);
        } else {
          throw "Fallo del servidor";
        }
      }else return 0;
    }catch(e){
      print("ERR:$esp::getProrrateo::$e");
    }
  }
  Future<List<ModelLote>> getLotes(int codAlm, String codProd)async{
    try{
      http.Response res = await http.get("${url}inventario/lotes/$codAlm/$codProd");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelLote> list = body.map((dynamic item) => ModelLote.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getLotes::$e");
    }
  }

  Future<double> getCantidadExistente(int codAlm, String codProd)async{
    try{
      http.Response res = await http.get("${url}${esp}/$codAlm/$codProd");
      if (res.statusCode == 200) {
        return double.parse(jsonDecode(res.body));
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioByAlmacenAndCodProd::$e");
    }
  }

  Future<List<ModelInventario>> getInventarioByAlmacenAndCodProd(int codAlm, String codProd)async{
    try{
      http.Response res = await http.get("${url}inventario/$codAlm/$codProd");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        print("${list.length}");
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioByAlmacenAndCodProd::$e");
    }
  }

  Future<List<ModelInventario>> getInventarioExistentes(int codAlm)async{
    try{
      http.Response res = await http.get("${url}inventario/$codAlm");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioExistentes::$e");
    }
  }

  Future<List<ModelInventario>> getInventarioFecha(int codAlm, String fechaIniMandar)async{
    try{
      http.Response res = await http.get("${url}inventario/historial/$codAlm/$fechaIniMandar");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioExistentes::$e");
    }
  }

  Future<List<ModelRegistroIngreso>> getRegistroIngresos()async{
    try{
      http.Response res = await http.get("${url}inventario/registro/ingresos");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelRegistroIngreso> list = body.map((dynamic item) => ModelRegistroIngreso.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioExistentes::$e");
    }
  }

  Future<List<ModelRegistroIngreso>> getRegistroDate(String dateIni, String dateFin)async{
    try{
      var json = {
        "dateIni": dateIni,
        "dateFin": dateFin
      };
      print (json);
      http.Response res = await http.post("${url}inventario/get/date",
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(json));
      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        List<dynamic> body = jsonDecode(res.body);
        List<ModelRegistroIngreso> list = body.map((dynamic item) => ModelRegistroIngreso.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioExistentes::$e");
    }
  }

  Future<int> getRegistroIngresosCount()async{
    try{
      http.Response res = await http.get("${url}inventario/registro/count");
      if (res.statusCode == 200) {
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelRegistroIngreso> list = body.map((dynamic item) => ModelRegistroIngreso.fromJson(item)).toList();
        return int.parse(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::getInventarioExistentes::$e");
    }
  }

  Future<ModelInventario> insertInventory(List<ModelInventario> o, BuildContext context) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("${url}inventario",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(json));
      return ModelInventario.fromJson(jsonDecode(res.body));
      //Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // if(res.statusCode==201){
      //   Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // }
    }catch(e){
      print("ERR:$esp::insertInventory::$e");
    }
  }

  Future<List<ModelInventario>> discountInventory(List<ModelLote> o,int codAlm, String codProd) async{
    try{
      String json = jsonEncode({
        'data': o.map((e) => e).toList(),
      });
      print(json);
      http.Response res = await http.post("$url$esp/discount/$codAlm/$codProd",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelInventario>> returnInventory(List<ModelInventario> o) async{
    try{
      String json = jsonEncode({
        'data': o.map((e) => e.toJson()).toList(),
      });
      print("returnInv::${json}");
      http.Response res = await http.post("$url$esp/return",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List body = jsonDecode(res.body);
        List<ModelInventario> list = body.map((dynamic item) => ModelInventario.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
}