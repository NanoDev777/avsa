class ModelSubCliente{
  int id;
  String codigo;
  int tipo;
  String razonSocial;
  String nit;
  String direccion;
  String telefono;
  String pais;
  String correo;
  String c_nombre;
  String c_cargo;
  String c_direccion;
  String c_pais;
  String c_telefono;
  String c_correo;
  String c_adicionales;
  int id_cliente;
  int estado;
  String rs;
  String c;

  ModelSubCliente(
      {this.id,
        this.codigo,
        this.tipo,
      this.razonSocial,
      this.nit,
      this.direccion,
      this.telefono,
      this.pais,
      this.correo,
      this.c_nombre,
      this.c_cargo,
      this.c_direccion,
      this.c_pais,
      this.c_telefono,
      this.c_correo,
      this.c_adicionales,
      this.id_cliente,
      this.estado,
      this.rs,
      this.c});

  factory ModelSubCliente.fromJson(Map<dynamic,dynamic> json){
    return ModelSubCliente(
      id: json['id'],
      codigo: json['codigo']!=null?json['codigo']:"",
        tipo: json['tipo']!=null?json['tipo']:"",
        razonSocial: json['razonSocial']!=null?json['razonSocial']:"",
        nit: json['nit']!=null?json['nit']:"",
        direccion: json['direccion']!=null?json['direccion']:"",
        telefono: json['telefono']!=null?json['telefono']:"",
        pais: json['pais']!=null?json['pais']:"",
        correo: json['correo']!=null?json['correo']:"",
        c_nombre: json['c_nombre']!=null?json['c_nombre']:"",
        c_cargo: json['c_cargo']!=null?json['c_cargo']:"",
        c_direccion: json['c_direccion']!=null?json['c_direccion']:"",
        c_pais: json['c_pais']!=null?json['c_pais']:"",
        c_telefono: json['c_telefono']!=null?json['c_telefono']:"",
        c_correo: json['c_correo']!=null?json['c_correo']:"",
        c_adicionales: json['c_adicionales']!=null?json['c_adicionales']:"",
        id_cliente: json['id_cliente']!=null?json['id_cliente']:"",
        estado: json['estado']!=null?json['estado']:"",
      rs: json['rs']!=null?json['rs']:"",
      c: json['c']!=null?json['c']:"",
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'codigo':codigo,
    'tipo':tipo,
    'razonSocial':razonSocial,
    'nit':nit,
    'direccion':direccion,
    'telefono':telefono,
    'pais':pais,
    'correo':correo,
    'c_nombre':c_nombre,
    'c_cargo':c_cargo,
    'c_direccion':c_direccion,
    'c_pais':c_pais,
    'c_telefono':c_telefono,
    'c_correo':c_correo,
    'c_adicionales':c_adicionales,
    'id_cliente':id_cliente,
    'estado':estado,
  };
}