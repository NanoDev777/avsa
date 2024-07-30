<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class almacen extends Model
{
    protected $table = 'almacenes';
    protected $fillable = ['codAlm',
'name',
'ubicAlmacen',
'telf',
'activo',
'fechaRegistro',
'usrRegistro',
'ProdPermitidos'];
    protected $hidden = ['created_at','updated_at'];
}
