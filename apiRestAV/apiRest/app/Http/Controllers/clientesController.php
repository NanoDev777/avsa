<?php

namespace App\Http\Controllers;

use App\clientes;
use Illuminate\Http\Request;

class clientesController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return clientes::all();
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
        $o = clientes::create([
            'tipo' => $request['tipo'],
            'razonSocial' => $request['razonSocial'],
            'nit' => $request['nit'],
            'contacto' => $request['contacto'],
            'telf' => $request['telf'],
            'email' => $request['email'],
            'pais' => $request['pais'],
            'codigo' => $request['codigo'],
            'estado' => $request['estado']
        ]);
        return response()->json($o,201);
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
        $o = clientes::where('id','=',$id)->update([
            'tipo' => $request['tipo'],
            'razonSocial' => $request['razonSocial'],
            'nit' => $request['nit'],
            'contacto' => $request['contacto'],
            'telf' => $request['telf'],
            'email' => $request['email'],
            'pais' => $request['pais'],
            'codigo' => $request['codigo'],
            'estado' => $request['estado']
        ]);
        return response()->json($o,201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function activar($id)
    {
        $o = clientes::where('id','=',$id)->update(['estado'=>1]);
        return response()->json($o,201);
    }
    public function desactivar($id)
    {
        $o = clientes::where('id','=',$id)->update(['estado'=>2]);
        return response()->json($o,201);
    }
    public function destroy($id)
    {
        $o = clientes::where('id','=',$id)->update(['estado'=>3]);
        return response()->json($o,201);
    }
}
