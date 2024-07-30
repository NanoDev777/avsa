
class ModelMessage{
  int id;
  String asunto;
  String msj;
  String remitente;
  DateTime fecha;

  ModelMessage({this.id, this.asunto, this.msj, this.remitente, this.fecha});

  factory ModelMessage.fromJson(int key, Map<dynamic, dynamic> json){
    return ModelMessage(
        id: key,
        asunto: json['asunto'],
        msj: json['msj'],
        remitente: json['remitente'],
        fecha: json['fecha']
    );
  }

  Map<dynamic, dynamic> toJson()=>{
    "id": id,
    "asunto": asunto,
    "msj": msj,
    "remitente": remitente,
    "fecha": fecha
  };
}