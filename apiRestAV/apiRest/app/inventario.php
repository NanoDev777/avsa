<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class inventario extends Model
{
    protected $table = 'inventarios';
    protected $hidden = ['fecIngreso'];
    protected $fillable = ['idCodigo','codAlm', 'codProd','codigo','cantidad','costoUnitario'
		,'costo','prorrateo','lote','loteVenta','factura'
		,'idProv','fecIngreso','fecVencimiento','aprovConta','aprovCalidad','estado'];
}
