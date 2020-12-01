import 'dart:async';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/socket/repository.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallBlocEvent, CallBlocState> {
  final TAG = 'Call BLoC: ';
  final CallUIBloc _callUIBloc;
  final Repository _repository;
  CallType type;

  CallBloc(this._callUIBloc, this._repository) : super(CallStateIdle()) {
    bool _micMuted = false;
    bool _camRear = false;
    _callUIBloc.listen((state) {
      if (state is CallUIStateInitRenderers) {
        _repository.initClientRTC(
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
        add(CallEventEnd());
    });
  }

  @override
  Stream<CallBlocState> mapEventToState(CallBlocEvent event) async* {
    if (event is CallEventInit)
      yield* _mapStartToState(event);
    else if (event is CallEventConnect)
      yield* _mapConnectToState(event);
    else if (event is CallEventConnected)
      yield* _mapConnectedToState(event);
    else if (event is CallEventBusy ||
        event is CallEventReject ||
        event is CallEventEnd)
      yield* _mapEndToState(event);
    else
      throw Exception("EventNotFound");
  }

  Stream<CallBlocState> _mapStartToState(CallEventInit event) async* {
    print(TAG + "Call State Initial");
    yield CallStateIdle();
  }

  Stream<CallBlocState> _mapConnectToState(CallEventConnect event) async* {
    print(TAG + "Call Connect Executed");
    type = event.type;
    _repository.connect(
      type: event.type,
      peer: event.peer,
      connected: () => add(CallEventConnected()),
      decline: (event) => add(event),
      end: () {
        if (!(state is CallStateDeclined)) add(CallEventEnd());
      },
    );

    _callUIBloc.add(CallUIEventConnect());
    yield CallStateInitialise();
  }

  Stream<CallBlocState> _mapConnectedToState(CallEventConnected event) async* {
    _callUIBloc.add(CallUIEventConnected());
    yield CallStateConnected();
  }

  Stream<CallBlocState> _mapEndToState(CallBlocEvent event) async* {
    if (!(event is CallEventEnd)) {
      if (event is CallEventBusy) {
        print(TAG + 'Call Busy');
        _callUIBloc.add(CallUIEventBusy());
        yield CallStateDeclined(status: Status.BUSY);
      } else {
        print(TAG + 'Call Rejected');
        _callUIBloc.add(CallUIEventReject());
        yield CallStateDeclined(status: Status.REJECT);
      }
    } else {
      _repository.cDisconnect();
      _callUIBloc.add(CallUIEventEnd());
      yield CallStateIdle();
    }
  }
}
