<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class registroProcProd extends Model
{
    protected $table = 'registro_proc_prods';
    protected $fillable = [
    	'idFormula',
		'idCliente',
		'idLinProd',
		'codAlmProd',
		'codAlmDest',
		'loteProd',
		'loteVenta',
		'unidad',
		'cantidad',
		'costoReal',
		'costoReceta',
		'variacion',
		'obs',
		'usrReg',
		'aprob',
		'estado',
		'fecInicio',
		'fecFin',
		'fecVenc',
		'fecCulminacion',
		'estadoTransferenciaSolicitada'
    ];
}
