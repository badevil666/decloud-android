import 'package:flutter/material.dart';
import 'storage/secure_storage.dart';
import 'crypto/wallet_service.dart';

class AuthNotifier extends ChangeNotifier {
  static final AuthNotifier _instance = AuthNotifier._internal();
  factory AuthNotifier() => _instance;
  AuthNotifier._internal();

  bool _isLoggedIn = false;
  String? _walletAddress;

  bool get isLoggedIn => _isLoggedIn;
  String? get walletAddress => _walletAddress;

  /// Call this when the app starts.
  Future<void> init() async {
    final loggedInStr = await SecureStorage.read('is_logged_in');
    final address = await SecureStorage.read('wallet_address');

    _isLoggedIn = loggedInStr == 'true';
    _walletAddress = address;
    notifyListeners();
  }

  /// Mark the user as logged in and refresh state.
  Future<void> login() async {
    await SecureStorage.write('is_logged_in', 'true');
    await init();
  }

  /// Sign out of the profile session (keeps wallet keys intact).
  Future<void> logout() async {
    await SecureStorage.delete('is_logged_in');
    await init();
  }

  /// Wipe every piece of wallet data and reset state.
  Future<void> disconnectWallet() async {
    await WalletService.disconnect();
    _isLoggedIn = false;
    _walletAddress = null;
    notifyListeners();
  }

  /// Re-read wallet_address from storage (called after external wallet changes).
  Future<void> updateWallet() async {
    final address = await SecureStorage.read('wallet_address');
    _walletAddress = address;
    notifyListeners();
  }
}
