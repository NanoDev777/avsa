<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class registroIngresos extends Model
{
    protected $table = 'registro_ingresos';
    protected $hidden = ['fecRegistro','created_at','updated_at'];
    protected $fillable = ['codigo', 'aprobConta','aprobCalida','usuario','fecIngreso'];
}
