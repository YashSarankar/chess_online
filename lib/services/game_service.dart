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
        'status': 'waiting',
        'time_control': timeControl,
        'created_at': FieldValue.serverTimestamp(),
        'white_time': timeControl * 60,
        'black_time': timeControl * 60,
        'winner': null,
      });
      
      return gameRef.id;
    } catch (e) {
      throw 'Failed to create game: $e';
    }
  }

  // Join an existing game
  Future<void> joinGame(String gameId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw 'User not authenticated';

      final gameDoc = await _firestore.collection('games').doc(gameId).get();
      if (!gameDoc.exists) throw 'Game not found';

      final data = gameDoc.data() as Map<String, dynamic>;
      if (data['player2'] != null) throw 'Game is full';
      if (data['player1'] == userId) throw 'Cannot join your own game';

      await _firestore.collection('games').doc(gameId).update({
        'player2': userId,
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
    required String boardState,
    required String turn,
  }) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'last_move': move,
        'board_state': boardState,
        'turn': turn,
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

  // Listen to game changes
  Stream<DocumentSnapshot> listenToGame(String gameId) {
    return _firestore.collection('games').doc(gameId).snapshots();
  }

  // Update game status
  Future<void> updateGameStatus({
    required String gameId,
    required String status,
    String? winner,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };
      
      if (winner != null) {
        updates['winner'] = winner;
      }
      
      await _firestore.collection('games').doc(gameId).update(updates);
    } catch (e) {
      throw 'Failed to update game status: $e';
    }
  }

  // Update time remaining
  Future<void> updateTime({
    required String gameId,
    required int whiteTime,
    required int blackTime,
  }) async {
    try {
      await _firestore.collection('games').doc(gameId).update({
        'white_time': whiteTime,
        'black_time': blackTime,
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