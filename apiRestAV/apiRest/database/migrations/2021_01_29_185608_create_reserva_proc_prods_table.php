<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateReservaProcProdsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('reserva_proc_prods', function (Blueprint $table) {
            $table->id();
            $table->integer('idProcProd');
            $table->integer('tipo');
            $table->text('codProd');
            $table->text('lote');
            $table->text('loteVenta')->nullable();
            $table->decimal('cantidadReceta',50,2);
            $table->decimal('cantidad',50,2);
            $table->decimal('costoUnit',50,4);
            $table->integer('estado');
            $table->integer('idInventario')->nullable();
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
        Schema::dropIfExists('reserva_proc_prods');
    }
}
