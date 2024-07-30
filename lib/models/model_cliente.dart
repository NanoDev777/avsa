
class ModelCliente{
  int id;
  int tipo;
  String razonSocial;
  String nit;
  String contacto;
  String telf;
  String email;
  String pais;
  String codigo;
  String direccion;
  String c_direccion;
  String c_cargo;
  String c_telefono;
  String c_pais;
  String c_correo;
  int estado;

  ModelCliente(
      {this.id,
      this.tipo,
      this.razonSocial,
      this.nit,
      this.contacto,
      this.telf,
      this.email,
      this.pais,
      this.codigo,
        this.direccion,
        this.c_direccion,
        this.c_cargo,
        this.c_telefono,
        this.c_pais,
        this.c_correo,
      this.estado});

  factory ModelCliente.fromJson(Map<dynamic,dynamic> json){
    return ModelCliente(
        id: json['id'],
        tipo: json['tipo'],
        razonSocial: json['razonSocial'],
        nit: json['nit'],
        contacto: json['contacto']!=null?json['contacto']:"",
        telf: json['telf'],
        email: json['email'],
        pais: json['pais'],
        codigo: json['codigo'],
        direccion: json['direccion'],
        c_direccion: json['c_direccion'],
        c_cargo: json['c_cargo'],
        c_telefono: json['c_telefono'],
        c_pais: json['c_pais'],
        c_correo: json['c_correo'],
        estado: json['estado']
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'tipo': tipo,
    'razonSocial': razonSocial,
    'nit': nit,
    'contacto': contacto,
    'telf': telf,
    'email': email,
    'pais': pais,
    'codigo': codigo,
    'direccion':direccion,
    'c_direccion':c_direccion,
    'c_cargo':c_cargo,
    'c_telefono':c_telefono,
    'c_pais':c_pais,
    'c_correo':c_correo,
    'estado': estado
  };
}