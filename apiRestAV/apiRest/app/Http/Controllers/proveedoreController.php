<?php

namespace App\Http\Controllers;

use App\proveedores;
use Illuminate\Http\Request;

class proveedoreController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return proveedores::all();
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
        $o = proveedores::create([
            'nombre' => $request['nombre'],
            'direccion' => $request['direccion'],
            'telefono' => $request['telefono'],
            'celular' => $request['celular'],
            'notas' => $request['notas'],
            'estado' => $request['estado'],
            'usrRegistro' => $request['usrRegistro'],
            'fecRegistro' => $request['fecRegistro'],
            'contacto' => $request['contacto']
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
        return proveedores::where('id','=',$id)->get();
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
        $o = proveedores::where('id','=',$id)->update([
            'nombre' => $request['nombre'],
            'direccion' => $request['direccion'],
            'telefono' => $request['telefono'],
            'celular' => $request['celular'],
            'notas' => $request['notas'],
            'estado' => $request['estado'],
            'usrRegistro' => $request['usrRegistro'],
            'fecRegistro' => $request['fecRegistro'],
            'contacto' => $request['contacto']
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
        $o = proveedores::where('id','=',$id)->update(['estado'=>1]);
        return response()->json($o,201);
    }
    public function desactivar($id)
    {
        $o = proveedores::where('id','=',$id)->update(['estado'=>2]);
        return response()->json($o,201);
    }
    public function destroy($id)
    {
        $o = proveedores::where('id','=',$id)->update(['estado'=>3]);
        return response()->json($o,201);
    }
}
