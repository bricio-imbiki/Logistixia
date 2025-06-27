<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\ClientController;
use App\Http\Controllers\Api\CamionController;
 Route::apiResource('clients', ClientController::class);
    Route::apiResource('camions', CamionController::class);
Route::middleware('auth:sanctum')->group(function () {

});

