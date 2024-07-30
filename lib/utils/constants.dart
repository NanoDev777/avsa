import 'package:andeanvalleysystem/models/model_almacenes.dart';
import 'package:andeanvalleysystem/models/model_proceso_produccion.dart';
import 'package:andeanvalleysystem/models/model_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/models/model_transferencia.dart';
import 'package:andeanvalleysystem/utils/api_connections.dart';
import 'package:andeanvalleysystem/utils/connections/api_orden_compra.dart';
import 'package:andeanvalleysystem/utils/connections/api_procesos_produccion.dart';
import 'package:andeanvalleysystem/utils/connections/api_solicitud_transferencia.dart';
import 'package:andeanvalleysystem/utils/connections/api_transferencias.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constant{
  Future<List<ModelAlmacenes>> getAlmacenes() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> codAlm = sp.getString("almacenes").split(',');
    List<int> almacenes = List();
    codAlm.forEach((element) {
      almacenes.add(int.parse(element));
    });
    return await ApiConnections().getAlmacenesPermitidos(almacenes);
  }

  // Future<List<ModelSolicitudTransferencia>> getOrdenesPendientesInAlm() async{
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   List<String> codAlm = sp.getString("almacenes").split(',');
  //   List<int> almacenes = List();
  //   codAlm.forEach((element) {
  //     almacenes.add(int.parse(element));
  //   });
  //   return await ApiSolicitudTransferencia().getPendientes(almacenes);
  // }
  Future<List<ModelProcesoProduccion>> getProcProdPendientes() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> codAlm = sp.getString("almacenes").split(',');
    List<int> almacenes = List();
    codAlm.forEach((element) {
      almacenes.add(int.parse(element));
    });
    return await ApiProcesosProduccion().getPendientes(almacenes);
  }
  Future<List<ModelTransferencia>> getTransferPendientesAlm() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<String> codAlm = sp.getString("almacenes").split(',');
    List<int> almacenes = List();
    codAlm.forEach((element) {
      almacenes.add(int.parse(element));
    });
    return await ApiTransferencias().getPendientesAlmacen(almacenes);
  }
}