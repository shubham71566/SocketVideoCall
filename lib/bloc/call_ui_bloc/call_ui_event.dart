part of 'call_ui_bloc.dart';

abstract class CallUIEvent extends Equatable {
  const CallUIEvent();
}

class CallUIEventInit extends CallUIEvent {
  final User peer;
  final CallType type;
  const CallUIEventInit({this.peer, this.type});

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Call Event Initial';
}

class CallUIEventInitCallBacks extends CallUIEvent {
  final Function onLocalStream;
  final Function onAddRemoteStream;
  final Function onRemoveRemoteStream;
  const CallUIEventInitCallBacks(
      {this.onLocalStream, this.onAddRemoteStream, this.onRemoveRemoteStream});

  @override
  List<Object> get props =>
      [onLocalStream, onAddRemoteStream, onAddRemoteStream];

  @override
  String toString() => 'Call Event Initial';
}

class CallUIEventConnect extends CallUIEvent {
  const CallUIEventConnect();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Connect to peer';
}

class CallUIEventToggleOverlay extends CallUIEvent {
  const CallUIEventToggleOverlay({this.forcedValue});

  final bool forcedValue;
  @override
  List<Object> get props => [this.forcedValue];

  @override
  String toString() => 'Event Toggle Screen Overlay';
}

/// The events like Mute Mic, Turn on loud speaker, etc
class CallUIEventMuteMic extends CallUIEvent {
  final bool mute;
  const CallUIEventMuteMic({this.mute});

  @override
  List<Object> get props => [mute];

  @override
  String toString() => 'Event Mute mic in call';
}

class CallUIEventSwitchCamera extends CallUIEvent {
  final bool speaker;
  const CallUIEventSwitchCamera({this.speaker});

  @override
  List<Object> get props => [speaker];

  @override
  String toString() => 'Event Speaker On in call';
}

/// The Events originated by Client()
class CallUIEventBusy extends CallUIEvent {
  const CallUIEventBusy();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Busy end the call';
}

class CallUIEventReject extends CallUIEvent {
  const CallUIEventReject();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Reject end the call';
}

class CallUIEventConnected extends CallUIEvent {
  const CallUIEventConnected();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Accept';
}

class CallUIEventEnd extends CallUIEvent {
  const CallUIEventEnd();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event end the call';
}
