import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/constants.dart';
import '../../core/crypto/eth_service.dart';

// TODO: replace with your actual ERC-20 / RPC service
// import '../../core/crypto/eth_service.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String? address;
  double balance = 0.0;
  double maxBalance = 10.0; // optional reference cap
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _loadWalletData();
  }

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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
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
                          // ===== ADDRESS INSIDE CARD =====
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

                          // ===== BALANCE =====
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

                          // ===== PROGRESS =====
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

                          // ===== ACTION =====
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Send / Receive flow
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
