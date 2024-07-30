
import 'package:andeanvalleysystem/models/model_reserva_itmes_proc_prod.dart';

class ModelProcesoProduccion {
  int id;
  int idFormula;
  int idCliente;
  int idLinProd;
  int codAlmProd;
  int codAlmDest;
  String loteProd;
  String loteVenta;
  String unidad;
  String fecRegistro;
  double cantidad;
  double costoReal;
  double costoReceta;
  double variacion;
  String obs;
  int usrReg;
  int aprob;
  int estado;
  String fecInicio;
  String fecFin;
  String fecVenc;
  String fecCulminacion;
  String createAt;
  String nombreProducto;
  String lineaProd;
  String clienteRZ;
  List<ModelReservaItemsProcProd> reservas = List();
  String tituloProd;
  String codProdRes;
  String fecAprob;
  String linProdName;
  String usrRegName;

  ModelProcesoProduccion(
      {this.id,
        this.idFormula,
        this.idCliente,
        this.idLinProd,
        this.codAlmProd,
        this.codAlmDest,
        this.loteProd,
        this.loteVenta,
        this.unidad,
        this.fecRegistro,
        this.cantidad,
        this.costoReal,
        this.costoReceta,
        this.variacion,
        this.obs,
        this.usrReg,
        this.aprob,
        this.estado,
        this.fecInicio,
        this.fecFin,
        this.fecVenc,
        this.fecCulminacion,
        this.createAt,
        this.nombreProducto,
        this.lineaProd,
        this.clienteRZ,
        this.codProdRes,
        this.tituloProd,
      this.fecAprob,
      this.linProdName,
      this.usrRegName});

  factory ModelProcesoProduccion.fromJson(Map<dynamic, dynamic> json) {
    return ModelProcesoProduccion(
        id: json['id'],
        idFormula: json['idFormula'],
        idCliente: json['idCliente'],
        idLinProd: json['idLinProd'],
        codAlmProd: json['codAlmProd'],
        codAlmDest: json['codAlmDest'],
        loteProd: json['loteProd'],
        loteVenta: json['loteVenta'],
        unidad: json['unidad'],
        fecRegistro: json['fecRegistro'],
        cantidad: double.parse(json['cantidad'].toString()),
        costoReal: json['costoReal']!=null?double.parse(json['costoReal'].toString()):0,
        costoReceta: json['costoReceta']!=null?double.parse(json['costoReal'].toString()):0,
        variacion: json['variacion']!=null?double.parse(json['variacion'].toString()):0,
        obs: json['obs'],
        usrReg: json['usrReg'],
        aprob: json['aprob'],
        estado: json['estado'],
        fecInicio: json['fecInicio'],
        fecFin: json['fecFin'],
        fecVenc: json['fecVenc'],
        fecCulminacion: json['fecCulminacion'],
        createAt: json['created_at'],
        nombreProducto: json['nombre'] != null ? json['nombre'] : null,
        lineaProd: json['titulo'] != null ? json['titulo'] : null,
        clienteRZ: json['razonSocial'] != null ? json['razonSocial'] : null,
        codProdRes: json['codProdRes'] != null ? json['codProdRes'] : null,
        tituloProd: json['titulo'] != null ? json['titulo'] : null,
      fecAprob: json['fecAprob'],
        linProdName: json['linProd'],
        usrRegName: "${json['nombres']} ${json['apPaterno']} ${json['apMaterno']}"
    );
  }

  Map<dynamic, dynamic> toJson() => {
    'idFormula': idFormula,
    'idCliente': idCliente,
    'idLinProd': idLinProd,
    'codAlmProd': codAlmProd,
    'codAlmDest': codAlmDest,
    'loteProd': loteProd,
    'loteVenta': loteVenta,
    'unidad': unidad,
    'fecRegistro': fecRegistro,
    'cantidad': cantidad,
    'costoReal': costoReal,
    'costoReceta': costoReceta,
    'variacion': variacion,
    'obs': obs,
    'usrReg': usrReg,
    'aprob': aprob,
    'estado': estado,
    'fecInicio': fecInicio,
    'fecFin': fecFin,
    'fecVenc': fecVenc,
    'fecCulminacion': fecCulminacion,
    'reservas': reservas.map((e) => e.toJson()).toList()
  };
}
