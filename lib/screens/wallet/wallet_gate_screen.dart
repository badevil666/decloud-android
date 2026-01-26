import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import './wallet_home_screen.dart';
import 'wallet_setup_screen.dart';

class WalletGateScreen extends StatefulWidget {
  const WalletGateScreen({super.key});

  @override
  State<WalletGateScreen> createState() => _WalletGateScreenState();
}

class _WalletGateScreenState extends State<WalletGateScreen> {
  bool loading = true;
  bool walletExists = false;

  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

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
      backgroundColor: Colors.black, // TEMP: force contrast
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : walletExists
            ? const WalletHomeScreen()
            : const WalletSetupScreen(),
      ),
    );
  }
}
