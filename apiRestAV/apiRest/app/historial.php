<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class historial extends Model
{
    protected $table = 'historials';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = [
    	'idReg',
		'codAlm',
		'codProd',
		'cantidad',
		'costo',
		'costoUnitario',
		'prorrateo',
		'saldo',
		'saldoCosto',
		'lote',
		'usuario',
		'accion',
		'creado_en'
    ];
}
