<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateRegistroIngresosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('registro_ingresos', function (Blueprint $table) {
            $table->id();
            $table->text('codigo');
            $table->integer('aprobConta');
            $table->integer('aprobCalida');
            $table->text('usuario');
            $table->text('fecIngreso');
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
        Schema::dropIfExists('registro_ingresos');
    }
}
