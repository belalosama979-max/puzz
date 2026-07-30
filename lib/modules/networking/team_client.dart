import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/packet_model.dart';
import 'packet_codec.dart';
import 'heartbeat_service.dart';
import 'reconnect_service.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Events emitted from the host to a team client.
enum TeamClientEvent {
  connected,
  disconnected,
  rejected,
  kicked,
  roundOpen,
  roundClose,
  roundReset,
  winner,
  lock,
  unlock,
  teamListUpdate,
  competitionEnd,
  pause,
  resume,
  acceptAnswer,
  rejectAnswer,
  reopenBuzz,
}

class TeamClientUpdate {
  const TeamClientUpdate({
    required this.event,
    this.packet,
    this.pingMs,
  });

  final TeamClientEvent event;
  final PacketModel? packet;
  final int? pingMs;
}

/// TCP client that connects to the host server.
///
/// Manages connection, authentication, heartbeats, reconnection,
/// and provides a stream of events for the team UI to consume.
class TeamClient {
  TeamClient({
    required this.heartbeatService,
    required this.reconnectService,
  });

  final HeartbeatService heartbeatService;
  final ReconnectService reconnectService;

  Socket? _socket;
  HeartbeatSession? _heartbeat;
  String _localId = '';
  String _hostAddress = '';
  int _hostPort = AppConstants.hostPort;
  String _roomCode = '';
  String _teamName = '';
  int _teamColor = 0xFF6C63FF;
  String _avatar = 'lion';

  bool _connected = false;
  bool _autoReconnect = true;
  int _seq = 0;

  final _eventController = StreamController<TeamClientUpdate>.broadcast();
  Stream<TeamClientUpdate> get events => _eventController.stream;

  bool get isConnected => _connected;
  int get currentSeq => _seq;

  /// Connect to the host at [address]:[port] and join the room.
  Future<bool> connect({
    required String localId,
    required String hostAddress,
    required int hostPort,
    required String roomCode,
    required String teamName,
    required int teamColor,
    required String avatar,
    bool autoReconnect = true,
  }) async {
    _localId = localId;
    _hostAddress = hostAddress;
    _hostPort = hostPort;
    _roomCode = roomCode;
    _teamName = teamName;
    _teamColor = teamColor;
    _avatar = avatar;
    _autoReconnect = autoReconnect;

    return _doConnect();
  }

  Future<bool> _doConnect() async {
    try {
      _socket = await Socket.connect(
        _hostAddress,
        _hostPort,
        timeout: const Duration(seconds: 8),
      );
      _socket!.setOption(SocketOption.tcpNoDelay, true);

      _log.d('Connected to host $_hostAddress:$_hostPort');

      // Setup heartbeat.
      _heartbeat = heartbeatService.create(
        localId: _localId,
        remoteId: 'host',
        sendPacket: _sendPacket,
        onTimeout: (_) => _onDisconnect(),
      );
      _heartbeat!.start();

      // Listen for framed packets.
      final stream = PacketCodec.framer(_socket!.cast<Uint8List>());
      stream.listen(
        _handlePacket,
        onDone: _onDisconnect,
        onError: (e) {
          _log.e('Socket error: $e');
          _onDisconnect();
        },
      );

      // Send join request.
      await _sendPacket(PacketModel(
        type: PacketType.joinRequest,
        senderId: _localId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: _nextSeq(),
        payload: {
          'roomCode': _roomCode,
          'teamName': _teamName,
          'teamColor': _teamColor,
          'avatar': _avatar,
        },
      ));

      return true;
    } catch (e) {
      _log.e('Connection failed: $e');
      _onDisconnect();
      return false;
    }
  }

  void _handlePacket(PacketModel packet) {
    heartbeatService.notifyReceived('host');

    switch (packet.type) {
      case PacketType.joinAccepted:
        _connected = true;
        reconnectService.cancel();
        _eventController.add(const TeamClientUpdate(
          event: TeamClientEvent.connected,
        ));

      case PacketType.joinRejected:
        _connected = false;
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.rejected,
          packet: packet,
        ));

      case PacketType.roundOpen:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.roundOpen,
          packet: packet,
        ));

      case PacketType.roundClose:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.roundClose,
          packet: packet,
        ));

      case PacketType.roundReset:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.roundReset,
          packet: packet,
        ));

      case PacketType.winner:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.winner,
          packet: packet,
        ));

      case PacketType.lock:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.lock,
          packet: packet,
        ));

      case PacketType.unlock:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.unlock,
          packet: packet,
        ));

      case PacketType.kick:
        _connected = false;
        _autoReconnect = false;
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.kicked,
          packet: packet,
        ));
        _cleanup();

      case PacketType.teamListUpdate:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.teamListUpdate,
          packet: packet,
        ));

      case PacketType.competitionEnd:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.competitionEnd,
          packet: packet,
        ));

      case PacketType.pause:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.pause,
          packet: packet,
        ));

      case PacketType.resume:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.resume,
          packet: packet,
        ));

      case PacketType.acceptAnswer:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.acceptAnswer,
          packet: packet,
        ));

      case PacketType.rejectAnswer:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.rejectAnswer,
          packet: packet,
        ));

      case PacketType.reopenBuzz:
        _eventController.add(TeamClientUpdate(
          event: TeamClientEvent.reopenBuzz,
          packet: packet,
        ));

      case PacketType.heartbeat:
        _heartbeat?.handleHeartbeat(packet);

      case PacketType.heartbeatAck:
        _heartbeat?.handleHeartbeatAck(packet);

      case PacketType.disconnect:
        _onDisconnect();

      default:
        break;
    }
  }

  /// Send a BUZZ packet to the host.
  Future<void> sendBuzz({
    required String roundId,
  }) async {
    if (!_connected) return;
    await _sendPacket(PacketModel(
      type: PacketType.buzz,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: _nextSeq(),
      payload: {
        'roundId': roundId,
        'clientTimestamp': DateTime.now().millisecondsSinceEpoch,
      },
    ));
  }

  /// Send battery level update to host.
  Future<void> sendBatteryUpdate(int level) async {
    if (!_connected) return;
    await _sendPacket(PacketModel(
      type: PacketType.batteryUpdate,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: _nextSeq(),
      payload: {'level': level},
    ));
  }

  void _onDisconnect() {
    final wasConnected = _connected;
    _connected = false;
    _cleanup();

    if (wasConnected) {
      _eventController.add(const TeamClientUpdate(
        event: TeamClientEvent.disconnected,
      ));
    }

    if (_autoReconnect) {
      reconnectService.scheduleReconnect(
        connect: _doConnect,
        onFailed: () {
          _eventController.add(const TeamClientUpdate(
            event: TeamClientEvent.disconnected,
          ));
        },
      );
    }
  }

  void _cleanup() {
    _heartbeat?.stop();
    _heartbeat = null;
    heartbeatService.remove('host');
    try {
      _socket?.destroy();
    } catch (_) {}
    _socket = null;
  }

  Future<void> _sendPacket(PacketModel packet) async {
    try {
      _socket?.add(PacketCodec.encode(packet));
    } catch (e) {
      _log.e('Send failed: $e');
    }
  }

  int _nextSeq() => _seq++;

  Future<void> disconnect() async {
    _autoReconnect = false;
    reconnectService.cancel();
    if (_connected) {
      await _sendPacket(PacketModel(
        type: PacketType.disconnect,
        senderId: _localId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: _nextSeq(),
      ));
    }
    _connected = false;
    _cleanup();
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
