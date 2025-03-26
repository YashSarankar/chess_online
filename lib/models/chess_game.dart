import 'package:chess/chess.dart' as chess;
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'dart:math' as math;

enum GameStatus {
  ongoing,
  checkmate,
  draw
}

class ChessGame {
  final chess.Chess _chess = chess.Chess();
  PlayerColor currentTurn = PlayerColor.white;
  List<Map<String, dynamic>> moveHistory = [];
  int currentMoveIndex = -1;
  String? _lastCapturedPiece;
  List<Map<String, dynamic>> capturedPieceHistory = [];
  bool isBotMode = false;
  bool playerIsWhite = true;

  static const Map<String, int> pieceValues = {
    'p': 100,   // pawn
    'n': 320,   // knight
    'b': 330,   // bishop
    'r': 500,   // rook
    'q': 900,   // queen
    'k': 20000, // king
  };

  static const List<List<int>> pawnPositionWeights = [
    [0,  0,  0,  0,  0,  0,  0,  0],
    [50, 50, 50, 50, 50, 50, 50, 50],
    [10, 10, 20, 30, 30, 20, 10, 10],
    [5,  5, 10, 25, 25, 10,  5,  5],
    [0,  0,  0, 20, 20,  0,  0,  0],
    [5, -5,-10,  0,  0,-10, -5,  5],
    [5, 10, 10,-20,-20, 10, 10,  5],
    [0,  0,  0,  0,  0,  0,  0,  0]
  ];

  bool get isCheckmate => _chess.in_checkmate;
  bool get isDraw => _chess.in_draw;
  PlayerColor get winner => currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
  bool get isInCheckmate => _chess.in_checkmate;

  void makeMove(String move) {
    final targetSquare = move.substring(2, 4);
    _lastCapturedPiece = _chess.get(targetSquare)?.color == Color.WHITE ? 
      'w${_chess.get(targetSquare)?.type.name.toLowerCase()}' :
      'b${_chess.get(targetSquare)?.type.name.toLowerCase()}';
    _chess.move(move);
    _addToHistory();
    toggleTurn();
  }

  void makeMoveFromTo(String from, String to) {
    _lastCapturedPiece = _chess.get(to)?.color == Color.WHITE ?
      'w${_chess.get(to)?.type.name.toLowerCase()}' :
      'b${_chess.get(to)?.type.name.toLowerCase()}';
    
    _chess.move({'from': from, 'to': to});
    _addToHistory();
    toggleTurn();
  }

  void _addToHistory() {
    if (currentMoveIndex < moveHistory.length - 1) {
      moveHistory = moveHistory.sublist(0, currentMoveIndex + 1);
      capturedPieceHistory = capturedPieceHistory.sublist(0, currentMoveIndex + 1);
    }
    moveHistory.add({
      'fen': _chess.fen,
      'turn': currentTurn,
    });
    capturedPieceHistory.add({
      'piece': _lastCapturedPiece,
    });
    currentMoveIndex++;
  }

  bool canUndo() => currentMoveIndex > -1;
  bool canRedo() => currentMoveIndex < moveHistory.length - 1;

  void undo() {
    if (canUndo()) {
      currentMoveIndex--;
      if (currentMoveIndex >= 0) {
        _chess.load(moveHistory[currentMoveIndex]['fen']);
        currentTurn = moveHistory[currentMoveIndex]['turn'];
      } else {
        _chess.reset();
        currentTurn = PlayerColor.white;
      }
    }
  }

  void redo() {
    if (canRedo()) {
      currentMoveIndex++;
      _chess.load(moveHistory[currentMoveIndex]['fen']);
      currentTurn = moveHistory[currentMoveIndex]['turn'];
    }
  }

  void toggleTurn() {
    currentTurn = currentTurn == PlayerColor.white ? PlayerColor.black : PlayerColor.white;
  }

  List<String> getLegalMoves(String square) {
    List<String> destinations = [];
    var moves = _chess.moves({
      'square': square,
      'verbose': true
    });

    for (var move in moves) {
      if (move is Map) {
        destinations.add(move['to']);
      }
    }
    return destinations;
  }

  void reset() {
    _chess.reset();
    currentTurn = PlayerColor.white;
    moveHistory.clear();
    capturedPieceHistory.clear();
    currentMoveIndex = -1;
    _lastCapturedPiece = null;
  }

  String getFen() => _chess.fen;

  String? getCapturedPiece() {
    return _lastCapturedPiece;
  }

  bool isPawnPromotion(String from, String to) {
    var piece = _chess.get(from);
    return piece?.type == chess.PieceType.PAWN && 
           (to[1] == '8' || to[1] == '1');
  }

  void makePromotionMove(String from, String to, String promotionPiece) {
    _lastCapturedPiece = _chess.get(to)?.color == Color.WHITE ? 
      'w${_chess.get(to)?.type.name.toLowerCase()}' :
      'b${_chess.get(to)?.type.name.toLowerCase()}';
    
    _chess.move({
      'from': from,
      'to': to,
      'promotion': promotionPiece,
    });
    _addToHistory();
    toggleTurn();
  }

  List<String> getCapturedPiecesUpToCurrentMove() {
    List<String> pieces = [];
    for (int i = 0; i <= currentMoveIndex; i++) {
      if (capturedPieceHistory[i]['piece'] != null) {
        pieces.add(capturedPieceHistory[i]['piece']!);
      }
    }
    return pieces;
  }

  GameStatus getGameStatus() {
    if (_chess.in_checkmate) {
      return GameStatus.checkmate;
    } else if (_chess.in_draw) {
      return GameStatus.draw;
    }
    return GameStatus.ongoing;
  }

  String? getBotMove() {
    if (!isBotMode) return null;
    
    var moves = _chess.moves({ 'verbose': true });
    if (moves.isEmpty) return null;

    Map<String, dynamic>? bestMove;
    int bestScore = -999999;
    
    for (var move in moves) {
      _chess.move(move);
      
      int score = -evaluatePosition();
      
      _chess.undo();
      
      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }
    
    if (bestMove != null) {
      return {
        'from': bestMove['from'],
        'to': bestMove['to'],
        'promotion': bestMove['promotion'],
      }.toString();
    }
    return null;
  }

  int evaluatePosition() {
    int score = 0;
    
    for (int rank = 0; rank < 8; rank++) {
      for (int file = 0; file < 8; file++) {
        final square = String.fromCharCode('a'.codeUnitAt(0) + file) + (8 - rank).toString();
        final piece = _chess.get(square);
        
        if (piece != null) {
          int materialValue = pieceValues[piece.type.name.toLowerCase()] ?? 0;
          
          int positionValue = 0;
          if (piece.type == chess.PieceType.PAWN) {
            positionValue = piece.color == chess.Color.WHITE ? 
              pawnPositionWeights[rank][file] :
              pawnPositionWeights[7-rank][file];
          }
          
          int value = materialValue + positionValue;
          score += piece.color == chess.Color.WHITE ? value : -value;
          
          if (piece.type == chess.PieceType.PAWN) {
            if (_isDoubledPawn(file, piece.color)) {
              score += piece.color == chess.Color.WHITE ? -20 : 20;
            }
            if (_isIsolatedPawn(file, piece.color)) {
              score += piece.color == chess.Color.WHITE ? -10 : 10;
            }
          }
        }
      }
    }
    
    return score;
  }

  bool _isDoubledPawn(int file, chess.Color color) {
    int pawnCount = 0;
    for (int rank = 0; rank < 8; rank++) {
      final square = String.fromCharCode('a'.codeUnitAt(0) + file) + (rank + 1).toString();
      final piece = _chess.get(square);
      if (piece != null && 
          piece.type == chess.PieceType.PAWN && 
          piece.color == color) {
        pawnCount++;
      }
    }
    return pawnCount > 1;
  }

  bool _isIsolatedPawn(int file, chess.Color color) {
    bool hasNeighborPawn = false;
    
    for (int f = math.max(0, file - 1); f <= math.min(7, file + 1); f++) {
      if (f == file) continue;
      
      for (int rank = 0; rank < 8; rank++) {
        final square = String.fromCharCode('a'.codeUnitAt(0) + f) + (rank + 1).toString();
        final piece = _chess.get(square);
        if (piece != null && 
            piece.type == chess.PieceType.PAWN && 
            piece.color == color) {
          hasNeighborPawn = true;
          break;
        }
      }
    }
    
    return !hasNeighborPawn;
  }

  void setBotMode(bool enabled) {
    isBotMode = enabled;
  }

  void setPlayerColor(bool isWhite) {
    playerIsWhite = isWhite;
  }

  bool canMakeMove() {
    return !isBotMode || (currentTurn == PlayerColor.white) == playerIsWhite;
  }
} 