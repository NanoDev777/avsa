<?php

namespace App\Http\Controllers;

use App\parametrosLineaProduccion;
use Illuminate\Http\Request;

class parametrosLineaProduccionController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return parametrosLineaProduccion::all();
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
        $plp = parametrosLineaProduccion::create([
            'titulo'=>$request['titulo'],
            'estado'=>$request['estado']
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        return parametrosLineaProduccion::where('id','=',$id)->get();
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
        $uplp = parametrosLineaProduccion::where('id','=',$id)->update([
            'titulo'=>$request['titulo'],
            'estado'=>$request['estado']
        ]);
    }

    public function activar($id)
    {
        $uplp = parametrosLineaProduccion::where('id','=',$id)->update([
            'estado'=>1
        ]);
        return response()->json($fd,201);
    }
    public function desactivar($id)
    {
        $uplp = parametrosLineaProduccion::where('id','=',$id)->update([
            'estado'=>2
        ]);
        return response()->json($fd,201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy(Request $request, $id)
    {
        $uplp = parametrosLineaProduccion::where('id','=',$id)->update([
            'estado'=>3
        ]);
        return response()->json($fd,201);
    }
}
