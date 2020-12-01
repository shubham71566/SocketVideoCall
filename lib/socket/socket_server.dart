import 'dart:io';
import 'package:video_call/model/user.dart';
import 'package:video_call/socket/socket.dart';

///A Server to listen on a port and handle incoming connections.
///
///
///Steps followed by the server:
///
///1) Initiate a port listen.
///2) Send a "HELLO" command with User info (Name) to every incoming connection,
///   wait for a "HELLO" command reply with info (Name).
///3) Wait for a "CALL" command reply from client,
///   if it's a scan for available peers, the client might close connection.
///4) Next Action:
///   -If user is already on a call, send a "BUSY" command and close.
///   -Initiate a Incoming call screen to display to the user.
///     -- If user REJECTs the call, send "REJECT" command, and close.
///     -- If user ACCEPTs the call, send "ACCEPT" command.
///5) Initiate RTC and then wait for the "SDP" command with SDP info from the client.
///6) Send user SDP info to client with "SDP" command.
///7) Wait for and send ICE candidates by RTC.
const TAG = "Server: ";

class Server {
  //The client that we can communicate with.
  Socket _client;
  User _clientInfo;
  User _hostInfo;
  Function _incomingCall;
  Function(dynamic) _sdp;
  Function(dynamic) _ice;
  Function _onDone;

  final _message = Message();

  bool get isConnected => (_client != null);

  set host(User host) {
    this._hostInfo = host;
  }

  void init(
      {User hostInfo,
      Function incomingCall,
      Function onDone,
      Function sdp,
      Function ice}) {
    this._hostInfo = hostInfo;
    this._incomingCall = incomingCall;
    this._sdp = sdp;
    this._ice = ice;
    this._onDone = onDone;
    try {
      ///1) Initiating the port listen
      ServerSocket.bind(InternetAddress.anyIPv4, SOCKET_PORT)
          .then((ServerSocket server) {
        this._hostInfo = _hostInfo.copyWith(ip: server.address.host);
        server.listen(
          handleClient,
        );
      });
    } catch (e) {
      print(TAG +
          "FATAL! Error initialising Server!! Exception: " +
          e.toString());
    }
  }

  void handleClient(Socket client) {
    //Debug INFO
    print(TAG +
        'Incoming Connection from '
            '${client.remoteAddress.address}:${client.remotePort}');

    //4) Check if BUSY and send BUSY command.
    if (isConnected) {
      _sendMessage(command: 'BUSY');
      client.close();
      return;
    }

    _client = client;

    //Initialise Client IP with UNKNOWN creds if the client doesnt send HELLO command
    _clientInfo = User(name: "UNKNOWN", ip: "0.0.0.0");

    ///Listen to the client messages and handle the reply
    _client.listen(
      handleReply,
      onDone: () {
        print(TAG + 'Connection closed!');
        _onDone();
        disconnect();
      },
      onError: (e) {
        _onDone();
        print(TAG + 'Error in connection! Connection closed!');
        disconnect();
      },
      cancelOnError: true,
    );
  }

  _sendMessage({String command, String message = ''}) async {
    if (_client != null) {
      _client.write(
          _message.encode({'command': command, 'message': message}) + '~~');
      print(TAG + 'Wrote command: $command');
    }
  }

  _sendMap({String command, Map<String, dynamic> message}) {
    if (_client != null) {
      Map map = Map();
      map['command'] = command;
      map['message'] = message;
      _client.write(_message.encode(map) + '~~');
      print(TAG + 'Wrote command: $command');
    }
  }

  var _incompletes = "";

  void handleReply(dynamic data) {
    var raw = String.fromCharCodes(data).trim();
    if (raw.contains('~~')) {
      raw = _incompletes + raw;
      var rawResponses = raw.split('~~');
      for (var rawResponse in rawResponses) {
        if (rawResponse.startsWith('{') && rawResponse.endsWith('}')) {
          _decode(rawResponse);
        }
        // } else if (rawResponse.startsWith('{')) {
        //   print(TAG + "This message has ending incomplete! : $rawResponse");
        //   _incompletes.add(rawResponse);
        // } else if (rawResponse.endsWith('}')) {
        //   print(TAG + "This message has starting incomplete! : $rawResponse");
        //   if (_incompletes.length > 0) {
        //     for (var _incomplete in _incompletes)
        //       _decode(_incomplete + rawResponse);
        //     _incompletes.clear();
        //   }
        // }
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

      ///2) The client *MUST* send a HELLO response with the name
      ///   Syntax: HELLO\nNAME\n  (Where NAME is the name of client)
      case "HELLO":
        _clientInfo =
            User(name: command.message, ip: _client.remoteAddress.address);

        ///2) Send the HELLO command
        _sendMessage(command: "HELLO", message: _hostInfo.name);
        break;

      case "CALL":

        /// 3) & 4) Wait for CALL command and launch Incoming Call Screen
        //  and send response either: "BUSY", "REJECT" or "ACCEPT" (Handled by BLoC)
        var type = CallType.audio;
        if (command.message == 'VIDEO') type = CallType.video;
        _incomingCall(_clientInfo, type);
        break;

      case "SDP":

        /// 5) When the SDP is recieved, initiate RTC connection
        var sdp = command.message;
        print(TAG + 'SDP Response: ${sdp['sdp']} ${sdp['type']}');
        _sdp(sdp);
        break;

      case "ICE":

        /// 6) When ICE candidate is sent, just pass it on to RTC
        var ice = _message.decode(command.message);
        print(TAG + 'ICE Candidate: $ice');
        _ice(ice);
        break;

      default:
        //Command not found! Quit the connection with "ERROR" command
        disconnect();
    }
  }

  //These will be called by the bloc for respective messages
  void hostBusy() {
    _sendMessage(command: 'BUSY');
    disconnect();
  }

  void hostReject() {
    _sendMessage(command: 'REJECT');
    disconnect();
  }

  void hostAccept() => _sendMessage(command: 'ACCEPT');

  /// 6) Send host SDP to client
  void sendAnswerSDP(Map<String, dynamic> sdp) {
    _sendMap(command: 'SDP', message: {'sdp': sdp['sdp'], 'type': sdp['type']});
  }

  void sendICECandidate(Map<String, dynamic> ice) {
    _sendMessage(command: 'ICE', message: _message.encode(ice));
  }

  void disconnect() {
    _incompletes = "";
    if (_client != null) {
      print(TAG + "Initiating Client disconnect!");
      _client.destroy();
      _client = null;
    }
  }
}
