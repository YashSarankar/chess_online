import 'package:chess_online/screens/profile_screens/wallet_screen.dart';
import 'package:chess_online/screens/wating.dart';
import 'package:flutter/material.dart';
import 'package:chess_online/screens/home_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'package:chess_online/screens/profile_screens/profile_screen.dart';
import '../services/notification_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const UnderProductionScreen(),
    const UnderProductionScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    String? token = await _notificationService.getToken();
    print('FCM Token: $token');
    // TODO: Send this token to your backend
    // You can store it in Firebase or your server to send notifications to this device
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _screens[_currentIndex],
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.r, 0, 12.r, 12.r),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 70.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.white.withOpacity(0.5),
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    iconSize: 22.sp,
                    selectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    items: [
                      _buildNavItem(Icons.home_rounded, 'Home'),
                      _buildNavItem(Icons.account_balance_wallet_rounded, 'Wallet'),
                      _buildNavItem(Icons.receipt_long_rounded, 'History'),
                      _buildNavItem(Icons.person_rounded, 'Profile'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    final isSelected = _currentIndex == _getIndexForLabel(label);
    
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.blue[400]!.withOpacity(0.5),
                    Colors.purple[400]!.withOpacity(0.5),
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue[400]!.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          shadows: isSelected
              ? [
                  Shadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
      ),
      label: label,
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Home':
        return 0;
      case 'Wallet':
        return 1;
      case 'History':
        return 2;
      case 'Profile':
        return 3;
      default:
        return 0;
    }
  }
} 