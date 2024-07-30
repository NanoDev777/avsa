// import 'package:flutter/foundation.dart';

class ModelHistorialKardex {
  String idReg;
  int codAlm;
  String codProd;
  double cantidad;
  double costo;
  double costoUnitario;
  double prorrateo;
  double saldo;
  double saldoCosto;
  String lote;
  int usuario;
  String accion;
  String created_at;
  String updated_at;

  ModelHistorialKardex(
      {this.idReg,
      this.codAlm,
      this.codProd,
      this.cantidad,
      this.costo,
      this.costoUnitario,
      this.prorrateo,
      this.saldo,
      this.saldoCosto,
      this.lote,
      this.usuario,
      this.accion,
      this.created_at,
      this.updated_at});

  factory ModelHistorialKardex.fromJson(Map<dynamic, dynamic> json) {
    List d = json['creado_en'].toString().split('-');
    return ModelHistorialKardex(
        idReg: json['idReg'] != null ? json['idReg'] : "",
        codAlm: json['codAlm'] != null ? json['codAlm'] : 0,
        codProd: json['codProd'] != null ? json['codProd'] : "",
        cantidad: double.parse(json['cantidad'].toString()),
        costo: double.parse(json['costo'].toString()),
        costoUnitario: double.parse(json['costoUnitario'].toString()),
        prorrateo: double.parse(json['prorrateo'].toString()),
        saldo: double.parse(json['saldo'].toString()),
        saldoCosto: double.parse(json['saldoCosto'].toString()),
        lote: json['lote'] != null ? json['lote'] : "",
        usuario: json['usuario'] != null ? json['usuario'] : 0,
        accion: json['accion'] != null ? json['accion'] : "",
        created_at: json['creado_en'] != null ? "${d[2]}/${d[1]}/${d[0]}" : "");
  }

  Map<dynamic, dynamic> toJson() => {
        'idReg': idReg,
        'codAlm': codAlm,
        'codProd': codProd,
        'cantidad': cantidad,
        'costo': costo,
        'costoUnitario': costoUnitario,
        'prorrateo': prorrateo,
        'saldo': saldo,
        'saldoCosto': saldoCosto,
        'lote': lote,
        'usuario': usuario,
        'accion': accion,
        'creado_en': created_at,
      };
}
