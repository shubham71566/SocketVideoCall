part of 'call_bloc.dart';

enum Status { BUSY, REJECT, ERROR, END }

abstract class CallBlocState extends Equatable {
  const CallBlocState();

  @override
  List<Object> get props => [];
}

class CallStateIdle extends CallBlocState {
  const CallStateIdle();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'CallStateIdle: Not calling';
}

class CallStateInitialise extends CallBlocState {
  const CallStateInitialise();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'State initialising renderers';
}

class CallStateConnecting extends CallBlocState {
  final Status status;

  const CallStateConnecting({this.status});

  @override
  List<Object> get props => [status];

  @override
  String toString() => 'State in call with status: ' + status.toString();
}

class CallStateConnected extends CallBlocState {
  const CallStateConnected();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'State in call Connected: ';
}

class CallStateDeclined extends CallBlocState {
  final Status status;

  const CallStateDeclined({this.status});

  @override
  List<Object> get props => [status];

  @override
  String toString() => 'State declined with reason: ' + status.toString();
}
