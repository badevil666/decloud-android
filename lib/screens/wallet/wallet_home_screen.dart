import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/crypto/eth_service.dart';
import '../../core/auth_notifier.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

enum WalletSection { transactions, contracts }

class _WalletHomeScreenState extends State<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  String? address;
  double balance = 0.0;
  double maxBalance = 10.0;
  bool loading = true;
  bool _addressCopied = false;

  // ✅ STATE BELONGS HERE
  WalletSection _activeSection = WalletSection.transactions;

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
    print('[WalletHome] _loadWalletData started');

    final addr = await SecureStorage.read('wallet_address');
    print('[WalletHome] wallet_address from storage: $addr');

    if (addr == null) {
      print('[WalletHome] No wallet address found - showing empty state');
      if (mounted) {
        setState(() {
          address = '';
          loading = false;
        });
      }
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    double realBalance = 0.0;
    try {
      print('[WalletHome] Fetching token balance for $addr...');
      realBalance = await EthService.getTokenBalance(addr);
      print('[WalletHome] Balance fetched: $realBalance DCLD');
    } catch (e, st) {
      print('[WalletHome] Failed to fetch balance: $e\n$st');
    }

    if (!mounted) return;

    print('[WalletHome] Setting state - address: $addr, balance: $realBalance');
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

  Widget _buildSectionSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _sectionButton(
            label: "Transactions",
            selected: _activeSection == WalletSection.transactions,
            onTap: () {
              setState(() {
                _activeSection = WalletSection.transactions;
              });
            },
          ),
          _sectionButton(
            label: "Smart Contracts",
            selected: _activeSection == WalletSection.contracts,
            onTap: () {
              setState(() {
                _activeSection = WalletSection.contracts;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Wallet",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: Color.fromARGB(200, 200, 200, 200),
                        ),
                      ),
                      const SizedBox(height: 15),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final scale = Curves.easeOutBack.transform(
                            _controller.value.clamp(0.0, 1.0),
                          );
                          return Transform.scale(
                            scale: scale,
                            alignment: Alignment.topCenter,
                            child: child,
                          );
                        },
                        child: _walletCard(),
                      ),
                      const SizedBox(height: 10),
                      _buildSectionSwitcher(),
                      const SizedBox(height: 10),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _activeSection == WalletSection.transactions
                            ? const _TransactionsSection()
                            : const _ContractsSection(),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _walletCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: kPrimaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 249, 249, 249).withAlpha(200),
            blurRadius: 20,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Wallet Address",
            style: TextStyle(
              color: Color.fromARGB(179, 2, 1, 1),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: address!));
              setState(() => _addressCopied = true);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) setState(() => _addressCopied = false);
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    address!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  _addressCopied ? Icons.check_rounded : Icons.copy_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          const Text(
            "Wallet Balance",
            style: TextStyle(
              color: Color.fromARGB(179, 10, 9, 9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            "$balance DCLD",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF181A20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Disconnect Wallet',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      content: const Text(
                        'Are you sure you want to disconnect? You will need your recovery phrase to reconnect.',
                        style: TextStyle(color: Colors.white70, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            'Disconnect',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await AuthNotifier().disconnectWallet();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  "Disconnect",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {},
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
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("transactions"),
      children: const [
        _TransactionTile(address: "0xA3f9...92C1", amount: 234.0),
        _TransactionTile(address: "0x91bE...7D2A", amount: -1324.0),
        _TransactionTile(address: "0xC44D...E18F", amount: 56.75),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String address;
  final double amount;

  const _TransactionTile({required this.address, required this.amount});

  @override
  Widget build(BuildContext context) {
    final incoming = amount >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: incoming ? Colors.green : Colors.red,
            child: Icon(
              incoming ? Icons.call_received : Icons.call_made,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  incoming ? "Received" : "Sent",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  address,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${incoming ? '+' : ''}${amount.toStringAsFixed(2)} DCLD",
            style: TextStyle(
              color: incoming ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContractsSection extends StatelessWidget {
  const _ContractsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey("contracts"),
      children: [
        Text(
          "No smart contracts connected",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
