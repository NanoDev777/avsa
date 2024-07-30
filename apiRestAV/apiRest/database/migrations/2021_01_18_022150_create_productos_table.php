<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('productos', function (Blueprint $table) {
            $table->id();
            $table->text('codigo');
            $table->text('nombre');
            $table->integer('unidadMedida');
            $table->integer('estado');
            $table->integer('sgi');
            $table->integer('usrRegistro');
            $table->text('descripcion');
            $table->integer('stock');
            $table->decimal('pesoNeto');
            $table->decimal('pesoBruto');
            $table->integer('cliente');
            $table->text('fecCreacion');
            $table->text('fecActualizacion');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('productos');
    }
}
