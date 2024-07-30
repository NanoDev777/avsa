
class ModelAlmacenes{
  int id;
  int codAlm;
  String name;
  String ubicAlmacen;
  String telf;
  int activo;
  String fechaRegistro;
  int usrRegistro;
  String ProdPermitidos;

  ModelAlmacenes(
      {this.id,
      this.name,
      this.ProdPermitidos,
      this.ubicAlmacen,
      this.telf,
      this.activo,
      this.fechaRegistro,
      this.codAlm,
      this.usrRegistro});

  factory ModelAlmacenes.fromJson(Map<dynamic, dynamic> json){
    return ModelAlmacenes(
        id: int.parse(json['id'].toString()),
        name: json['name'],
        ProdPermitidos: json['ProdPermitidos'],
        ubicAlmacen: json['ubicAlmacen'],
        telf: json['telf'],
        activo: int.parse(json['activo'].toString()),
        fechaRegistro: json['fechaRegistro'],
        codAlm: int.parse(json['codAlm'].toString()),
        usrRegistro: json['usrRegistro']
    );
  }

  Map<dynamic, dynamic> toJson()=>{
    "id": id,
    "name": name,
    "ProdPermitidos": ProdPermitidos,
    "ubicAlmacen": ubicAlmacen,
    "telf": telf,
    "activo": activo,
    "fechaRegistro": fechaRegistro,
    "codAlm": codAlm,
    "usrRegistro": usrRegistro
  };
}
