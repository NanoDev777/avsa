
class ModelLote{
  int id;
  String codProd;
  String lote;
  double cantidad;
  double costoUnit;
  double cantidadUsada;
  String fecVencimiento;

  ModelLote({this.id, this.codProd, this.lote, this.cantidad, this.costoUnit,this.cantidadUsada,this.fecVencimiento});

  factory ModelLote.fromJson(Map<dynamic,dynamic> json){
    return ModelLote(
        id:json['id']!=null?json['id']:"",
        lote:json['lote']!=null?json['lote']:"",
        cantidad: double.parse(json['cantidad']),
        costoUnit: double.parse(json['prorrateo']),
        fecVencimiento:json['fecVencimiento']!=null?json['fecVencimiento']:""
    );
  }
  Map<dynamic,dynamic> toJson()=>{
    "id": id,
    "lote": lote,
    "cantidad": cantidadUsada,
    "costoUnit": costoUnit,
    "fecVencimiento": fecVencimiento,
    'codProd':codProd
  };
}