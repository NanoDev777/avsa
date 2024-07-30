
import 'package:andeanvalleysystem/models/model_reserva_orden_compra.dart';

class ModelOrdenCompra {
  int id;
  String codigo;
  int codAlm;
  int usrReg;
  String fecIngreso;
  String fecReg;
  int estado;
  List<ModelReservaOrdenCompra> inventario = List();

  ModelOrdenCompra(
      {this.id,
      this.codigo,
      this.codAlm,
      this.usrReg,
      this.fecIngreso,
      this.fecReg,
      this.estado,
      this.inventario});

  factory ModelOrdenCompra.fromJson(Map<dynamic, dynamic> json) {
    List<ModelReservaOrdenCompra> inv = List();
    if (json['inventario'] != null) {
      List i = json['inventario'];
      i.forEach((element) {
        inv.add(ModelReservaOrdenCompra.fromJson(element));
      });
    }
    return ModelOrdenCompra(
        id: json['id'],
        codigo: json['codigo'],
        codAlm: json['codAlm'],
        usrReg: json['usrReg'],
        fecIngreso: json['fecIngreso'],
        estado: json['estado'],
        fecReg: json['fecReg'],
        inventario: inv);
  }

  Map<dynamic, dynamic> toJson() => {
        'codAlm': codAlm,
        'codigo': codigo,
        'usrReg': usrReg,
        'fecIngreso': fecIngreso,
        'estado': estado,
        'fecReg': fecReg,
        'inventario': inventario.map((e) => e.toJson()).toList()
      };
}
