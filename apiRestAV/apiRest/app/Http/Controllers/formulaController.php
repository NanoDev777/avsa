<?php

namespace App\Http\Controllers;

use App\formula;
use Illuminate\Http\Request;

class formulaController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return formula::leftjoin('clientes','clientes.id','=','formulas.cliente')
        ->leftjoin('productos','productos.codigo','=','formulas.codProdRes')
        ->leftjoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')
        ->select('formulas.*', 'clientes.razonSocial', 'parametros_unid_medidas.titulo as unidadMedida')
        ->where('formulas.estado','=','1')
        ->get();
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
        $cf = formula::create([
            'titulo' => $request['titulo'],
            'codProdRes' => $request['codProdRes'],
            'cantidad' => $request['cantidad'],
            'instruccion' => $request['instruccion'],
            'lineaProduccion' => $request['lineaProduccion'],
            'version' => $request['version'],
            'cliente' => $request['cliente'],
            'estado' => $request['estado'],
            'usrReg' => $request['usrReg'],
        ]);
        return response()->json($cf,201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        return formula::where("formulas.id","=",$id)->
        leftjoin('productos','productos.codigo','=','formulas.codProdRes')->
        leftjoin('parametros_unid_medidas','parametros_unid_medidas.id','=','productos.unidadMedida')->
        leftjoin('parametros_linea_produccions','parametros_linea_produccions.id','=','formulas.lineaProduccion')->
        leftjoin('clientes','clientes.id','=','formulas.cliente')->
        select('formulas.id','formulas.codProdRes','formulas.titulo','parametros_unid_medidas.titulo as unidadMedida','parametros_linea_produccions.titulo as lineaProduccionTitulo','clientes.razonSocial as razonSocial')->
        first();
    }
    public function showCodProd($codProd)
    {
        return formula::where("codProdRes","=",$codProd)->get();
    }
    public function showLinProd($linProd)
    {
        return formula::where("lineaProduccion","=",$linProd)->get();
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
        $uf = formula::where('id','=',$id)->update([
            'titulo' => $request['titulo'],
            'codProdRes' => $request['codProdRes'],
            'cantidad' => $request['cantidad'],
            'instruccion' => $request['instruccion'],
            'lineaProduccion' => $request['lineaProduccion'],
            'version' => $request['version'],
            'cliente' => $request['cliente'],
            'estado' => $request['estado'],
            'usrReg' => $request['usrReg'],
        ]);
        return response()->json($uf,201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function activar($id)
    {
        $fd = ordenCompra::where('id','=',$id)->update(['estado'=>1]);
        return response()->json($fd,201);
    }
    public function desactivar($id)
    {
        $fd = ordenCompra::where('id','=',$id)->update(['estado'=>0]);
        return response()->json($fd,201);
    }
}
