<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateRegistroProcProdsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('registro_proc_prods', function (Blueprint $table) {
            $table->id();
            $table->integer('idFormula');
            $table->integer('idCliente');
            $table->integer('idLinProd');
            $table->integer('codAlmProd');
            $table->integer('codAlmDest')->nullable();
            $table->text('loteProd');
            $table->text('loteVenta')->nullable();
            $table->text('unidad');
            $table->decimal('cantidad',50,2);
            $table->decimal('costoReal',50,4)->nullable();
            $table->decimal('costoReceta',50,4)->nullable();
            $table->decimal('variacion',50,4)->nullable();
            $table->text('obs')->nullable();
            $table->integer('usrReg');
            $table->integer('aprob');
            $table->integer('estado');
            $table->text('fecInicio')->nullable();
            $table->text('fecFin')->nullable();
            $table->text('fecVenc')->nullable();
            $table->text('fecCulminacion')->nullable();
            $table->int('estadoTransferenciaSolicitada');
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
        Schema::dropIfExists('registro_proc_prods');
    }
}
