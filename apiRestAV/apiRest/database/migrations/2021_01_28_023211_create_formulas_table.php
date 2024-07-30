<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateFormulasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('formulas', function (Blueprint $table) {
            $table->id();
            $table->text('titulo');
            $table->text('codProdRes');
            $table->decimal('cantidad',50,2)->nullable();
            $table->text('instruccion')->nullable();
            $table->integer('lineaProduccion');
            $table->integer('version');
            $table->integer('cliente')->nullable();
            $table->integer('estado');
            $table->integer('usrReg');
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
        Schema::dropIfExists('formulas');
    }
}
