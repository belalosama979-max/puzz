import 'package:audioplayers/audioplayers.dart';
import 'package:logger/logger.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Manages all sound effects in BuzzMaster.
class AudioService {
  AudioService({this.soundEnabled = true});

  bool soundEnabled;
  final _player = AudioPlayer();

  // Sound asset paths (to be placed in assets/sounds/).
  static const String _buzzSound = 'sounds/buzz.mp3';
  static const String _winnerSound = 'sounds/winner.mp3';
  static const String _lockSound = 'sounds/lock.mp3';
  static const String _openRoundSound = 'sounds/open_round.mp3';
  static const String _errorSound = 'sounds/error.mp3';
  static const String _joinSound = 'sounds/join.mp3';

  Future<void> playBuzz() => _play(_buzzSound);
  Future<void> playWinner() => _play(_winnerSound);
  Future<void> playLock() => _play(_lockSound);
  Future<void> playOpenRound() => _play(_openRoundSound);
  Future<void> playError() => _play(_errorSound);
  Future<void> playJoin() => _play(_joinSound);

  Future<void> _play(String asset) async {
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource(asset));
    } catch (e) {
      _log.w('Failed to play sound $asset: $e');
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
