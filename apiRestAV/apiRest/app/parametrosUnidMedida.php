<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class parametrosUnidMedida extends Model
{
    protected $table = 'parametros_unid_medidas';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = ['titulo',
							'estado'];
}
