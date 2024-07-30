<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateItemsOrdenComprasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('items_orden_compras', function (Blueprint $table) {
            $table->id();
            $table->integer('ordenCompraId');
            $table->text('codProd');
            $table->decimal('cantidad');
            $table->decimal('costoTotal');
            $table->integer('proveedor');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('items_orden_compras');
    }
}
