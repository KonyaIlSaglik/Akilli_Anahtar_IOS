import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:loggerx/loggerx.dart';

import 'src/my_aes.dart';
import 'src/my_bottleneck.dart';
import 'src/my_crc.dart';
import 'src/my_exceptions.dart';
import 'src/my_provisioning_request.dart';
import 'src/my_provisioning_response.dart';

/// Provisioning protocol
abstract class MyProtocol {
  /// Protocol name
  String get name;

  /// Network broadcast address
  static final broadcastAddress =
      InternetAddress.fromRawAddress(Uint8List.fromList([234, 1, 1, 1]));

  /// UDP port of Esp device
  static final devicePort = 7001;

  /// UDP socket used for sending and receiving packets
  late final RawDatagramSocket _socket;

  /// Index of protocol port
  late final int portIndex;

  /// Provisioning request
  late final MyProvisioningRequest request;

  /// Protocol bottlenecker
  final bottleneck = MyBottleneck(15);

  /// Logger
  late final Logger logger;

  /// List of the protocol [ports].
  /// Provisioner will take one port after the another and try to open it.
  /// After first successfully opened port provisioner will stop and set
  /// the [portIndex] of opened port
  List<int> get ports => [18266];

  /// Blocks that needs to be transmitted to device
  final blocks = <int>[];

  int _blockIndex = 0;

  final _responsesList = <MyProvisioningResponse>[];

  /// Send block and return index of sent block.
  ///
  /// If sending is gonna be sent through the [bottleneck], and
  /// [bottleneck] has not pass, function will return null which means
  /// that block is not sent in [bottleneck] flow
  int? sendBlock({MyBottleneck? bottleneck, Function()? onAllBlocksSent}) {
    int? sentBlockIndex;

    void _() {
      sentBlockIndex = _blockIndex;
      send(Uint8List(blocks[_blockIndex++]));

      if (_blockIndex >= blocks.length) {
        _blockIndex = 0;

        if (onAllBlocksSent != null) {
          onAllBlocksSent();
        }
      }
    }

    if (bottleneck != null) {
      bottleneck.flow(_);
    } else {
      _();
    }

    return sentBlockIndex;
  }

  /// Protocol installation
  void install(RawDatagramSocket socket, int portIndex,
      MyProvisioningRequest request, Logger logger) {
    _socket = socket;
    this.portIndex = portIndex;
    this.request = request;
    this.logger = logger;
  }

  /// Prepare package, set variables, etc...
  void prepare() {}

  /// Loop is invoked by provisioner [timer]
  /// in very short [stepMs] intervals, typically 1-20 ms.
  void loop(int stepMs, Timer timer) {
    sendBlock(bottleneck: bottleneck);
  }

  /// Find response in [_responsesList] by [bssid]
  MyProvisioningResponse? findResponse(MyProvisioningResponse response) {
    for (var r in _responsesList) {
      if (r == response) {
        return r;
      }
    }

    return null;
  }

  /// Returns added response
  ///
  /// Throws [ProvisioningResponseAlreadyReceivedError] if same response already exists
  MyProvisioningResponse addResponse(MyProvisioningResponse response) {
    final foundResponse = findResponse(response);

    if (foundResponse != null) {
      throw MyProvisioningResponseAlreadyReceivedError(
          "Response ($foundResponse) already received");
    }

    _responsesList.add(response);
    return response;
  }

  /// Sends a [buffer]
  int send(List<int> buffer) {
    return _socket.send(buffer, broadcastAddress, devicePort);
  }

  /// Receive data and returns response with device BSSID
  ///
  /// Throws [InvalidProvisioningResponseDataException] if data of received response is invalid
  MyProvisioningResponse receive(Uint8List data) {
    if (data.length < 7) {
      throw MyInvalidProvisioningResponseDataException(
          "Invalid data ($data). Length should be at least 7 elements");
    }

    return MyProvisioningResponse(
        Uint8List(6)..setAll(0, data.skip(1).take(6)));
  }

  /// Number of milliseconds since Unix epoch
  static int ms() => DateTime.now().millisecondsSinceEpoch;

  /// Number of milliseconds since Unix epoch
  int millis() => ms();

  /// Cast signed byte [s8] to unsigned byte [u8]
  int u8(int s8) => s8 & 0xFF;

  /// Cast signed 16 bit integer [s16] into unsigned 16 bit integer [u16]
  int u16(int s16) => s16 & 0xFFFF;

  /// Merge high/low nibbles into new unsigned byte
  int merge8(int high, int low) => u8((high << 4) | low);

  /// Spit unsigned [byte] to high and low nibbles
  Uint8List split8(int byte) =>
      Uint8List.fromList([(byte & 0xF0) >> 4, byte & 0x0F]);

  /// Merge two unsigned bytes ([high] and [low]) into new unsigned 16 bit integer
  int merge16(int high, int low) => u16((high << 8) | low);

  /// CRC of [data]
  int crc(Int8List data) => MyCrc.calculate(data);

  /// Returns encrypted [data] that is encrypted with the [key]
  Int8List encrypt(Int8List data, Int8List key) => MyAes.encrypt(data, key);

  /// Returns true if [data] is encoded
  bool isEncoded(Int8List data) => data.any((byte) => byte.isNegative);

  @override
  String toString() => name;
}
