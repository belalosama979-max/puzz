import 'dart:async';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/buzz_event_model.dart';
import '../../domain/models/packet_model.dart';
import 'buzz_validator.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Result after the buzz engine processes a buzz event.
class BuzzResult {
  const BuzzResult({
    required this.event,
    required this.isWinner,
  });

  final BuzzEventModel event;
  final bool isWinner;
}

/// The core buzz engine that runs on the host.
///
/// Responsibilities:
/// - Opens / closes rounds.
/// - Validates incoming buzz events via [BuzzValidator].
/// - Determines the first valid buzz as the winner.
/// - Locks all subsequent buzzes.
/// - Emits results via streams.
class BuzzEngine {
  BuzzEngine() : _validator = BuzzValidator();

  final BuzzValidator _validator;
  final _uuid = const Uuid();

  BuzzEngineState _state = BuzzEngineState.idle;
  String _currentRoundId = '';
  String? _winnerId;
  DateTime? _roundOpenedAt;

  final List<BuzzEventModel> _roundEvents = [];
  final _winnerController =
      StreamController<BuzzResult>.broadcast();
  final _buzzController = StreamController<BuzzEventModel>.broadcast();

  /// Emits the first valid buzz (winner).
  Stream<BuzzResult> get onWinner => _winnerController.stream;

  /// Emits every validated buzz event (including non-winners).
  Stream<BuzzEventModel> get onBuzz => _buzzController.stream;

  BuzzEngineState get state => _state;
  String get currentRoundId => _currentRoundId;
  String? get winnerId => _winnerId;
  List<BuzzEventModel> get roundEvents => List.unmodifiable(_roundEvents);

  // ─── Round control ──────────────────────────────────────────────────────────

  /// Open the buzzer for a new round.
  String openRound() {
    _currentRoundId = _uuid.v4();
    _roundOpenedAt = DateTime.now();
    _winnerId = null;
    _roundEvents.clear();
    _state = BuzzEngineState.open;
    _validator.openRound(_currentRoundId);
    _log.d('Round opened: $_currentRoundId');
    return _currentRoundId;
  }

  /// Reopen buzzer for same round (after reject answer).
  void reopenBuzz() {
    if (_state != BuzzEngineState.answered) return;
    _winnerId = null;
    _state = BuzzEngineState.open;
    _validator.resetRound();
    _log.d('Buzz reopened for round $_currentRoundId');
  }

  /// Close the current round.
  void closeRound() {
    _state = BuzzEngineState.closed;
    _validator.closeRound();
    _log.d('Round closed');
  }

  /// Reset to idle.
  void reset() {
    _state = BuzzEngineState.idle;
    _currentRoundId = '';
    _winnerId = null;
    _roundEvents.clear();
    _validator.closeRound();
  }

  // ─── Buzz processing ────────────────────────────────────────────────────────

  /// Process a BUZZ packet received from a team.
  ///
  /// Returns a [BuzzResult] indicating whether this buzz won.
  BuzzResult processBuzz(PacketModel packet) {
    if (_state != BuzzEngineState.open) {
      // Round is not open; reject silently.
      final event = BuzzEventModel(
        teamId: packet.senderId,
        teamName: packet.payload['teamName'] as String? ?? '',
        roomCode: packet.payload['roomCode'] as String? ?? '',
        roundId: packet.payload['roundId'] as String? ?? '',
        clientTimestamp: packet.payload['clientTimestamp'] as int? ??
            packet.timestamp,
        sequenceNumber: packet.sequenceNumber,
        isValid: false,
      );
      return BuzzResult(event: event, isWinner: false);
    }

    final rawEvent = BuzzEventModel(
      teamId: packet.senderId,
      teamName: packet.payload['teamName'] as String? ?? '',
      roomCode: packet.payload['roomCode'] as String? ?? '',
      roundId: packet.payload['roundId'] as String? ?? '',
      clientTimestamp: packet.payload['clientTimestamp'] as int? ??
          packet.timestamp,
      sequenceNumber: packet.sequenceNumber,
    );

    final validated = _validator.validate(rawEvent);
    _roundEvents.add(validated);
    _buzzController.add(validated);

    // If invalid or duplicate, not a winner.
    if (!validated.isValid || validated.isDuplicate) {
      return BuzzResult(event: validated, isWinner: false);
    }

    // First valid buzz = winner.
    if (_winnerId == null) {
      _winnerId = validated.teamId;
      _state = BuzzEngineState.answered;
      _log.d(
        'Winner: ${validated.teamName} in ${validated.reactionTimeMs}ms',
      );
      final result = BuzzResult(event: validated, isWinner: true);
      _winnerController.add(result);
      return result;
    }

    // Another valid buzz after winner determined – not a winner.
    return BuzzResult(event: validated, isWinner: false);
  }

  void dispose() {
    _winnerController.close();
    _buzzController.close();
  }
}

enum BuzzEngineState { idle, open, answered, closed }
