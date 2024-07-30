<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class formula extends Model
{
    protected $table = 'formulas';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = [	'titulo',
							'codProdRes',
							'cantidad',
							'instruccion',
							'lineaProduccion',
							'version',
							'cliente',
							'estado',
							'usrReg'
		];
}
