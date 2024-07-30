import 'dart:convert';
import 'dart:io';

import 'package:andeanvalleysystem/models/model_ingredientes_formula.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:http/http.dart' as http;

class ApiIngredientesFormulas{
  String esp="ingredientesformulas";
  String url = ApiConnections().url;

  Future<int> make(List<ModelIngredientesFormulas> m)async{
    try{
      var json = {};
      json['data'] = m.map((e) => e.toJson()).toList();
      print(jsonEncode(json));
      final res = await http.post("${url}$esp",headers: {
        HttpHeaders.contentTypeHeader: 'application/json'
      },body: jsonEncode(json));
      if(res.statusCode==201){
        return jsonDecode(res.body);
      }
      return null;
    }catch(e){
      print("ERR:$esp::$e");
    }
  }
}