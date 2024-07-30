<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->text('nombres');
            $table->text('apPaterno');
            $table->text('apMaterno');
            $table->text('carnetIdentidad');
            $table->text('email');
            $table->text('usuario');
            $table->text('password');
            $table->integer('cargo');
            $table->text('ultimoAcceso');
            $table->text('fCreacion');
            $table->text('fActualizacion');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('users');
    }
}
