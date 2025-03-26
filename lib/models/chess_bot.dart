import 'package:chess/chess.dart' as chess;
import 'package:stockfish/stockfish.dart' as sf;

enum BotDifficulty {
  easy,    // Depth 1-2
  medium,  // Depth 3-4
  hard,    // Depth 5-6
  expert   // Depth 8-10
}

class ChessBot {
  late final sf.Stockfish _stockfish;
  bool _isReady = false;
  BotDifficulty _difficulty;

  ChessBot({BotDifficulty difficulty = BotDifficulty.medium}) 
      : _difficulty = difficulty {
    // Remove the direct call to async method
  }

  // Create a static factory constructor instead
  static Future<ChessBot> create({BotDifficulty difficulty = BotDifficulty.medium}) async {
    final bot = ChessBot(difficulty: difficulty);
    await bot._initializeEngine();
    return bot;
  }

  Future<void> _initializeEngine() async {
    _stockfish = sf.Stockfish();
    _stockfish.stdin = 'uci\n';
    _stockfish.stdin = 'isready\n';
    _isReady = true;
  }

  int _getSearchDepth() {
    switch (_difficulty) {
      case BotDifficulty.easy:
        return 2;
      case BotDifficulty.medium:
        return 4;
      case BotDifficulty.hard:
        return 6;
      case BotDifficulty.expert:
        return 10;
    }
  }

  Future<Map<String, String>?> calculateNextMove(chess.Chess game) async {
    if (!_isReady) {
      await _initializeEngine();
    }

    _stockfish.stdin = 'position fen ${game.fen}\n';
    _stockfish.stdin = 'go depth ${_getSearchDepth()}\n';

    String? bestMove;
    await for (final line in _stockfish.stdout) {
      if (line.startsWith('bestmove')) {
        bestMove = line.split(' ')[1];
        break;
      }
    }

    if (bestMove == null || bestMove == '(none)') return null;

    // Convert bestMove to from/to format
    return {
      'from': bestMove.substring(0, 2),
      'to': bestMove.substring(2, 4),
      if (bestMove.length > 4) 'promotion': bestMove[4],
    };
  }

  void setDifficulty(BotDifficulty difficulty) {
    _difficulty = difficulty;
  }

  Future<void> dispose() async {
    if (_isReady) {
      _stockfish.dispose();
      _isReady = false;
    }
  }
} 