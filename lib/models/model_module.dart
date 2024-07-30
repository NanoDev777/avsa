
class ModelModule{
  int id;
  int patern;
  String name;
  String icon;
  bool activo;

  ModelModule({this.id, this.patern, this.name, this.icon,this.activo=false});

  factory ModelModule.fromJson(int key, Map<dynamic, dynamic> json){
    return ModelModule(
        id: key,
        name: json['name'],
      patern: json['patern'],
      icon: json['icon']
    );
  }

  Map<dynamic, dynamic> toJson()=>{
    "id": id,
    "name": name,
    'patern': patern,
    'icon': icon
  };
}