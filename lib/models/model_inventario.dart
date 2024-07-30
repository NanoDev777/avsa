
import 'package:andeanvalleysystem/models/model_item.dart';
import 'package:andeanvalleysystem/models/model_lote.dart';
import 'package:andeanvalleysystem/models/model_proveedores.dart';

class ModelInventario{
  int id;
  String idCodigo;
  int codAlm;
  String codProd;
  String codigo;
  double cantidad;
  double costoUnitario;
  double costo;
  double prorrateo;
  String lote;
  String loteVenta;
  String factura;
  int idProv;
  String fecIngreso;
  String fecVencimiento;
  int usuario;
  ModelItem producto;
  ModelProveedores proveedor;
  String nombre;
  String unidad;
  ModelItem prodSelect;
  double cantidadTotalLotes=0;
  // String fechaIngresoSistema;
  List<ModelLote> lotes = List();
  int idLote;
  String fechaSistema;
  String recibo;
  String obs;

  ModelInventario(
      {this.id,
        this.idCodigo,
      this.codAlm,
      this.codProd,
      this.codigo,
      this.cantidad,
      this.costoUnitario,
      this.costo,
      this.prorrateo,
      this.lote,
      this.loteVenta,
      this.factura,
      this.idProv,
      this.fecIngreso,
      this.fecVencimiento,
        this.usuario,
      this.producto,
      this.proveedor,
      this.nombre,
      this.unidad, this.prodSelect,
      // this.fechaIngresoSistema,
      this.idLote,
      this.fechaSistema,
      this.recibo,
      this.obs});

  factory ModelInventario.fromJson(Map<dynamic,dynamic> json){
    return ModelInventario(
        id: int.parse(json['id'].toString()),
        idCodigo: json['idCodigo']==null?"":json['idCodigo'],
        codAlm: int.parse(json['codAlm'].toString()),
        codProd: json['codProd']==null?"":json['codProd'],
        codigo: json['codigo']==null?"":json['codigo'],
        cantidad: json['cantidad']==null?0:double.parse(json['cantidad'].toString()),
        costoUnitario: json['costoUnitario']==null?0:double.parse(json['costoUnitario'].toString()),
        costo: json['costo']==null?0:double.parse(json['costo'].toString()),
        prorrateo: json['prorrateo']==null?0:double.parse(json['prorrateo'].toString()),
        lote: json['lote']==null?"n/a":json['lote'],
        loteVenta: json['loteVenta']==null?"":json['loteVenta'],
        factura: json['factura']!=null?json['factura']:null,
        idProv: json['idProv']!=null?int.parse(json['idProv'].toString()):null,
        fecVencimiento: json['fecVencimiento']==null?"sin fecha de vencimiento":json['fecVencimiento'],
        nombre: json['nombre']==null?"sin nombre":json['nombre'],
      unidad: json['unidadMedida']==null?"sin unidad":json['unidadMedida'],
        recibo: json['recibo_compra']==null?"sin unidad":json['recibo_compra'],
        obs: json['obs']==null?"sin unidad":json['obs']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'idCodigo':idCodigo,
    'codAlm':codAlm,
    'codProd':codProd,
    'codigo':codigo,
    'cantidad':cantidad,
    'costoUnitario':costoUnitario,
    'costo':costo,
    'prorrateo':prorrateo,
    'lote':lote,
    'loteVenta':loteVenta,
    'factura':factura,
    'idProv':idProv,
    'fecIngreso':fecIngreso,
    'fecVencimiento':fecVencimiento,
    'usuario':usuario,
    'fechaIngresoSistema': fechaSistema,
    'idLote': idLote,
    'recibo_compra': recibo,
    'obs': obs
  };
}