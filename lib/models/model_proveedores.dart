
class ModelProveedores{
  int id;
  String nombre;
  String direccion;
  String telefono;
  String celular;
  String notas;
  int estado;
  int usrRegistro;
  String contacto;
  String fecRegistro;
  String numRAU;
  String vigenciaRAU;

  ModelProveedores(
      {this.id,
      this.nombre,
      this.direccion,
      this.telefono,
      this.celular,
      this.notas,
      this.estado,
      this.usrRegistro,
      this.contacto,
      this.fecRegistro,
      this.numRAU,
      this.vigenciaRAU});

  factory ModelProveedores.fromJson(Map<dynamic,dynamic> json){
    return ModelProveedores(
        id: json['id'],
        nombre: json['nombre'],
        direccion: json['direccion'],
        telefono: json['telefono'],
        celular: json['celular'],
        notas: json['notas'],
        estado: int.parse(json['estado'].toString()),
        usrRegistro: int.parse(json['usrRegistro'].toString()),
        contacto: json['contacto'],
        fecRegistro: json['fecRegistro'],
        numRAU: json['numRAU'],
        vigenciaRAU: json['vigenciaRAU']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'nombre':nombre,
    'direccion':direccion,
    'telefono':telefono,
    'celular':celular,
    'notas':notas,
    'estado':estado,
    'usrRegistro':usrRegistro,
    'contacto':contacto,
    'fecCreacion':fecRegistro,
    'numRAU':numRAU,
    'vigenciaRAU':vigenciaRAU
  };
}