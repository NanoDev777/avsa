<?php

namespace App\Http\Controllers;

use App\solicitud_transferencias;
use Illuminate\Http\Request;

class solicitud_transfer extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return solicitud_transferencias::all();
    }

    public function indexPendientes(Request $request)
    {
        return solicitud_transferencias::where('estado','=',0)->
        whereIn('almDestino',$request['data'])->
        select('solicitud_transferencias.codTransferencia','solicitud_transferencias.almDestino','solicitud_transferencias.fechaReg')->orderby('almDestino','asc')->
        groupby('codTransferencia','almDestino','fechaReg')->
        get();
    }

    public function getSolicitud($codigo)
    {
        return solicitud_transferencias::where('codTransferencia','=',$codigo)->
        leftJoin('productos','productos.codigo','=','solicitud_transferencias.codProd')->
        select('solicitud_transferencias.*','productos.nombre')->
        orderby('codProd')->
        get();
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        foreach ($request->data as $value) {
            $inv = solicitud_transferencias::create([
            'codTransferencia' => $value['codTransferencia'],
            'almDestino' => $value['almDestino'],
            'codProd' => $value['codProd'],
            'cantidad' => $value['cantidad'],
            'usrReg' => $value['usrReg'],
            'fechaReg' => $value['fechaReg'],
            'estado' => 0,

            ]);
        }
        return response()->json($request,201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        return solicitud_transferencias::where('id','=',$id)->get();
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {

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
        $update = solicitud_transferencias::update([
            'estado' => 1
        ])->where('id','=',$id);
    }

    public function transferido($codTransf)
    {
        solicitud_transferencias::where('codTransferencia','=',$codTransf)->
        update([
            'estado' => 1
        ]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $update = solicitud_transferencias::update([
            'estado' => 2,
        ])->where('id','=',$id);
    }


    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function cant()
    {
        return solicitud_transferencias::get()->groupby("codTransferencia")->count();
    }
}
