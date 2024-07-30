class ModelSalidasBajas{
  String codigoSalida;
  String tipo;
  String motivo;
  int codAlm;
  String codProd;
  String lote;
  String loteVenta;
  double cantidad;
  double costoUnit;
  String fecReg;
  int usrReg;
  int aprov;
  String fecAprov;
  int idLote;
  int estado;
  int solicitante;
  String area;
  String observacion;
  //extras
  String usuario;
  String solicitanteName;
  String nombreProd;
  String unidadMedida;
  String fecVencimiento;
  double costoTotal;
  String nameAlmacen;

  ModelSalidasBajas(
      {this.codigoSalida,
        this.tipo,
        this.motivo,
      this.codAlm,
      this.codProd,
        this.lote,
        this.loteVenta,
      this.cantidad,
      this.costoUnit,
      this.fecReg,
      this.usrReg,
      this.aprov,
      this.fecAprov,
      this.idLote,
      this.estado,
      this.solicitante,
      this.area,
      this.observacion,
      this.usuario,
      this.nombreProd,
      this.unidadMedida,
      this.fecVencimiento,
      this.costoTotal,
      this.solicitanteName,
      this.nameAlmacen});

  factory ModelSalidasBajas.fromJson(Map<dynamic,dynamic> json){
    return ModelSalidasBajas(
        codigoSalida: json['codigoSalida'],
      tipo: json['tipo'],
      motivo: json['motivo']!=null?json['motivo']:"",
        codAlm: json['codAlm'],
        codProd: json['codProd'],
        lote: json['lote'],
      loteVenta: json['loteVenta'],
        cantidad: double.parse(json['cantidad']),
        costoUnit: double.parse(json['costoUnit']),
        fecReg: json['fecReg'],
        usrReg: json['usrReg'],
        aprov: json['aprov'],
        fecAprov: json['fecAprov']!=null?json['fecAprov']:"",
        idLote: json['idLote'],
        estado: json['estado'],
        solicitante: json['solicitante'],
        area: json['area'],
        observacion: json['observacion']!=null?json['observacion']:"",
        usuario: "${json['nombreUsrReg']} ${json['apPaternoUsrReg']} ${json['apMaternoUsrReg']!=null?json['apMaternoUsrReg']:""}",
      solicitanteName: "${json['nombreSol']} ${json['apPaternoSol']} ${json['apMaternoSol']!=null?json['apMaternoSol']:""}",
        nombreProd: json['nombre'],
      unidadMedida: json['titulo'],
      fecVencimiento: json['fecVencimiento'],
      nameAlmacen: json['name'],
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'codigoSalida':codigoSalida,
    'tipo':tipo,
    'motivo':motivo,
    'codAlm':codAlm,
    'codProd':codProd,
    'lote':lote,
    'cantidad':cantidad,
    'costoUnit':costoUnit,
    'fecReg':fecReg,
    'usrReg':usrReg,
    'aprov':aprov,
    'fecAprov':fecAprov,
    'idLote':idLote,
    'estado':estado,
    'solicitante':solicitante,
    'area':area,
    'observacion':observacion
  };


}