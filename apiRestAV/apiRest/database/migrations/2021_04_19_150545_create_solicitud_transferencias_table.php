<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSolicitudTransferenciasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('solicitud_transferencias', function (Blueprint $table) {
            $table->id();
            $table->text('codTransferencia');
            $table->integer('almDestino');
            $table->text('codProd');
            $table->decimal('cantidad',50,2);
            $table->integer('usrReg');
            $table->text('fechaReg');
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
        Schema::dropIfExists('solicitud_transferencias');
    }
}
