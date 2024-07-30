<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class historial_transferencias extends Model
{
    protected $table = 'historial_transferencias';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = [
    	'codTransferencia',
		'almOrigen',
		'almDestino',
		'loteTransferido',
		'codProd',
		'cantidad',
		'fechaTransferencia',
		'usrTransferencia',
		'fechaAceptacion',
		'usrAceptacion',
		'idLote',
		'estado'
    ];
}
