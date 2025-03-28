import 'package:flutter/material.dart';
import 'dart:math';

class UnderProductionScreen extends StatefulWidget {
  const UnderProductionScreen({super.key});

  @override
  State<UnderProductionScreen> createState() => _UnderProductionScreenState();
}

class _UnderProductionScreenState extends State<UnderProductionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;
  
  final List<Color> _divineColors = [
    const Color(0xFFE6D5AC), // Royal Gold
    const Color(0xFFF8F1E3), // Divine White
    const Color(0xFF2C1810), // Royal Dark
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: pi * 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              const Color(0xFF2A1F3D),
              const Color(0xFF1A1A2E),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Divine rays
            ...List.generate(36, (index) => _buildDivineRay(index)),
            // Shining particles
            ...List.generate(30, (index) => _buildShiningParticle(index)),
            
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Sacred Halo
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: SweepGradient(
                                    colors: _divineColors,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _divineColors[0].withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Icon
                            Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.7),
                                  border: Border.all(
                                    color: _divineColors[0],
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.extension_rounded,
                                  size: 72,
                                  color: _divineColors[0],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    
                    // Divine Text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: _divineColors,
                      ).createShader(bounds),
                      child: const Text(
                        'Chess Earn',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Text(
                      'UNDER DEVELOPMENT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6D5AC),
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Mystical Message
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _opacityAnimation.value,
                          child: Text(
                            'Crafting your ultimate chess experience',
                            style: TextStyle(
                              fontSize: 18,
                              color: _divineColors[0].withOpacity(0.8),
                              letterSpacing: 0.5,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                    
                    // Divine Progress Indicator
                    _buildDivineProgressIndicator(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivineProgressIndicator() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            return Transform.rotate(
              angle: _rotationAnimation.value + (index * pi / 1.5),
              child: Container(
                width: 60 + (index * 20),
                height: 60 + (index * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _divineColors[index].withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _divineColors[index].withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDivineRay(int index) {
    final angle = (index * pi / 18);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width / 2,
          top: MediaQuery.of(context).size.height / 2,
          child: Transform.rotate(
            angle: angle,
            child: Opacity(
              opacity: _opacityAnimation.value * 0.3,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _divineColors[0].withOpacity(0.5),
                      _divineColors[0].withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiningParticle(int index) {
    final random = index * 0.1;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * (index % 6 / 6),
          top: MediaQuery.of(context).size.height * ((index % 5) / 5),
          child: Transform.translate(
            offset: Offset(
              70 * sin(_controller.value * 2 * pi + random),
              70 * cos(_controller.value * 2 * pi + random),
            ),
            child: Opacity(
              opacity: _opacityAnimation.value * 0.7,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _divineColors[index % 3],
                  boxShadow: [
                    BoxShadow(
                      color: _divineColors[index % 3].withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
