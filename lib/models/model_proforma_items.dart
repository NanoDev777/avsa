class ModelProformaItems{
  int id;
  int idProforma;
  String codProd;
  String nameProd;
  double precio;
  // double prorrateo;
  double cantidad;
  double cantidadCajasBolsas;
  double pesoNeto;
  double valorTotal;
  String unidad;

  double cantidadUsada=0;
  String lotesUsados="";
  String fecVenc="";

  ModelProformaItems(
      {this.id,
      this.idProforma,
      this.codProd,
      this.nameProd,
      this.precio,
        // this.prorrateo,
      this.cantidad,
      this.cantidadCajasBolsas,
      this.pesoNeto,
      this.valorTotal,
      this.unidad});

  factory ModelProformaItems.fromJson(Map<dynamic,dynamic> json){
    return ModelProformaItems(
      id:json["id"],
      idProforma:json["idProforma"],
      codProd:json["codProd"],
      nameProd:json["nameProd"],
      precio:double.parse(json["precio"]),
      cantidad:double.parse(json["cantidad"]),
      cantidadCajasBolsas:double.parse(json["cantidadCajasBolsas"]),
      pesoNeto:double.parse(json["pesoNeto"]),
      valorTotal:double.parse(json["valorTotal"]),
        unidad:json["titulo"]!=null?json["titulo"]:""
    );
  }
  Map<dynamic,dynamic> toJson()=>{
    "idProforma": idProforma,
    "codProd": codProd,
    "nameProd": nameProd,
    "precio": precio,
    "cantidad": cantidad,
    "cantidadCajasBolsas": cantidadCajasBolsas,
    "pesoNeto": pesoNeto,
    "valorTotal": valorTotal
  };
}