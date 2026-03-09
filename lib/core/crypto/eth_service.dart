import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../config/blockchain_config.dart';
import 'erc20_abi.dart';

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
}
