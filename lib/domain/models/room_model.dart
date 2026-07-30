import 'team_model.dart';

/// State of the competition room.
enum RoomState {
  waiting,    // Lobby – waiting for teams
  locked,     // Room closed – no new joins
  active,     // Competition started
  paused,     // Competition paused
  ended,      // Competition finished
}

/// State of an individual round.
enum RoundState {
  idle,       // Round not started
  open,       // Buzzer is open – teams can buzz
  answered,   // A team buzzed and answer is pending
  closed,     // Round concluded
}

/// Model representing the competition room.
class RoomModel {
  const RoomModel({
    required this.code,
    required this.hostId,
    required this.competitionName,
    required this.createdAt,
    this.teams = const [],
    this.state = RoomState.waiting,
    this.roundState = RoundState.idle,
    this.currentRound = 0,
    this.hostAddress = '',
    this.hostPort = 0,
  });

  final String code;
  final String hostId;
  final String competitionName;
  final DateTime createdAt;
  final List<TeamModel> teams;
  final RoomState state;
  final RoundState roundState;
  final int currentRound;
  final String hostAddress;
  final int hostPort;

  bool get isWaiting => state == RoomState.waiting;
  bool get isLocked => state == RoomState.locked;
  bool get isActive => state == RoomState.active;
  bool get isPaused => state == RoomState.paused;
  bool get isEnded => state == RoomState.ended;
  bool get isBuzzerOpen => roundState == RoundState.open;

  int get connectedTeamCount => teams
      .where((t) => t.connectionState == TeamConnectionState.connected)
      .length;

  RoomModel copyWith({
    String? code,
    String? hostId,
    String? competitionName,
    DateTime? createdAt,
    List<TeamModel>? teams,
    RoomState? state,
    RoundState? roundState,
    int? currentRound,
    String? hostAddress,
    int? hostPort,
  }) {
    return RoomModel(
      code: code ?? this.code,
      hostId: hostId ?? this.hostId,
      competitionName: competitionName ?? this.competitionName,
      createdAt: createdAt ?? this.createdAt,
      teams: teams ?? this.teams,
      state: state ?? this.state,
      roundState: roundState ?? this.roundState,
      currentRound: currentRound ?? this.currentRound,
      hostAddress: hostAddress ?? this.hostAddress,
      hostPort: hostPort ?? this.hostPort,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'hostId': hostId,
        'competitionName': competitionName,
        'createdAt': createdAt.toIso8601String(),
        'teams': teams.map((t) => t.toJson()).toList(),
        'state': state.name,
        'roundState': roundState.name,
        'currentRound': currentRound,
        'hostAddress': hostAddress,
        'hostPort': hostPort,
      };

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        code: json['code'] as String,
        hostId: json['hostId'] as String,
        competitionName: json['competitionName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        teams: (json['teams'] as List<dynamic>? ?? [])
            .map((t) => TeamModel.fromJson(t as Map<String, dynamic>))
            .toList(),
        state: RoomState.values.firstWhere(
          (s) => s.name == json['state'],
          orElse: () => RoomState.waiting,
        ),
        roundState: RoundState.values.firstWhere(
          (s) => s.name == json['roundState'],
          orElse: () => RoundState.idle,
        ),
        currentRound: json['currentRound'] as int? ?? 0,
        hostAddress: json['hostAddress'] as String? ?? '',
        hostPort: json['hostPort'] as int? ?? 0,
      );
}
