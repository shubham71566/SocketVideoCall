part of 'server_bloc.dart';

abstract class ServerState extends Equatable {
  const ServerState();
}

class ServerStateInitial extends ServerState {
  @override
  List<Object> get props => [];
}

class ServerStateIncomingCall extends ServerState {
  final User peer;
  const ServerStateIncomingCall({this.peer});

  @override
  List<Object> get props => [peer];
}

class ServerStateBusy extends ServerState {
  @override
  List<Object> get props => [];
}

// class ServerStateReject extends ServerState {
//   @override
//   List<Object> get props => [];
// }

// class ServerStateAccept extends ServerState {
//   @override
//   List<Object> get props => [];
// }

class ServerStateSDP extends ServerState {
  @override
  List<Object> get props => [];
}
