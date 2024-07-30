
class ModelParametros{
  int id;
  String titulo;
  int estado;

  ModelParametros({this.id, this.titulo, this.estado});

  factory ModelParametros.fromJson(Map<dynamic,dynamic> json){
    return ModelParametros(
        id: json['id'],
        titulo: json['titulo'],
        estado: json['estado']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'titulo': titulo,
    'estado': estado,
  };
}