<?php

namespace App\Http\Controllers;

use App\ordenCompra;
use App\itemsOrdenCompra;
use Illuminate\Http\Request;

class ordenComprasController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return ordenCompra::All();
    }

    public function insertOrdenCompra(Request $request){
        $oc = ordenCompra::create([
            'codigo' => $request['codigo'],
            'codAlm' => $request['codAlm'],
            'usrReg' => $request['usrReg'],
            'fecIngreso' => $request['fecIngreso'],
            'estado' => $request['estado'],
            'fecReg' => $request['fecReg'],
        ]);
        foreach ($request->inventario as $value) {
            $inv = itemsOrdenCompra::create([
                'ordenCompraId' => $oc['id'],
                'codProd' => $value['codProd'],
                'cantidad' => $value['cantidad'],
                'costoTotal' => $value['costoTotal'],
                'proveedor' => $value['proveedor']
            ]);
        }
        return response()->json($oc['id'],201);
    }

    public function pendient($estado){
        return ordenCompra::where('estado','=',$estado)->get();
    }


    public function terminarOrden($id){
        $ce = ordenCompra::where('id','=',$id)->update(['estado'=>1]);
        return response()->json($ce,201);
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
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        return clientes::where('id','=',$id)->get();
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
