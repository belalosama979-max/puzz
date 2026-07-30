import '../../core/constants/app_constants.dart';
import '../../domain/models/buzz_event_model.dart';

/// Validates individual buzz events for the fairness engine.
///
/// Rules:
/// 1. The event's round ID must match the current open round.
/// 2. The server-side receive timestamp must be within the allowed window.
/// 3. The event must not be a duplicate (same teamId + roundId seen before).
class BuzzValidator {
  final Set<String> _seenTeamRoundPairs = {};
  String _currentRoundId = '';
  int _roundOpenTimestamp = 0; // Server epoch ms when round was opened.

  /// Call this when a new round is opened by the host.
  void openRound(String roundId) {
    _currentRoundId = roundId;
    _roundOpenTimestamp = DateTime.now().millisecondsSinceEpoch;
    _seenTeamRoundPairs.clear();
  }

  /// Reset for the same round (reopen buzz).
  void resetRound() {
    _seenTeamRoundPairs.clear();
  }

  /// Close the current round.
  void closeRound() {
    _currentRoundId = '';
  }

  /// Validate a buzz event received by the host.
  ///
  /// Returns a [BuzzEventModel] with validity flags set.
  BuzzEventModel validate(BuzzEventModel event) {
    final serverTimestamp = DateTime.now().millisecondsSinceEpoch;

    // 1. Must be for the current round.
    if (event.roundId != _currentRoundId) {
      return event.copyWith(
        isValid: false,
        serverTimestamp: serverTimestamp,
      );
    }

    // 2. Must be within time window.
    final age = serverTimestamp - _roundOpenTimestamp;
    if (age > AppConstants.buzzMaxAgeMs) {
      return event.copyWith(
        isValid: false,
        serverTimestamp: serverTimestamp,
      );
    }

    // 3. Duplicate detection: one buzz per team per round.
    final key = '${event.teamId}:${event.roundId}';
    if (_seenTeamRoundPairs.contains(key)) {
      return event.copyWith(
        isValid: true,
        isDuplicate: true,
        serverTimestamp: serverTimestamp,
      );
    }
    _seenTeamRoundPairs.add(key);

    // Valid buzz.
    final reactionTimeMs = serverTimestamp - _roundOpenTimestamp;
    return event.copyWith(
      isValid: true,
      isDuplicate: false,
      serverTimestamp: serverTimestamp,
      reactionTimeMs: reactionTimeMs,
    );
  }
}
