import 'dart:async';

/// A pauseable countdown timer with stream-based updates.
///
/// Emits remaining milliseconds every tick.
class TimerEngine {
  Timer? _ticker;
  int _remainingMs = 0;
  int _totalMs = 0;
  bool _running = false;
  bool _paused = false;

  final _tickController = StreamController<int>.broadcast();
  final _expiredController = StreamController<void>.broadcast();

  /// Stream of remaining milliseconds.
  Stream<int> get onTick => _tickController.stream;

  /// Emits when the timer reaches zero.
  Stream<void> get onExpired => _expiredController.stream;

  bool get isRunning => _running;
  bool get isPaused => _paused;
  int get remainingMs => _remainingMs;
  int get totalMs => _totalMs;

  /// Start a countdown timer for [durationMs] milliseconds.
  void start(int durationMs) {
    stop();
    _totalMs = durationMs;
    _remainingMs = durationMs;
    _running = true;
    _paused = false;
    _startTicking();
  }

  void _startTicking() {
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_paused || !_running) return;
      _remainingMs -= 50;
      if (_remainingMs <= 0) {
        _remainingMs = 0;
        _running = false;
        _ticker?.cancel();
        _tickController.add(0);
        _expiredController.add(null);
      } else {
        _tickController.add(_remainingMs);
      }
    });
  }

  void pause() {
    if (!_running) return;
    _paused = true;
  }

  void resumeTimer() {
    if (!_running) return;
    _paused = false;
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
    _running = false;
    _paused = false;
    _remainingMs = 0;
  }

  void dispose() {
    stop();
    _tickController.close();
    _expiredController.close();
  }
}
