class ModelTransferencia{
  int id;
  String codTransferencia;
  int almOrigen;
  int almDestino;
  String loteTransferido;
  String codProd;
  double cantidad=0;
  String fechaTransferencia;
  int usrTransferencia;
  String fechaAceptacion;
  int usrAceptacion;
  int idLote;
  int estado;
  double costoUnitario;
  String fecVencimiento;
  String descripcion;
  String unidad;
  String usuario;
  String loteVenta;
  double prorrateo;
  String creado_en;
  String usuarioTransferencia;

  ModelTransferencia(
      {this.id,
      this.codTransferencia,
      this.almOrigen,
      this.almDestino,
      this.loteTransferido,
      this.codProd,
      this.cantidad,
      this.fechaTransferencia,
      this.usrTransferencia,
      this.fechaAceptacion,
      this.usrAceptacion,
      this.idLote,
      this.estado,
      this.costoUnitario,
      this.fecVencimiento,
        this.descripcion,
        this. unidad,
        this. usuario,
        this. loteVenta,
        this. prorrateo,
        this.creado_en,
        this.usuarioTransferencia
      });

  factory ModelTransferencia.fromJson(Map<dynamic,dynamic> json){
    print("${json['cantidad'].toString()}::${json['costoUnit'].toString()}");
    return ModelTransferencia(
        id: json['id'],
        codTransferencia: json['codTransferencia'],
        almOrigen: json['almOrigen'],
        almDestino: json['almDestino'],
        loteTransferido: json['loteTransferido'],
        codProd: json['codProd'],
        cantidad: json['cantidad']!=null?double.parse(json['cantidad'].toString()):0,
        costoUnitario: json['costoUnit']!=null?double.parse(json['costoUnit'].toString()):0,
        fechaTransferencia: json['fechaTransferencia'],
        usrTransferencia: json['usrTransferencia'],
        fechaAceptacion: json['fechaAceptacion'],
        usrAceptacion: json['usrAceptacion'],
        idLote: json['idLote'],
        estado: json['estado'],
        descripcion: json['nombre'],
      unidad: json['titulo'],
      usuario: "${json['nombres']} ${json['apPaterno']}",
      loteVenta: json['loteVenta'],
      prorrateo: json['prorrateo']!=null?double.parse(json['prorrateo'].toString()):0,
        fecVencimiento: json['fecVencimiento'],
      creado_en: json['creado_en'],
      usuarioTransferencia: "${json['nombres']} ${json['apPaterno']} ${json['apMaterno']}",
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'codTransferencia': codTransferencia,
    'almOrigen': almOrigen,
    'almDestino': almDestino,
    'loteTransferido': loteTransferido,
    'codProd': codProd,
    'cantidad': cantidad,
    'costoUnit': costoUnitario,
    'fechaTransferencia': fechaTransferencia,
    'usrTransferencia': usrTransferencia,
    'fechaAceptacion': fechaAceptacion,
    'usrAceptacion': usrAceptacion,
    'idLote': idLote,
    'estado': estado,
    'creado_en':creado_en
  };
}