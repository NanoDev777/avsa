
class ModelSolicitudTransferencia{
  int id;
  String codTransferencia;
  int almDestino;
  String codProd;
  double cantidad;
  int usrReg;
  int usrPet;
  String fechaReg;
  int estado;
  String nombre;
  String comentario;
  String nombres;
  String apPaterno;
  String apMaterno;
  String name;


  ModelSolicitudTransferencia(
      {this.id,
      this.codTransferencia,
      this.almDestino,
      this.codProd,
      this.cantidad,
      this.usrReg,
        this.usrPet,
      this.fechaReg,
      this.estado,
      this.nombre,
      this.comentario,
      this.name,
      this.apMaterno,
      this.apPaterno,
      this.nombres});

  factory ModelSolicitudTransferencia.fromJson(Map<dynamic,dynamic> json){
    return ModelSolicitudTransferencia(
      id: json['id'],
      codTransferencia: json['codTransferencia'],
      almDestino: json['almDestino'],
      codProd: json['codProd'],
      cantidad: json['cantidad']!=null?double.parse(json['cantidad']):0,
      usrReg: json['usrReg'],
        usrPet: json['usrPet'],
      fechaReg: json['fechaReg'],
      estado: json['estado'],
      nombre: json['nombre'],
      comentario: json['comentario'],
        nombres: json['nombres'],
        apPaterno: json['apPaterno'],
        apMaterno: json['apMaterno'],
        name: json['name']
    );
  }
  Map<dynamic,dynamic> toJson()=>{
    'codTransferencia': codTransferencia,
    'almDestino': almDestino,
    'codProd': codProd,
    'cantidad': cantidad,
    'usrReg': usrReg,
    'usrPet': usrPet,
    'fechaReg': fechaReg,
    'estado': estado,
    'comentario':comentario
  };
}