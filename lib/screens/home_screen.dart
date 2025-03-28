import 'package:chess_online/auth/auth_service.dart';
import 'package:chess_online/auth/login_screen.dart';
import 'package:chess_online/screens/wating.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chess_board_style.dart';
import 'chess_game_page.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chess_online/screens/game_lobby_screen.dart';
import 'dart:math' show pi;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo[900]!,
                Colors.purple[900]!,
                Colors.blue[900]!,
              ],
            ),
          ),
        ),

        // Animated stars background
        ...List.generate(20, (index) {
          final double size = (index % 3 + 1) * 2.0;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double value = (_controller.value + index / 20) % 1.0;
              return Positioned(
                left: MediaQuery.of(context).size.width * ((index * 17 % 100) / 100),
                top: MediaQuery.of(context).size.height * value,
                child: Opacity(
                  opacity: (1 - value) * 0.2,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Main content with blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0.h),
                  child: Hero(
                    tag: 'app_title',
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 2 * pi),
                            duration: const Duration(seconds: 10),
                            builder: (context, double value, child) {
                              return Transform.rotate(
                                angle: value,
                                child: Text(
                                  '♔',
                                  style: TextStyle(
                                    fontSize: 32.sp,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Chess Time',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Experience Chess Like Never Before',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        Text(
                          'Select Game Mode',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickPlayButton(
                                context,
                                title: 'Play Bot',
                                subtitle: 'Challenge AI',
                                icon: Icons.smart_toy_rounded,
                                gradient: [
                                  Colors.deepPurple[400]!,
                                  Colors.deepPurple[700]!,
                                ],
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: EdgeInsets.all(24.r),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.indigo[900]!,
                                                Colors.indigo[800]!,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(20.r),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Choose Your Color',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 24.h),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  _buildColorChoice(
                                                    context,
                                                    isWhite: true,
                                                    onSelected: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ChessGamePage(
                                                          timeControl: 10,
                                                          boardStyle: ChessBoardStyle.brown,
                                                          isBotMode: true,
                                                          playerIsWhite: true,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  _buildColorChoice(
                                                    context,
                                                    isWhite: false,
                                                    onSelected: () => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => ChessGamePage(
                                                          timeControl: 10,
                                                          boardStyle: ChessBoardStyle.brown,
                                                          isBotMode: true,
                                                          playerIsWhite: false,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _buildQuickPlayButton(
                                context,
                                title: 'Multiplayer',
                                subtitle: 'Play Friends',
                                icon: Icons.people_rounded,
                                gradient: [
                                  Colors.blue[400]!,
                                  Colors.blue[700]!,
                                ],
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GameLobbyScreen(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Or Choose Time Control',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildTimeControlButton(
                                  context,
                                  minutes: 1,
                                  icon: Icons.bolt,
                                  subtitle: 'Bullet Chess',
                                  gradient: [Colors.orange[700]!, Colors.deepOrange[800]!],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Expanded(
                                child: _buildTimeControlButton(
                                  context,
                                  minutes: 3,
                                  icon: Icons.flash_on,
                                  subtitle: 'Blitz Chess',
                                  gradient: [Colors.blue[600]!, Colors.blue[900]!],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Expanded(
                                child: _buildTimeControlButton(
                                  context,
                                  minutes: 5,
                                  icon: Icons.timer,
                                  subtitle: 'Rapid Chess',
                                  gradient: [Colors.green[600]!, Colors.green[900]!],
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Expanded(
                                child: _buildTimeControlButton(
                                  context,
                                  minutes: 10,
                                  icon: Icons.hourglass_bottom,
                                  subtitle: 'Classical Chess',
                                  gradient: [Colors.purple[600]!, Colors.purple[900]!],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.h),
                  child: Text(
                    'Join thousands of players worldwide in exciting chess matches!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showBoardStyleDialog(BuildContext context, int minutes) async {
    final styles = [
      {
        'style': ChessBoardStyle.brown,
        'name': 'Classic Brown',
        'colors': [Colors.brown[300]!, Colors.brown[600]!],
      },
      {
        'style': ChessBoardStyle.green,
        'name': 'Forest Green',
        'colors': [Colors.green[100]!, Colors.green[800]!],
      },
      {
        'style': ChessBoardStyle.darkBrown,
        'name': 'Dark Wood',
        'colors': [Colors.brown[400]!, Colors.brown[900]!],
      },
      {
        'style': ChessBoardStyle.orange,
        'name': 'Amber Gold',
        'colors': [Colors.orange[200]!, Colors.orange[900]!],
      },
    ];

    final result = await showDialog<ChessBoardStyle>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.indigo[900],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Board Style',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...styles.map((style) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, style['style'] as ChessBoardStyle),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: style['colors'] as List<Color>,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            style['name'] as String,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChessGamePage(
              timeControl: minutes,
              boardStyle: result,
            ),
          ),
        );
      }
    }
  }

  Widget _buildTimeControlButton(
    BuildContext context, {
    required int minutes,
    required IconData icon,
    required String subtitle,
    required List<Color> gradient,
  }) {
    return Hero(
      tag: 'time_control_$minutes',
      child: GestureDetector(
        onTap: () => _showBoardStyleDialog(context, minutes),
        child: Container(
          height: 72.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[1].withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$minutes ${minutes == 1 ? 'Minute' : 'Minutes'}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.9),
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPlayButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Hero(
      tag: 'quick_play_$title',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: gradient[1].withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: Colors.white.withOpacity(1),
                  size: 24.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(1),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title == 'Play Bot' ? 'Try it out!' : subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(1),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorChoice(BuildContext context, {required bool isWhite, required VoidCallback onSelected}) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSelected();
      },
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isWhite ? Colors.white : Colors.black,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person,
              size: 48.sp,
              color: isWhite ? Colors.black : Colors.white,
            ),
            SizedBox(height: 8.h),
            Text(
              isWhite ? 'White' : 'Black',
              style: TextStyle(
                color: isWhite ? Colors.black : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 