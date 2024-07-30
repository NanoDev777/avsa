<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateInventariosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('inventarios', function (Blueprint $table) {
            $table->id();
            $table->text('idCodigo');
            $table->integer('codAlm');
            $table->text('codProd');
            $table->text('codigo')->nullable();
            $table->decimal('cantidad',50,2);
            $table->decimal('costoUnitario',50,4);
            $table->decimal('costo',50,4);
            $table->decimal('prorrateo',50,4)->nullable();
            $table->text('lote')->nullable();
            $table->text('loteVenta')->nullable();
            $table->text('factura')->nullable();
            $table->integer('idProv');
            $table->text('fecIngreso');
            $table->text('fecVencimiento')->nullable();
            $table->text('aprovConta');
            $table->text('aprovCalida');
            $table->text('estado');
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
        Schema::dropIfExists('inventarios');
    }
}
