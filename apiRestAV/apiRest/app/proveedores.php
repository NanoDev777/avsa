<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class proveedores extends Model
{
    protected $table = 'proveedores';
    protected $hidden = ['fecRegistro','created_at','updated_at'];
}
