import 'package:chess_online/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chess_online/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show pi, cos, sin;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 3)); // Show splash for 3 seconds

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null ? const MainScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Stack(
            children: [
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
                        opacity: (1 - value) * 0.5,
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
              
              // Divine rays
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        Transform.rotate(
                          angle: _controller.value * 2 * pi,
                          child: Container(
                            width: 300.w,
                            height: 300.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Inner counter-rotating ring
                        Transform.rotate(
                          angle: -_controller.value * pi,
                          child: Container(
                            width: 200.w,
                            height: 200.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + 0.2 * sin(_controller.value * 2 * pi),
                          child: Icon(
                            Icons.auto_awesome,
                            color: Colors.white.withOpacity(0.3),
                            size: 40.sp,
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    // Enhanced Logo with smooth rotating rings
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer rotating ring
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _controller.value * 2 * pi,
                              child: Container(
                                width: 160.w,
                                height: 160.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Middle rotating ring
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: -_controller.value * 2 * pi,
                              child: Container(
                                width: 150.w,
                                height: 150.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Main logo container with smooth pulse
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + 0.05 * sin(_controller.value * 4 * pi),
                              child: Container(
                                width: 140.w,
                                height: 140.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.blue[400]!,
                                      Colors.purple[400]!,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue[400]!.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                    BoxShadow(
                                      color: Colors.purple[400]!.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.sports_esports,
                                  size: 70.sp,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ).animate()
                     .fadeIn(duration: const Duration(milliseconds: 800))
                     .scale(delay: const Duration(milliseconds: 400)),

                    SizedBox(height: 40.h),

                    // Enhanced App Name with divine glow
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white.withOpacity(0.1)),
                          bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                      ),
                      child: Text(
                        'CHESS TIME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.blue[400]!.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                            Shadow(
                              color: Colors.purple[400]!.withOpacity(0.5),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                    ).animate()
                     .fadeIn(delay: const Duration(milliseconds: 400))
                     .slideY(begin: 0.3, end: 0),

                    SizedBox(height: 16.h),

                    // Enhanced Tagline
                    Text(
                      'MASTER • COMPETE • CONQUER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16.sp,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.blue[400]!.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ).animate()
                     .fadeIn(delay: const Duration(milliseconds: 600))
                     .slideY(begin: 0.3, end: 0),

                    SizedBox(height: 48.h),

                    // Enhanced loading indicator with smooth rotation
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _controller.value * 4 * pi,
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
                                strokeWidth: 3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final double animationValue;

  ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 70; i++) {
      final x = (size.width * (i * 0.1 + animationValue)) % size.width;
      final y = (size.height * (i * 0.1 + animationValue)) % size.height;
      canvas.drawCircle(Offset(x, y), 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => 
      animationValue != oldDelegate.animationValue;
}

// New divine light rays painter
class LightRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width));

    for (var i = 0; i < 12; i++) {
      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.lineTo(
        center.dx + cos(i * pi / 6) * size.width,
        center.dy + sin(i * pi / 6) * size.height,
      );
      path.lineTo(
        center.dx + cos((i + 0.5) * pi / 6) * size.width,
        center.dy + sin((i + 0.5) * pi / 6) * size.height,
      );
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 