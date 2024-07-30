<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateHistorialTransferenciasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('historial_transferencias', function (Blueprint $table) {
            $table->id();
            $table->text ('codTransferencia');
            $table->integer('almOrigen');
            $table->integer('almDestino');
            $table->text('loteTransferido');
            $table->text('codProd');
            $table->text('cantidad');
            $table->text('fechaTransferencia');
            $table->integer('usrTransferencia');
            $table->text('fechaAceptacion')->nullable();
            $table->integer('usrAceptacion')->nullable();
            $table->integer('idLote');
            $table->integer('estado');
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
        Schema::dropIfExists('historial_transferencias');
    }
}
