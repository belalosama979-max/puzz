import 'round_model.dart';
import 'team_model.dart';

/// Per-team statistics accumulated over an entire competition.
class TeamStatistics {
  const TeamStatistics({
    required this.team,
    this.wins = 0,
    this.buzzAttempts = 0,
    this.fastestReactionMs,
    this.totalReactionMs = 0,
    this.validBuzzCount = 0,
  });

  final TeamModel team;
  final int wins;
  final int buzzAttempts;
  final int? fastestReactionMs;
  final int totalReactionMs;
  final int validBuzzCount;

  double get averageReactionMs =>
      validBuzzCount > 0 ? totalReactionMs / validBuzzCount : 0;

  double get winRate => buzzAttempts > 0 ? wins / buzzAttempts : 0;

  TeamStatistics copyWith({
    TeamModel? team,
    int? wins,
    int? buzzAttempts,
    int? fastestReactionMs,
    int? totalReactionMs,
    int? validBuzzCount,
  }) {
    return TeamStatistics(
      team: team ?? this.team,
      wins: wins ?? this.wins,
      buzzAttempts: buzzAttempts ?? this.buzzAttempts,
      fastestReactionMs: fastestReactionMs ?? this.fastestReactionMs,
      totalReactionMs: totalReactionMs ?? this.totalReactionMs,
      validBuzzCount: validBuzzCount ?? this.validBuzzCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'team': team.toJson(),
        'wins': wins,
        'buzzAttempts': buzzAttempts,
        'fastestReactionMs': fastestReactionMs,
        'totalReactionMs': totalReactionMs,
        'validBuzzCount': validBuzzCount,
      };

  factory TeamStatistics.fromJson(Map<String, dynamic> json) => TeamStatistics(
        team: TeamModel.fromJson(json['team'] as Map<String, dynamic>),
        wins: json['wins'] as int? ?? 0,
        buzzAttempts: json['buzzAttempts'] as int? ?? 0,
        fastestReactionMs: json['fastestReactionMs'] as int?,
        totalReactionMs: json['totalReactionMs'] as int? ?? 0,
        validBuzzCount: json['validBuzzCount'] as int? ?? 0,
      );
}

/// Aggregated statistics for the full competition.
class StatisticsModel {
  const StatisticsModel({
    required this.roomCode,
    required this.competitionName,
    required this.startedAt,
    this.endedAt,
    this.teamStats = const [],
    this.rounds = const [],
  });

  final String roomCode;
  final String competitionName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<TeamStatistics> teamStats;
  final List<RoundModel> rounds;

  int get totalRounds => rounds.length;
  Duration? get totalDuration =>
      endedAt != null ? endedAt!.difference(startedAt) : null;

  /// Sorted leaderboard by wins descending, then fastest reaction ascending.
  List<TeamStatistics> get leaderboard {
    final sorted = List<TeamStatistics>.from(teamStats);
    sorted.sort((a, b) {
      final winComp = b.wins.compareTo(a.wins);
      if (winComp != 0) return winComp;
      if (a.fastestReactionMs == null) return 1;
      if (b.fastestReactionMs == null) return -1;
      return a.fastestReactionMs!.compareTo(b.fastestReactionMs!);
    });
    return sorted;
  }

  TeamStatistics? get overallFastest {
    TeamStatistics? fastest;
    for (final ts in teamStats) {
      if (ts.fastestReactionMs == null) continue;
      if (fastest == null ||
          ts.fastestReactionMs! < fastest.fastestReactionMs!) {
        fastest = ts;
      }
    }
    return fastest;
  }

  Map<String, dynamic> toJson() => {
        'roomCode': roomCode,
        'competitionName': competitionName,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
        'teamStats': teamStats.map((t) => t.toJson()).toList(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
      };

  factory StatisticsModel.fromJson(Map<String, dynamic> json) =>
      StatisticsModel(
        roomCode: json['roomCode'] as String,
        competitionName: json['competitionName'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        teamStats: (json['teamStats'] as List<dynamic>? ?? [])
            .map((t) => TeamStatistics.fromJson(t as Map<String, dynamic>))
            .toList(),
        rounds: (json['rounds'] as List<dynamic>? ?? [])
            .map((r) => RoundModel.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}
