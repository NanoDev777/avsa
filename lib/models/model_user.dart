
class ModelUser{
  int id;
  String name;
  String almacenes;
  String cargo;
  String modulos;
  String usuario;

  String nombres;
  String apPaterno;
  String apMaterno;
  String carnetIdentidad;
  String email;
  String password;
  String fecCreacion;
  String fecUpdate;

  ModelUser({this.id, this.name,this.almacenes,this.cargo,this.modulos,
  this.nombres,this.apMaterno,this.apPaterno,this.carnetIdentidad,this.email,this.password,this.usuario,this.fecCreacion,this.fecUpdate});

  factory ModelUser.fromJson(Map<dynamic, dynamic> json){
    return ModelUser(
      id: json['id'],
      name: "${json['nombres']} ${json['apPaterno']} ${json['apMaterno']!=null?json['apMaterno']:""}",
      almacenes: json['almacenes'],
      modulos: json['modulos'],
      cargo: json['cargo']!=null && json['cargo']!="0"?json['cargo']:"",
      nombres: json['nombres'],
      apPaterno: json['apPaterno'],
      apMaterno: json['apMaterno'],
      carnetIdentidad: json['carnetIdentidad'],
      email: json['email'],
      password: json['password'],
      usuario: json['usuario'],
      fecCreacion: json['fCreacion'],
      fecUpdate: json['fActualizacion']
    );
  }

  Map<dynamic, dynamic> toJson()=>{
    "id": id,
    "name": name,
    "almacenes": almacenes,
    'nombres':nombres,
    'apPaterno':apPaterno,
    'apMaterno':apMaterno,
    'carnetIdentidad':carnetIdentidad,
    'email':email,
    'password':password,
    'usuario':usuario,
    'cargo':cargo,
    'fCreacion': fecCreacion,
    'fActualizacion':fecUpdate,
    'modulos':modulos
  };
}