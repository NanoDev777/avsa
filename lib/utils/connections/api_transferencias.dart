import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_formula.dart';
import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_transferencia.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiTransferencias{
  String esp="transferencias";
  String url = ApiConnections().url;

  Future<List<ModelTransferencia>> get()async{
    try{
      http.Response res = await http.get("${url}${esp}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelTransferencia>> getPendientes()async{
    try{
      http.Response res = await http.get("${url}${esp}/pendientes");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelTransferencia>> getAceptados()async{
    try{
      http.Response res = await http.get("${url}${esp}/aceptados");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelTransferencia>> getRechazados()async{
    try{
      http.Response res = await http.get("${url}${esp}/rechazados");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelTransferencia>> aceptar(String codTransf)async{
    try{
      SharedPreferences sp = await SharedPreferences.getInstance();
      String json = jsonEncode(
         {
          'codTransferencia': codTransf,
          'fechaAceptacion': DateFormat("dd/MM/yyyy").format(DateTime.now()),
          'usrAceptacion': sp.getInt('sessionID')
        }
      );
      print(json);
      http.Response res = await http.post("$url$esp/aceptar/transferencia",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
  Future<List<ModelTransferencia>> getRechazar(String codTranf)async{
    try{
      String json = jsonEncode(
          {
            'codTransferencia': codTranf,
            'fechaAceptacion': DateFormat("dd/MM/yyyy").format(DateTime.now()),
            'usrAceptacion': 0
          }
      );
      print(json);
      http.Response res = await http.post("$url$esp/rechazar/transferencia",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelTransferencia> getId(int id)async{
    try{
      http.Response res = await http.get("${url}${esp}/$id");
      if (res.statusCode == 200) {

        return ModelTransferencia.fromJson(jsonDecode(res.body));
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelTransferencia>> getCodTrans(String codTrans)async{
    try{
      http.Response res = await http.get("${url}${esp}/codtrans/${codTrans}");
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelTransferencia>> getTranferenciasPorFechas(String fecIni, String fecFin)async{
    try{
      String json = jsonEncode({
        'dateIni': fecIni,
        'dateFin': fecFin
      });
      http.Response res = await http.post("$url$esp/get/date",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);

      if (res.statusCode == 200) {
        print(jsonDecode(res.body));
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<List<ModelTransferencia>> getPendientesAlmacen(List<int> almacenes)async{
    try{
      String json = jsonEncode({
        'data': almacenes.map((e) => e).toList(),
      });
      print(json);
      http.Response res = await http.post("$url$esp/pendientes",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if (res.statusCode == 200) {
        List<dynamic> body = jsonDecode(res.body);
        List<ModelTransferencia> list = body.map((dynamic item) => ModelTransferencia.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> make(List<ModelTransferencia> m)async{
    try{
      String json = jsonEncode({
        'data': m.map((e) => e.toJson()).toList(),
      });
      print(json);
      final res = await http.post("$url$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: json);
      if(res.statusCode==201){
        print(jsonDecode(res.body));
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<int> update(ModelTransferencia m)async{
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
  Future<int> updateCodTransf(ModelTransferencia m)async{
    try{
      final res = await http.post("$url$esp/${m.codTransferencia}",headers: {
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
  Future<int> count () async{
    try{
      http.Response res = await http.get("$url$esp/cant/transferencias");
      if (res.statusCode == 200) {
        return int.parse(res.body);
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::count::$e");
    }
  }
}