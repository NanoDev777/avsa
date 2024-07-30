<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateIngredientesFormulasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ingredientes_formulas', function (Blueprint $table) {
            $table->id();
            $table->integer('idFormula');
            $table->integer('orden');
            $table->integer('tipo');
            $table->text('codProd');
            $table->decimal('cantProd',50,2);
            $table->integer('comentarios')->nullable();
            $table->integer('costoAdicional')->nullable();
            $table->integer('usrReg');
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
        Schema::dropIfExists('ingredientes_formulas');
    }
}
