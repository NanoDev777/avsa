<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class itemsOrdenCompra extends Model
{
    protected $table = 'items_orden_compras';
    protected $hidden = ['fecReg'];
    protected $fillable = ['ordenCompraId', 'codProd','cantidad','costoTotal','proveedor'];
}
