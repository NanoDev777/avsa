<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateHistorialsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('historials', function (Blueprint $table) {
            $table->id();
            $table->text('idReg');
            $table->integer('codAlm');
            $table->text('codProd');
            $table->decimal('cantidad',50,2);
            $table->decimal('costo',50,4);
            $table->decimal('costoUnitario',50,4);
            $table->decimal('prorrateo',50,4);
            $table->decimal('saldo',50,2);
            $table->decimal('saldoCosto',50,2);
            $table->text('lote');
            $table->integer('usuario')->nullable();
            $table->text('accion');
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
        Schema::dropIfExists('historials');
    }
}
