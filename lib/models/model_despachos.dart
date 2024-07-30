class ModelDespachos{
  int id;
  String codigo;
  int idProforma;
  int cliente;
  int subCliente;
  String lote;
  double cantidad;
  double costoTotal;
  int idUsr;
  String fecDespacho;
  String fecSalida;
  String hrCarguio;
  String hrCarguioFin;
  String numFactura;
  String placaVehiculo;
  String tipoTransporte;
  String respEntrega;
  String respRecepcion;
  String obs;
  String lotes;
  String cantUsada;

  ModelDespachos(
      {
        this.id,
        this.codigo,
      this.idProforma,
        this.cliente,
        this.subCliente,
      this.lote,
      this.cantidad,
      this.costoTotal,
      this.idUsr,
      this.fecDespacho,
        this.fecSalida,
        this.hrCarguio,
        this.hrCarguioFin,
        this.numFactura,
        this.placaVehiculo,
        this.tipoTransporte,
        this.respEntrega,
        this.respRecepcion,
        this.obs,
        this.lotes,
        this.cantUsada,
      });

  factory ModelDespachos.fromJson(Map<dynamic,dynamic> json){
    return ModelDespachos(
        id: json['id']!=null?json['id']:0,
        codigo: json['codigo'],
        idProforma: int.parse(json['idProforma'].toString()),
        lote: json['lote'],
        cliente: json['cliente'],
        subCliente: json['subCliente'],
        cantidad: json['cantidad'],
        costoTotal: json['costoTotal'],
        idUsr: int.parse(json['idUsr'].toString()),
        fecDespacho: json['fecDespacho'],
        fecSalida: json['fecSalida'],
        hrCarguio: json['hrCarguio'],
        hrCarguioFin: json['hrCarguioFin'],
        numFactura: json['numFactura'],
        placaVehiculo: json['placaVehiculo'],
        tipoTransporte: json['tipoTransporte'],
        respEntrega: json['respEntrega'],
        respRecepcion: json['respRecepcion'],
        obs: json['obs'],
        lotes: json['lotes'],
        cantUsada: json['cantUsada']
    );
  }

  Map<dynamic,dynamic> toJson() => {
    'codigo':codigo,
    'idProforma':idProforma,
    'cliente':cliente,
    'subCliente':subCliente,
    'lote':lote,
    'cantidad':cantidad,
    'costoTotal':costoTotal,
    'idUsr':idUsr,
    'fecDespacho':fecDespacho,
    'fecSalida':fecSalida,
    'hrCarguio':hrCarguio,
    'hrCarguioFin':hrCarguioFin,
    'numFactura':numFactura,
    'placaVehiculo':placaVehiculo,
    'tipoTransporte':tipoTransporte,
    'respEntrega':respEntrega,
    'respRecepcion':respRecepcion,
    'obs':obs,
    'lotes':lotes,
    'cantUsada':cantUsada
  };
}