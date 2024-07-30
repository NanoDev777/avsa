class ModelPrecios{
  int id;
  int guia;
  int id_cliente;
  String nombre_grupo;
  String codProd;
  String nombre;
  String nombre_cliente;
  String cod_cliente;
  double precio_unitario;
  int estado;
  double pesoNeto;
  int factor;
  double cantidad;
  int accion;

  ModelPrecios(
      {this.id,
        this.guia,
        this.id_cliente,
      this.nombre_grupo,
      this.codProd,
        this.nombre,
        this.nombre_cliente,
        this.cod_cliente,
      this.precio_unitario,
      this.estado,
      this.factor,
      this.pesoNeto,
      this.cantidad});

  factory ModelPrecios.fromJson(Map<dynamic,dynamic> json){
    return ModelPrecios(
      id: json['id'],
      guia: json['guia'],
        id_cliente: int.parse(json['id_cliente'].toString()),
        nombre_grupo: json['nombre_grupo'],
        codProd: json['codProd'],
      nombre: json['nombre'],
      nombre_cliente: json['nombre_cliente'],
      cod_cliente: json['cod_cliente'],
        precio_unitario: double.parse(json['precio_unitario'].toString()),
        estado: int.parse(json['estado'].toString()),
      factor: json['factor']!=null?int.parse(json['factor'].toString()):0,
      pesoNeto: json['pesoNeto']!=null?double.parse(json['pesoNeto'].toString()):0,
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'guia': guia,
    'id_cliente':id_cliente,
    'nombre_grupo':nombre_grupo,
    'codProd':codProd,
    'nombre':nombre,
    'nombre_cliente':nombre_cliente,
    'cod_cliente':cod_cliente,
    'precio_unitario':precio_unitario,
    'estado':estado,
    'factor':factor,
    'pesoNeto':pesoNeto
  };
}