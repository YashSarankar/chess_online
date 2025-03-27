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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
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
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => _showJoinGameDialog(context),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                backgroundColor: Colors.green[700],
              ),
              child: Text(
                'Join Game',
                style: TextStyle(fontSize: 18.sp),
              ),
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

  void _showJoinGameDialog(BuildContext context) {
    final TextEditingController gameIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Game'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the game code:'),
              SizedBox(height: 16.h),
              TextField(
                controller: gameIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter game code',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _gameService.joinGame(gameIdController.text);
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MultiplayerGameScreen(
                          gameId: gameIdController.text,
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
          ],
        );
      },
    );
  }
} 