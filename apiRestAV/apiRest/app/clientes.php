<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class clientes extends Model
{
    protected $table = 'clientes';
    protected $fillable = [
    	'tipo',
		'razonSocial',
		'nit',
		'contacto',
		'telf',
		'email',
		'pais',
		'codigo',
		'estado'
    ];
}
