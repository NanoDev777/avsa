<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class prodPermitidosAlm extends Model
{
    protected $table = 'prod_permitidos_alms';
    protected $hidden = ['created_at','updated_at'];
    protected $fillable = ['codAlm',
							'indexProd'];
}
