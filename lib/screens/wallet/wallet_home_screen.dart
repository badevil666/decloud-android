// This file defines the WalletHomeScreen, which displays the user's wallet address and DCLD balance.
// It fetches wallet data from secure storage and uses EthService to get the token balance.
// The UI includes an animated balance card and a button to send tokens.
import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants.dart';
import '../../core/crypto/eth_service.dart';

// TODO: replace with your actual ERC-20 / RPC service
// import '../../core/crypto/eth_service.dart';

/// WalletHomeScreen is a StatefulWidget that displays the user's wallet information.
/// It shows the wallet address, current DCLD balance, and a progress indicator.
class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for the wallet balance card.
  late AnimationController _controller;

  // The wallet address of the current user.
  String? address;
  // The current DCLD balance of the wallet.
  double balance = 0.0;
  // An optional maximum balance for the progress indicator.
  double maxBalance = 10.0;
  // Flag to indicate if wallet data is still being loaded.
  bool loading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Load wallet data when the state is initialized.
    _loadWalletData();
  }

  /// Loads the wallet address from secure storage and fetches the DCLD balance.
  /// Updates [address], [balance], and [loading] accordingly.
  Future<void> _loadWalletData() async {
    final addr = await SecureStorage.read('wallet_address');

    if (addr == null) {
      return;
    }

    // ===============================
    // 🔥 FETCH REAL BALANCE HERE
    // ===============================
    // Example (pseudo-code):
    //
    // final rawBalance = await EthService.getTokenBalance(addr);
    // final decimals = await EthService.getTokenDecimals();
    // final realBalance =
    //     rawBalance / BigInt.from(10).pow(decimals);
    //
    // For now, simulate network delay + value:
    await Future.delayed(const Duration(milliseconds: 500));
    final realBalance = await EthService.getTokenBalance(addr);
    debugPrint("DCLD balance: $realBalance");

    setState(() {
      address = addr;
      balance = realBalance;
      loading = false;
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sets the background color of the screen.
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator()) // Shows a loading indicator while data is being fetched.
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = Curves.easeOutBack.transform(
                        _controller.value.clamp(0.0, 1.0),
                      );
                      return Transform.scale(scale: scale, child: child);
                    },
                    // The main wallet card displaying address, balance, and progress.
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ===== WALLET ADDRESS DISPLAY =====
                          const Text(
                            "Wallet Address",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ===== WALLET BALANCE DISPLAY =====
                          const Text(
                            "Wallet Balance",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$balance DCLD",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ===== BALANCE PROGRESS INDICATOR =====
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: (balance / maxBalance).clamp(0.0, 1.0),
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ===== ACTION BUTTON (SEND TOKENS) =====
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement Send / Receive token flow.
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                elevation: 0,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                "Send Tokens",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
