import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_service.dart';
import 'multiplayer_game_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameLobbyScreen extends StatelessWidget {
  final GameService _gameService = GameService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GameLobbyScreen({super.key});

  void _showCreateGameDialog(BuildContext context) {
    int selectedTime = 10; // Default time control

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
                  'Create New Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Select Time Control',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        _buildTimeOption(
                          context,
                          time: 1,
                          selectedTime: selectedTime,
                          onSelected: (time) {
                            setState(() => selectedTime = time);
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildTimeOption(
                          context,
                          time: 3,
                          selectedTime: selectedTime,
                          onSelected: (time) {
                            setState(() => selectedTime = time);
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildTimeOption(
                          context,
                          time: 5,
                          selectedTime: selectedTime,
                          onSelected: (time) {
                            setState(() => selectedTime = time);
                          },
                        ),
                        SizedBox(height: 8.h),
                        _buildTimeOption(
                          context,
                          time: 10,
                          selectedTime: selectedTime,
                          onSelected: (time) {
                            setState(() => selectedTime = time);
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final userId = _auth.currentUser?.uid;
                        if (userId != null) {
                          final gameId = await _gameService.createGame(
                            creatorId: userId,
                            timeControl: selectedTime,
                          );
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiplayerGameScreen(
                                  gameId: gameId,
                                  isCreator: true,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 12.h,
                        ),
                        backgroundColor: Colors.blue[700],
                      ),
                      child: Text(
                        'Create Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
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
  }

  Widget _buildTimeOption(
    BuildContext context, {
    required int time,
    required int selectedTime,
    required Function(int) onSelected,
  }) {
    final isSelected = time == selectedTime;
    return GestureDetector(
      onTap: () => onSelected(time),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue[700]!.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? Colors.blue[700]!
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$time ${time == 1 ? 'Minute' : 'Minutes'}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue[700],
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Game Lobby',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _gameService.getAvailableGames(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No games available.\nCreate one to start playing!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16.sp,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final game = snapshot.data!.docs[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              'Game #${game.id.substring(0, 6)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Time Control: ${game['time_control']} minutes',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14.sp,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await _gameService.joinGame(game.id);
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MultiplayerGameScreen(
                                        gameId: game.id,
                                        isCreator: false,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                              child: Text(
                                'Join Game',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGameDialog(context),
        backgroundColor: Colors.blue[700],
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
    );
  }
} 