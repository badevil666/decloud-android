import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import '../../core/auth_notifier.dart';
import '../../core/auth/auth_service.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/config/api_config_service.dart';
import '../../core/config/api_config.dart';
import '../wallet/wallet_setup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authNotifier = AuthNotifier();
  bool _isDeCloudConnected = false;
  String _apiUrl = '';

  @override
  void initState() {
    super.initState();
    _authNotifier.addListener(_onAuthChanged);
    _loadDeCloudState();
  }

  @override
  void dispose() {
    _authNotifier.removeListener(_onAuthChanged);
    super.dispose();
  }

  Future<void> _loadDeCloudState() async {
    final token = await AuthService.getToken();
    final url = await ApiConfigService.getBaseUrl();
    if (mounted) {
      setState(() {
        _isDeCloudConnected = token != null;
        _apiUrl = url;
      });
    }
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
      _loadDeCloudState();
    }
  }

  void _openApiSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ApiSettingsSheet(),
    ).then((_) => _loadDeCloudState());
  }

  Future<void> _openConnectSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ConnectNetworkSheet(),
    );
    await _loadDeCloudState();
  }

  Future<void> _signOutDeCloud() async {
    await AuthService.clearToken();
    await _loadDeCloudState();
  }

  @override
  Widget build(BuildContext context) {
    final walletAddress = _authNotifier.walletAddress;

    Widget body;
    if (walletAddress != null && _isDeCloudConnected) {
      body = _DeCloudProfileView(
        walletAddress: walletAddress,
        apiUrl: _apiUrl,
        onSignOut: _signOutDeCloud,
        onDisconnectWallet: () => _authNotifier.disconnectWallet(),
      );
    } else if (walletAddress != null) {
      body = _ConnectDeCloudView(
        walletAddress: walletAddress,
        onConnect: _openConnectSheet,
        onDisconnectWallet: () => _authNotifier.disconnectWallet(),
      );
    } else {
      body = _NoWalletView(authNotifier: _authNotifier);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: _openApiSettings,
                  icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                  tooltip: 'API Settings',
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

// ── No wallet ─────────────────────────────────────────────────────────────────

class _NoWalletView extends StatelessWidget {
  final AuthNotifier authNotifier;
  const _NoWalletView({required this.authNotifier});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 72, color: Colors.white54),
          const SizedBox(height: 24),
          const Text(
            'No Wallet Connected',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connect or create a wallet to access your DeCloud profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletSetupScreen()),
              );
              await authNotifier.updateWallet();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Set Up Wallet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ── Wallet connected, not on DeCloud yet ─────────────────────────────────────

class _ConnectDeCloudView extends StatelessWidget {
  final String walletAddress;
  final VoidCallback onConnect;
  final VoidCallback onDisconnectWallet;
  const _ConnectDeCloudView({
    required this.walletAddress,
    required this.onConnect,
    required this.onDisconnectWallet,
  });

  String _truncate(String addr) =>
      '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Wallet card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kDividerColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Wallet Connected',
                          style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(_truncate(walletAddress),
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Not connected to DeCloud
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kCardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kDividerColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.cloud_off_rounded, color: Colors.orangeAccent, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Not on DeCloud',
                          style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w600, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Login or register to access the network.',
                          style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onConnect,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Connect to DeCloud', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: onDisconnectWallet,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Disconnect Wallet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fully connected profile ───────────────────────────────────────────────────

class _DeCloudProfileView extends StatefulWidget {
  final String walletAddress;
  final String apiUrl;
  final VoidCallback onSignOut;
  final VoidCallback onDisconnectWallet;

  const _DeCloudProfileView({
    required this.walletAddress,
    required this.apiUrl,
    required this.onSignOut,
    required this.onDisconnectWallet,
  });

  @override
  State<_DeCloudProfileView> createState() => _DeCloudProfileViewState();
}

class _DeCloudProfileViewState extends State<_DeCloudProfileView> {
  bool _addressCopied = false;

  String _truncate(String addr) =>
      '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';

  Future<void> _copyAddress() async {
    await Clipboard.setData(ClipboardData(text: widget.walletAddress));
    setState(() => _addressCopied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _addressCopied = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header card ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: kPrimaryGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                const Text(
                  'DeCloud User',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _copyAddress,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _truncate(widget.walletAddress),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _addressCopied ? Icons.check_rounded : Icons.copy_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Info rows ────────────────────────────────────────────────────
          _InfoCard(rows: [
            _InfoRow(
              icon: Icons.cloud_done_rounded,
              iconColor: Colors.greenAccent,
              label: 'Status',
              value: 'Connected',
              valueColor: Colors.greenAccent,
            ),
            _InfoRow(
              icon: Icons.lan_rounded,
              iconColor: Colors.cyanAccent,
              label: 'Network',
              value: 'Sepolia Testnet',
            ),
            _InfoRow(
              icon: Icons.token_rounded,
              iconColor: Colors.purpleAccent,
              label: 'Token',
              value: 'DCLD',
            ),
            _InfoRow(
              icon: Icons.link_rounded,
              iconColor: Colors.white54,
              label: 'API',
              value: widget.apiUrl,
              smallValue: true,
            ),
          ]),
          const SizedBox(height: 28),

          // ── Actions ──────────────────────────────────────────────────────
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out from DeCloud', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: kDividerColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: widget.onDisconnectWallet,
              icon: const Icon(Icons.link_off_rounded, size: 18),
              label: const Text('Disconnect Wallet', style: TextStyle(fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kDividerColor),
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final isLast = e.key == rows.length - 1;
          return Column(
            children: [
              e.value,
              if (!isLast)
                const Divider(height: 1, color: kDividerColor, indent: 52),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;
  final bool smallValue;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
    this.smallValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: smallValue ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Connect to DeCloud network sheet ─────────────────────────────────────────

class _ConnectNetworkSheet extends StatefulWidget {
  const _ConnectNetworkSheet();

  @override
  State<_ConnectNetworkSheet> createState() => _ConnectNetworkSheetState();
}

class _ConnectNetworkSheetState extends State<_ConnectNetworkSheet> {
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _connect({required bool isRegister}) async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final privateKeyHex = await SecureStorage.read('wallet_private_key');
      if (privateKeyHex == null) throw Exception('Private key not found.');

      if (isRegister) {
        await AuthService.register(privateKeyHex);
      } else {
        await AuthService.login(privateKeyHex);
      }

      if (mounted) {
        setState(() {
          _loading = false;
          _success = isRegister ? 'Registered successfully!' : 'Logged in successfully!';
        });
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Connect to DeCloud',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Are you a new user? Register your wallet. Otherwise log in.',
            style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            _Banner(message: _error!, color: Colors.redAccent, icon: Icons.error_outline),
            const SizedBox(height: 16),
          ],
          if (_success != null) ...[
            _Banner(message: _success!, color: Colors.greenAccent, icon: Icons.check_circle_outline),
            const SizedBox(height: 16),
          ],
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () => _connect(isRegister: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () => _connect(isRegister: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: kDividerColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                ),
                child: const Text('Register', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _Banner({required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}

// ── API Settings bottom sheet ─────────────────────────────────────────────────

class _ApiSettingsSheet extends StatefulWidget {
  const _ApiSettingsSheet();

  @override
  State<_ApiSettingsSheet> createState() => _ApiSettingsSheetState();
}

class _ApiSettingsSheetState extends State<_ApiSettingsSheet> {
  late TextEditingController _controller;
  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    final url = await ApiConfigService.getBaseUrl();
    if (mounted) {
      _controller.text = url;
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    await ApiConfigService.setBaseUrl(url);
    if (mounted) {
      setState(() => _saved = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _reset() async {
    await ApiConfigService.resetToDefault();
    if (mounted) setState(() => _controller.text = apiBaseUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'API Settings',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
                tooltip: 'Reset to default',
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Set the base URL for the Decloud API. Changes take effect immediately on the next request.',
            style: TextStyle(color: kTextSecondary, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kDividerColor),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'https://api.example.com',
                  hintStyle: TextStyle(color: kTextSecondary),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saved ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _saved ? 'Saved!' : 'Save',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
