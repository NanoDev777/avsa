
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';

class ModelReservaOrdenCompra{
  int id;
  int ordenCompraId;
  String codProd;
  double cantidad;
  double costoTotal;
  int proveedor;
  ModelItem item;
  ModelProveedores prov;

  ModelReservaOrdenCompra(
      {this.id,
      this.ordenCompraId,
      this.codProd,
      this.cantidad,
      this.costoTotal,
      this.proveedor,
      this.item,
      this.prov});

  factory ModelReservaOrdenCompra.fromJson(Map<dynamic,dynamic> json){
    return ModelReservaOrdenCompra(
        id: json['id'],
        ordenCompraId: json['ordenCompraId'],
        codProd: json['codProd'],
        cantidad: double.parse(json['cantidad']),
        costoTotal: double.parse(json['costoTotal']),
        proveedor: json['proveedor']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
        'ordenCompraId':ordenCompraId,
        'codProd':codProd,
        'cantidad':cantidad,
        'costoTotal':costoTotal,
        'proveedor':proveedor
  };
}