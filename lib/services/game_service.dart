import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new game
  Future<String> createGame({
    required String creatorId,
    required int timeControl,
  }) async {
    try {
      final gameRef = _firestore.collection('games').doc();
      
      await gameRef.set({
        'player1': creatorId,
        'player2': null,
        'board_state': 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR',
        'turn': 'white',
        'last_move': null,
        'winner': null,
        'status': 'waiting', // waiting, active, completed
        'created_at': FieldValue.serverTimestamp(),
        'time_control': timeControl,
        'player1_time': timeControl * 60,
        'player2_time': timeControl * 60,
        'last_move_time': FieldValue.serverTimestamp(),
      });

      return gameRef.id;
    } catch (e) {
      throw 'Failed to create game: $e';
    }
  }

  // Join an existing game
  Future<void> joinGame(String gameId) async {
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) throw 'User not authenticated';

      await _firestore.collection('games').doc(gameId).update({
        'player2': currentUserId,
        'status': 'active',
      });
    } catch (e) {
      throw 'Failed to join game: $e';
    }
  }

  // Make a move
  Future<void> makeMove({
    required String gameId,
    required String move,
    required String newBoardState,
    required String currentTurn,
  }) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'last_move': move,
        'board_state': newBoardState,
        'turn': currentTurn == 'white' ? 'black' : 'white',
        'last_move_time': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to make move: $e';
    }
  }

  // Get available games
  Stream<QuerySnapshot> getAvailableGames() {
    return _firestore
        .collection('games')
        .where('status', isEqualTo: 'waiting')
        .where('player2', isNull: true)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  // Listen to specific game
  Stream<DocumentSnapshot> listenToGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  // End game
  Future<void> endGame({
    required String gameId,
    required String winnerId,
  }) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'status': 'completed',
        'winner': winnerId,
      });
    } catch (e) {
      throw 'Failed to end game: $e';
    }
  }

  // Update player time
  Future<void> updatePlayerTime({
    required String gameId,
    required String playerId,
    required int timeLeft,
  }) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      final data = gameDoc.data() as Map<String, dynamic>;
      
      final String timeField = data['player1'] == playerId ? 'player1_time' : 'player2_time';
      
      await _firestore.collection('games').doc(gameId).update({
        timeField: timeLeft,
      });
    } catch (e) {
      throw 'Failed to update time: $e';
    }
  }

  // Resign game
  Future<void> resignGame({
    required String gameId,
    required String resigningPlayerId,
  }) async {
    try {
      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      final data = gameDoc.data() as Map<String, dynamic>;
      
      final winnerId = data['player1'] == resigningPlayerId ? data['player2'] : data['player1'];
      
      await _firestore.collection('games').doc(gameId).update({
        'status': 'completed',
        'winner': winnerId,
      });
    } catch (e) {
      throw 'Failed to resign game: $e';
    }
  }
} 