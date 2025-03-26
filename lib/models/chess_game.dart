import 'package:chess/chess.dart' as chess;
import 'package:flutter_chess_board/flutter_chess_board.dart';

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
} 