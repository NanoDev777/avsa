<?php

namespace App\Http\Controllers;

use App\productos;
use Illuminate\Http\Request;

class productosController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return productos::orderBy('codigo','asc')->get();
    }

    public function getProdCodProd($codProd)
    {
        return productos::where('codigo','=',$codProd)->get();
    }

    public function permitidosAlmacen(Request $request){  
        $tb = productos::where('indiceProd', '=', 0)->
            leftJoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->select('productos.*', 'parametros_unid_medidas.titulo');
        foreach ($request->indices as $value) {
            $tb = productos::where('indiceProd', '=', $value)->
            leftJoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->select('productos.*', 'parametros_unid_medidas.titulo')
            ->union($tb);
        }
        $tb = productos::where('indiceProd', '=', 0)->
            leftJoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->select('productos.*', 'parametros_unid_medidas.titulo')
            ->union($tb)
            ->orderBy('codigo', 'asc')->get();

        return response()->json($tb,200);
        /*return productos::where('indiceProd','=',$indice)
            ->orderby('codigo','asc')
            ->get();*/
    }

    public function getUnidadMedida($codProd){
        $c = productos::where('codigo','=',$codProd)
            ->get();
        return response()->json($c[0]['unidadMedida'],200);
    }
    public function getNameUnidadMedida($unidad){
        $c = parametrosUnidMedida::where('id','=',$unidad)
            ->get();
        return response()->json($c[0]['titulo'],200);
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
