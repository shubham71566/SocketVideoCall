import 'dart:convert';

const int SOCKET_PORT = 1111;
const int UDP_PORT = 2222;

class Command {
  final String command;
  final message;

  const Command(this.command, this.message);
}

class Message {
  JsonEncoder _encoder = new JsonEncoder();
  JsonDecoder _decoder = new JsonDecoder();

  String encode(message) {
    return _encoder.convert(message);
  }

  Map<String, dynamic> decode(String message) {
    return _decoder.convert(message);
  }
}
