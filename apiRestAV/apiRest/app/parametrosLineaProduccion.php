<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class parametrosLineaProduccion extends Model
{
    protected $table = 'parametros_linea_produccions';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = ['titulo',
							'estado'];
}
