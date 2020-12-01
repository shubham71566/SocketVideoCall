part of 'call_bloc.dart';

abstract class CallBlocEvent extends Equatable {
  const CallBlocEvent();

  @override
  List<Object> get props => [];
}

class CallEventInit extends CallBlocEvent {
  const CallEventInit();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'call Event Initial';
}

class CallEventConnect extends CallBlocEvent {
  final User peer;
  final CallType type;
  const CallEventConnect({this.peer, this.type});

  @override
  List<Object> get props => [peer, type];

  @override
  String toString() => 'Event Connect to peer';
}

/// The events like Mute Mic, Turn on loud speaker, etc
class CallEventMuteMic extends CallBlocEvent {
  final bool mute;
  const CallEventMuteMic({this.mute});

  @override
  List<Object> get props => [mute];

  @override
  String toString() => 'Event Mute mic in call';
}

class CallEventSpeakerOn extends CallBlocEvent {
  final bool speaker;
  const CallEventSpeakerOn({this.speaker});

  @override
  List<Object> get props => [speaker];

  @override
  String toString() => 'Event Speaker On in call';
}

/// The Events originated by Client()
class CallEventBusy extends CallBlocEvent {
  const CallEventBusy();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Busy end the call';
}

class CallEventReject extends CallBlocEvent {
  const CallEventReject();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event Reject end the call';
}

class CallEventConnected extends CallBlocEvent {
  const CallEventConnected();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event call connected';
}

class CallEventEnd extends CallBlocEvent {
  const CallEventEnd();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Event end the call';
}
