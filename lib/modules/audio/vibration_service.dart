import 'package:vibration/vibration.dart';
import 'package:logger/logger.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Manages haptic feedback patterns.
class VibrationService {
  VibrationService({this.vibrationEnabled = true});

  bool vibrationEnabled;

  /// Short tap – buzz pressed.
  Future<void> buzzTap() => _vibrate([0, 80]);

  /// Win pattern – long celebratory vibration.
  Future<void> winPattern() => _vibrate([0, 200, 100, 200, 100, 400]);

  /// Lose pattern – two short pulses.
  Future<void> losePattern() => _vibrate([0, 60, 80, 60]);

  /// Locked pattern – single short.
  Future<void> lockedPattern() => _vibrate([0, 40]);

  /// Error pattern – rapid double.
  Future<void> errorPattern() => _vibrate([0, 100, 50, 100]);

  Future<void> _vibrate(List<int> pattern) async {
    if (!vibrationEnabled) return;
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (!hasVibrator) return;
      await Vibration.vibrate(pattern: pattern);
    } catch (e) {
      _log.w('Vibration error: $e');
    }
  }
}
