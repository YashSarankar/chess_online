import 'package:chess_online/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_service.dart';
import 'multiplayer_game_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_animations/simple_animations.dart';

class GameLobbyScreen extends StatelessWidget {
  final GameService _gameService = GameService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, bool> _joiningGames = {};

  GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Chess Arena',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 26.sp,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo[900]!,
              Colors.indigo[800]!,
              Colors.deepPurple[700]!,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Replace network image with a custom pattern
            Positioned.fill(
              child: CustomPaint(
                painter: ChessPatternPainter(),
              ),
            ),
            Column(
              children: [
                SizedBox(height: kToolbarHeight + 20.h),
                // Create Game Button
                PlayAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutQuad,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.white.withOpacity(0.9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showCreateGameDialog(context),
                              borderRadius: BorderRadius.circular(15.r),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 28.sp,
                                      color: Colors.indigo[900],
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Create New Game',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.indigo[900],
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Games List Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Row(
                    children: [
                      Text(
                        'Available Games',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Pull to refresh',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Games List
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.indigo[700],
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('games')
                          .where('status', isEqualTo: 'waiting')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print('Error fetching games: ${snapshot.error}');
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          );
                        }

                        final allGames = snapshot.data!.docs;
                        final games = allGames.where((doc) {
                          final game = doc.data() as Map<String, dynamic>;
                          return game['player2'] == null && 
                                 game['game_over'] != true &&
                                 game['status'] == 'waiting' &&
                                 game['player1'] != _auth.currentUser?.uid &&
                                 game['player2'] != _auth.currentUser?.uid;
                        }).toList();
                        
                        games.sort((a, b) {
                          final aTime = (a.data() as Map<String, dynamic>)['created_at'];
                          final bTime = (b.data() as Map<String, dynamic>)['created_at'];
                          if (aTime == null || bTime == null) return 0;
                          return bTime.compareTo(aTime);
                        });
                        
                        print('Found ${games.length} available games');
                        if (games.isEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 100.h),
                                  child: Text(
                                    'No active games\nBe the first to create one!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index].data() as Map<String, dynamic>;
                            final gameId = games[index].id;
                            final creatorName = game['player1_name'] ?? 'Anonymous';
                            final timeControl = game['time_control'] ?? 10;

                            return PlayAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              curve: Curves.easeOutQuad,
                              builder: (context, value, child) {
                                return Transform.translate(
                                  offset: Offset(0, 50 * (1 - value)),
                                  child: Opacity(
                                    opacity: value,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8.h),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.white.withOpacity(0.95),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12.r),
                                          onTap: () => _joinGame(context, gameId),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8.r),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Colors.indigo[700]!,
                                                        Colors.indigo[900]!,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.indigo.withOpacity(0.2),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                    size: 20.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        creatorName,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15.sp,
                                                          color: Colors.indigo[900],
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(
                                                              horizontal: 8.w,
                                                              vertical: 4.h,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: Colors.indigo[50],
                                                              borderRadius: BorderRadius.circular(6.r),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                  Icons.timer_outlined,
                                                                  size: 14.sp,
                                                                  color: Colors.indigo[700],
                                                                ),
                                                                SizedBox(width: 4.w),
                                                                Text(
                                                                  '$timeControl min',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors.indigo[700],
                                                                    fontSize: 13.sp,
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: _joiningGames[gameId] == true
                                                      ? null
                                                      : () => _joinGame(context, gameId),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.indigo[700],
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 16.w,
                                                      vertical: 8.h,
                                                    ),
                                                    elevation: 2,
                                                    shadowColor: Colors.indigo.withOpacity(0.3),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8.r),
                                                    ),
                                                    minimumSize: Size(80.w, 32.h),
                                                  ),
                                                  child: _joiningGames[gameId] == true
                                                      ? SizedBox(
                                                          height: 20.h,
                                                          width: 20.w,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                          ),
                                                        )
                                                      : Text(
                                                          'Join',
                                                          style: GoogleFonts.poppins(
                                                            fontWeight: FontWeight.w600,
                                                            fontSize: 13.sp,
                                                          ),
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGameDialog(BuildContext context) {
    int selectedTime = 10;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          title: Text(
            'Create New Game',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          content: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
                      child: Text(
                        'Select Time Control:',
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('1 Minute'),
                      leading: Radio<int>(
                        value: 1,
                        groupValue: selectedTime,
                        onChanged: (int? value) {
                          setState(() => selectedTime = value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('3 Minutes'),
                      leading: Radio<int>(
                        value: 3,
                        groupValue: selectedTime,
                        onChanged: (int? value) {
                          setState(() => selectedTime = value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('5 Minutes'),
                      leading: Radio<int>(
                        value: 5,
                        groupValue: selectedTime,
                        onChanged: (int? value) {
                          setState(() => selectedTime = value!);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('10 Minutes'),
                      leading: Radio<int>(
                        value: 10,
                        groupValue: selectedTime,
                        onChanged: (int? value) {
                          setState(() => selectedTime = value!);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    final gameId = await _gameService.createGame(
                      creatorId: userId,
                      timeControl: selectedTime,
                    );
                    await FirebaseFirestore.instance
                        .collection('games')
                        .doc(gameId)
                        .update({
                      'status': 'waiting',
                      'player2': null,
                      'created_at': FieldValue.serverTimestamp(),
                    });
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WaitingScreen(gameId: gameId),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _joinGame(BuildContext context, String gameId) async {
    _joiningGames[gameId] = true;
    
    try {
      await _gameService.joinGame(gameId);

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiplayerGameScreen(
              gameId: gameId,
              isCreator: false,
            ),
          ),
        );
      }
    } catch (e) {
      _joiningGames[gameId] = false;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join game: ${e.toString()}'),
            backgroundColor: Colors.red[400],
          ),
        );
      }
    }
  }
}

// Add this custom painter class at the bottom of the file
class ChessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final squareSize = size.width / 15; // Adjust the division factor to change pattern density

    for (var i = 0; i < size.width; i += squareSize.toInt()) {
      for (var j = 0; j < size.height; j += squareSize.toInt()) {
        if ((i + j) ~/ squareSize % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i.toDouble(), j.toDouble(), squareSize, squareSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
} 