<?php

namespace App\Http\Controllers;

use App\almacen;
use App\prod_permitidos_alms;
use Illuminate\Http\Request;

class almacenesController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index(Request $request)
    {
        //return response()->json($request['data'],201);
        $a1 = almacen::whereIn('codAlm',$request['data'])->orderby('codAlm','asc')->
        get();

        return response()->json($a1,201);
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
        $cf = almacen::create([
            'codAlm' => $request['codAlm'],
            'name' => $request['name'],
            'ubicAlmacen' => $request['ubicAlmacen'],
            'telf' => $request['telf'],
            'activo' => $request['activo'],
            'fechaRegistro' => $request['fechaRegistro'],
            'usrRegistro' => $request['usrRegistro'],
            'ProdPermitidos' => $request['ProdPermitidos'],
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
        return almacen::where("id","=",$id)->get();
    }
    public function showCodProd($codAlm)
    {
        return almacen::where("codProdRes","=",$codAlm)->get();
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
        $uf = almacen::where('id','=',$id)->update([
            'codAlm' => $request['codAlm'],
            'name' => $request['name'],
            'ubicAlmacen' => $request['ubicAlmacen'],
            'telf' => $request['telf'],
            'activo' => $request['activo'],
            'fechaRegistro' => $request['fechaRegistro'],
            'usrRegistro' => $request['usrRegistro'],
            'ProdPermitidos' => $request['ProdPermitidos']
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
        $fd = almacen::where('id','=',$id)->update(['activo'=>1]);
        return response()->json($fd,201);
    }
    public function desactivar($id)
    {
        $fd = almacen::where('id','=',$id)->update(['activo'=>2]);
        return response()->json($fd,201);
    }
    public function destroy($id)
    {
        $fd = almacen::where('id','=',$id)->update(['activo'=>3]);
        return response()->json($fd,201);
    }
}



/*Users::with(['city'])->select(['name', 'age', 'city_id'])
                     ->where('age', '!=', 18)
                     ->where('name', 'like', 'se%')
                     ->orderBy('age', 'asc')
                     ->take(2)*/

                     //https://stackify.com/laravel-eloquent-tutorial/