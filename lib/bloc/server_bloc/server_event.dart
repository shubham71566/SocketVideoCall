part of 'server_bloc.dart';

abstract class ServerEvent extends Equatable {
  const ServerEvent();
}

class ServerEventInit extends ServerEvent {
  const ServerEventInit();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Home Page';
}

class ServerEventCall extends ServerEvent {
  final User peer;
  final CallType type;
  const ServerEventCall({this.peer, this.type});

  @override
  List<Object> get props => [peer, type];

  @override
  String toString() => 'Server Event New Client Connected';
}

class ServerEventCallBusy extends ServerEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Host BUSY';
}

class ServerEventCallReject extends ServerEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Host REJECT';
}

class ServerEventCallAccept extends ServerEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Host ACCEPT';
}

class ServerEventCallConnected extends ServerEvent {
  const ServerEventCallConnected();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Call ended';
}

class ServerEventCallEnd extends ServerEvent {
  const ServerEventCallEnd();

  @override
  List<Object> get props => [];

  @override
  String toString() => 'Server Event Call ended';
}

class ServerEventUpdateHost extends ServerEvent {
  final User host;
  const ServerEventUpdateHost({this.host});

  @override
  List<Object> get props => [host];

  @override
  String toString() => 'Server Event Update host';
}
