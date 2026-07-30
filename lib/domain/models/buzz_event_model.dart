/// A buzz event emitted by a team device.
class BuzzEventModel {
  const BuzzEventModel({
    required this.teamId,
    required this.teamName,
    required this.roomCode,
    required this.roundId,
    required this.clientTimestamp,
    required this.sequenceNumber,
    this.serverTimestamp,
    this.reactionTimeMs,
    this.isValid = true,
    this.isDuplicate = false,
  });

  /// The team that pressed the buzzer.
  final String teamId;
  final String teamName;

  /// The room this event belongs to.
  final String roomCode;

  /// The round identifier.
  final String roundId;

  /// UTC timestamp when the client pressed the buzzer (epoch ms).
  final int clientTimestamp;

  /// UTC timestamp when the server received this packet (epoch ms).
  /// Set by the host server upon receipt.
  final int? serverTimestamp;

  /// Time from round open to buzz receipt on the server (ms).
  final int? reactionTimeMs;

  /// Packet sequence number for ordering.
  final int sequenceNumber;

  /// Whether this buzz is valid (within time window, not duplicate).
  final bool isValid;

  /// Whether this was a duplicate packet (same team, same round).
  final bool isDuplicate;

  BuzzEventModel copyWith({
    String? teamId,
    String? teamName,
    String? roomCode,
    String? roundId,
    int? clientTimestamp,
    int? serverTimestamp,
    int? reactionTimeMs,
    int? sequenceNumber,
    bool? isValid,
    bool? isDuplicate,
  }) {
    return BuzzEventModel(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      roomCode: roomCode ?? this.roomCode,
      roundId: roundId ?? this.roundId,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      serverTimestamp: serverTimestamp ?? this.serverTimestamp,
      reactionTimeMs: reactionTimeMs ?? this.reactionTimeMs,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      isValid: isValid ?? this.isValid,
      isDuplicate: isDuplicate ?? this.isDuplicate,
    );
  }

  Map<String, dynamic> toJson() => {
        'teamId': teamId,
        'teamName': teamName,
        'roomCode': roomCode,
        'roundId': roundId,
        'clientTimestamp': clientTimestamp,
        'serverTimestamp': serverTimestamp,
        'reactionTimeMs': reactionTimeMs,
        'sequenceNumber': sequenceNumber,
        'isValid': isValid,
        'isDuplicate': isDuplicate,
      };

  factory BuzzEventModel.fromJson(Map<String, dynamic> json) => BuzzEventModel(
        teamId: json['teamId'] as String,
        teamName: json['teamName'] as String,
        roomCode: json['roomCode'] as String,
        roundId: json['roundId'] as String,
        clientTimestamp: json['clientTimestamp'] as int,
        serverTimestamp: json['serverTimestamp'] as int?,
        reactionTimeMs: json['reactionTimeMs'] as int?,
        sequenceNumber: json['sequenceNumber'] as int? ?? 0,
        isValid: json['isValid'] as bool? ?? true,
        isDuplicate: json['isDuplicate'] as bool? ?? false,
      );
}
