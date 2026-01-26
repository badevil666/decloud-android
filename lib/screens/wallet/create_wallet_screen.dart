import 'package:flutter/material.dart';
import '../../core/crypto/wallet_service.dart';
import '../../widgets/mnemonic_backup_widget.dart';
//import './wallet_home_screen.dart';

class CreateWalletFlow extends StatefulWidget {
  const CreateWalletFlow({super.key});

  @override
  State<CreateWalletFlow> createState() => _CreateWalletFlowState();
}

class _CreateWalletFlowState extends State<CreateWalletFlow> {
  String? mnemonic;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _createWallet();
  }

  Future<void> _createWallet() async {
    final result = await WalletService.createWallet();
    setState(() {
      mnemonic = result.mnemonic;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Backup Recovery Phrase"),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : MnemonicBackupWidget(
                mnemonic: mnemonic!,
                onConfirmed: () {
                  // wipe mnemonic from memory
                  mnemonic = null;

                  // IMPORTANT: do NOT kill the entire app navigation
                  Navigator.pop(context);
                  // WalletGateScreen will re-evaluate and show WalletHome
                },
              ),
      ),
    );
  }
}
