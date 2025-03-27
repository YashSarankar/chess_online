import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChessGameWidgets {
  static Widget buildCustomAppBar({
    required String title,
    required String subtitle,
    required VoidCallback onBackPressed,
    required List<Widget> actions,
  }) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
            onPressed: onBackPressed,
          ),
          Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          Row(children: actions),
        ],
      ),
    );
  }

  static Widget buildPlayerInfo({
    required bool isWhite,
    required int timeLeft,
    required bool isCurrentTurn,
    required String playerName,
    required Animation<double> pulseAnimation,
    required List<String> capturedPieces,
  }) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final glowOpacity = isCurrentTurn ? 
            0.3 + (0.2 * pulseAnimation.value) : 
            0.0;
            
        return Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: 10.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isCurrentTurn 
                      ? Colors.blue.withOpacity(0.15)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isCurrentTurn 
                        ? Colors.blue.withOpacity(0.5) 
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isCurrentTurn ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(glowOpacity),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.r),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: isWhite ? Colors.white : Colors.black,
                            child: Icon(
                              Icons.person,
                              size: 20.sp,
                              color: isWhite ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerName,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                                fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isCurrentTurn)
                              Text(
                                'Your turn',
                                style: TextStyle(
                                  color: Colors.blue.withOpacity(0.9),
                                  fontSize: 12.sp,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    buildTimer(timeLeft, isCurrentTurn),
                  ],
                ),
              ),
              buildCapturedPieces(capturedPieces),
            ],
          ),
        );
      },
    );
  }

  static Widget buildTimer(int timeLeft, bool isCurrentTurn) {
    final isLowTime = timeLeft < 30;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: isLowTime 
            ? Colors.red.withOpacity(0.1) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLowTime 
              ? Colors.red.withOpacity(0.5) 
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Text(
        formatTime(timeLeft),
        style: TextStyle(
          color: isLowTime 
              ? Colors.red 
              : Colors.white.withOpacity(0.9),
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto Mono',
        ),
      ),
    );
  }

  static Widget buildCapturedPieces(List<String> pieces) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: pieces.isEmpty 
          ? [
              Text(
                '---',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 20.sp,
                ),
              ),
            ]
          : pieces.map((piece) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  getPieceSymbol(piece),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  static Widget buildDialogButton(
    String text,
    IconData icon,
    MaterialColor color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String getPieceSymbol(String piece) {
    final Map<String, String> symbols = {
      'wp': '♙', 'wr': '♖', 'wn': '♘', 'wb': '♗', 'wq': '♕', 'wk': '♔',
      'bp': '♟', 'br': '♜', 'bn': '♞', 'bb': '♝', 'bq': '♛', 'bk': '♚',
    };
    return symbols[piece] ?? '';
  }
} 