import 'dart:async';

import 'package:video_call/bloc/bloc.dart';
part 'call_ui_event.dart';
part 'call_ui_state.dart';

class CallUIBloc extends Bloc<CallUIEvent, CallUIState> {
  CallUIBloc() : super(CallUIIdle());
  bool _micMuted = false;
  bool _camRear = false;
  bool _overlayHidden = false;

  @override
  Stream<CallUIState> mapEventToState(
    CallUIEvent event,
  ) async* {
    if (event is CallUIEventInit)
      yield CallUIStateInitialise(user: event.peer, type: event.type);
    else if (event is CallUIEventInitCallBacks) {
      print('IMPORTANT! : CALLUIBLOC pasted the stream callbacks!');
      yield CallUIStateInitRenderers(
        onLocalStream: event.onLocalStream,
        onAddRemoteStream: event.onAddRemoteStream,
        onRemoveRemoteStream: event.onRemoveRemoteStream,
      );
    } else if (event is CallUIEventConnect)
      yield CallUIStateConnecting();
    else if (event is CallUIEventBusy)
      yield CallUIStateDeclined(status: Status.BUSY);
    else if (event is CallUIEventReject)
      yield CallUIStateDeclined(status: Status.REJECT);
    else if (event is CallUIEventConnected)
      yield CallUIStateConnected();
    else if (event is CallUIEventToggleOverlay) {
      if (event.forcedValue != null)
        _overlayHidden = event.forcedValue;
      else
        _overlayHidden = !_overlayHidden;
      yield CallUIStateConnected(
          overlayHidden: _overlayHidden,
          camRear: _camRear,
          micMuted: _micMuted);
    } else if (event is CallUIEventMuteMic) {
      _micMuted = !_micMuted;
      yield CallUIStateConnected(
          overlayHidden: _overlayHidden,
          camRear: _camRear,
          micMuted: _micMuted);
    } else if (event is CallUIEventSwitchCamera) {
      _camRear = !_camRear;
      yield CallUIStateConnected(
          overlayHidden: _overlayHidden,
          camRear: _camRear,
          micMuted: _micMuted);
    } else if (event is CallUIEventConnected) {
      Future.delayed(Duration(seconds: 2))
          .then((_) => add(CallUIEventToggleOverlay(forcedValue: true)));
      yield CallUIStateConnected();
    } else if (event is CallUIEventEnd)
      yield CallUIStateDeclined(status: Status.END);
    else
      throw Exception("EventNotFound");
  }
}
