// This screen acts as a gate for the wallet functionality.
// It checks if a wallet already exists on the device.
// If a wallet exists, it navigates to the WalletHomeScreen.
// Otherwise, it navigates to the WalletSetupScreen to allow the user to create or import a wallet.
import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import './wallet_home_screen.dart';
import 'wallet_setup_screen.dart';

/// WalletGateScreen is a StatefulWidget that acts as a gateway for the wallet feature.
/// It determines whether to show the WalletHomeScreen or the WalletSetupScreen based on
/// whether a wallet address is found in secure storage.
class WalletGateScreen extends StatefulWidget {
  const WalletGateScreen({super.key});

  @override
  State<WalletGateScreen> createState() => _WalletGateScreenState();
}

class _WalletGateScreenState extends State<WalletGateScreen> {
  // Flag to indicate if the wallet existence check is still in progress.
  bool loading = true;
  // Flag to indicate if a wallet address is found in secure storage.
  bool walletExists = false;

  @override
  void initState() {
    super.initState();
    // Perform the wallet existence check when the state is initialized.
    _checkWallet();
  }

  /// Checks if a wallet address is stored in secure storage.
  /// Updates [walletExists] and [loading] accordingly.
  Future<void> _checkWallet() async {
    final address = await SecureStorage.read('wallet_address');
    setState(() {
      walletExists = address != null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // TEMP: force contrast - Sets the background color of the screen.
      body: Center(
        // Displays a loading indicator if the wallet check is in progress.
        // Otherwise, it shows either WalletHomeScreen or WalletSetupScreen based on wallet existence.
        child: loading
            ? const CircularProgressIndicator()
            : walletExists
            ? const WalletHomeScreen()
            : const WalletSetupScreen(),
      ),
    );
  }
}
