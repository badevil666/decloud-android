# Decloud Android Wallet

A **non-custodial Android wallet** built with **Flutter** for the **Decloud** project.  
This wallet securely manages user keys, connects to the **Ethereum Sepolia testnet**, and displays balances of the **DCLD ERC-20 token**.

The wallet is designed as part of a decentralized storage ecosystem where users earn and spend tokens for storage services.

---

## 🚀 Features

- 🔐 **Non-custodial wallet**
  - BIP-39 mnemonic generation
  - BIP-44 Ethereum key derivation
  - Private keys never leave the device

- 🛡 **Secure local storage**
  - Encrypted storage using platform keystore
  - No backend custody

- 🌐 **Ethereum integration**
  - Sepolia testnet support
  - ERC-20 token interaction (DCLD)
  - Real on-chain balance fetching

- 💰 **Wallet UI**
  - Animated wallet balance card
  - Wallet address display
  - Clean, modern Flutter UI

- 🔄 **Wallet management**
  - Create new wallet
  - Import wallet using recovery phrase
  - Disconnect / reset wallet (development-ready)

---

## 🧱 Tech Stack

- Flutter (Dart)
- web3dart
- Ethereum (Sepolia Testnet)
- ERC-20 Smart Contracts
- Flutter Secure Storage

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── crypto/
│   │   ├── mnemonic_service.dart
│   │   ├── wallet_service.dart
│   │   ├── eth_service.dart
│   │   └── erc20_abi.dart
│   ├── storage/
│   │   └── secure_storage.dart
│   └── config/
│       └── blockchain_config.example.dart
│
├── screens/
│   ├── wallet/
│   │   ├── wallet_gate_screen.dart
│   │   ├── wallet_home_screen.dart
│   │   ├── create_wallet_screen.dart
│   │   └── import_wallet_screen.dart
│   └── navigation/
│       └── main_navigation.dart
│
├── widgets/
│   └── mnemonic_backup_widget.dart
│
└── main.dart
