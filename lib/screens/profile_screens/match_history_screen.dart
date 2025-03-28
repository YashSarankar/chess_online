import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

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
                      'Match History',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('matches')
                          .where('players', arrayContains: user?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final totalMatches = snapshot.data?.docs.length ?? 0;
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '$totalMatches Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate()
                         .fadeIn(duration: const Duration(milliseconds: 500))
                         .scale(delay: const Duration(milliseconds: 200));
                      },
                    ),
                  ],
                ),
              ),

              // Match History List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('matches')
                      .where('players', arrayContains: user?.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_esports,
                              color: Colors.white.withOpacity(0.5),
                              size: 64.sp,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No matches played yet',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final match = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        final timestamp = (match['timestamp'] as Timestamp).toDate();
                        final winner = match['winner'];
                        final opponent = match['players']
                            .firstWhere((id) => id != user?.uid, orElse: () => 'Unknown');

                        return FutureBuilder<DocumentSnapshot>(
                          future: firestore.collection('users').doc(opponent).get(),
                          builder: (context, opponentSnapshot) {
                            final opponentName = opponentSnapshot.data?.get('name') ?? 'Unknown Player';
                            final isWinner = winner == user?.uid;
                            
                            return _buildMatchCard(
                              opponentName: opponentName,
                              isWinner: isWinner,
                              timestamp: timestamp,
                              moveCount: match['moves']?.length ?? 0,
                            ).animate()
                             .fadeIn(duration: const Duration(milliseconds: 500))
                             .slideX(
                               begin: -0.2,
                               end: 0,
                               delay: Duration(milliseconds: 100 * index),
                             );
                          },
                        );
                      },
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

  Widget _buildMatchCard({
    required String opponentName,
    required bool isWinner,
    required DateTime timestamp,
    required int moveCount,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWinner
                ? [Colors.green[700]!, Colors.green[900]!]
                : [Colors.red[700]!, Colors.red[900]!],
          ),
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: (isWinner ? Colors.green : Colors.red).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                  isWinner ? Icons.emoji_events : Icons.close,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isWinner ? 'Won against' : 'Lost to',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          opponentName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.7),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          DateFormat('MMM d, y • h:mm a').format(timestamp),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Icon(
                          Icons.swap_horiz,
                          color: Colors.white.withOpacity(0.7),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '$moveCount moves',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
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