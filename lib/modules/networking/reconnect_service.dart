import 'dart:async';
import 'dart:math';

import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Implements exponential backoff reconnection logic.
///
/// Call [scheduleReconnect] to queue a reconnect attempt.
/// The caller provides a [connect] callback that returns true on success.
class ReconnectService {
  int _attempts = 0;
  Timer? _timer;
  bool _active = false;

  bool get isActive => _active;
  int get attempts => _attempts;

  /// Schedule a reconnect attempt with exponential backoff.
  ///
  /// [connect] - async function that returns true if connection succeeded.
  /// [onFailed] - called when max attempts are exhausted.
  void scheduleReconnect({
    required Future<bool> Function() connect,
    required void Function() onFailed,
    bool resetAttempts = false,
  }) {
    if (resetAttempts) _attempts = 0;
    if (_attempts >= AppConstants.maxReconnectAttempts) {
      _log.w('Max reconnect attempts reached, giving up');
      _active = false;
      onFailed();
      return;
    }

    final delay = _calculateDelay();
    _log.d(
      'Reconnect attempt ${_attempts + 1}/${AppConstants.maxReconnectAttempts} '
      'in ${delay}ms',
    );

    _active = true;
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: delay), () async {
      _attempts++;
      final success = await connect();
      if (success) {
        _log.d('Reconnection successful after $_attempts attempts');
        _attempts = 0;
        _active = false;
      } else {
        scheduleReconnect(connect: connect, onFailed: onFailed);
      }
    });
  }

  /// Cancel any pending reconnect.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _active = false;
    _attempts = 0;
  }

  int _calculateDelay() {
    // Exponential backoff: base * 2^attempts, capped at 16s, with jitter.
    final baseMs = AppConstants.reconnectBaseDelayMs;
    final exp = min(_attempts, 5);
    final backoff = baseMs * (1 << exp);
    final jitter = Random().nextInt(300);
    return min(backoff + jitter, 16000);
  }
}
