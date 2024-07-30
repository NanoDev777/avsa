<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ordenCompra extends Model
{
    protected $table = 'orden_compras';
    protected $hidden = ['fecReg'];
    protected $fillable = ['codigo', 'codAlm','usrReg','fecIngreso','fecReg','estado'];
}
