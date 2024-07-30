<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAlmacensTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('almacenes', function (Blueprint $table) {
            $table->id();
            $table->Integer ('codAlm');
            $table->Text ('name');
            $table->Text ('ubicAlmacen');
            $table->Text ('telf');
            $table->Integer ('activo');
            $table->Text ('fechaRegistro');
            $table->Integer ('usrRegistro');
            $table->Text ('ProdPermitidos');
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
        Schema::dropIfExists('almacens');
    }
}
