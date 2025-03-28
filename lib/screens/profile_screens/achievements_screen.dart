import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';  // Add this import for ImageFilter

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

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
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Achievements',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<DocumentSnapshot>(
                      stream: firestore.collection('users').doc(user?.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                        final totalAchievements = userData['achievements']?.length ?? 0;
                        
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.amber,
                                size: 20.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '$totalAchievements/12',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate()
                         .fadeIn(duration: const Duration(milliseconds: 500))
                         .scale(delay: const Duration(milliseconds: 200));
                      },
                    ),
                  ],
                ),
              ),

              // Achievements List
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestore.collection('users').doc(user?.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    final userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                    final achievements = userData['achievements'] as List<dynamic>? ?? [];

                    return ListView(
                      padding: EdgeInsets.all(16.w),
                      children: [
                        _buildAchievementCard(
                          title: 'First Victory',
                          description: 'Win your first chess game',
                          icon: Icons.military_tech,
                          isUnlocked: achievements.contains('first_victory'),
                        ),
                        _buildAchievementCard(
                          title: 'Quick Thinker',
                          description: 'Win a game in under 10 moves',
                          icon: Icons.bolt,
                          isUnlocked: achievements.contains('quick_win'),
                        ),
                        _buildAchievementCard(
                          title: 'Winning Streak',
                          description: 'Win 3 games in a row',
                          icon: Icons.local_fire_department,
                          isUnlocked: achievements.contains('winning_streak'),
                        ),
                        _buildAchievementCard(
                          title: 'Grandmaster',
                          description: 'Win 50 games',
                          icon: Icons.workspace_premium,
                          isUnlocked: achievements.contains('grandmaster'),
                        ),
                        _buildAchievementCard(
                          title: 'Checkmate Master',
                          description: 'Win with a checkmate in 5 different ways',
                          icon: Icons.psychology,
                          isUnlocked: achievements.contains('checkmate_master'),
                        ),
                        _buildAchievementCard(
                          title: 'Social Butterfly',
                          description: 'Play against 10 different opponents',
                          icon: Icons.people,
                          isUnlocked: achievements.contains('social_butterfly'),
                        ),
                      ].animate(interval: const Duration(milliseconds: 100))
                       .fadeIn(duration: const Duration(milliseconds: 500))
                       .slideX(begin: -0.2, end: 0),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isUnlocked,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isUnlocked
                ? [
                    Colors.blue[400]!,
                    Colors.purple[400]!,
                  ]
                : [
                    Colors.grey[800]!,
                    Colors.grey[900]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? Colors.blue[400]!.withOpacity(0.3)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      icon,
                      color: isUnlocked ? Colors.amber : Colors.grey,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isUnlocked)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[300],
                      size: 24.sp,
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(
                       duration: const Duration(seconds: 2),
                       color: Colors.white.withOpacity(0.2),
                     ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 