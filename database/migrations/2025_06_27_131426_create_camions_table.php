<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('camions', function (Blueprint $table) {
        $table->id();
        $table->string('matricule')->unique();
        $table->string('marque')->nullable();
        $table->string('modele')->nullable();
        $table->integer('capacite_kg')->nullable();
        $table->enum('statut', ['disponible', 'en mission', 'panne', 'maintenance'])->default('disponible');
        $table->boolean('est_interne')->default(true);
        $table->string('societe_proprietaire')->nullable();
        $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('camions');
    }
};
