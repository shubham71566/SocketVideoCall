import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/model/user.dart';
import 'package:video_call/socket/socket_client.dart';
import 'package:flutter_incall/flutter_incall.dart';
import 'package:video_call/socket/socket_server.dart';
import 'package:video_call/web-rtc/rtc_handler.dart';

class Repository {
  Client _client = Client();
  final Server _server = Server();
  User host;
  final rtcHandler = RTCHandler();

  final incallManager = new IncallManager();

  final TAG = 'Repository: ';

  void initClientRTC(
      {onLocalStream, onAddRemoteStream, onRemoveRemoteStream}) async {
    await rtcHandler.initCallbacks(
      ice: (ice) => _cSendIce(ice),
      onLocalStream: onLocalStream,
      onAddRemoteStream: onAddRemoteStream,
      onRemoveRemoteStream: onRemoveRemoteStream,
    );
  }

  Future<dynamic> getLocalVideo() async {
    return rtcHandler.getLocalVideo();
  }

  void connect({User peer, type, end, decline, accept, connected}) async {
    incallManager.start(
      media: (type == CallType.video) ? MediaType.VIDEO : MediaType.AUDIO,
      // media: MediaType.VIDEO,
      ringback: '_DTMF_',
    );
    var prefs = await SharedPreferences.getInstance();
    _client.connect(
      host: User(name: prefs.getString('name') ?? 'UNKNOWN', ip: ''),
      peer: peer,
      type: type,
      onDone: () {
        ///Peer/ Server closed connection!
        print(TAG + "Peer/ Server closed connection!");
        _client.disconnect();
        incallManager.stop();
        rtcHandler.hangUp();
        end();
      },
      onError: () {
        ///Error in between communication!
        print(TAG + "Error in between communication!");
        incallManager.stop();
        rtcHandler.hangUp();
        end();
      },
      peerBusy: () {
        _client.disconnect();
        incallManager.stop(busytone: '_DTMF_');
        decline(CallEventBusy());
      },
      peerReject: () {
        _client.disconnect();
        incallManager.stop(busytone: '_DTMF_');
        decline(CallEventBusy());
      },
      peerAccept: () => _cAccept(type),
      peerSDP: (sdp) => _cSdp(sdp, connected),
      ice: (ice) => _onReceiveIce(ice),
    );
  }

  void cDisconnect() {
    _client.disconnect();
    incallManager.stop();
    rtcHandler.hangUp();
  }

  _cSdp(sdp, connected) async {
    ///Send the peer SDP back to RTC and complete the connection
    await rtcHandler.setRemoteDescription(sdp);
    if (connected != null) connected();
  }

  _cAccept(type) async {
    print(TAG + 'Call Accepted | State: CALLING');

    ///Initiate RTC connection and then send SDP
    var offerSDP = await rtcHandler.connect(true, (type == CallType.video));
    // print(TAG + 'Offer SDP created | SDP: $offerSDP');
    _client.sendOfferSDP(offerSDP);
    incallManager.stopRingback();
  }

  _onReceiveIce(ice) async {
    /// This will send RTC handler the ICE that was recieved through the socket

    print(TAG + 'ICE candidate recieved : $ice');
    await rtcHandler.addICECandidate(ice);
  }

  _cSendIce(ice) async {
    /// The ICE to be sent from RTC handler is sent through Socket
    print(TAG + 'ICE candidate to be sent : $ice');
    await _client.sendICECandidate(ice);
  }

  void muteMic(bool micMuted) {
    rtcHandler.muteMic(micMuted);
  }

  void switchCam() {
    rtcHandler.switchCamera();
  }

  void initServerRTC(
      {onLocalStream, onAddRemoteStream, onRemoveRemoteStream}) async {
    await rtcHandler.initCallbacks(
      ice: (ice) => _sSendIce(ice),
      onLocalStream: onLocalStream,
      onAddRemoteStream: onAddRemoteStream,
      onRemoveRemoteStream: onRemoveRemoteStream,
    );
  }

  void initServer({
    call,
    onDone,
    connected,
  }) async {
    print(TAG + "Initialised Server");
    var prefs = await SharedPreferences.getInstance();
    var _type;
    _server.init(
      hostInfo: User(name: prefs.getString('name') ?? 'UNKNOWN', ip: ''),
      incomingCall: (User peer, type) {
        print(TAG +
            'Incoming Call event added! Peer: ${peer.name} | ${peer.ip} Call Type: $type');
        _type = type;
        call(peer, type);
      },
      ice: _onReceiveIce,
      onDone: () => _onDone(onDone),
      sdp: (sdp) =>
          _sSdp(sdp, ((_type ?? CallType.audio) == CallType.video), connected),
    );
  }

  _onDone(onDone) {
    rtcHandler.hangUp();
    incallManager.stop();
    if (onDone != null) onDone();
  }

  void serverBusy() {
    _server.hostBusy();
  }

  void startRingtone() {
    incallManager.startRingtone(RingtoneUriType.DEFAULT, 'default', 30);
  }

  void accept(type) {
    incallManager.stopRingtone();
    incallManager.start(
      media: (type == CallType.video) ? MediaType.VIDEO : MediaType.AUDIO,
      // media: MediaType.VIDEO,
    );
    _server.hostAccept();
  }

  void stopRingtone() {
    incallManager.stopRingtone();
    incallManager.stop();
  }

  void hostReject() {
    rtcHandler.hangUp();
    incallManager.stopRingtone();
    _server.hostReject();
  }

  void updateHost(host) {
    _server.host = host;
  }

  void sDisconnect() {
    _server.disconnect();
    rtcHandler.hangUp();
    incallManager.stop();
  }

  _sSdp(sdp, video, connected) async {
    var answerSDP = await rtcHandler.recieve(sdp, video);
    // print(TAG + 'SDP recieved SDP: $answerSDP');
    _server.sendAnswerSDP(answerSDP);
    connected();
  }

  _sSendIce(ice) async {
    /// The ICE to be sent from RTC handler is sent through Socket
    print(TAG + 'ICE candidate to be sent : $ice');
    await _server.sendICECandidate(ice);
  }
}
