class ModelMotivos{
  int id;
  String nombre;
  int idUsr;
  String creado_en;
  int estado;

  ModelMotivos(
      {this.id, this.nombre, this.idUsr, this.creado_en, this.estado});

  factory ModelMotivos.fromJson(Map<dynamic,dynamic> json){
    return ModelMotivos(
        id: json['id'],
        nombre:  json['nombre'],
        idUsr:  json['idUsr'],
        creado_en:  json['creado_en'],
        estado:  json['estado']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'id':id,
    'nombre':nombre,
    'idUsr':idUsr,
    'creado_en':creado_en,
    'estado':estado
  };
}