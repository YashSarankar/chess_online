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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // Animated background
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
          // Particle effect overlay
          CustomPaint(
            painter: ParticlePainter(),
            size: Size.infinite,
          ),
          // Main content
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
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '♔',
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: Colors.white.withOpacity(0.95),
                                shadows: [
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Chess Time',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.95),
                                letterSpacing: 1.2,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.logout_outlined,color: Colors.white,),
                              onPressed: () => showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.7),
                                builder: (context) => BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                  child: Dialog(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(24.r),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.indigo[900]!.withOpacity(0.95),
                                            Colors.purple[900]!.withOpacity(0.95),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(16.r),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red[400]!.withOpacity(0.2),
                                            ),
                                            child: Icon(
                                              Icons.logout_rounded,
                                              color: Colors.red[400],
                                              size: 32.sp,
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                          Text(
                                            'Confirm Logout',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            'Are you sure you want to leave?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    backgroundColor: Colors.white.withOpacity(0.1),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12.r),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                  setState(() {
                                                    AuthService().signOut();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => const LoginScreen(),
                                                      ),
                                                    );
                                                  });
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    backgroundColor: Colors.red[400],
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12.r),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Logout',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
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
                      'Choose your preferred time control to start playing',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: -5,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
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
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12.sp,
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

class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Create a static chess-themed particle pattern
    for (var i = 0; i < 50; i++) {
      final x = (i * size.width / 50);
      final y = (i * size.height / 50);
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 