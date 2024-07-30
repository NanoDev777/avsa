<?php

namespace App\Http\Controllers;

use App\historial_transferencias;
use App\inventario;
use Illuminate\Http\Request;

class historial_transferencias_controller extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return historial_transferencias::all();
    }

    public function indexPendientes()
    {
        return historial_transferencias::where('estado','=','0')->get();
    }
    public function indexAceptadas()
    {
        return historial_transferencias::where('estado','=','1')->get();
    }
    public function indexRechazadas()
    {
        return historial_transferencias::where('estado','=','2')->get();
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
            $c = historial_transferencias::create([
                'codTransferencia' => $value['codTransferencia'],
                'almOrigen' => $value['almOrigen'],
                'almDestino' => $value['almDestino'],
                'loteTransferido' => $value['loteTransferido'],
                'codProd' => $value['codProd'],
                'cantidad' => $value['cantidad'],
                'fechaTransferencia' => $value['fechaTransferencia'],
                'usrTransferencia' => $value['usrTransferencia'],
                'idLote' => $value['idLote'],
                'estado' => 0
            ]);
        }
        
        return response()->json($c,201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        return historial_transferencias::where('id','=',$id);
    }

    public function showCodTransf($codTranf)
    {
        return historial_transferencias::where('codTransferencia','=',$codTranf);
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
        $c = registroProcProd::where('id','=',$id)->
        update([
            'almOrigen' => $request['almOrigen'],
            'almDestino' => $request['almDestino'],
            'loteTransferido' => $request['loteTransferido'],
            'codProd' => $request['codProd'],
            'cantidad' => $request['cantidad'],
            'fechaTransferencia' => $request['fechaTransferencia'],
            'usrTransferencia' => $request['usrTransferencia'],
            'fechaAceptacion' => $request['fechaAceptacion'],
            'usrAceptacion' => $request['usrAceptacion'],
            'idLote' => $request['idLote'],
            'estado' => 0
        ]);
        return response()->json($c,201);
    }

    public function updateCodTransferencia(Request $request, $codTranf)
    {
        $c = registroProcProd::where('codTransferencia','=',$codTranf)->
        update([
            'almOrigen' => $request['almOrigen'],
            'almDestino' => $request['almDestino'],
            'loteTransferido' => $request['loteTransferido'],
            'codProd' => $request['codProd'],
            'cantidad' => $request['cantidad'],
            'fechaTransferencia' => $request['fechaTransferencia'],
            'usrTransferencia' => $request['usrTransferencia'],
            'fechaAceptacion' => $request['fechaAceptacion'],
            'usrAceptacion' => $request['usrAceptacion'],
            'idLote' => $request['idLote'],
            'estado' => 0
        ]);
        return response()->json($c,201);
    }

    public function aceptarTransferencia($codTranf)
    {
        $c = registroProcProd::where('codTransferencia','=',$codTranf)->
        create([
            'fechaAceptacion' => $request['fechaAceptacion'],
            'usrAceptacion' => $request['usrAceptacion'],
            'estado' => 1
        ]);
        return response()->json($c,201);
    }
    public function rechazarTransferencia($codTranf)
    {
        $c = registroProcProd::where('codTransferencia','=',$codTranf)->
        create([
            'fechaAceptacion' => $request['fechaAceptacion'],
            'usrAceptacion' => $request['usrAceptacion'],
            'estado' => 2
        ]);
        return response()->json($c,201);
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

    public function cant()
    {
        return historial_transferencias::get()->groupby("codTransferencia")->count();
    }
}
