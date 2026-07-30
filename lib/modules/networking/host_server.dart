import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/models/packet_model.dart';
import '../../domain/models/team_model.dart';
import 'packet_codec.dart';
import 'heartbeat_service.dart';
import 'discovery_service.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Represents an active connection from a team to the host.
class TeamConnection {
  TeamConnection({
    required this.socket,
    required this.team,
    required this.heartbeat,
  });

  final Socket socket;
  TeamModel team;
  final HeartbeatSession heartbeat;
  int _seq = 0;
  final Set<int> _seenSequences = {};
  int _lastPingMs = 0;

  int get lastPingMs => _lastPingMs;

  /// Send a packet to this team.
  Future<void> send(PacketModel packet) async {
    try {
      socket.add(PacketCodec.encode(packet));
    } catch (e) {
      _log.e('Failed to send to ${team.name}: $e');
    }
  }

  /// Check and record sequence number for duplicate detection.
  bool isDuplicate(int seq) {
    if (_seenSequences.contains(seq)) return true;
    _seenSequences.add(seq);
    // Keep only last 100 sequence numbers.
    if (_seenSequences.length > 100) {
      _seenSequences.remove(_seenSequences.first);
    }
    return false;
  }
}

/// Events emitted by [HostServer].
enum HostServerEvent {
  teamJoined,
  teamDisconnected,
  buzzReceived,
  teamReady,
  batteryUpdate,
}

class HostServerUpdate {
  const HostServerUpdate({
    required this.event,
    required this.teamId,
    this.packet,
    this.pingMs,
    this.batteryLevel,
  });

  final HostServerEvent event;
  final String teamId;
  final PacketModel? packet;
  final int? pingMs;
  final int? batteryLevel;
}

/// The TCP server that hosts the competition room.
///
/// Listens on [AppConstants.hostPort], accepts team connections,
/// processes all incoming packets, and provides a stream of events
/// for the game engine to consume.
class HostServer {
  HostServer({
    required this.heartbeatService,
    required this.discoveryService,
  });

  final HeartbeatService heartbeatService;
  final DiscoveryService discoveryService;

  ServerSocket? _serverSocket;
  String _localId = '';
  String _roomCode = '';
  String _competitionName = '';
  bool _isOpen = false;

  final Map<String, TeamConnection> _connections = {};
  final _eventController = StreamController<HostServerUpdate>.broadcast();

  Stream<HostServerUpdate> get events => _eventController.stream;
  Map<String, TeamConnection> get connections => Map.unmodifiable(_connections);
  bool get isRunning => _serverSocket != null;

  /// Start the host server and begin accepting connections.
  Future<void> start({
    required String localId,
    required String roomCode,
    required String competitionName,
  }) async {
    _localId = localId;
    _roomCode = roomCode;
    _competitionName = competitionName;
    _isOpen = true;

    _serverSocket = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      AppConstants.hostPort,
    );
    _log.d('Host server started on port ${AppConstants.hostPort}');

    // Start UDP discovery broadcasting.
    await discoveryService.startBroadcasting(
      roomCode: roomCode,
      competitionName: competitionName,
      teamCount: 0,
      maxTeams: AppConstants.maxTeams,
    );

    _serverSocket!.listen(
      _onNewConnection,
      onError: (e) => _log.e('Server socket error: $e'),
    );
  }

  void _onNewConnection(Socket socket) {
    final address = socket.remoteAddress.address;
    _log.d('New TCP connection from $address');

    socket.setOption(SocketOption.tcpNoDelay, true);

    // Parse framed packets from this connection.
    final packetStream = PacketCodec.framer(
      socket.cast<Uint8List>(),
    );

    String? connectedTeamId;

    packetStream.listen(
      (packet) {
        heartbeatService.notifyReceived(packet.senderId);

        // Duplicate detection.
        if (connectedTeamId != null) {
          final conn = _connections[connectedTeamId];
          if (conn != null && conn.isDuplicate(packet.sequenceNumber)) {
            _log.d('Duplicate packet ignored: seq=${packet.sequenceNumber}');
            return;
          }
        }

        _handlePacket(packet, socket, (teamId) {
          connectedTeamId = teamId;
        });
      },
      onDone: () {
        if (connectedTeamId != null) {
          _handleDisconnect(connectedTeamId!);
        }
      },
      onError: (e) {
        _log.e('Socket error from $address: $e');
        if (connectedTeamId != null) {
          _handleDisconnect(connectedTeamId!);
        }
      },
    );
  }

  void _handlePacket(
    PacketModel packet,
    Socket socket,
    void Function(String) setTeamId,
  ) {
    switch (packet.type) {
      case PacketType.joinRequest:
        _handleJoinRequest(packet, socket, setTeamId);

      case PacketType.buzz:
        if (_connections.containsKey(packet.senderId)) {
          _eventController.add(HostServerUpdate(
            event: HostServerEvent.buzzReceived,
            teamId: packet.senderId,
            packet: packet,
          ));
        }

      case PacketType.heartbeat:
        _connections[packet.senderId]?.heartbeat.handleHeartbeat(packet);

      case PacketType.heartbeatAck:
        _connections[packet.senderId]?.heartbeat.handleHeartbeatAck(packet);

      case PacketType.batteryUpdate:
        final level = packet.payload['level'] as int? ?? -1;
        _updateTeam(
          packet.senderId,
          (t) => t.copyWith(batteryLevel: level),
        );
        _eventController.add(HostServerUpdate(
          event: HostServerEvent.batteryUpdate,
          teamId: packet.senderId,
          batteryLevel: level,
        ));

      case PacketType.disconnect:
        _handleDisconnect(packet.senderId);

      default:
        break;
    }
  }

  void _handleJoinRequest(
    PacketModel packet,
    Socket socket,
    void Function(String) setTeamId,
  ) {
    final payload = packet.payload;
    final teamId = packet.senderId;

    // Validate room code.
    if (payload['roomCode'] != _roomCode) {
      _sendToSocket(socket, PacketModel(
        type: PacketType.joinRejected,
        senderId: _localId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: 0,
        payload: {'reason': 'WRONG_CODE'},
      ));
      return;
    }

    // Room is locked?
    if (!_isOpen && !_connections.containsKey(teamId)) {
      _sendToSocket(socket, PacketModel(
        type: PacketType.joinRejected,
        senderId: _localId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: 0,
        payload: {'reason': 'ROOM_LOCKED'},
      ));
      return;
    }

    // Max teams reached?
    if (_connections.length >= AppConstants.maxTeams &&
        !_connections.containsKey(teamId)) {
      _sendToSocket(socket, PacketModel(
        type: PacketType.joinRejected,
        senderId: _localId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        sequenceNumber: 0,
        payload: {'reason': 'ROOM_FULL'},
      ));
      return;
    }

    // Build team model.
    final team = TeamModel(
      id: teamId,
      name: payload['teamName'] as String? ?? 'فريق',
      color: payload['teamColor'] as int? ?? 0xFF6C63FF,
      avatar: payload['avatar'] as String? ?? 'lion',
      connectionState: TeamConnectionState.connected,
      address: socket.remoteAddress.address,
      port: socket.remotePort,
    );

    // Setup heartbeat for this connection.
    final heartbeat = heartbeatService.create(
      localId: _localId,
      remoteId: teamId,
      sendPacket: (p) async => _sendToSocket(socket, p),
      onTimeout: (id) => _handleDisconnect(id),
    );

    final conn = TeamConnection(
      socket: socket,
      team: team,
      heartbeat: heartbeat,
    );
    _connections[teamId] = conn;
    heartbeat.start();
    setTeamId(teamId);

    // Accept the join.
    _sendToSocket(socket, PacketModel(
      type: PacketType.joinAccepted,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
      payload: {'roomCode': _roomCode, 'teamId': teamId},
    ));

    _log.d('Team "${team.name}" joined ($teamId)');

    // Broadcast updated team list.
    broadcastTeamList();
    _updateDiscovery();

    _eventController.add(HostServerUpdate(
      event: HostServerEvent.teamJoined,
      teamId: teamId,
    ));
  }

  void _handleDisconnect(String teamId) {
    final conn = _connections.remove(teamId);
    if (conn == null) return;
    conn.heartbeat.stop();
    heartbeatService.remove(teamId);
    try {
      conn.socket.destroy();
    } catch (_) {}
    _log.d('Team ${conn.team.name} disconnected');
    broadcastTeamList();
    _updateDiscovery();
    _eventController.add(HostServerUpdate(
      event: HostServerEvent.teamDisconnected,
      teamId: teamId,
    ));
  }

  void _updateTeam(String teamId, TeamModel Function(TeamModel) updater) {
    final conn = _connections[teamId];
    if (conn == null) return;
    conn.team = updater(conn.team);
  }

  // ─── Broadcast helpers ──────────────────────────────────────────────────────

  /// Send a packet to all connected teams.
  Future<void> broadcast(PacketModel packet) async {
    for (final conn in _connections.values) {
      await conn.send(packet);
    }
  }

  /// Send an updated team list to all connected teams.
  Future<void> broadcastTeamList() async {
    final teams = _connections.values
        .map((c) => c.team.toJson())
        .toList();
    await broadcast(PacketModel(
      type: PacketType.teamListUpdate,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
      payload: {'teams': teams},
    ));
  }

  /// Send a packet to a specific team only.
  Future<void> sendTo(String teamId, PacketModel packet) async {
    await _connections[teamId]?.send(packet);
  }

  /// Kick a team from the room.
  Future<void> kickTeam(String teamId) async {
    await sendTo(teamId, PacketModel(
      type: PacketType.kick,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
    _handleDisconnect(teamId);
  }

  void _sendToSocket(Socket socket, PacketModel packet) {
    try {
      socket.add(PacketCodec.encode(packet));
    } catch (e) {
      _log.e('Failed to send packet: $e');
    }
  }

  void _updateDiscovery() {
    discoveryService.startBroadcasting(
      roomCode: _roomCode,
      competitionName: _competitionName,
      teamCount: _connections.length,
      maxTeams: AppConstants.maxTeams,
    );
  }

  List<TeamModel> get connectedTeams =>
      _connections.values.map((c) => c.team).toList();

  void lockRoom() => _isOpen = false;
  void unlockRoom() => _isOpen = true;

  Future<void> stop() async {
    await broadcast(PacketModel(
      type: PacketType.disconnect,
      senderId: _localId,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sequenceNumber: 0,
    ));
    heartbeatService.dispose();
    await discoveryService.stopBroadcasting();
    for (final conn in _connections.values) {
      conn.heartbeat.stop();
      try {
        conn.socket.destroy();
      } catch (_) {}
    }
    _connections.clear();
    await _serverSocket?.close();
    _serverSocket = null;
    _log.d('Host server stopped');
  }

  void dispose() {
    stop();
    _eventController.close();
  }
}
