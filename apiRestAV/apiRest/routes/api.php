<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/


Route::get('/test', function (Request $request) {
    return "hola";
});

Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});
//almacenes
//Route::get('almacenes','almacenesController@index');
//Route::get('almacenes/permitidos/{codAlm}','almacenesController@prodPermitido');

Route::get('login/{usuario}/{password}','userController@login');
Route::get('users','userController@index');

Route::post('almacenes/i','almacenesController@index');
Route::get('almacenes/{id}','almacenesController@show');
Route::post('almacenes','almacenesController@store');
Route::post('almacenes/{id}','almacenesController@update');
Route::post('almacenes/activar/{id}','almacenesController@activar');
Route::post('almacenes/desactivar/{id}','almacenesController@desactivar');
Route::post('almacenes/borrar/{id}','almacenesController@destroy');
//productos
Route::get('productos','productosController@index');
Route::post('productos/permitidos','productosController@permitidosAlmacen');
Route::get('productos/{codProd}','productosController@getProdCodProd');
Route::get('productos/unidadMedida/{codProd}','productosController@getUnidadMedida');
Route::get('productos/nameUnidadMedida/{codProd}','productosController@getNameUnidadMedida');
//proveedores
Route::get('proveedores','proveedoreController@index');
Route::get('proveedores/{id}','proveedoreController@show');
Route::post('proveedores','proveedoreController@store');
Route::post('proveedores/{id}','proveedoreController@update');
Route::post('proveedores/activar/{id}','proveedoreController@activar');
Route::post('proveedores/desactivar/{id}','proveedoreController@desactivar');
Route::post('proveedores/borrar/{id}','proveedoreController@destroy');
//inventarios
Route::get('inventario','inventarioController@index');
Route::post('inventario/discount','inventarioController@discountInventory');
Route::post('inventario/return','inventarioController@returnInventory');
Route::get('inventario/prorrateo/{codAlm}/{codProd}','inventarioController@getInventariosProrrateo');
Route::get('inventario/lotes/{codAlm}/{codProd}','inventarioController@getInventariosLotes');
Route::get('inventario/{codAlm}','inventarioController@getInventariosByAlmacen');
Route::get('inventario/{codAlm}/{codProd}','inventarioController@getInventariosByAlmacenAndCodProd');
Route::post('inventario','inventarioController@store');
Route::get('inventario/registro','registroIngresoController@index');
Route::get('inventario/getcantidadtotal/{codAlm}/{codProd}','inventarioController@getCantidadTotal');
Route::get('inventario/getcostototal/{codAlm}/{codProd}','inventarioController@getCostoTotal');
Route::post('inventario/registro','registroIngresoController@store');
Route::get('inventario/cantidad/{codAlm}/{codProd}','inventarioController@getCantidadExistente');
//ordenes de compra
Route::get('ordencompra','ordenComprasController@index');
Route::post('ordencompra','ordenComprasController@insertOrdenCompra');
Route::get('ordencompra/{id}','ordenComprasController@terminarOrden');
Route::get('ordencompra/pendient/{estado}','ordenComprasController@pendient');
Route::get('ordencompra/terminar/{id}','ordenComprasController@terminarOrden');
Route::get('itemsordencompra','itemsOrdenComprasController@index');
Route::get('itemsordencompra/{idOC}','itemsOrdenComprasController@show');
//formulas
Route::get('formulas','formulaController@index');
Route::get('formulas/{id}','formulaController@show');
Route::get('formulas/codProd/{codProd}','formulaController@showCodProd');
Route::get('formulas/lineaProd/{linProd}','formulaController@showLinProd');
Route::post('formulas','formulaController@store');
Route::post('formulas/{id}','formulaController@update');
Route::get('formulas/activar/{id}','formulaController@activar');
Route::get('formulas/desactivar/{id}','formulaController@desactivar');
//ingredientes formulas
Route::get('ingredientesformulas','ingredientesFormulasController@index');
Route::get('ingredientesformulas/{id}/{idProcProd}','ingredientesFormulasController@show');
Route::post('ingredientesformulas','ingredientesFormulasController@store');
Route::post('ingredientesformulas/update/{id}','ingredientesFormulasController@update');
//parametros linea de produccion
Route::get('linProd','parametrosLineaProduccionController@index');
Route::get('linProd/{id}','parametrosLineaProduccionController@show');
Route::post('linProd','parametrosLineaProduccionController@store');
Route::post('linProd/{id}','parametrosLineaProduccionController@update');
Route::post('linProd/activar/{id}','parametrosLineaProduccionController@activar');
Route::post('linProd/desactivar/{id}','parametrosLineaProduccionController@desactivar');
Route::post('linProd/borrar/{id}','parametrosLineaProduccionController@destroy');
//registro proceso produccion
Route::get('regProcProd','registroProcProdController@index');
Route::get('regProcProd/solicitarTransferencia/{id}','registroProcProdController@transferenciaSolicitada');
Route::post('regProcProd/pendientes','registroProcProdController@showPendientes');
Route::get('regProcProd/pendientes/solicitud','registroProcProdController@showPendientesSolicitud');
Route::get('regProcProd/{id}','registroProcProdController@show');
Route::get('regProcProd/ing/{id}','registroProcProdController@getIngredientes');
Route::post('regProcProd','registroProcProdController@store');
Route::post('regProcProd/{id}','registroProcProdController@update');
Route::get('regProcProd/aprobar/{id}','registroProcProdController@aprobar');
Route::get('regProcProd/rechazar/{id}','registroProcProdController@rechazar');
Route::get('regProcProd/cancelar/{id}','registroProcProdController@destroy');
Route::get('regProcProd/borrar/{id}','registroProcProdController@borrar');
Route::get('regProcProd/variacion/pendientes','registroProcProdController@getVariacionPendiente');
//ingredientes
Route::get('ProcProdIngr','ingredientesFormulasController@index');
Route::get('ProcProdIngr/{id}','ingredientesFormulasController@show');

//clientes
Route::get('clientes','clientesController@index');
Route::get('clientes/{id}','clientesController@show');
Route::post('clientes','clientesController@store');
Route::post('clientes/{id}','clientesController@update');
Route::post('clientes/activar/{id}','clientesController@activar');
Route::post('clientes/desactivar/{id}','clientesController@desactivar');
Route::post('clientes/borrar/{id}','clientesController@destroy');
//parametros unidad de medida
Route::get('unidMedida','parametrosUnidMedidaController@index');
Route::get('unidMedida/{id}','parametrosUnidMedidaController@show');
Route::post('unidMedida','parametrosUnidMedidaController@store');
Route::post('unidMedida/{id}','parametrosUnidMedidaController@update');
Route::post('unidMedida/activar/{id}','parametrosUnidMedidaController@activar');
Route::post('unidMedida/desactivar/{id}','parametrosUnidMedidaController@desactivar');
Route::post('unidMedida/borrar/{id}','parametrosUnidMedidaController@destroy');
//permiso productos almacen
Route::get('prodPermAlm','prodPermitidosAlmController@index');
Route::get('prodPermAlm/{alm}','prodPermitidosAlmController@show');
Route::post('prodPermAlm','prodPermitidosAlmController@store');
Route::post('prodPermAlm/{id}','prodPermitidosAlmController@update');
Route::post('prodPermAlm/borrar/{id}','prodPermitidosAlmController@destroy');
//solicitudes de transferencias
Route::get('solTransf','solicitud_transfer@index');
Route::post('solTransf/pendientes','solicitud_transfer@indexPendientes');
Route::get('solTransf/detalle/{codigo}','solicitud_transfer@getSolicitud');
Route::post('solTransf','solicitud_transfer@store');
Route::get('solTransf/{id}','solicitud_transfer@show');
Route::post('solTransf/{id}','solicitud_transfer@update');
Route::get('solTransf/cant/sol','solicitud_transfer@cant');
Route::get('solTransf/borrar/{id}','solicitud_transfer@destroy');
Route::get('solTransf/transferido/{id}','solicitud_transfer@transferido');
//transferencias
Route::get('transferencias','historial_transferencias_controller@index');
Route::get('transferencias/pendientes','historial_transferencias_controller@indexPendientes');
Route::get('transferencias/aceptados','historial_transferencias_controller@indexAceptadas');
Route::get('transferencias/rechazados','historial_transferencias_controller@indexRechazadas');
Route::post('transferencias','historial_transferencias_controller@store');
Route::get('transferencias/{id}','historial_transferencias_controller@show');
Route::get('transferencias/{codTranf}','historial_transferencias_controller@showCodTransf');
Route::post('transferencias/{id}','historial_transferencias_controller@update');
Route::post('transferencias/codtrans/{codTranf}','historial_transferencias_controller@updateCodTransferencia');
Route::get('transferencias/cant/transferencias','historial_transferencias_controller@cant');
Route::get('transferencias/aceptar/{codTranf}','historial_transferencias_controller@aceptarTransferencia');
Route::get('transferencias/rechazar/{codTranf}','historial_transferencias_controller@rechazarTransferencia');

//historial kardex
Route::get('historial','historialController@index');
Route::post('historial/gethistorial','historialController@getCodProdAlm');
Route::post('historial','historialController@store');