<?php

namespace App\Http\Controllers;

use App\inventario;
use App\historial;
use Illuminate\Http\Request;

class inventarioController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return inventario::all();
    }

    public function getInventariosByAlmacen($codAlm){
        return inventario::where('codAlm','=',$codAlm)->
        where('cantidad','>',0)->
        leftjoin('productos','productos.codigo','=','inventarios.codProd')->
        leftjoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->
        selectRaw('inventarios.id,inventarios.codAlm,inventarios.codProd,productos.nombre,inventarios.cantidad, inventarios.prorrateo, parametros_unid_medidas.titulo as unidadMedida, inventarios.lote,inventarios.loteVenta')->
        orderby('codProd','asc')->
        get();
        /*$i = inventario::where('codAlm','=',$codAlm)
        ->where('cantidad','>',0)
        ->groupby('inventarios.codAlm','inventarios.codProd',
            'productos.nombre','parametros_unid_medidas.titulo', 'inventarios.prorrateo')
        ->leftjoin('productos','productos.codigo','=','inventarios.codProd')
        ->leftjoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')
        ->selectRaw('inventarios.codAlm,inventarios.codProd,productos.nombre,sum(inventarios.cantidad) as cantidad, inventarios.prorrateo, parametros_unid_medidas.titulo as unidadMedida')
        ->get();

        foreach ($i as $key => $value) {
            $inv = inventario::where('codAlm','=',$value['codAlm'])->
            where('codProd','=',$value['codProd'])->
            get();
        }

        return response()->json($i,201);*/
    }

    public function getCantidadExistente($codAlm, $codProd){
        return inventario::where('codAlm','=',$codAlm)->
        where('codProd','=',$codProd)->sum('cantidad');
    }

    public function discountInventory(Request $request){
        foreach ($request -> data as $value) {
            inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->update([
                    'costo'=> inventario::raw('cantidad*prorrateo')
                ]);
            $cant = inventario::where('id','=',$value['id'])->sum('cantidad');
            $prorrateo = inventario::where('id','=',$value['id'])->sum('prorrateo');
            $newCant = $cant-$value['cantidad'];
            $newCosto = $newCant*$prorrateo;
            $o = inventario::where('id','=',$value['id'])->update([
                'cantidad' => $newCant,
                'costo' => $newCosto
            ]);
        }
        
        return response()->json(['msj'=>'Descuento Correcto.'],201);
    }

    public function returnInventory(Request $request){
        foreach ($request -> data as $value) {
            $cant = inventario::where('id','=',$value['id'])->sum('cantidad');
            $prorrateo = inventario::where('id','=',$value['id'])->sum('prorrateo');

            $cantidad = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->where('cantidad','>',0)->sum('cantidad');
            $costo = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->where('cantidad','>',0)->
                //sum('costo');
                selectRaw("sum(inventarios.cantidad*inventarios.prorrateo) as costo")->first();
        //return response()->json($costo,201);
            $newCant = $cant+$value['cantidad'];
            $newCosto = $newCant*$prorrateo;

            $prorrateo = (((int)$costo['costo'])+$value['costo'])/($cantidad+$value['cantidad']);
            $ingreso = inventario::where('id','=',$value['id'])->update([
                'cantidad'=>$newCant,
                'costo'=>$value['costo']
            ]);

            inventario::where('codProd','=',$value['codProd'])
            ->where('codAlm','=',$value['codAlm'])->update([
                'prorrateo'=>$prorrateo
            ]);
        }
        
        return response()->json(['msj'=>'Orden Procesada Correctamente.'],201);
    }

    public function getCantidadTotal($codAlm, $codProd){
        return inventario::where('codAlm','=',$codAlm)->
        where('codProd','=',$codProd)->sum('cantidad');
    }
    public function getCostoTotal($codAlm, $codProd){
        return inventario::where('codAlm','=',$codAlm)->
        where('codProd','=',$codProd)->sum('costo');
    }

    public function getInventariosByAlmacenAndCodProd($codAlm,$codProd){
        return inventario::where('codAlm','=',$codAlm)
        ->where('codProd','=',$codProd)
        ->where('cantidad','>',0)
        ->leftjoin('productos','productos.codigo','=','inventarios.codProd')
        ->leftjoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')
        ->get();
    }

    public function getInventariosProrrateo($codAlm, $codProd){
        return inventario::
        where('inventarios.codAlm','=',$codAlm)->
        where('inventarios.codProd','=',$codProd)->
        select('inventarios.prorrateo')->
        first();
    }
    public function getInventariosLotes($codAlm, $codProd){
        return inventario::where('codAlm','=',$codAlm)->
        where('codProd','=',$codProd)->
        where('cantidad','>',0)->
        select('inventarios.id','inventarios.lote','inventarios.cantidad','inventarios.prorrateo','inventarios.fecVencimiento')->
        get();
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

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        foreach ($request -> data as $value) {
            $cantidad = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->where('cantidad','>',0)->sum('cantidad');
            $costo = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->where('cantidad','>',0)->
                //sum('costo');
                selectRaw("sum(inventarios.cantidad*inventarios.prorrateo) as costo")->first();
        //return response()->json($costo,201);

            $prorrateo = (((int)$costo['costo'])+$value['costo'])/($cantidad+$value['cantidad']);
            $ingreso = inventario::create([
                'idCodigo' => $value['idCodigo'],
                'codAlm' => $value['codAlm'],
                'codProd' => $value['codProd'],
                'codigo' => $value['codigo'],
                'cantidad' => $value['cantidad'],
                'costoUnitario' => $value['costoUnitario'],
                'costo' => $value['costo'],
                'prorrateo' => $value['prorrateo'],
                'lote' => $value['lote'],
                'loteVenta' => $value['loteVenta'],
                'factura' => $value['factura'],
                'idProv' => $value['idProv'],
                'fecIngreso' => $value['fecIngreso'],
                'fecVencimiento' => $value['fecVencimiento'],
                'aprovConta'=>0,
                'aprovCalidad'=>0,
                'estado' => 0
            ]);

            inventario::where('codProd','=',$value['codProd'])
            ->where('codAlm','=',$value['codAlm'])->update([
                'prorrateo'=>$prorrateo
            ]);

            inventario::where('codProd','=',$value['codProd'])
            ->where('codAlm','=',$value['codAlm'])->update([
                'costo'=> inventario::raw('cantidad*prorrateo')
            ]);

            $saldo = $cantidad + $value['cantidad'];
            $saldoCosto = inventario::where('codProd','=',$value['codProd'])
                ->where('codAlm','=',$value['codAlm'])->where('cantidad','>',0)->
                sum('costo');
        
            historial::create([
                'idReg' => $ingreso['idCodigo'],
                'codAlm' => $ingreso['codAlm'],
                'codProd' => $ingreso['codProd'],
                'cantidad' => $ingreso['cantidad'],
                'costo' => $ingreso['costo'],
                'costoUnitario' => $ingreso['costoUnitario'],
                'prorrateo' => $prorrateo,
                'saldo' => $saldo,
                'saldoCosto' => $saldoCosto,
                'lote' => $ingreso['lote'],
                'usuario' => $value['usuario'],
                'accion' => 'ingreso',
                'creado_en' => $value['fechaIngresoSistema']
            ]);
        }
        
        return response()->json(['msj'=>'Ingreso Generado Correctamente.'],201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
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
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
