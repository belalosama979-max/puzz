import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

import '../../domain/models/statistics_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Exports competition statistics as JSON.
class JsonExporter {
  Future<String?> export(StatisticsModel stats) async {
    try {
      final json = const JsonEncoder.withIndent('  ').convert(stats.toJson());
      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'buzz_master_${stats.roomCode}_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(json, encoding: utf8);
      _log.d('JSON exported to ${file.path}');
      return file.path;
    } catch (e) {
      _log.e('JSON export failed: $e');
      return null;
    }
  }
}
