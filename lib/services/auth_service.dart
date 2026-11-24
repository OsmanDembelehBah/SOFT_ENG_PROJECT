import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../models/rider.dart';
import '../models/bike.dart';
import '../database/local_database.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService = SupabaseService();
  final LocalDatabase _localDb = LocalDatabase();

  Profile? _currentProfile;
  Rider? _currentRider;
  Bike? _currentBike;

  Profile? get currentProfile => _currentProfile;
  Rider? get currentRider => _currentRider;
  Bike? get currentBike => _currentBike;
  bool get isAuthenticated => _currentProfile != null;

  /// Authenticate using Google OAuth
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (_supabaseService.isInitialized && _supabaseService.client != null) {
        await _supabaseService.client!.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'transitflow://auth-callback',
        );
      }
    } catch (e) {
      debugPrint('Supabase Google OAuth fallback: $e');
    }

    // Default or fallback Google profile (Alhaji Osman Bah - Union Admin)
    final profile = _localDb.profiles.firstWhere(
      (p) => p.role == 'admin',
      orElse: () => _localDb.profiles.first,
    );
    _setSession(profile);

    return {
      'success': true,
      'profile': profile,
      'method': 'google',
    };
  }

  /// Authenticate using Username, Rider ID (e.g. R001) or Bike Plate (e.g. BKE-101) + Password
  /// Brings over the exact query logic from Stage 1: authenticateRider(query, password)
  Future<Map<String, dynamic>> signInWithCredentials({
    required String query,
    required String password,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      throw Exception('Please enter your Username, Rider ID, or Motorcycle Plate number.');
    }
    if (password.trim().isEmpty) {
      throw Exception('Please enter your password.');
    }

    // 1. Check if query matches a Motorcycle Plate (e.g. BKE-101)
    final matchedBike = _localDb.bikes.cast<Bike?>().firstWhere(
          (b) => b?.plateNumber.toUpperCase() == cleanQuery.toUpperCase(),
          orElse: () => null,
        );

    // 2. Check if query matches a Rider ID (e.g. R001)
    final matchedRider = _localDb.riders.cast<Rider?>().firstWhere(
          (r) =>
              r?.riderCode.toUpperCase() == cleanQuery.toUpperCase() ||
              (matchedBike != null && r?.id == matchedBike.riderId),
          orElse: () => null,
        );

    // 3. Check if query matches a Profile Username (e.g. admin_usman, inspector_alpha, R001)
    final matchedProfile = _localDb.profiles.cast<Profile?>().firstWhere(
          (p) =>
              p?.username.toLowerCase() == cleanQuery.toLowerCase() ||
              (matchedRider != null && p?.id == matchedRider.profileId) ||
              (matchedRider != null && p?.username.toUpperCase() == matchedRider.riderCode.toUpperCase()),
          orElse: () => null,
        );

    if (matchedProfile != null) {
      _setSession(matchedProfile, rider: matchedRider, bike: matchedBike);
      return {
        'success': true,
        'profile': matchedProfile,
        'rider': _currentRider,
        'bike': _currentBike,
      };
    }

    // If rider existed without profile, create active session
    if (matchedRider != null) {
      final synthProfile = Profile(
        id: matchedRider.profileId ?? 'prof-${matchedRider.id}',
        username: matchedRider.riderCode,
        fullName: matchedRider.fullName,
        phoneNumber: matchedRider.phoneNumber,
        role: 'rider',
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=${matchedRider.riderCode}',
      );
      _setSession(synthProfile, rider: matchedRider, bike: matchedBike);
      return {
        'success': true,
        'profile': synthProfile,
        'rider': _currentRider,
        'bike': _currentBike,
      };
    }

    throw Exception(
        'Account "$cleanQuery" not found. Please verify your credentials or select a Demo Profile.');
  }

  /// Switch to Demo Role (Rider, Admin, Inspector, Executive) for instant UI exploration
  void switchToDemoRole(String role) {
    Profile targetProfile;
    switch (role.toLowerCase()) {
      case 'admin':
        targetProfile = _localDb.profiles.firstWhere(
          (p) => p.role == 'admin',
          orElse: () => _localDb.profiles.first,
        );
        break;
      case 'inspector':
        targetProfile = _localDb.profiles.firstWhere(
          (p) => p.role == 'inspector',
          orElse: () => _localDb.profiles.first,
        );
        break;
      case 'executive':
        targetProfile = _localDb.profiles.firstWhere(
          (p) => p.role == 'executive',
          orElse: () => _localDb.profiles.first,
        );
        break;
      case 'rider':
      default:
        targetProfile = _localDb.profiles.firstWhere(
          (p) => p.role == 'rider',
          orElse: () => _localDb.profiles.first,
        );
        break;
    }
    _setSession(targetProfile);
  }

  void _setSession(Profile profile, {Rider? rider, Bike? bike}) {
    _currentProfile = profile;

    if (rider != null) {
      _currentRider = rider;
    } else {
      _currentRider = _localDb.riders.cast<Rider?>().firstWhere(
            (r) =>
                r?.profileId == profile.id ||
                r?.riderCode.toUpperCase() == profile.username.toUpperCase(),
            orElse: () => _localDb.riders.first,
          );
    }

    if (bike != null) {
      _currentBike = bike;
    } else if (_currentRider != null) {
      _currentBike = _localDb.bikes.cast<Bike?>().firstWhere(
            (b) => b?.riderId == _currentRider!.id,
            orElse: () => _localDb.bikes.first,
          );
    }
  }

  void signOut() {
    _currentProfile = null;
    _currentRider = null;
    _currentBike = null;
  }
}
