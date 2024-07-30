
class ModelRegistroIngreso{
  int id;
  String codigo;
  int codAlm;
  String codProd;
  double cantidad;
  double costo;
  double costoUnitario;
  String lote;
  String loteVenta;
  String factura;
  int idProv;
  int aprobConta;
  int aprobCalida;
  int usuario;
  String fecIngreso;
  String fecVencimiento;
  String nombreProd;
  String nombreAlm;
  String unidadMedida;
  String provName;
  String fecRegistro;
  String provname;
  String numRAU;
  String vigeniaRau;
  String notas;
  String recibo;
  String obs;


  ModelRegistroIngreso({
    this.id,
      this.codigo,
      this.codAlm,
      this.codProd,
      this.cantidad,
      this.costo,
      this.costoUnitario,
      this.lote,
      this.loteVenta,
      this.factura,
      this.idProv,
      this.aprobConta,
      this.aprobCalida,
      this.usuario,
      this.fecIngreso,
      this.fecVencimiento,
    this.nombreProd,
    this.nombreAlm,
    this.unidadMedida,
    this.provName,
    this.fecRegistro,
    this.provname,
    this.numRAU,
    this.vigeniaRau,
    this.notas,
    this.recibo,
    this.obs
  });

  factory ModelRegistroIngreso.fromJson(Map<dynamic,dynamic> json){
    return ModelRegistroIngreso(
      id: int.parse(json['id'].toString()),
        codigo: json['codigo']!=null?json['codigo']:"",
        codAlm: int.parse(json['codAlm'].toString()),
        codProd: json['codProd'],
        cantidad: double.parse(json['cantidad'].toString()),
        costo: double.parse(json['costo'].toString()),
        costoUnitario: double.parse(json['costoUnitario'].toString()),
        lote: json['lote'],
        loteVenta: json['loteVenta']!=null?json['loteVenta']:"",
        factura: json['factura']!=null?json['factura']:"",
        idProv: int.parse(json['idProv'].toString()),
        aprobConta: int.parse(json['aprobConta'].toString()),
        aprobCalida: int.parse(json['aprobCalida'].toString()),
        usuario: int.parse(json['usuario'].toString()),
        fecIngreso: json['fecIngreso'],
        fecVencimiento: json['fecVencimiento'],
      nombreProd: json['nombre'],
      nombreAlm: json['name'],
      unidadMedida: json['titulo'],
      provName: json['prov']!=null?json['prov']:"",
      fecRegistro: json['fecRegistro']!=null?json['fecRegistro']:"",
      numRAU: json['numRAU']!=null?json['numRAU']:"",
      vigeniaRau: json['vigenciaRAU']!=null?json['vigenciaRAU']:"",
      notas: json['notas']!=null?json['notas']:"",
      recibo: json['recibo_compra']!=null?json['recibo_compra']:"",
      obs: json['obs']!=null?json['obs']:"",
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'codigo': codigo,
        'codAlm': codAlm,
        'codProd': codProd,
        'cantidad': cantidad,
        'costoUnitario': costoUnitario,
        'costo': costo,
        'lote': lote,
        'loteVenta': loteVenta,
        'factura': factura,
        'idProv': idProv,
        'aprobConta': aprobConta,
        'aprobCalida': aprobCalida,
        'usuario': usuario,
    'fecIngreso': fecIngreso,
    'fecVencimiento': fecVencimiento,
    'fecRegistro':fecRegistro,
    'recibo_compra':recibo,
    'obs':obs
  };
}