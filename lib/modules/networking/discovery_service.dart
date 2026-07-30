import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../core/constants/app_constants.dart';

final _log = Logger(printer: PrettyPrinter(methodCount: 0));

/// Information about a discovered host on the local network.
class DiscoveredHost {
  const DiscoveredHost({
    required this.address,
    required this.port,
    required this.roomCode,
    required this.competitionName,
    required this.teamCount,
    required this.maxTeams,
  });

  final String address;
  final int port;
  final String roomCode;
  final String competitionName;
  final int teamCount;
  final int maxTeams;

  @override
  String toString() =>
      'DiscoveredHost(roomCode: $roomCode, address: $address:$port)';
}

/// Discovers BuzzMaster hosts on the local Wi-Fi network via UDP broadcast.
///
/// Host side: broadcasts a presence packet every 2 seconds.
/// Team side: listens for broadcast packets and emits [DiscoveredHost] events.
class DiscoveryService {
  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _listenSocket;
  Timer? _broadcastTimer;
  final _discoveredController =
      StreamController<DiscoveredHost>.broadcast();

  Stream<DiscoveredHost> get onHostDiscovered => _discoveredController.stream;

  // ─── Host side ──────────────────────────────────────────────────────────────

  /// Start broadcasting room presence on the local network.
  Future<void> startBroadcasting({
    required String roomCode,
    required String competitionName,
    required int teamCount,
    required int maxTeams,
  }) async {
    await stopBroadcasting();
    try {
      _broadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );
      _broadcastSocket!.broadcastEnabled = true;

      final payload = jsonEncode({
        'type': 'BUZZ_MASTER_HOST',
        'roomCode': roomCode,
        'competitionName': competitionName,
        'teamCount': teamCount,
        'maxTeams': maxTeams,
        'port': AppConstants.hostPort,
      });
      final data = utf8.encode(payload);

      _broadcastTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) {
          _broadcastSocket?.send(
            data,
            InternetAddress('255.255.255.255'),
            AppConstants.discoveryPort,
          );
        },
      );

      _log.d('Discovery broadcasting started for room $roomCode');
    } catch (e) {
      _log.e('Failed to start broadcasting: $e');
    }
  }

  Future<void> stopBroadcasting() async {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _broadcastSocket?.close();
    _broadcastSocket = null;
  }

  // ─── Team side ──────────────────────────────────────────────────────────────

  /// Start listening for host broadcasts on the local network.
  Future<void> startListening() async {
    await stopListening();
    try {
      _listenSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        AppConstants.discoveryPort,
        reuseAddress: true,
        reusePort: true,
      );

      _listenSocket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _listenSocket!.receive();
          if (datagram == null) return;
          try {
            final payload = utf8.decode(datagram.data);
            final json = jsonDecode(payload) as Map<String, dynamic>;
            if (json['type'] != 'BUZZ_MASTER_HOST') return;
            final host = DiscoveredHost(
              address: datagram.address.address,
              port: json['port'] as int,
              roomCode: json['roomCode'] as String,
              competitionName: json['competitionName'] as String,
              teamCount: json['teamCount'] as int,
              maxTeams: json['maxTeams'] as int,
            );
            _discoveredController.add(host);
          } catch (_) {
            // Malformed discovery packet – ignore.
          }
        }
      });

      _log.d('Discovery listening started on port ${AppConstants.discoveryPort}');
    } catch (e) {
      _log.e('Failed to start listening: $e');
    }
  }

  Future<void> stopListening() async {
    _listenSocket?.close();
    _listenSocket = null;
  }

  /// Get local device IP address.
  Future<String?> getLocalIpAddress() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP();
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    stopBroadcasting();
    stopListening();
    _discoveredController.close();
  }
}
