import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '../../core/constants/arabic_strings.dart';
import '../../domain/models/statistics_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Exports competition statistics to CSV with Arabic headers.
class CsvExporter {
  Future<String?> export(StatisticsModel stats) async {
    try {
      final rows = <List<dynamic>>[
        // Arabic headers
        [
          ArabicStrings.csvRank,
          ArabicStrings.csvTeam,
          ArabicStrings.csvWins,
          ArabicStrings.csvBuzzAttempts,
          ArabicStrings.csvReactionTime,
          ArabicStrings.winRate,
        ],
        // Data rows
        ...stats.leaderboard.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final ts = entry.value;
          return [
            rank,
            ts.team.name,
            ts.wins,
            ts.buzzAttempts,
            ts.fastestReactionMs ?? '',
            '${(ts.winRate * 100).toStringAsFixed(1)}%',
          ];
        }),
        [], // Empty separator
        // Round results
        [
          ArabicStrings.csvRound,
          ArabicStrings.csvWinner,
          ArabicStrings.csvReactionTime,
        ],
        ...stats.rounds.map((r) => [
              r.roundNumber,
              r.winnerTeamName ?? '—',
              r.winnerReactionMs != null ? '${r.winnerReactionMs} ms' : '—',
            ]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'buzz_master_${stats.roomCode}_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${dir.path}/$fileName');
      // Add UTF-8 BOM for Excel Arabic compatibility.
      await file.writeAsBytes([0xEF, 0xBB, 0xBF, ...csv.codeUnits]);
      _log.d('CSV exported to ${file.path}');
      return file.path;
    } catch (e) {
      _log.e('CSV export failed: $e');
      return null;
    }
  }
}
