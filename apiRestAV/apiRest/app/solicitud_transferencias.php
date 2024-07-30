<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class solicitud_transferencias extends Model
{
    protected $table = 'solicitud_transferencias';
    protected $fillable = [
    	'codTransferencia',
		'almDestino',
		'codProd',
		'cantidad',
		'usrReg',
		'fechaReg',
		'estado'
    ];
    protected $hidden = ['created_at','updated_at'];
}
