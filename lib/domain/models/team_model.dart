import 'package:flutter/material.dart';

/// Enum describing a team's connection state.
enum TeamConnectionState {
  connecting,
  connected,
  disconnected,
  reconnecting,
  kicked,
}

/// Signal quality levels.
enum SignalQuality { excellent, good, fair, poor, unknown }

/// Model representing a connected team.
class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    required this.color,
    required this.avatar,
    this.connectionState = TeamConnectionState.connecting,
    this.batteryLevel = -1,
    this.signalQuality = SignalQuality.unknown,
    this.pingMs = 0,
    this.isReady = false,
    this.address = '',
    this.port = 0,
  });

  final String id;
  final String name;
  final int color;
  final String avatar;
  final TeamConnectionState connectionState;

  /// Battery level 0–100, -1 = unknown.
  final int batteryLevel;
  final SignalQuality signalQuality;
  final int pingMs;
  final bool isReady;

  /// IP address of the team device.
  final String address;
  final int port;

  Color get colorValue => Color(color);

  TeamModel copyWith({
    String? id,
    String? name,
    int? color,
    String? avatar,
    TeamConnectionState? connectionState,
    int? batteryLevel,
    SignalQuality? signalQuality,
    int? pingMs,
    bool? isReady,
    String? address,
    int? port,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      avatar: avatar ?? this.avatar,
      connectionState: connectionState ?? this.connectionState,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      signalQuality: signalQuality ?? this.signalQuality,
      pingMs: pingMs ?? this.pingMs,
      isReady: isReady ?? this.isReady,
      address: address ?? this.address,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'avatar': avatar,
        'address': address,
        'port': port,
      };

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as int,
        avatar: json['avatar'] as String,
        address: json['address'] as String? ?? '',
        port: json['port'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TeamModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
