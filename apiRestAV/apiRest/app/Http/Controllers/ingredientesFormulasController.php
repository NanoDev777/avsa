<?php

namespace App\Http\Controllers;

use App\ingredientesFormulas;
use App\registroProcProd;
use Illuminate\Http\Request;

class ingredientesFormulasController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return ingredientesFormulas::all();
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
        $if = formula::create([
            'idFormula' => $request['idFormula'],
            'orden' => $request['orden'],
            'tipo' => $request['tipo'],
            'codProd' => $request['codProd'],
            'cantProd' => $request['cantProd'],
            'comentarios' => $request['comentarios'],
            'costoAdicional' => $request['costoAdicional'],
            'usrReg' => $request['usrReg'],
            'estado' => $request['estado'],
        ]);
        return response()->json($if,201);
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id, $idProcProd)
    {
        return ingredientesFormulas::where('ingredientes_formulas.guidForm','=',$id)->
        leftjoin('productos','productos.codigo','=','ingredientes_formulas.codProd')->
        leftjoin('parametros_unid_medidas','productos.unidadMedida','=','parametros_unid_medidas.id')->
        leftjoin('registro_proc_prods','registro_proc_prods.id','=',$idProcProd)->
        /*leftjoin('inventarios',function($join){
            $join->on('inventarios.codProd','=','ingredientes_formulas.codProd')->
            where('inventarios.codAlm','=','registro_proc_prods.codAlmProd');
        })->*/
        select('ingredientes_formulas.*','productos.nombre','parametros_unid_medidas.titulo'/*,'inventarios.prorrateo'*/)->
        get();
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
        $ui = ingredientesFormulas::where('idFormula','=',$id)->update([
            'idFormula' => $request['idFormula'],
            'orden' => $request['orden'],
            'tipo' => $request['tipo'],
            'codProd' => $request['codProd'],
            'cantProd' => $request['cantProd'],
            'comentarios' => $request['comentarios'],
            'costoAdicional' => $request['costoAdicional'],
            'usrReg' => $request['usrReg'],
            'estado' => $request['estado'],
        ]);
        return response()->json($ui,201);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        $o = ingredientesFormulas::where('id','=',$id)->delete();
    }
}
