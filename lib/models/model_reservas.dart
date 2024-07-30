
class ModelReservas{
  int idProcProd;
  int tipo;
  String codProd;
  String lote;
  String loteVenta;
  double cantidadReceta;
  double cantidad;
  double costoUnit;
  int estado;
  int idInventario;

  ModelReservas(
      {this.idProcProd,
      this.tipo,
      this.codProd,
      this.lote,
      this.loteVenta,
      this.cantidadReceta,
      this.cantidad,
      this.costoUnit,
      this.estado,
      this.idInventario});

  factory ModelReservas.fromJson(Map<dynamic,dynamic> json){
    return ModelReservas(
        idProcProd: json['idProcProd'],
        tipo: json['tipo'],
        codProd: json['codProd'],
        lote: json['lote'],
        loteVenta: json['loteVenta'],
        cantidadReceta: json['cantidadReceta'],
        cantidad: json['cantidad'],
        costoUnit: json['costoUnit'],
        estado: json['estado'],
        idInventario: json['idInventario']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'idProcProd': idProcProd,
    'tipo': tipo,
    'codProd': codProd,
    'lote': lote,
    'loteVenta': loteVenta,
    'cantidadReceta': cantidadReceta,
    'cantidad': cantidad,
    'costoUnit': costoUnit,
    'estado': estado,
    'idInventario': idInventario
  };
}