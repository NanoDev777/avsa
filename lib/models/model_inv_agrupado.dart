import 'package:andeanvalleysystem/models/model_inventario.dart';

class ModelInvAgrupado{
  int codAlm;
  String codProd;
  String nombre;
  double cantidad;
  String unidadMedida;
  double prorrateo;
  List<ModelInventario> inventarios = List();

  ModelInvAgrupado({this.codAlm, this.codProd, this.nombre, this.cantidad, this.unidadMedida,this.prorrateo});

  factory ModelInvAgrupado.fromJson(Map<dynamic,dynamic> json){
    return ModelInvAgrupado(
      codAlm: json['codAlm']==null?0:json['codAlm'],
      codProd:  json['codProd']==null?"":json['codProd'],
      nombre:  json['nombre']==null?"sin nombre":json['nombre'],
      cantidad:  json['cantidad']==null?0:double.parse(json['cantidad'].toString()),
      unidadMedida:  json['unidadMedida']==null?"sin unidad":json['unidadMedida'],
      prorrateo:  json['prorrateo']!=null?double.parse(json['prorrateo'].toString()):0,
    );
  }
}