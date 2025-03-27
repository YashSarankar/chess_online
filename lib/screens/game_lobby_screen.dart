import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/game_service.dart';
import 'multiplayer_game_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'waiting_screen.dart';

class GameLobbyScreen extends StatelessWidget {
  final GameService _gameService = GameService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GameLobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Lobby'),
        backgroundColor: Colors.indigo[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.h),
            child: ElevatedButton(
              onPressed: () => _showCreateGameDialog(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                backgroundColor: Colors.indigo[700],
              ),
              child: Text(
                'Create New Game',
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('games')
                  .where('status', isEqualTo: 'waiting')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final games = snapshot.data!.docs;
                if (games.isEmpty) {
                  return const Center(child: Text('No games available'));
                }

                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index].data() as Map<String, dynamic>;
                    final gameId = games[index].id;
                    final creatorName = game['player1_name'] ?? 'Anonymous';
                    final timeControl = game['time_control'] ?? 10;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: ListTile(
                        title: Text('Game by $creatorName'),
                        subtitle: Text('Time Control: $timeControl minutes'),
                        trailing: ElevatedButton(
                          onPressed: () async {
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
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            }
                          },
                          child: const Text('Join'),
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
    );
  }

  void _showCreateGameDialog(BuildContext context) {
    int selectedTime = 10;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Game'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Select Time Control:'),
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
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
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
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
} 