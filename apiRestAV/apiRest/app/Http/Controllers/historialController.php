<?php

namespace App\Http\Controllers;
use App\inventario;
use App\historial;
use Illuminate\Http\Request;

class historialController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return historial::orderby('created_at','asc')->get();
    }

    public function getCodProdAlm(Request $request)
    {
        $his = historial::where('codAlm','=',$request['codAlm'])->
        where('codProd','=',$request['codProd'])->
        whereBetween('creado_en',[$request['fechaIni'],$request['fechaFin']])->
        orderby('creado_en','asc')->orderby('id','asc')->get();
        if(empty($his)){
            return historial::where('codAlm','=',$request['codAlm'])->
            where('codProd','=',$request['codProd'])->
            where('accion','=','masivo')->
            get();
        }else{
            return $his;
        }
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
            $cant = inventario::where('codAlm','=',$value['codAlm'])->
            where('codProd','=',$value['codProd'])->
            sum('cantidad');
            $costo = inventario::where('codAlm','=',$value['codAlm'])->
            where('codProd','=',$value['codProd'])->
            sum('costo');

            historial::create([
                'idReg' => $value['idReg'],
                'codAlm' => $value['codAlm'],
                'codProd' => $value['codProd'],
                'cantidad' => $value['cantidad'],
                'costo' => $value['cantidad']*$value['costoUnitario'],
                'costoUnitario' => $value['costoUnitario'],
                'prorrateo' => $value['prorrateo'],
                'saldo' => $cant, //- $value['cantidad'],
                'saldoCosto' => $costo, //- $value['saldoCosto'],
                'lote' => $value['lote'],
                'usuario' => $value['usuario'],
                'accion' => $value['accion'],
                'creado_en'=> $value['creado_en'],
            ]);
        }
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
