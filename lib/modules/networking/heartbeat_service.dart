import 'dart:async';

import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/packet_model.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Callback when a heartbeat timeout is detected for a sender.
typedef HeartbeatTimeoutCallback = void Function(String senderId);

/// Manages heartbeat packets for a single connection.
///
/// The local side sends HEARTBEAT packets every [AppConstants.heartbeatIntervalMs]
/// and expects HEARTBEAT_ACK responses. If no ACK (or any packet) is received
/// within [AppConstants.connectionTimeoutMs], the timeout callback is invoked.
class HeartbeatSession {
  HeartbeatSession({
    required this.senderId,
    required this.remoteSenderId,
    required this.sendPacket,
    required this.onTimeout,
  });

  final String senderId;
  final String remoteSenderId;

  /// Function that sends a packet to the remote peer.
  final Future<void> Function(PacketModel) sendPacket;
  final HeartbeatTimeoutCallback onTimeout;

  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;
  int _seq = 0;

  /// Start sending heartbeats.
  void start() {
    _resetTimeout();
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: AppConstants.heartbeatIntervalMs),
      (_) => _sendHeartbeat(),
    );
  }

  /// Call this whenever any packet is received from the remote peer.
  void onPacketReceived() {
    _resetTimeout();
  }

  /// Handle an incoming HEARTBEAT by replying with HEARTBEAT_ACK.
  Future<void> handleHeartbeat(PacketModel packet) async {
    onPacketReceived();
    await sendPacket(PacketModel(
      type: PacketType.heartbeatAck,
      senderId: senderId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: packet.sequenceNumber,
    ));
  }

  void handleHeartbeatAck(PacketModel packet) {
    onPacketReceived();
    final sentTs = packet.payload['sentTimestamp'] as int?;
    if (sentTs != null) {
      final pingMs = DateTime.now().millisecondsSinceEpoch - sentTs;
      _log.d(
        'Heartbeat RTT with $remoteSenderId: ${pingMs}ms',
      );
    }
  }

  void stop() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    _heartbeatTimer = null;
    _timeoutTimer = null;
  }

  void _sendHeartbeat() {
    final now = DateTime.now().millisecondsSinceEpoch;
    sendPacket(PacketModel(
      type: PacketType.heartbeat,
      senderId: senderId,
      timestamp: now,
      sequenceNumber: _seq++,
      payload: {'sentTimestamp': now},
    ));
  }

  void _resetTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(
      Duration(milliseconds: AppConstants.connectionTimeoutMs),
      () {
        _log.w('Heartbeat timeout for $remoteSenderId');
        onTimeout(remoteSenderId);
      },
    );
  }
}

/// Factory/registry for heartbeat sessions.
class HeartbeatService {
  final Map<String, HeartbeatSession> _sessions = {};

  HeartbeatSession create({
    required String localId,
    required String remoteId,
    required Future<void> Function(PacketModel) sendPacket,
    required HeartbeatTimeoutCallback onTimeout,
  }) {
    final session = HeartbeatSession(
      senderId: localId,
      remoteSenderId: remoteId,
      sendPacket: sendPacket,
      onTimeout: onTimeout,
    );
    _sessions[remoteId] = session;
    return session;
  }

  void notifyReceived(String remoteId) {
    _sessions[remoteId]?.onPacketReceived();
  }

  void remove(String remoteId) {
    _sessions[remoteId]?.stop();
    _sessions.remove(remoteId);
  }

  void dispose() {
    for (final s in _sessions.values) {
      s.stop();
    }
    _sessions.clear();
  }
}
