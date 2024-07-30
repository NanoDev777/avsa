
class ModelItem{
  int id;
  String codigo;
  int indiceProd;
  String nombre;
  int unidadMedida;
  int estado;
  int sgi;
  int usrRegistro;
  String descripcion;
  int stock;
  int factor;
  double pesoNeto;
  double pesoBruto;
  int cliente;
  String titulo;
  String razonSocial;

  double cantidad;
  double precio;


  ModelItem(
      {this.id,
      this.codigo,
      this.indiceProd,
      this.nombre,
      this.unidadMedida,
      this.estado,
      this.sgi,
      this.usrRegistro,
      this.descripcion,
      this.stock,
        this.factor,
      this.pesoNeto,
      this.pesoBruto,
      this.cliente,
      this.titulo,
      this.razonSocial});

  factory ModelItem.fromJson(Map<dynamic, dynamic> json){
    return ModelItem(
      id: int.parse(json['id'].toString()),
        codigo: json['codigo'],
        indiceProd: int.parse(json['indiceProd'].toString()),
        nombre: json['nombre'],
        unidadMedida: int.parse(json['unidadMedida'].toString()),
        estado: int.parse(json['estado'].toString()),
        sgi: int.parse(json['sgi'].toString()),
        usrRegistro: int.parse(json['usrRegistro'].toString()),
        descripcion: json['descripcion'],
        stock: int.parse(json['stock'].toString()),
        factor: int.parse(json['factor'].toString()),
        pesoNeto: double.parse(json['pesoNeto'].toString()),
        pesoBruto: double.parse(json['pesoBruto'].toString()),
        cliente: int.parse(json['cliente'].toString()),
        titulo: json['titulo'].toString(),
        razonSocial: json['razonSocial'].toString()
    );
  }

  Map<dynamic, dynamic> toJson()=>{
    "codigo": codigo,
    "indiceProd": indiceProd,
    "nombre": nombre,
    "unidadMedida": unidadMedida,
    "estado": estado,
    "sgi": sgi,
    "usrRegistro": usrRegistro,
    "descripcion": descripcion,
    "stock": stock,
    "factor": factor,
    "pesoNeto": pesoNeto,
    "pesoBruto": pesoBruto,
    "cliente": cliente
  };
}