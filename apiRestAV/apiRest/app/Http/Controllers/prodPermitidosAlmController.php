<?php

namespace App\Http\Controllers;

use App\prodPermitidosAlm;
use Illuminate\Http\Request;

class prodPermitidosAlmController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return prodPermitidosAlm::get();
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
        return prodPermitidosAlm::create([
            'codAlm' => $request['codAlm'],
            'indexProd' => $request['indexProd']
        ])->get();
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($alm)
    {
        return prodPermitidosAlm::where('codAlm','=',$alm)->get();
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
        return prodPermitidosAlm::where('codAlm','=',$alm)->update([
            'codAlm' => $request['codAlm'],
            'indexProd' => $request['indexProd']
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
        return prodPermitidosAlm::where('id','=',$id)->delete();
    }
}
