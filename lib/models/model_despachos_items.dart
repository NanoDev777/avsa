class ModelDespachosItems {
  int idDespacho;
  String codProd;
  String producto;
  String idUnidad;
  double cantidad;
  String loteProd;
  String loteVent;
  String fechaVencimiento;
  double costoProd;
  double costoTotal;
  double pesoNetoTotal;

  ModelDespachosItems({
    this. idDespacho,
    this. codProd,
    this. producto,
    this. idUnidad,
    this. cantidad,
    this. loteProd,
    this. loteVent,
    this. fechaVencimiento,
    this. costoProd,
    this. costoTotal,
    this. pesoNetoTotal,
  });

  factory ModelDespachosItems.fromJson(Map<dynamic,dynamic> json){
    return ModelDespachosItems(
        idDespacho: int.parse(json['idDespacho'].toString()),
        codProd: json['codProd'],
        producto: json['producto'],
        idUnidad: json['idUnidad'],
        cantidad: double.parse(json['cantidad'].toString()),
        loteProd: json['loteProd'],
        loteVent: json['loteVent'],
        fechaVencimiento: json['fechaVencimiento'],
        costoProd: double.parse(json['costoProd'].toString()),
        costoTotal: double.parse(json['costoTotal'].toString()),
        pesoNetoTotal: double.parse(json['pesoNetoTotal'].toString()),
    );
  }

  Map<dynamic,dynamic> toJson() => {
    'idDespacho':idDespacho,
    'codProd':codProd,
    'producto':producto,
    'idUnidad':idUnidad,
    'cantidad':cantidad,
    'loteProd':loteProd,
    'loteVent':loteVent,
    'fechaVencimiento':fechaVencimiento,
    'costoProd':costoProd,
    'costoTotal':costoTotal,
    'pesoNetoTotal':pesoNetoTotal,
  };
}