<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class user extends Model
{
    protected $table = 'users';
    protected $fillable = [
    	'nombres',
		'apPaterno',
		'apMaterno',
		'carnetIdentidad',
		'email',
		'usuario',
		'cargo',
		'ultimoAcceso',
		'fCreacion',
		'fActualizacion',
		'almacenes'
    ];
}
