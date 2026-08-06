import 'buzz_event_model.dart';

/// Result of a single round.
class RoundModel {
  const RoundModel({
    required this.id,
    required this.roomCode,
    required this.roundNumber,
    required this.startedAt,
    this.endedAt,
    this.winnerTeamId,
    this.winnerTeamName,
    this.winnerReactionMs,
    this.answerAccepted,
    this.buzzEvents = const [],
  });

  final String id;
  final String roomCode;
  final int roundNumber;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// The winning team's ID, null if round had no winner.
  final String? winnerTeamId;
  final String? winnerTeamName;
  final int? winnerReactionMs;

  /// null = pending, true = accepted, false = rejected
  final bool? answerAccepted;

  /// All buzz events received during this round.
  final List<BuzzEventModel> buzzEvents;

  bool get hasWinner => winnerTeamId != null;
  bool get isComplete => endedAt != null;
  Duration? get duration =>
      endedAt != null ? endedAt!.difference(startedAt) : null;

  int get totalBuzzAttempts => buzzEvents.where((e) => e.isValid).length;

  RoundModel copyWith({
    String? id,
    String? roomCode,
    int? roundNumber,
    DateTime? startedAt,
    DateTime? endedAt,
    String? winnerTeamId,
    String? winnerTeamName,
    int? winnerReactionMs,
    bool? answerAccepted,
    List<BuzzEventModel>? buzzEvents,
  }) {
    return RoundModel(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      roundNumber: roundNumber ?? this.roundNumber,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
      winnerTeamName: winnerTeamName ?? this.winnerTeamName,
      winnerReactionMs: winnerReactionMs ?? this.winnerReactionMs,
      answerAccepted: answerAccepted ?? this.answerAccepted,
      buzzEvents: buzzEvents ?? this.buzzEvents,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomCode': roomCode,
        'roundNumber': roundNumber,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'winnerTeamId': winnerTeamId,
        'winnerTeamName': winnerTeamName,
        'winnerReactionMs': winnerReactionMs,
        'answerAccepted': answerAccepted,
        'buzzEvents': buzzEvents.map((e) => e.toJson()).toList(),
      };

  factory RoundModel.fromJson(Map<String, dynamic> json) => RoundModel(
        id: json['id'] as String,
        roomCode: json['roomCode'] as String,
        roundNumber: json['roundNumber'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        winnerTeamId: json['winnerTeamId'] as String?,
        winnerTeamName: json['winnerTeamName'] as String?,
        winnerReactionMs: json['winnerReactionMs'] as int?,
        answerAccepted: json['answerAccepted'] as bool?,
        buzzEvents: (json['buzzEvents'] as List<dynamic>? ?? [])
            .map((e) => BuzzEventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
