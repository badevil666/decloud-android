import 'package:flutter/material.dart';
//import '../../core/storage/secure_storage.dart';
import '../../core/crypto/wallet_service.dart';
import './wallet_home_screen.dart';

class ImportWalletScreen extends StatefulWidget {
  const ImportWalletScreen({super.key});

  @override
  State<ImportWalletScreen> createState() => _ImportWalletScreenState();
}

class _ImportWalletScreenState extends State<ImportWalletScreen> {
  final controller = TextEditingController();
  bool loading = false;
  String? error;

  Future<void> _import() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      await WalletService.importWallet(controller.text.trim());

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WalletHomeScreen()),
        (_) => false,
      );
    } catch (e) {
      setState(() {
        error = "Invalid recovery phrase";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Import Wallet"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: controller,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Recovery Phrase",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: loading ? null : _import,
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Import Wallet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
