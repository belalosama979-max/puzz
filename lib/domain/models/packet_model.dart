import 'dart:convert';
import 'dart:typed_data';

/// All packet types used in the BuzzMaster protocol.
enum PacketType {
  joinRequest,
  joinAccepted,
  joinRejected,
  teamListUpdate,
  roundOpen,
  roundClose,
  roundReset,
  buzz,
  buzzAck,
  winner,
  lock,
  unlock,
  kick,
  heartbeat,
  heartbeatAck,
  disconnect,
  competitionEnd,
  pause,
  resume,
  acceptAnswer,
  rejectAnswer,
  reopenBuzz,
  batteryUpdate,
}

/// Extension to convert enum to/from wire string.
extension PacketTypeExt on PacketType {
  String get wireValue {
    const map = {
      PacketType.joinRequest: 'JOIN_REQUEST',
      PacketType.joinAccepted: 'JOIN_ACCEPTED',
      PacketType.joinRejected: 'JOIN_REJECTED',
      PacketType.teamListUpdate: 'TEAM_LIST_UPDATE',
      PacketType.roundOpen: 'ROUND_OPEN',
      PacketType.roundClose: 'ROUND_CLOSE',
      PacketType.roundReset: 'ROUND_RESET',
      PacketType.buzz: 'BUZZ',
      PacketType.buzzAck: 'BUZZ_ACK',
      PacketType.winner: 'WINNER',
      PacketType.lock: 'LOCK',
      PacketType.unlock: 'UNLOCK',
      PacketType.kick: 'KICK',
      PacketType.heartbeat: 'HEARTBEAT',
      PacketType.heartbeatAck: 'HEARTBEAT_ACK',
      PacketType.disconnect: 'DISCONNECT',
      PacketType.competitionEnd: 'COMPETITION_END',
      PacketType.pause: 'PAUSE',
      PacketType.resume: 'RESUME',
      PacketType.acceptAnswer: 'ACCEPT_ANSWER',
      PacketType.rejectAnswer: 'REJECT_ANSWER',
      PacketType.reopenBuzz: 'REOPEN_BUZZ',
      PacketType.batteryUpdate: 'BATTERY_UPDATE',
    };
    return map[this]!;
  }

  static PacketType fromWire(String s) {
    const map = {
      'JOIN_REQUEST': PacketType.joinRequest,
      'JOIN_ACCEPTED': PacketType.joinAccepted,
      'JOIN_REJECTED': PacketType.joinRejected,
      'TEAM_LIST_UPDATE': PacketType.teamListUpdate,
      'ROUND_OPEN': PacketType.roundOpen,
      'ROUND_CLOSE': PacketType.roundClose,
      'ROUND_RESET': PacketType.roundReset,
      'BUZZ': PacketType.buzz,
      'BUZZ_ACK': PacketType.buzzAck,
      'WINNER': PacketType.winner,
      'LOCK': PacketType.lock,
      'UNLOCK': PacketType.unlock,
      'KICK': PacketType.kick,
      'HEARTBEAT': PacketType.heartbeat,
      'HEARTBEAT_ACK': PacketType.heartbeatAck,
      'DISCONNECT': PacketType.disconnect,
      'COMPETITION_END': PacketType.competitionEnd,
      'PAUSE': PacketType.pause,
      'RESUME': PacketType.resume,
      'ACCEPT_ANSWER': PacketType.acceptAnswer,
      'REJECT_ANSWER': PacketType.rejectAnswer,
      'REOPEN_BUZZ': PacketType.reopenBuzz,
      'BATTERY_UPDATE': PacketType.batteryUpdate,
    };
    return map[s] ?? (throw ArgumentError('Unknown packet type: $s'));
  }
}

/// A network packet in the BuzzMaster protocol.
class PacketModel {
  const PacketModel({
    required this.type,
    required this.senderId,
    required this.timestamp,
    required this.sequenceNumber,
    this.payload = const {},
  });

  final PacketType type;
  final String senderId;

  /// UTC epoch milliseconds when the packet was created.
  final int timestamp;

  /// Monotonically increasing per sender.
  final int sequenceNumber;

  /// Arbitrary payload data.
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'type': type.wireValue,
        'senderId': senderId,
        'timestamp': timestamp,
        'seq': sequenceNumber,
        'payload': payload,
      };

  factory PacketModel.fromJson(Map<String, dynamic> json) => PacketModel(
        type: PacketTypeExt.fromWire(json['type'] as String),
        senderId: json['senderId'] as String,
        timestamp: json['timestamp'] as int,
        sequenceNumber: json['seq'] as int? ?? 0,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
      );

  String toJsonString() => jsonEncode(toJson());

  factory PacketModel.fromJsonString(String s) =>
      PacketModel.fromJson(jsonDecode(s) as Map<String, dynamic>);

  /// Encode as length-prefixed bytes: [4-byte BE length][UTF-8 JSON]
  Uint8List toBytes() {
    final jsonBytes = utf8.encode(toJsonString());
    final buffer = ByteData(4 + jsonBytes.length);
    buffer.setUint32(0, jsonBytes.length, Endian.big);
    final result = buffer.buffer.asUint8List();
    result.setRange(4, result.length, jsonBytes);
    return result;
  }
}
