import 'package:flutter_webrtc/webrtc.dart';
import 'dart:core';
import 'dart:async';

class RTCHandler {
  MediaStream localStream;
  MediaStream remoteStream;
  RTCPeerConnection _peerConnection;

  /// A callback to the BLoC when required to send an ICE candidate
  /// over the socket
  Function onIceCandidate;
  Function onLocalStream;
  Function onAddRemoteStream;
  Function onRemoveRemoteStream;

  List<dynamic> _pendingIce = List();

  initCallbacks(
      {Function ice,
      Function onLocalStream,
      Function onAddRemoteStream,
      Function onRemoveRemoteStream}) {
    this.onIceCandidate = ice;
    this.onLocalStream = onLocalStream;
    this.onAddRemoteStream = onAddRemoteStream;
    this.onRemoveRemoteStream = onRemoveRemoteStream;
  }

  final Map<String, dynamic> mediaConstraintsVideo = {
    "audio": true,
    "video": {
      "mandatory": {
        "minWidth": '854',
        "minHeight": '480',
        "minFrameRate": '30',
      },
      "facingMode": "user",
      "optional": [],
    }
  };

  final Map<String, dynamic> mediaConstraintsAudio = {
    "audio": {
      "mandatory": {"channelCount": "2", "sampleRate": "48000"},
      "optional": []
    },
  };

  Map<String, dynamic> configuration = {
    "iceServers": [
      {/*"url": "stun:stun.l.google.com:19302"*/},
    ]
  };

  final Map<String, dynamic> constraints = {
    "mandatory": {},
    "optional": [
      {"DtlsSrtpKeyAgreement": false},
    ],
  };

  void handleStatsReport(Timer timer) async {
    if (_peerConnection != null) {
      List<StatsReport> reports = await _peerConnection.getStats();
      reports.forEach((report) {
        print("report => { ");
        print("    id: " + report.id + ",");
        print("    type: " + report.type + ",");
        print("    timestamp: ${report.timestamp},");
        print("    values => {");
        report.values.forEach((key, value) {
          print("        " + key + " : " + value + ", ");
        });
        print("    }");
        print("}");
      });
    }
  }

  Future<MediaStream> getLocalVideo() async {
    localStream = await navigator.getUserMedia(mediaConstraintsVideo);
    return localStream;
  }

  void switchCamera() {
    if (localStream != null) {
      localStream.getVideoTracks()[0].switchCamera();
    }
  }

  void muteMic(bool micMuted) {
    if (localStream != null) {
      localStream.getAudioTracks()[0].setMicrophoneMute(micMuted);
    }
  }

  _onSignalingState(RTCSignalingState state) {
    print(state);
  }

  _onIceGatheringState(RTCIceGatheringState state) {
    print(state);
  }

  _onIceConnectionState(RTCIceConnectionState state) {
    print(state);
  }

  _onAddStream(MediaStream stream) {
    print('addStream: ' + stream.id);
    if (onAddRemoteStream != null) onAddRemoteStream(stream);
    print(stream.getVideoTracks());
  }

  _onRemoveStream(MediaStream stream) {
    if (onRemoveRemoteStream != null) onRemoveRemoteStream(stream);
  }

  _onCandidate(RTCIceCandidate candidate) {
    print('onCandidate: ' + candidate.candidate);

    /// Send this candidate over the socket to peer
    if (onIceCandidate != null) onIceCandidate(candidate.toMap());
  }

  _onRenegotiationNeeded() {
    print('RenegotiationNeeded');
  }

  addICECandidate(Map<String, dynamic> ice) async {
    RTCIceCandidate iceCandidate = new RTCIceCandidate(
        ice['candidate'], ice['sdpMid'], ice['sdpMLineIndex']);
    if (_peerConnection != null) {
      await _peerConnection.addCandidate(iceCandidate);
    } else {
      _pendingIce.add(iceCandidate);
    }
  }

  /// This is the connect method
  /// This initiates a RTC connection creating the OFFER SDP and sending it
  /// back to the caller, and then waits for the answer SDP to set the
  /// Remote Description
  Future<Map<String, dynamic>> connect(bool audio, bool video) async {
    final TAG = 'ClientRTC: ';
    print(TAG + 'Started connection.');

    RTCSessionDescription hostSDP;

    Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": video,
      },
      "optional": [],
    };

    if (_peerConnection != null) {
      //TODO: Handle this error - Already on a call
      print(TAG + 'Already on call!');
      return null;
    }

    try {
      //Initialising local renderer
      print(TAG + 'Initialising Local Stream');
      localStream = await navigator.getUserMedia(//mediaConstraintsVideo);
          (video) ? mediaConstraintsVideo : mediaConstraintsAudio);
      print(TAG + 'Initialised Local Stream');

      if (onLocalStream != null) onLocalStream(localStream);
      print(TAG + 'Initialised local renderer');

      _peerConnection = await createPeerConnection(configuration, constraints);
      print(TAG + 'Created peer connection');

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      _peerConnection.addStream(localStream);

      hostSDP = await _peerConnection.createOffer(offerSdpConstraints);
      // print(TAG + 'SDP Offer: ${hostSDP.sdp}');
      await _peerConnection.setLocalDescription(hostSDP);
    } catch (e) {
      print(e.toString());
    }
    // print(TAG + 'SDP Offer: ${hostSDP.toMap()}');
    return hostSDP.toMap();
  }

  setRemoteDescription(Map<String, dynamic> peerSDP) async {
    final TAG = 'ClientRTC: ';
    // print(TAG + 'SDP Answer Recieved: $peerSDP');
    var peerDescription = RTCSessionDescription(
      peerSDP['sdp'],
      peerSDP['type'],
    );

    await _peerConnection.setRemoteDescription(peerDescription);

    localStream.getAudioTracks()[0].setMicrophoneMute(false);
    // Timer.periodic(Duration(seconds: 10), handleStatsReport);
  }

  Future<Map<String, dynamic>> recieve(
      Map<String, dynamic> peerSDPMap, bool video) async {
    final TAG = 'ServerRTC: ';
    // print(TAG + 'SDP Offer Recieved: $peerSDPMap');
    var answerSDP;
    var peerSDP = RTCSessionDescription(peerSDPMap['sdp'], peerSDPMap['type']);

    // if (_peerConnection != null) {
    //   print(TAG + 'Connection Error');
    //   return null;
    // }

    Map<String, dynamic> answerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": video,
      },
      "optional": [],
    };

    try {
      //Initialising local renderer
      print(TAG + 'Initialising Local Stream');
      localStream = await navigator.getUserMedia(//mediaConstraintsVideo);
          (video) ? mediaConstraintsVideo : mediaConstraintsAudio);
      print(TAG + 'Initialised Local Stream');

      if (onLocalStream != null) onLocalStream(localStream);
      print(TAG + 'Initialised local renderer');

      _peerConnection = await createPeerConnection(configuration, constraints);
      print(TAG + 'Created peer connection');

      _peerConnection.onSignalingState = _onSignalingState;
      _peerConnection.onIceGatheringState = _onIceGatheringState;
      _peerConnection.onIceConnectionState = _onIceConnectionState;
      _peerConnection.onAddStream = _onAddStream;
      _peerConnection.onRemoveStream = _onRemoveStream;
      _peerConnection.onIceCandidate = _onCandidate;
      _peerConnection.onRenegotiationNeeded = _onRenegotiationNeeded;

      await _peerConnection.addStream(localStream);
      print(TAG + 'Added Local Stream');

      await _peerConnection.setRemoteDescription(peerSDP);
      answerSDP = await _peerConnection.createAnswer(constraints);
      // print(TAG + 'Answer SDP Created | SDP: ${answerSDP.sdp}');

      await _peerConnection.setLocalDescription(answerSDP);

      if (this._pendingIce.length > 0) {
        _pendingIce.forEach((candidate) async {
          await _peerConnection.addCandidate(candidate);
        });
        _pendingIce.clear();
      }
      localStream.getAudioTracks()[0].setMicrophoneMute(false);

      print(TAG + 'Completed Server Side Connecition!');

      ///Connection complete
    } catch (e) {
      print(e.toString());
    }
    return answerSDP.toMap();
  }

  hangUp() async {
    try {
      print('Initialting Hang UP');
      if (localStream != null) await localStream.dispose();
      if (_peerConnection != null) await _peerConnection.close();
      _peerConnection = null;
      localStream = null;
      remoteStream = null;

      /// Disposing the callbacks:
      onIceCandidate = null;
      onLocalStream = null;
      onAddRemoteStream = null;
      onRemoveRemoteStream = null;
      _pendingIce.clear();
    } catch (e) {
      print(e.toString());
    }
  }
}
