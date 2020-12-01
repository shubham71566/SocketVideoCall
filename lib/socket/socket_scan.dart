import 'dart:io';
import 'package:video_call/model/user.dart';

import './socket.dart';

final TAG = 'Socket Scan: ';

/// Using the broadcast address to find for peers

class SocketScan {
  RawDatagramSocket _socket;
  final _message = Message();
  User _host;
  String _hello, _scan;
  Function _update;

  List<User> _activeIPs = List();

  void init({User host, Function updateUsers}) {
    _update = updateUsers;
    print('Scan Init: Host given: ${host.ip}');
    _host = host;
    _hello = _message.encode({'command': 'HELLO', 'message': host.name});
    _scan = _message.encode({'command': 'SCAN', 'message': host.name});
    RawDatagramSocket.bind(InternetAddress.anyIPv4, UDP_PORT)
        .then((RawDatagramSocket socket) {
      socket.broadcastEnabled = true;
      print('Datagram socket ready to receive');
      print('${socket.address.address}:${socket.port}');
      _socket = socket;
      socket.listen((RawSocketEvent e) {
        handleReply();
      });
    });
  }

  void updateHost(User host) {
    _host = host;
  }

  Future<void> scan() async {
    if (_socket == null) return;
    if (_host.ip.isEmpty) return;
    print('Scan: Host value: ${_host.ip}');
    var brdcst = _host.ip.substring(0, _host.ip.lastIndexOf('.') + 1) + '255';
    print(TAG + 'Broadcast address: ' + brdcst);
    var broadcast = InternetAddress(brdcst);
    _socket.send(_scan.codeUnits, broadcast, UDP_PORT);

    /// Wait Half a second to wait for replies
    await Future.delayed(Duration(milliseconds: 500));
  }

  void handleReply() {
    Datagram d = _socket.receive();
    if (d == null) return;
    String message = new String.fromCharCodes(d.data).trim();
    print('Datagram from ${d.address.address}:${d.port}: $message');
    try {
      var _decoded = _message.decode(message);
      var command = Command(_decoded['command'], _decoded['message']);
      _mapCommandToResponse(command, d);
    } catch (e) {
      /// Ignore the packet
      print("Couldn't decode message: $message Due to : ${e.toString()}");
    }
    //Call MapResponseToAction
  }

  _mapCommandToResponse(Command command, dynamic d) {
    switch (command.command) {
      case 'SCAN':

        /// Ping the sender HELLO command with the host name
        if (command.message != _host.name) {
          print(
              'SCAN Command: Updated user: ${command.message}, ${d.address.address}');
          _updateUsers(command.message, d.address.address);
          _socket.send(_hello.codeUnits, d.address, d.port);
          print('Sent the datagram to : ${d.address.address}, ${d.port}');
        } else {
          print('Found self at IP: ${d.address.address}');
        }
        break;

      case 'HELLO':

        /// Update the user list with the peer's name
        print(
            'HELLO Command: Updated user: ${command.message}, ${d.address.address}');
        _updateUsers(command.message ?? "UNKNOWN", d.address.address);
    }
  }

  _updateUsers(String name, String ip) {
    if (ip != _host.ip) {
      print('Added user $name to list!!');
      for (var i = 0; i < _activeIPs.length; i++) {
        if (_activeIPs[i].ip == ip) {
          _activeIPs[i] = _activeIPs[i].copyWith(name: name);
          (_update != null)
              ? _update(_activeIPs)
              : print("Unable to call Update from the Home Screen");
          return;
        }
      }

      /// If the IP does not already exist, add it as a new entry
      _activeIPs.add(User(ip: ip, name: name));
      (_update != null)
          ? _update(_activeIPs)
          : print("Unable to call Update from the Home Screen");
    } else
      print('Found self at IP: $ip');
  }
}
