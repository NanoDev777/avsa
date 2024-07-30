<?php

namespace App\Http\Controllers;

use App\reservaProcProd;
use App\registroProcProd;
use App\inventario;
use App\ingredientesFormulas;
use App\productos;
use App\historial;
use App\Http\Controllers\inventarioController;
use Illuminate\Http\Request;

class registroProcProdController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return registroProcProd::all();
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    public function getVariacionPendiente()
    {
        return registroProcProd::where('registro_proc_prods.estado','=',1)->
        where('registro_proc_prods.aprob','=',0)->
        join('formulas','formulas.id','=','registro_proc_prods.idFormula')->
        join('productos','formulas.codProdRes','=','productos.codigo')->
        join('parametros_linea_produccions','formulas.lineaProduccion','=','parametros_linea_produccions.id')->
        leftJoin('clientes','registro_proc_prods.idCliente','=','clientes.id')->
        select('registro_proc_prods.*','productos.nombre','parametros_linea_produccions.titulo',
            'clientes.razonSocial')->orderBy('created_at','asc')->get();
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $o = registroProcProd::create([
            'idFormula' => $request['idFormula'],
            'idCliente' => $request['idCliente'],
            'idLinProd' => $request['idLinProd'],
            'codAlmProd' => $request['codAlmProd'],
            'loteProd' => $request['loteProd'],
            'unidad' => $request['unidad'],
            'cantidad' => $request['cantidad'],
            'usrReg' => $request['usrReg'],
            'aprob' => $request['aprob'],
            'estado' => 0,
            'estadoTransferenciaSolicitada' => 0
        ]);
        return response()->json($o['id'],201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function getIngredientes($id)
    {
        return registroProcProd::where('registro_proc_prods.id','=',$id)->
                        leftJoin('formulas','formulas.id','=','registro_proc_prods.idFormula')->
                        leftJoin('ingredientes_formulas','ingredientes_formulas.guidForm','=','formulas.guidForm')->
                        leftJoin('productos','productos.codigo','=','ingredientes_formulas.codProd')->
                        leftJoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->
                        leftJoin('inventarios', function($join){
                            $join->on('inventarios.codAlm','=','registro_proc_prods.codAlmProd')
                            ->on('inventarios.codProd','=','ingredientes_formulas.codProd');
                        })->
                        select(
                            'ingredientes_formulas.id',
                            'ingredientes_formulas.orden',
                            'ingredientes_formulas.tipo',
                            'ingredientes_formulas.codProd',
                            'ingredientes_formulas.cantProd',
                            'ingredientes_formulas.comentarios',
                            'ingredientes_formulas.costoAdicional',
                            'ingredientes_formulas.usrReg',
                            'ingredientes_formulas.estado',
                            'productos.nombre',
                            'parametros_unid_medidas.titulo',
                            'inventarios.prorrateo')->
                        groupBy(
                            'ingredientes_formulas.id',
                            'ingredientes_formulas.orden',
                            'ingredientes_formulas.tipo',
                            'ingredientes_formulas.codProd',
                            'ingredientes_formulas.cantProd',
                            'ingredientes_formulas.comentarios',
                            'ingredientes_formulas.costoAdicional',
                            'ingredientes_formulas.usrReg',
                            'ingredientes_formulas.estado',
                            'productos.nombre',
                            'parametros_unid_medidas.titulo',
                            'inventarios.prorrateo')->
                        orderBy('orden','asc')->
                        get();

    }

    public function show($id)
    {
        return registroProcProd::where('id','=',$id)->get();
    }

    public function showPendientes(Request $request)
    {
        return registroProcProd::where('registro_proc_prods.estado','=',0)->
        where('registro_proc_prods.aprob','=',0)->
        whereIn('codAlmProd',$request['data'])->
        join('formulas','formulas.id','=','registro_proc_prods.idFormula')->
        join('productos','formulas.codProdRes','=','productos.codigo')->
        join('parametros_linea_produccions','formulas.lineaProduccion','=','parametros_linea_produccions.id')->
        leftJoin('clientes','registro_proc_prods.idCliente','=','clientes.id')->
        select('registro_proc_prods.*','productos.nombre','parametros_linea_produccions.titulo',
            'clientes.razonSocial')->orderBy('created_at','asc')->get();
    }

    public function showPendientesSolicitud()
    {
        return registroProcProd::where('registro_proc_prods.estado','=',0)->
        where('registro_proc_prods.aprob','=',0)->
        where('estadoTransferenciaSolicitada','=',0)->
        join('formulas','formulas.id','=','registro_proc_prods.idFormula')->
        join('productos','formulas.codProdRes','=','productos.codigo')->
        join('parametros_linea_produccions','formulas.lineaProduccion','=','parametros_linea_produccions.id')->
        leftJoin('clientes','registro_proc_prods.idCliente','=','clientes.id')->
        select('registro_proc_prods.*','productos.nombre','parametros_linea_produccions.titulo',
            'clientes.razonSocial')->get();
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        $o = registroProcProd::where('id','=',$id)->update([
            'codAlmDest' => $request['codAlmDest'],
            'loteVenta' => $request['loteVenta'],
            'costoReal' => $request['costoReal'],
            'costoReceta' => $request['costoReceta'],
            'variacion' => $request['variacion'],
            'obs' => $request['obs'],
            'estado' => $request['estado'],
            'aprob' => $request['aprob'],
            'fecInicio' => $request['fecInicio'],
            'fecFin' => $request['fecFin'],
            'fecVenc' => $request['fecVenc'],
            'fecCulminacion' => $request['fecCulminacion'],
            'estadoTransferenciaSolicitada' => 0
        ]);
        foreach ($request->reservas as $value) {
            $inv = reservaProcProd::create([
                'idProcProd'=>$value['idProcProd'],
                'tipo'=>$value['tipo'],
                'codProd'=>$value['codProd'],
                'lote'=>$value['lote'],
                'loteVenta'=>$value['loteVenta'],
                'cantidadReceta'=>$value['cantidadReceta'],
                'cantidad'=>$value['cantidad'],
                'costoUnit'=>$value['costoUnit'],
                'estado'=>$value['estado'],
                'idInventario'=>$value['idInventario']
            ]);

            if($request['aprob']==1 && $value['tipo']==1){
                $cantidad = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$request['codAlmDest'])->where('cantidad','>',0)->sum('cantidad');
                $costo = inventario::where('codProd','=',$value['codProd'])
                    ->where('codAlm','=',$request['codAlmDest'])->where('cantidad','>',0)->
                    //sum('costo');
                    selectRaw("sum(inventarios.cantidad*inventarios.prorrateo) as costo")->first();
            //return response()->json($costo,201);

                $prorrateo = (((int)$costo['costo'])+($value['cantidad']*$value['costoUnit']))/($cantidad+$value['cantidad']);
                $ingreso = inventario::create([
                    'idCodigo' => '',
                    'codAlm' => $request['codAlmDest'],
                    'codProd' => $value['codProd'],
                    'codigo' => 'pp',
                    'cantidad' => $value['cantidad'],
                    'costoUnitario' => $value['costoUnit'],
                    'costo' => $value['cantidad']*$value['costoUnit'],
                    'prorrateo' => 0,
                    'lote' => $value['lote'],
                    'loteVenta' => $request['loteVenta'],
                    'factura' => '',
                    'idProv' => 0,
                    'fecIngreso' => $request['fecCulminacion'],
                    'fecVencimiento' => $request['fecVenc'],
                    'aprovConta'=>1,
                    'aprovCalidad'=>1,
                    'estado' => 0
                ]);

                inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$request['codAlmDest'])->update([
                    'prorrateo'=>$prorrateo
                ]);
                inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->update([
                    'costo'=> inventario::raw('cantidad*prorrateo')
                ]);

                $saldo = $cantidad + $value['cantidad'];
                $saldoCosto = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$request['codAlmDest'])->where('cantidad','>',0)->
                sum('costo');
            
                /*historial::create([
                    'idReg' => 'IPP-'.$ingreso['lote'],
                    'codAlm' => $ingreso['codAlm'],
                    'codProd' => $ingreso['codProd'],
                    'cantidad' => $ingreso['cantidad'],
                    'costo' => $ingreso['costo'],
                    'costoUnitario' => $ingreso['costoUnitario'],
                    'prorrateo' => $prorrateo,
                    'saldo' => $saldo,
                    'saldoCosto' => $saldoCosto,
                    'lote' => $ingreso['lote'],
                    'usuario' => $request['usrReg'],
                    'accion' => 'ingreso',
                    'creado_en' => $request['fecHistorial']
                ]);*/
            }
            /*if($value['idInventario'] != null){
                $cant = inventario::where('id','=',$value['idInventario'])->select('inventarios.cantidad')->first();
                $tot = $cant['cantidad'] - floatval($value['cantidad']);
                inventario::where('id','=',$value['idInventario'])
                ->update(['cantidad'=> $tot]);
            }*/
        }
        return response()->json($o,201);
    }
    public function aprobar($id)
    {
        $o = registroProcProd::where('id','=',$id)->update(['aprob'=>1]);
        return response()->json($o,201);
    }
    public function rechazar($id)
    {
        $o = registroProcProd::where('id','=',$id)->update(['aprob'=>2]);
        return response()->json($o,201);
    }
    public function borrar($id)
    {
        $o = registroProcProd::where('id','=',$id)->update(['estado'=>3]);
        return response()->json($o,201);
    }
    public function transferenciaSolicitada($id)
    {
        $o = registroProcProd::where('id','=',$id)->update(['estadoTransferenciaSolicitada'=>1]);
        return response()->json($o,201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $o = registroProcProd::where('id','=',$id)->update(['aprob'=>4]);
        return response()->json($o,201);
    }
}
