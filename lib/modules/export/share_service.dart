import 'package:share_plus/share_plus.dart';
import 'package:logger/logger.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Shares exported files via the Android share sheet.
class ShareService {
  Future<void> shareFile(String filePath, String subject) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject,
      );
    } catch (e) {
      _log.e('Share failed: $e');
    }
  }

  Future<void> shareText(String text, String subject) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      _log.e('Share text failed: $e');
    }
  }
}
