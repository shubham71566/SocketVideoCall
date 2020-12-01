part of 'call_ui_bloc.dart';

abstract class CallUIState extends Equatable {
  const CallUIState();
}

class CallUIIdle extends CallUIState {
  @override
  List<Object> get props => [];
}

class CallUIStateInitialise extends CallUIState {
  final User user;
  final CallType type;
  const CallUIStateInitialise({this.user, this.type});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'CallUIStateIdle: User: ${user.name} Type: $type';
}

class CallUIStateInitRenderers extends CallUIState {
  final Function onLocalStream;
  final Function onAddRemoteStream;
  final Function onRemoveRemoteStream;

  const CallUIStateInitRenderers(
      {this.onLocalStream, this.onAddRemoteStream, this.onRemoveRemoteStream});

  @override
  List<Object> get props =>
      [onLocalStream, onAddRemoteStream, onRemoveRemoteStream];

  @override
  String toString() => 'CallUIStateInitialise the render callbacks';
}

class CallUIStateConnecting extends CallUIState {
  const CallUIStateConnecting();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'State initialising renderers';
}

class CallUIStateConnected extends CallUIState {
  final bool overlayHidden;
  final bool camRear;
  final bool micMuted;
  const CallUIStateConnected(
      {this.overlayHidden = false,
      this.micMuted = false,
      this.camRear = false});

  @override
  List<Object> get props => [overlayHidden, micMuted, camRear];

  @override
  String toString() => 'State in call Connected: ';
}

class CallUIStateDeclined extends CallUIState {
  final Status status;

  const CallUIStateDeclined({this.status});

  @override
  List<Object> get props => [status];

  @override
  String toString() => 'State declined with reason: ' + status.toString();
}
