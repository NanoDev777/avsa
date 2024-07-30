<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class reservaProcProd extends Model
{
	protected $table ='reserva_proc_prods';
    protected $fillable=[
    	'idProcProd',
		'tipo',
		'codProd',
		'lote',
		'loteVenta',
		'cantidadReceta',
		'cantidad',
		'costoUnit',
		'estado',
		'idInventario'
    ];
}
