class ModelProforma{
  int id;
  String codProf;
  String codigo;
  int id_cliente;
  int id_subcliente;
  int id_precio;
  String id_tipo_pago;
  String obs;
  String fec_creacion;
  int id_usuario;
  String fec_aprob;
  int id_usuario_aprob;
  int estado;
  String mes;

  String nombreCliente;
  String nombreSubCliente;
  String nombrePrecio;

  ModelProforma(
      {this.id,
        this.codProf,
      this.codigo,
      this.id_cliente,
      this.id_subcliente,
      this.id_precio,
      this.id_tipo_pago,
      this.obs,
      this.fec_creacion,
      this.id_usuario,
      this.fec_aprob,
      this.id_usuario_aprob,
      this.estado,
      this.nombreCliente,
      this.nombreSubCliente,
      this.nombrePrecio,
      this.mes});

  factory ModelProforma.fromJson(Map<dynamic,dynamic> json){
    return ModelProforma(
        id:json["id"],
      codigo:json["codigo"],
      codProf:json["codProf"],
        id_cliente:json["id_cliente"],
        id_subcliente:json["id_subcliente"],
        id_precio:json["id_precio"]!=null?json["id_precio"]:0,
        id_tipo_pago:json["id_tipo_pago"],
        obs:json["obs"]!=null?json["obs"]:"",
        fec_creacion:json["fec_creacion"],
        id_usuario:json["id_usuario"],
        fec_aprob:json["fec_aprob"],
        id_usuario_aprob:json["id_usuario_aprob"],
        estado:json["estado"],
      nombreCliente:json["razonSocial"],
      nombreSubCliente:json["rzsub"],
      nombrePrecio:json["nombre_grupo"]!=null?json["nombre_grupo"]:"",
      mes:json["mes"]!=null?json["mes"]:"",
    );
  }
  Map<dynamic,dynamic> toJson()=>{
    "codProf": codProf,
    "codigo": codigo,
    "id_cliente": id_cliente,
    "id_subcliente": id_subcliente,
    "id_precio": id_precio,
    "id_tipo_pago": id_tipo_pago,
    "obs": obs,
    "fec_creacion": fec_creacion,
    "id_usuario": id_usuario,
    "fec_aprob": fec_aprob,
    "id_usuario_aprob": id_usuario_aprob,
    "estado": estado,
    "mes": mes
  };
}