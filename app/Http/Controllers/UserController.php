<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class UserController extends Controller
{
    public function createProfile(Request $request)
    {
        $request->validate([
            'wallet_address' => 'required|unique:users',
            'name' => 'required|string|max:255',
            'blood_type' => 'required|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
            'age' => 'required|integer|min:18|max:65',
            'location' => 'sometimes|string',
            'emergency_contact' => 'sometimes|string'
        ]);

        $user = User::create($request->all());

        $token = $user->createToken('BloodDonationApp')->accessToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'message' => 'Profile created successfully'
        ], 201);
    }

    public function getProfile(Request $request)
    {
        return response()->json([
            'user' => $request->user()
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'blood_type' => 'sometimes|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
            'age' => 'sometimes|integer|min:18|max:65',
            'location' => 'sometimes|string',
            'emergency_contact' => 'sometimes|string'
        ]);

        $user->update($request->all());

        return response()->json([
            'user' => $user,
            'message' => 'Profile updated successfully'
        ]);
    }
}
