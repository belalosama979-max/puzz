import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

import '../../core/constants/arabic_strings.dart';
import '../../domain/models/statistics_model.dart';
import '../../domain/models/round_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Generates Arabic PDF competition reports.
class PdfExporter {
  /// Generate a PDF report from [stats] and return the file path.
  Future<String?> export(StatisticsModel stats) async {
    try {
      final pdf = pw.Document();
      final dateFormatter = DateFormat('yyyy/MM/dd – HH:mm');

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            textDirection: pw.TextDirection.rtl,
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
            buildBackground: (ctx) => pw.Container(
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF5F4FF),
              ),
            ),
          ),
          build: (ctx) => [
            // Header
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    ArabicStrings.pdfTitle,
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF6C63FF),
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    ArabicStrings.pdfSubtitle,
                    style: const pw.TextStyle(fontSize: 14),
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Competition Details
            _buildSection(
              title: ArabicStrings.pdfCompetitionDetails,
              children: [
                _buildRow(
                  ArabicStrings.competitionName,
                  stats.competitionName,
                ),
                _buildRow(
                  ArabicStrings.roomCode,
                  stats.roomCode,
                ),
                _buildRow(
                  ArabicStrings.dateTime,
                  dateFormatter.format(stats.startedAt),
                ),
                _buildRow(
                  ArabicStrings.totalRounds,
                  '${stats.totalRounds}',
                ),
                if (stats.endedAt != null)
                  _buildRow(
                    ArabicStrings.duration,
                    _formatDuration(stats.totalDuration!),
                  ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Leaderboard
            _buildSection(
              title: ArabicStrings.leaderboard,
              children: [
                pw.Table(
                  border: pw.TableBorder.all(
                    color: const PdfColor.fromInt(0xFFE8E7FF),
                    width: 1,
                  ),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF6C63FF),
                      ),
                      children: [
                        _tableCell(ArabicStrings.csvRank, isHeader: true),
                        _tableCell(ArabicStrings.csvTeam, isHeader: true),
                        _tableCell(ArabicStrings.csvWins, isHeader: true),
                        _tableCell(
                          ArabicStrings.fastestReaction,
                          isHeader: true,
                        ),
                      ],
                    ),
                    // Data rows
                    ...stats.leaderboard.asMap().entries.map((entry) {
                      final rank = entry.key + 1;
                      final ts = entry.value;
                      return pw.TableRow(
                        children: [
                          _tableCell('#$rank'),
                          _tableCell(ts.team.name),
                          _tableCell('${ts.wins}'),
                          _tableCell(
                            ts.fastestReactionMs != null
                                ? '${ts.fastestReactionMs} ms'
                                : '—',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Round Results
            _buildSection(
              title: ArabicStrings.pdfRoundResults,
              children: stats.rounds.map((r) => _buildRoundRow(r)).toList(),
            ),

            // Footer
            pw.SizedBox(height: 24),
            pw.Center(
              child: pw.Text(
                '${ArabicStrings.pdfGeneratedAt}: ${dateFormatter.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'buzz_master_${stats.roomCode}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      _log.d('PDF exported to ${file.path}');
      return file.path;
    } catch (e) {
      _log.e('PDF export failed: $e');
      return null;
    }
  }

  pw.Widget _buildSection({
    required String title,
    required List<pw.Widget> children,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: const PdfColor.fromInt(0xFF6C63FF),
          ),
          textDirection: pw.TextDirection.rtl,
        ),
        pw.Divider(color: const PdfColor.fromInt(0xFF6C63FF)),
        pw.SizedBox(height: 8),
        ...children,
      ],
    );
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(value, textDirection: pw.TextDirection.rtl),
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRoundRow(RoundModel round) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            round.winnerTeamName ?? '—',
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            '${ArabicStrings.roundNumber} ${round.roundNumber}: '
            '${round.winnerReactionMs != null ? "${round.winnerReactionMs} ms" : "—"}',
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textDirection: pw.TextDirection.rtl,
        style: isHeader
            ? pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              )
            : null,
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '$h ساعة $m دقيقة';
    if (m > 0) return '$m دقيقة $s ثانية';
    return '$s ثانية';
  }
}
