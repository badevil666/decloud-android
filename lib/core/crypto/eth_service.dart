import 'dart:convert';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../config/blockchain_config.dart';
import 'erc20_abi.dart';

class TokenTransfer {
  final String txHash;
  final String from;
  final String to;
  final double amount;
  final int blockNumber;

  const TokenTransfer({
    required this.txHash,
    required this.from,
    required this.to,
    required this.amount,
    required this.blockNumber,
  });
}

class EthService {
  static final Web3Client _primaryClient = Web3Client(sepoliaRpcUrl, Client());
  static final Web3Client _fallbackClient = Web3Client(sepoliaFallbackRpcUrl, Client());

  static final EthereumAddress _tokenAddress = EthereumAddress.fromHex(
    dcldTokenAddress,
  );

  static final DeployedContract _contract = DeployedContract(
    ContractAbi.fromJson(erc20Abi, "DCLD"),
    _tokenAddress,
  );

  static final ContractFunction _balanceOf = _contract.function("balanceOf");

  static final ContractFunction _decimals = _contract.function("decimals");

  static Future<double> getTokenBalance(String walletAddress) async {
    print('[EthService] getTokenBalance called for $walletAddress');

    final EthereumAddress address = EthereumAddress.fromHex(walletAddress);

    try {
      print('[EthService] Trying primary RPC: $sepoliaRpcUrl');
      return await _fetchBalance(address, _primaryClient)
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      print('[EthService] Primary RPC failed: $e');
      print('[EthService] Falling back to: $sepoliaFallbackRpcUrl');
      return await _fetchBalance(address, _fallbackClient)
          .timeout(const Duration(seconds: 10));
    }
  }

  static Future<double> _fetchBalance(
    EthereumAddress address,
    Web3Client client,
  ) async {
    print('[EthService] Calling balanceOf...');
    final List<dynamic> balanceResult = await client.call(
      contract: _contract,
      function: _balanceOf,
      params: [address],
    );
    print('[EthService] balanceOf returned: $balanceResult');

    print('[EthService] Calling decimals...');
    final List<dynamic> decimalsResult = await client.call(
      contract: _contract,
      function: _decimals,
      params: [],
    );
    print('[EthService] decimals returned: $decimalsResult');

    final BigInt rawBalance = balanceResult.first as BigInt;
    final BigInt decimalsBig = decimalsResult.first as BigInt;

    final int decimals = decimalsBig.toInt();
    final BigInt divisor = BigInt.from(10).pow(decimals);

    final double balance = rawBalance.toDouble() / divisor.toDouble();
    print('[EthService] Computed balance: $balance DCLD');

    return balance;
  }

  static Future<double> getEthBalance(String walletAddress) async {
    final address = EthereumAddress.fromHex(walletAddress);
    try {
      final wei = await _primaryClient
          .getBalance(address)
          .timeout(const Duration(seconds: 8));
      return wei.getInWei.toDouble() / 1e18;
    } catch (_) {
      final wei = await _fallbackClient
          .getBalance(address)
          .timeout(const Duration(seconds: 10));
      return wei.getInWei.toDouble() / 1e18;
    }
  }

  /// Fetches the 20 most recent DCLD Transfer events involving [walletAddress].
  /// Uses eth_getLogs over the Infura RPC — no extra API key needed.
  static Future<List<TokenTransfer>> getRecentTransfers(String walletAddress) async {
    // Transfer(address indexed from, address indexed to, uint256 value)
    const transferTopic = '0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef';

    // Pad address to 32 bytes (64 hex chars, left-padded with zeros)
    final paddedAddress = '0x' + walletAddress.toLowerCase().replaceFirst('0x', '').padLeft(64, '0');

    // Look back ~50 000 blocks (~7 days on Sepolia at ~12s/block)
    final latestHex = await _getLatestBlockHex();
    final fromBlock = _subtractHex(latestHex, 50000);

    // Fetch incoming and outgoing transfers in parallel
    final results = await Future.wait([
      _getLogs(transferTopic, paddedAddress, isFrom: false, fromBlock: fromBlock), // incoming
      _getLogs(transferTopic, paddedAddress, isFrom: true,  fromBlock: fromBlock), // outgoing
    ]);

    final all = [...results[0], ...results[1]];
    all.sort((a, b) => b.blockNumber.compareTo(a.blockNumber));
    return all.take(20).toList();
  }

  static Future<String> _getLatestBlockHex() async {
    final resp = await http.post(
      Uri.parse(sepoliaRpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'jsonrpc': '2.0', 'id': 1, 'method': 'eth_blockNumber', 'params': []}),
    ).timeout(const Duration(seconds: 8));
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return data['result'] as String;
  }

  static String _subtractHex(String hexBlock, int amount) {
    final n = int.parse(hexBlock.replaceFirst('0x', ''), radix: 16) - amount;
    return '0x${n.toRadixString(16)}';
  }

  static Future<List<TokenTransfer>> _getLogs(
    String transferTopic,
    String paddedAddress, {
    required bool isFrom,
    required String fromBlock,
  }) async {
    // topic1 = from address, topic2 = to address
    final topics = isFrom
        ? [transferTopic, paddedAddress]
        : [transferTopic, null, paddedAddress];

    final resp = await http.post(
      Uri.parse(sepoliaRpcUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'eth_getLogs',
        'params': [{
          'address': dcldTokenAddress,
          'fromBlock': fromBlock,
          'toBlock': 'latest',
          'topics': topics,
        }],
      }),
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final logs = (data['result'] as List?) ?? [];

    return logs.map((log) {
      final topics = log['topics'] as List;
      final from = _topicToAddress(topics[1] as String);
      final to   = _topicToAddress(topics[2] as String);
      final rawValue = BigInt.parse((log['data'] as String).replaceFirst('0x', ''), radix: 16);
      final amount = rawValue.toDouble() / 1e18;
      final block = int.parse((log['blockNumber'] as String).replaceFirst('0x', ''), radix: 16);
      return TokenTransfer(
        txHash: log['transactionHash'] as String,
        from: from,
        to: to,
        amount: amount,
        blockNumber: block,
      );
    }).toList();
  }

  static String _topicToAddress(String topic) {
    // topic is 0x + 64 hex chars; address is last 40 chars
    return '0x${topic.substring(topic.length - 40)}';
  }
}
