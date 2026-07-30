import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../domain/models/packet_model.dart';

/// Encodes and decodes packets using length-prefixed framing.
///
/// Wire format: [4-byte big-endian length][UTF-8 JSON payload]
///
/// This framing ensures packet boundaries are preserved over a stream socket.
class PacketCodec {
  PacketCodec._();

  /// Encode a [PacketModel] to length-prefixed bytes.
  static Uint8List encode(PacketModel packet) => packet.toBytes();

  /// Decode a single packet from raw bytes (without the length prefix).
  static PacketModel decode(Uint8List jsonBytes) {
    final jsonStr = utf8.decode(jsonBytes);
    return PacketModel.fromJsonString(jsonStr);
  }

  /// Returns a [Stream<PacketModel>] that reassembles packets from a raw
  /// [Socket] byte stream.
  ///
  /// Each packet is prefixed with a 4-byte big-endian length.
  static Stream<PacketModel> framer(Stream<Uint8List> rawStream) async* {
    final buffer = <int>[];
    await for (final chunk in rawStream) {
      buffer.addAll(chunk);
      while (true) {
        if (buffer.length < 4) break;

        // Read the length prefix.
        final length = (buffer[0] << 24) |
            (buffer[1] << 16) |
            (buffer[2] << 8) |
            buffer[3];

        // Sanity check: reject absurdly large packets.
        if (length > 1024 * 1024) {
          buffer.clear();
          break;
        }

        if (buffer.length < 4 + length) break;

        // Extract the JSON payload.
        final jsonBytes = Uint8List.fromList(
          buffer.sublist(4, 4 + length),
        );
        buffer.removeRange(0, 4 + length);

        try {
          yield decode(jsonBytes);
        } catch (_) {
          // Malformed packet – skip and continue.
        }
      }
    }
  }
}
