
import 'package:andeanvalleysystem/models/model_lote.dart';

class ModelReservaItemsProcProd{
  int id;
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
  double cantidadRequerida;
  String nombreProd;
  String unidad;
  double costoTotalReal;
  double costoTotalReceta;
  List<ModelLote> lotes = List();
  int adicional;

  ModelReservaItemsProcProd(
      {this.id,
        this.idProcProd,
      this.tipo,
      this.codProd,
      this.lote,
      this.loteVenta,
      this.cantidadReceta,
      this.cantidad,
      this.costoUnit,
      this.estado,
      this.idInventario,
      this.cantidadRequerida,
      this.nombreProd,
      this.unidad,
      this.costoTotalReal,
      this.costoTotalReceta,
      this.adicional=0});

  factory ModelReservaItemsProcProd.fromJson(Map<dynamic,dynamic> json){
    print("cant::${json['cantidadReceta'].toString()}::cantPro::${json['cantidadProd'].toString()}");
    return ModelReservaItemsProcProd(
        id: json['id'],
        idProcProd: json['idProcProd'],
        tipo: json['tipo'],
        codProd: json['codProd'],
        lote: json['lote'],
        loteVenta: json['loteVenta'],
        cantidadReceta: double.parse(json['cantidadReceta'].toString()),
        cantidad: json['cantidadProd']!=null?double.parse(json['cantidadProd'].toString()):double.parse(json['cantidad'].toString()),
        costoUnit: double.parse(json['costoUnit'].toString()),
        estado: json['estado'],
        idInventario: json['idInventario'],
        unidad: json['titulo']!=null?json['titulo']:"",
        nombreProd: json['nombre']!=null?json['nombre']:""
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