<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    public function walletLogin(Request $request)
    {
        $request->validate([
            'wallet_address' => 'required|string'
        ]);

        $user = User::where('wallet_address', $request->wallet_address)->first();

        if (!$user) {
            return response()->json([
                'message' => 'User not found. Please create profile first.',
                'needs_profile' => true
            ], 404);
        }

        $token = $user->createToken('BloodDonationApp')->accessToken;

        return response()->json([
            'token' => $token,
            'user' => $user,
            'needs_profile' => false
        ]);
    }

    public function verifySignature(Request $request)
    {
        // Implement wallet signature verification
        // This is a simplified version
        $request->validate([
            'wallet_address' => 'required',
            'signature' => 'required',
            'message' => 'required'
        ]);

        // In production, use a proper signature verification library
        $isValid = $this->verifyWalletSignature(
            $request->wallet_address,
            $request->signature,
            $request->message
        );

        if ($isValid) {
            $user = User::where('wallet_address', $request->wallet_address)->first();

            if ($user) {
                $token = $user->createToken('BloodDonationApp')->accessToken;
                return response()->json(['token' => $token, 'user' => $user]);
            }

            return response()->json(['needs_profile' => true], 200);
        }

        return response()->json(['error' => 'Invalid signature'], 401);
    }

    private function verifyWalletSignature($address, $signature, $message)
    {
        // Implement proper signature verification
        // For now, return true for development
        return true;
    }
}
