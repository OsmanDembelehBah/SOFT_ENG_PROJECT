import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../models/rider.dart';
import '../models/bike.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Profile? get currentProfile => _authService.currentProfile;
  Rider? get currentRider => _authService.currentRider;
  Bike? get currentBike => _authService.currentBike;
  bool get isAuthenticated => _authService.isAuthenticated;

  String get activeRole => currentProfile?.role ?? 'rider';
  bool get isAdmin => currentProfile?.isAdmin ?? false;
  bool get isInspector => currentProfile?.isInspector ?? false;
  bool get isExecutive => currentProfile?.isExecutive ?? false;
  bool get isRider => currentProfile?.isRider ?? true;

  AuthController() {
    // Default to Alhaji Bah (R001) for immediate interactive experience
    _authService.switchToDemoRole('rider');
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.signInWithGoogle();
      _isLoading = false;
      notifyListeners();
      return res['success'] == true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithCredentials({
    required String query,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithCredentials(query: query, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void switchRole(String role) {
    _authService.switchToDemoRole(role);
    _errorMessage = null;
    notifyListeners();
  }

  void signOut() {
    _authService.signOut();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
