import 'dart:io';
import 'package:video_call/model/user.dart';

import './socket.dart';

///A Client to initiate a connection on a listening port of the peer.
///
///
///Steps followed by the client:
///
///1) Initiate a connect with the specified port no.
///2) Send a "HELLO" command with User info (Name),
///   wait for a "HELLO" command reply with info (Name).
///3) Send a "CALL" command.
///4) Wait for a reply command:
///   -"BUSY" / "REJECT"  command - inform user and close connection.
///   -"ACCEPT" command - continue.
///5) Initiate RTC and send the "SDP" command with SDP info.
///6) Wait for "SDP" command of server with SDP info.
///7) Wait for and send ICE candidates by RTC.

const TAG = 'Clinet: ';

class Client {
  Socket _socket;
  User _host;
  User _peer;
  var _type;
  Function _onDoneCallback;
  Function _peerBusy;
  Function _peerReject;
  Function _peerAccept;
  Function _peerSDP;
  Function(dynamic) _ice;

  final _message = Message();

  void connect({
    User host, //required
    User peer, //required
    var type, //required
    Function onDone, //required
    Function onError, //required
    Function peerBusy, //required
    Function peerReject, //required
    Function peerAccept, //required
    Function peerSDP, //required
    Function ice,
  }) async {
    _host = host;
    _peer = peer;
    _type = type;
    _onDoneCallback = onDone;
    _peerBusy = peerBusy;
    _peerReject = peerReject;
    _peerAccept = peerAccept;
    _peerSDP = peerSDP;
    _ice = ice;
    try {
      await Socket.connect(_peer.ip, SOCKET_PORT).then((socket) {
        this._host = _host.copyWith(ip: socket.address.host);
        print(TAG + "Host Address: ${_host.ip}");

        /// 1) Initiate a socket connection
        print(TAG +
            'Connected to: '
                '${socket.remoteAddress.address}:${socket.remotePort}');

        _socket = socket;

        socket.listen(handleReply,
            onDone: _onDone, onError: (e) => onError(), cancelOnError: true);
        _sendMessage(command: "HELLO", message: _host.name);
      });
    } catch (e) {
      //TODO: IP doesn't exist!
      onError();
      print(TAG + "Error: " + e.toString());
    }
  }

  _sendMessage({String command, String message = ''}) {
    if (_socket != null) {
      _socket.write(
          _message.encode({'command': command, 'message': message}) + '~~');
      print(TAG + 'Wrote command: $command');
    }
  }

  _sendMap({String command, Map<String, dynamic> message}) {
    if (_socket != null) {
      var map = Map<String, dynamic>();
      map['command'] = command;
      map['message'] = message;
      _socket.write(_message.encode(map) + '~~');
      print(TAG + 'Wrote command: $command');
    }
  }

  var _incompletes = "";

  void handleReply(dynamic data) {
    var raw = String.fromCharCodes(data).trim();
    if (raw.contains('~~')) {
      raw = _incompletes + raw;
      _incompletes = "";
      var rawResponses = raw.split('~~');
      for (var rawResponse in rawResponses) {
        if (rawResponse.startsWith('{') && rawResponse.endsWith('}')) {
          _decode(rawResponse);
        }
      }
    } else {
      _incompletes += raw;
    }
  }

  void _decode(rawResponse) {
    /// The message has been transferred properly
    try {
      print(TAG + rawResponse);
      //Call MapResponseToAction
      var responses = _message.decode(rawResponse);
      //Checking for discrepencies to be implemented later
      // print(TAG + 'Response Split List: $responses');
      var command = Command(responses['command'], responses['message']);
      _mapCommandToAction(command);
    } catch (e) {
      print(TAG + "Couldn't decode message! : $rawResponse");
    }
  }

  void _mapCommandToAction(Command command) {
    switch (command.command) {
      case "HELLO":

        ///3) Send CALL command
        _sendMessage(
            command: "CALL",
            message: (_type == CallType.video) ? 'VIDEO' : 'AUDIO');
        break;

      /// 4) Wait for either one of the following 3 replies
      case "BUSY":
        _peerBusy();
        disconnect();
        break;

      case "REJECT":
        _peerReject();
        disconnect();
        break;

      case "ACCEPT":
        _peerAccept();

        /// 5) Initiate RTC connection and send SDP
        break;

      case "SDP":

        /// 6) Wait for SDP message from server
        var sdp = command.message;
        print(TAG + 'SDP: $sdp');
        _peerSDP(sdp);
        break;

      case "ICE":

        /// 6) When ICE candidate is sent, just pass it on to RTC
        var ice = _message.decode(command.message);
        print(TAG + 'ICE Candidate: $ice');
        _ice(ice);
        break;

      default:
        //TODO: Command not found! Quit the connection
        disconnect();
    }
  }

  /// 5) Initiate RTC connection and send SDP
  void sendOfferSDP(Map<String, dynamic> sdp) {
    _sendMap(command: 'SDP', message: {'sdp': sdp['sdp'], 'type': sdp['type']});
  }

  void sendICECandidate(Map<String, dynamic> ice) {
    _sendMessage(command: 'ICE', message: _message.encode(ice));
  }

  void _onDone() {
    _incompletes = "";
    print(TAG + "PEER has closed the connection!");
    _onDoneCallback();
    if (_socket != null) _socket.destroy();
  }

  void disconnect() {
    _incompletes = "";
    if (_socket != null) {
      print(TAG + "Initiating Server disconnect!");
      _socket.destroy();
      _socket = null;
    }
  }
}
