import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_call/bloc/bloc.dart';
import 'package:video_call/model/user.dart';
import 'package:video_call/screens/call/call_audio.dart';
import 'package:flutter_webrtc/webrtc.dart';

class ScreenCallVideo extends StatefulWidget {
  final User user;
  const ScreenCallVideo({@required this.user});
  @override
  _ScreenCallVideoState createState() => _ScreenCallVideoState();
}

class _ScreenCallVideoState extends State<ScreenCallVideo> {
  final RTCVideoRenderer _localView = RTCVideoRenderer();
  final RTCVideoRenderer _remoteView = RTCVideoRenderer();
  var _status = 'Initialising...';

  @override
  void initState() {
    super.initState();
    initRenderers();
  }

  @override
  void dispose() {
    _localView.dispose();
    _remoteView.dispose();
    super.dispose();
  }

  initRenderers() async {
    await _localView.initialize();
    await _remoteView.initialize();
  }

  initCallBacks(BuildContext context) {
    /// Add an Event to CallUIState to update the Callbacks for renderers
    print('Video Call Screen: Added callbacks');
    BlocProvider.of<CallUIBloc>(context).add(
      CallUIEventInitCallBacks(onLocalStream: (stream) {
        _localView.srcObject = stream;
      }, onAddRemoteStream: (stream) {
        print('Video Call Screen: Added remote stream!');
        _remoteView.srcObject = stream;
      }, onRemoveRemoteStream: (stream) {
        _remoteView.srcObject = null;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    initCallBacks(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              BlocProvider.of<CallUIBloc>(context).add(CallUIEventEnd());
              Navigator.of(context).maybePop();
            }),
        centerTitle: true,
        title: Text('Socket Video Call'),
      ),
      body: BlocConsumer(
        cubit: BlocProvider.of<CallUIBloc>(context),
        buildWhen: (previous, current) => (current is CallUIStateConnecting ||
            current is CallUIStateConnected),
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () => BlocProvider.of<CallUIBloc>(context)
                      .add(CallUIEventToggleOverlay()),
                  child: RemoteVideo(
                    renderer: _remoteView,
                  ),
                ),
                Positioned(
                  bottom: (state is CallUIStateConnected)
                      ? (state.overlayHidden)
                          ? 30.0
                          : MediaQuery.of(context).size.height * 0.22
                      : MediaQuery.of(context).size.height * 0.22,
                  right: 15.0,
                  child: Draggable(
                    child: LocalVideo(
                      renderer: _localView,
                    ),
                    childWhenDragging: Container(),
                    feedback: LocalVideo(
                      renderer: _localView,
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  crossFadeState: (state is CallUIStateConnected)
                      ? (state.overlayHidden)
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 300),
                  firstChild: ScreenCallOverlay(
                    status: _status,
                    name: widget.user.name,
                    ip: widget.user.ip,
                    leftButton: (state is CallUIStateConnected)
                        ? FloatingActionButton(
                            heroTag: null,
                            backgroundColor: (state.micMuted)
                                ? Colors.white
                                : Colors.transparent,
                            elevation: 0.0,
                            child: Icon(
                              Icons.mic_off,
                              color: (state.micMuted)
                                  ? Colors.black
                                  : Colors.white,
                            ),
                            onPressed: () {
                              BlocProvider.of<CallUIBloc>(context)
                                  .add(CallUIEventMuteMic());
                            },
                          )
                        : SizedBox(
                            height: 0.0,
                            width: 0.0,
                          ),
                    rightButton: (state is CallUIStateConnected)
                        ? FloatingActionButton(
                            heroTag: null,
                            backgroundColor: Colors.transparent,
                            elevation: 0.0,
                            child: Icon(
                              (state.camRear)
                                  ? Icons.camera_front
                                  : Icons.camera_rear,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              BlocProvider.of<CallUIBloc>(context)
                                  .add(CallUIEventSwitchCamera());
                            },
                          )
                        : SizedBox(
                            height: 0.0,
                            width: 0.0,
                          ),
                  ),
                  secondChild: Container(),
                ),
              ],
            ),
          );
        },
        listener: (BuildContext context, state) {
          _changeStatus(state);
          if (state is CallUIStateDeclined) {
            Future.delayed(Duration(seconds: 2)).then((value) {
              if (mounted) {
                print('Executed Maybe Pop!');
                BlocProvider.of<HomeBloc>(context).add(HomeEventInitialise());
                Navigator.of(context).maybePop();
              }
            });
          }
        },
      ),
    );
  }

  void _changeStatus(CallUIState state) {
    if (state is CallUIStateInitialise)
      _status = 'Initialising...';
    else if (state is CallUIStateConnecting ||
        state is CallUIStateInitRenderers)
      _status = 'Calling...';
    else if (state is CallUIStateConnected)
      _status = 'Connected';
    else if (state is CallUIStateDeclined) {
      var status = state.status;
      print('Call Video: ' + '${status.toString()} ${status.index} ');
      switch (status) {
        case Status.BUSY:
          _status = 'BUSY';
          break;
        case Status.REJECT:
          _status = 'Call Rejected';
          break;
        case Status.END:
          _status = 'Call Ended';
          break;
        default:
          _status = 'ERROR';
          break;
      }
    }
  }
}

class LocalVideo extends StatelessWidget {
  LocalVideo({
    Key key,
    @required this.renderer,
  }) : super(key: key);

  final RTCVideoRenderer renderer;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      decoration: BoxDecoration(color: Colors.black54),
      child: AspectRatio(
        aspectRatio: 9.0 / 16.0,
        //width: MediaQuery.of(context).size.width * 0.4,
        child: (renderer != null) ? RTCVideoView(renderer) : Container(),
        //decoration: BoxDecoration(color: Colors.black54),
      ),
    );
  }
}

class RemoteVideo extends StatelessWidget {
  RemoteVideo({
    Key key,
    @required this.renderer,
  }) : super(key: key);

  final RTCVideoRenderer renderer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: new EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: (renderer != null) ? RTCVideoView(renderer) : Container(),
      decoration: BoxDecoration(color: Colors.black54),
    );
  }
}
