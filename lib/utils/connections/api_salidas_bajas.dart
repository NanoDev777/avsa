import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_salidas_bajas.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

class ApiSalidasBajas{
  String esp ="salidasbajas";
  String url = ApiConnections().url;

  Future<List<ModelSalidasBajas>> get() async{
    try{
      final res = await http.get("$url$esp");
      if(res.statusCode==200){
        List<dynamic> body = jsonDecode(res.body);
        List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return list;
      }
      return null;
    }catch(e){
      print("ERR:$esp::get::$e");
    }
  }

  Future<List<ModelSalidasBajas>> getPendientes() async{
    try{
      final res = await http.get("$url$esp/pendientes");
      if(res.statusCode==200){
        print(jsonDecode(res.body).toString());
        List<dynamic> body = jsonDecode(res.body);
        List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return list;
      }
      return null;
    }catch(e){
      print("ERR:$esp::getPendientes::$e");
    }
  }

  Future<void> create(List<ModelSalidasBajas> o, BuildContext context) async{
    try{
      var json = {};
      json['data'] = o.map((e) => e.toJson()).toList();
      print("${jsonEncode(json)}");
      final res = await http.post("$url$esp",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },body: jsonEncode(json));
      Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // if(res.statusCode==201){
      //   Toast.show("${jsonDecode(res.body)['msj']}", context, duration:Toast.LENGTH_LONG);
      // }
    }catch(e){
      print("ERR:$esp::create::$e");
    }
  }

  Future<List<ModelSalidasBajas>> getPorFechas(String fecIni, String fecFin)async{
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
        List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return list;
      } else {
        throw "Fallo del servidor";
      }
    }catch(e){
      print("ERR:$esp::$e");
    }
  }

  Future<ModelSalidasBajas> aprovar(String cod) async{
    try{
      String json = jsonEncode({
        'aprov': 1,
        'fecAprov': DateFormat("dd/MM/yyyy").format(DateTime.now())
      });
      final res = await http.post("$url$esp/aprov/$cod",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },
        body: json
      );
      if(res.statusCode==201){
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return ModelSalidasBajas.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::aprovar::$e");
    }
  }
  Future<ModelSalidasBajas> rechazar(String cod) async{
    try{
      String json = jsonEncode({
        'aprov': 2,
        'fecAprov': DateFormat("dd/MM/yyyy").format(DateTime.now())
      });
      final res = await http.post("$url$esp/rechazo/$cod",
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json'
          },
          body: json
      );
      if(res.statusCode==201){
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return ModelSalidasBajas.fromJson(jsonDecode(res.body));
      }
      return null;
    }catch(e){
      print("ERR:$esp::rechazar::$e");
    }
  }
  Future<int> count() async{
    try{
      final res = await http.get("$url$esp/count");
      print(jsonDecode(res.body).toString());
      if(res.statusCode==200){
        // List<dynamic> body = jsonDecode(res.body);
        // List<ModelSalidasBajas> list = body.map((dynamic item) => ModelSalidasBajas.fromJson(item)).toList();
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::count::$e");
    }
  }

}