<?php

use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\DonationRequestController;
use App\Http\Controllers\Api\DonationController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    // User routes
    Route::post('/users/register', [UserController::class, 'register']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}/wallet', [UserController::class, 'updateWallet']);

    // Donation Request routes
    Route::get('/donation-requests', [DonationRequestController::class, 'index']);
    Route::post('/donation-requests', [DonationRequestController::class, 'store']);
    Route::put('/donation-requests/{id}/blockchain', [DonationRequestController::class, 'updateBlockchainHash']);

    // Donation routes
    Route::post('/donations', [DonationController::class, 'store']);
    Route::get('/donations/user/{userId}', [DonationController::class, 'userDonations']);
});
