/// Application-wide constants for BuzzMaster.
library;

class AppConstants {
  AppConstants._();

  // ─── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'BuzzMaster';
  static const String appVersion = '1.0.0';

  // ─── Networking ────────────────────────────────────────────────────────────
  /// TCP port the host server listens on.
  static const int hostPort = 47832;

  /// UDP port for room discovery broadcasts.
  static const int discoveryPort = 47833;

  /// Heartbeat interval in milliseconds.
  static const int heartbeatIntervalMs = 2000;

  /// Timeout before marking a client as disconnected.
  static const int connectionTimeoutMs = 8000;

  /// Reconnect base delay in milliseconds.
  static const int reconnectBaseDelayMs = 500;

  /// Maximum reconnect attempts.
  static const int maxReconnectAttempts = 10;

  /// Maximum allowed time delta for a buzz event (ms).
  /// Events older than this are rejected.
  static const int buzzMaxAgeMs = 5000;

  /// Maximum teams per room.
  static const int maxTeams = 8;

  /// Room code length.
  static const int roomCodeLength = 6;

  // ─── Game ──────────────────────────────────────────────────────────────────
  /// Duration before next round can start (ms).
  static const int roundCooldownMs = 1500;

  // ─── Storage ───────────────────────────────────────────────────────────────
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxProfile = 'profile';
  static const String hiveBoxSession = 'session';

  // ─── Packet Types ──────────────────────────────────────────────────────────
  static const String pktJoinRequest = 'JOIN_REQUEST';
  static const String pktJoinAccepted = 'JOIN_ACCEPTED';
  static const String pktJoinRejected = 'JOIN_REJECTED';
  static const String pktTeamListUpdate = 'TEAM_LIST_UPDATE';
  static const String pktRoundOpen = 'ROUND_OPEN';
  static const String pktRoundClose = 'ROUND_CLOSE';
  static const String pktRoundReset = 'ROUND_RESET';
  static const String pktBuzz = 'BUZZ';
  static const String pktBuzzAck = 'BUZZ_ACK';
  static const String pktWinner = 'WINNER';
  static const String pktLock = 'LOCK';
  static const String pktUnlock = 'UNLOCK';
  static const String pktKick = 'KICK';
  static const String pktHeartbeat = 'HEARTBEAT';
  static const String pktHeartbeatAck = 'HEARTBEAT_ACK';
  static const String pktDisconnect = 'DISCONNECT';
  static const String pktCompetitionEnd = 'COMPETITION_END';
  static const String pktPause = 'PAUSE';
  static const String pktResume = 'RESUME';
  static const String pktAcceptAnswer = 'ACCEPT_ANSWER';
  static const String pktRejectAnswer = 'REJECT_ANSWER';
  static const String pktReopenBuzz = 'REOPEN_BUZZ';
  static const String pktBatteryUpdate = 'BATTERY_UPDATE';

  // ─── Avatar IDs ────────────────────────────────────────────────────────────
  static const List<String> availableAvatars = [
    'lion', 'eagle', 'wolf', 'fox', 'bear', 'tiger', 'shark', 'falcon',
    'dragon', 'phoenix', 'panther', 'bull',
  ];

  // ─── Team Colors ───────────────────────────────────────────────────────────
  static const List<int> teamColorValues = [
    0xFFE53935, // أحمر
    0xFF1E88E5, // أزرق
    0xFF43A047, // أخضر
    0xFFFB8C00, // برتقالي
    0xFF8E24AA, // بنفسجي
    0xFF00ACC1, // سماوي
    0xFFFFB300, // ذهبي
    0xFFE91E63, // وردي
  ];

  // ─── Animation Durations ───────────────────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration confettiDuration = Duration(seconds: 3);
}
