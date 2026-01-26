import 'package:flutter/material.dart';
import '../core/constants.dart';

import 'home/homeScreen.dart';
import 'upload/uploadScreen.dart';
import 'files/filesScreen.dart';
import 'wallet/wallet_gate_screen.dart';
import '../widgets/animated_bottom_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 2;

  // ORDER MUST MATCH BottomNavigationBar items
  final List<Widget> _screens = [
    FilesScreen(),
    UploadScreen(),
    HomeScreen(),
    WalletGateScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,

      // Keeps screen state alive
      body: IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: AnimatedBottomBar(
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,

          selectedItemColor: Colors.white,
          unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),

          onTap: (index) {
            setState(() => _selectedIndex = index);
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_sharp),
              activeIcon: Icon(Icons.folder_open),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_upload_outlined),
              activeIcon: Icon(Icons.cloud_upload_outlined),
              label: 'Upload',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet_outlined),
              activeIcon: Icon(Icons.wallet),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}
