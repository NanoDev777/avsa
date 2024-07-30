
class ModelIngredientesFormulas{
  int id;
  int guidForm;
  int orden;
  int tipo;
  String codProd;
  double cantProd;
  String comentarios;
  double costoAdicional;
  double prorrateo;
  int usrReg;
  int estado;
  String nombreProd;
  String unidad;
  bool selection;

  ModelIngredientesFormulas(
      {this.id,
        this.guidForm,
      this.orden,
      this.tipo,
      this.codProd,
      this.cantProd,
      this.comentarios,
      this.costoAdicional,
      this.usrReg,
      this.estado,
      this.nombreProd,
      this.unidad,
        this.prorrateo});

  factory ModelIngredientesFormulas.fromJson(Map<dynamic,dynamic> json){
    return ModelIngredientesFormulas(
        id: json['id'],
        guidForm: json['guidForm'],
        orden: json['orden'],
        tipo: json['tipo'],
        codProd: json['codProd'],
        cantProd: double.parse(json['cantProd']),
        comentarios: json['comentarios'],
        costoAdicional: json['costoAdicional'],
        usrReg: json['usrReg'],
        estado: json['estado'],
        nombreProd: json['nombre']!=null?json['nombre']:null,
        unidad: json['titulo']!=null?json['titulo']:null,
        prorrateo: json['prorrateo']!=null?double.parse(json['prorrateo'].toString()):0
    );
  }

  Map<dynamic,dynamic> toJson()=>{
    'guidForm': guidForm,
    'orden': orden,
    'tipo': tipo,
    'codProd': codProd,
    'cantProd': cantProd,
    'comentarios': comentarios,
    'costoAdicional': costoAdicional,
    'usrReg': usrReg,
    'estado': estado
  };
}