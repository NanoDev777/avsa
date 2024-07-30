<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ingredientesFormulas extends Model
{
    protected $table = 'ingredientes_formulas';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = ['idFormula',
							'orden',
							'tipo',
							'codProd',
							'cantProd',
							'comentarios',
							'costoAdicional',
							'usrReg',
							'estado'
						];
}
