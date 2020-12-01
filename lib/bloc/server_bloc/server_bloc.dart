import 'dart:async';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/socket/repository.dart';

part 'server_event.dart';
part 'server_state.dart';

class ServerBloc extends Bloc<ServerEvent, ServerState> {
  final TAG = "Server BLOC: ";
  final _repository;
  User _peer;
  CallType _type;

  final CallUIBloc _callUIBloc;

  ServerBloc(this._callUIBloc, this._repository) : super(ServerStateInitial()) {
    bool _micMuted = false;
    bool _camRear = false;
    _callUIBloc.listen((state) {
      if (state is CallUIStateInitRenderers) {
        _repository.initServerRTC(
          onLocalStream: state.onLocalStream,
          onAddRemoteStream: state.onAddRemoteStream,
          onRemoveRemoteStream: state.onRemoveRemoteStream,
        );
      } else if (state is CallUIStateConnected) {
        if (_micMuted != state.micMuted) {
          _micMuted = state.micMuted;
          _repository.muteMic(_micMuted);
        }
        if (_camRear != state.camRear) {
          _camRear = state.camRear;
          _repository.switchCam();
        }
      } else if (state is CallUIStateDeclined) if (state.status == Status.END)
        add(ServerEventCallEnd());
    });
  }

  @override
  Stream<ServerState> mapEventToState(
    ServerEvent event,
  ) async* {
    if (event is ServerEventInit)
      yield* _mapInitToState(event);
    else if (event is ServerEventCall)
      yield* _mapCallToState(event);
    else if (event is ServerEventCallAccept)
      yield* _mapAcceptToState(event);
    else if (event is ServerEventCallConnected)
      yield* _mapConnectedToState(event);
    else if (event is ServerEventCallReject || event is ServerEventCallEnd)
      yield* _mapEndToState(event);
    else if (event is ServerEventUpdateHost)
      yield* _mapUpdateHost(event);
    else
      throw Exception("EventNotFound");
  }

  Stream<ServerState> _mapInitToState(ServerEventInit event) async* {
    print(TAG + "Initialised Server");
    _repository.initServer(
      call: (peer, type) {
        _peer = peer;
        add(ServerEventCall(peer: peer, type: type));
      },
      onDone: () => add(ServerEventCallEnd()),
      connected: () => add(ServerEventCallConnected()),
    );
    yield ServerStateInitial();
  }

  Stream<ServerState> _mapCallToState(ServerEventCall event) async* {
    /// If busy :
    if (_callUIBloc.state is CallUIStateConnecting ||
        _callUIBloc.state is CallUIStateConnected) {
      _repository.serverBusy();
      print(TAG + 'Server Busy!');

      ///No change in STATE
      yield ServerStateInitial();
    } else {
      print(TAG + 'Incoming call sent to user.');
      _type = event.type;
      _repository.startRingtone();
      yield ServerStateIncomingCall(
        peer: event.peer,
      );
    }
  }

  Stream<ServerState> _mapAcceptToState(ServerEventCallAccept event) async* {
    print(TAG + 'Incoming call accepted by user.');
    _repository.accept(_type);

    _callUIBloc.add(CallUIEventInit(
        peer: User(name: _peer.name, ip: _peer.ip),
        type: _type ?? CallType.audio));
    _callUIBloc.add(CallUIEventConnect());

    /// Return to initial state after the user accepts.
    yield ServerStateInitial();
  }

  Stream<ServerState> _mapConnectedToState(
      ServerEventCallConnected event) async* {
    /// This will complete the conection and the Local And Remote renderes
    /// Are called and updated by the RTC Framework
    ///
    /// This is a background change so no change in UI, hence no change in state
    _callUIBloc.add(CallUIEventConnected());
    yield state;
  }

  Stream<ServerState> _mapEndToState(ServerEvent event) async* {
    ///Send RTC end call signal and close the connection
    _repository.stopRingtone();

    if (event is ServerEventCallReject) {
      print(TAG + 'Incoming call rejected by user.');
      _repository.hostReject();
      _callUIBloc.add(CallUIEventReject());
    } else {
      _repository.sDisconnect();
      _callUIBloc.add(CallUIEventEnd());
    }
    yield ServerStateInitial();
  }

  Stream<ServerState> _mapUpdateHost(ServerEventUpdateHost event) async* {
    _repository.updateHost(event.host);
    yield state;
  }
}
