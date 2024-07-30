
class ModelFormula{
  int id;
  int guidForm;
  String titulo;
  String codProdRes;
  double cantidad;
  String instruccion;
  int lineaProduccion;
  int version;
  int cliente;
  int estado;
  int usrReg;
  String razonSocial;
  String unidadMedida;
  String lineaProduccionTitulo;

  ModelFormula(
      {this.id,
        this.guidForm,
        this.titulo,
      this.codProdRes,
      this.cantidad,
      this.instruccion,
      this.lineaProduccion,
      this.version,
      this.cliente,
      this.estado,
      this.usrReg,
      this.razonSocial,
      this.unidadMedida,
      this.lineaProduccionTitulo});

  factory ModelFormula.fromJson(Map<dynamic,dynamic> json){
    return ModelFormula(
        id: json['id'],
        guidForm: json['guidForm'],
        titulo: json['titulo'],
        codProdRes: json['codProdRes'],
        cantidad: json['cantidad']!=null?double.parse(json['cantidad'].toString()):0,
        instruccion: json['instruccion']!=null?json['instruccion']:"",
        lineaProduccion: json['lineaProduccion'],
        version: json['version']==null?0:json['version'],
        cliente: json['cliente']==null?0:json['cliente'],
        estado: json['estado']==null?0:json['estado'],
        usrReg: json['usrReg']==null?0:json['usrReg'],
        razonSocial: json['razonSocial']==null?"sin cliente":json['razonSocial'],
        unidadMedida: json['unidadMedida'],
      lineaProduccionTitulo: json['lineaProduccionTitulo']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'titulo': titulo,
    'codProdRes': codProdRes,
    'cantidad': cantidad,
    'instruccion': instruccion,
    'lineaProduccion': lineaProduccion,
    'version': version,
    'cliente': cliente,
    'estado': estado,
    'usrReg': usrReg
  };
}